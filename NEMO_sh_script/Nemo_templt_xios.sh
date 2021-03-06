#!//bin/bash -l 

#SBATCH -t 02:00:00
#SBATCH -J RUN_NAME_XIOS_PROCES.sh  ## remember to name the job as the name of this script
#SBATCH -p small
#SBATCH -o output_%j.txt
#SBATCH -e errors_%j.txt
#SBATCH -N 6

sleep 5s

## the last line is to 

set -ue

# librunscript defines some helper functions
source ./librunscript.sh

# =============================================================================
# *** BEGIN User configuration
# =============================================================================

# -----------------------------------------------------------------------------
# *** Preload modules in sisu 
# -----------------------------------------------------------------------------

pre_load_modules_cmd="module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.0.990"
${pre_load_modules_cmd}


# -----------------------------------------------------------------------------
# *** General configuration
# -----------------------------------------------------------------------------

# Component configuration
# (for syntax of the $config variable, see librunscript.sh)
config="nemo lim3 xios:detached"

# Experiment name (exactly 4 letters!)
exp_name=RUN_NAMEXIOS_PROCES

# Simulation start and end date. Use any (reasonable) syntax you want.
run_start_date="1990-01-01"
run_end_date="${run_start_date} + 12 months" # 

# Set $force_run_from_scratch to 'true' if you want to force this run to start
# from scratch, possibly ignoring any restart files present in the run
# directory. Leave set to 'false' otherwise.
# NOTE: If set to 'true' the run directory $run_dir is cleaned!
force_run_from_scratch=false #true

# Resolution
nem_grid=ORCA1L75

# Restart frequency. Use any (reasonable) number and time unit you want.
# For runs without restart, leave this variable empty
# Normally you need it if you want to resubmit jobs through the function Finalize
rst_freq="1 month"

# Number of restart legs to be run in one job
run_num_legs=2

# Directories

# Tells where to find the restart files if the first round of simulation is restarted from some other files.
# And also tells config file to find the run script to resubmit the job etc
start_dir=${PWD}

# Tells where to find namelist and xml etc. files
ctrl_file_dir=${USERAPPL}/NEMO/NEMO_local/ORCA1_cfg

# Tells where to find nemo executable
nem_src_dir=${WRKDIR}/DONOTREMOVE/NEMOEXP

# Architecture
#build_arch=my_ecconf   #?? it has been used anywhere ??

# This file is in the run dir and used to store information about restarts 
# If the first run leg is not restarting from anything it will be created in the run dir
nem_info_file="nem.info"   #?? should we change the name of the variable to avoid confusion ??

# -----------------------------------------------------------------------------
# *** Read platform dependent configuration
# -----------------------------------------------------------------------------
source ./nemconf.cfg  # read function configure from ecconf.cfg ?? probably need another name to avoid confusio??

configure

# -----------------------------------------------------------------------------
# *** Time step settings
# -----------------------------------------------------------------------------
case "${nem_grid}" in

    ORCA1L*)   nem_time_step_sec=2700; lim_time_step_sec=2700 ;;
    ORCA025L*) nem_time_step_sec=900 ; lim_time_step_sec=900  ;;

    *)  error "Can't set time steps for unknown horizontal grid: ${nem_grid}"
        ;;
esac

# -----------------------------------------------------------------------------
# *** NEMO/LIM configuration
# -----------------------------------------------------------------------------

# This is only needed if the experiment is started from an existing set of NEMO
# restart files
nem_restart_file_path=${start_dir}/nemo-rst

nem_restart_offset=0

nem_res_hor=$(echo ${nem_grid} | sed 's:ORCA\([0-9]\+\)L[0-9]\+:\1:')

# Pick correct NEMO configuration, which is one of:
#   NEMO standalone, NEMO+PISCES-standaone, PISCES-offline
                             nem_config_name=${nem_grid}_LIM3_standalone
has_config pisces         && nem_config_name=${nem_grid}_LIM3_PISCES_standalone
has_config pisces:offline && nem_config_name=${nem_grid}_OFF_PISCES

nem_exe_file=${nem_src_dir}/${nem_config_name}/BLD/bin/nemo.exe 
nem_numproc=72

# -----------------------------------------------------------------------------
# *** XIOS configuration
# -----------------------------------------------------------------------------

# Now we preload xios
xio_exe_file=$(which xios_server.exe)

xio_numproc=XIOS_PROCES #0  #??? don't really know, should change 0 to some integer if xios is not detached ??? 

# -----------------------------------------------------------------------------
# *** atmospheric model configuration
# -----------------------------------------------------------------------------

#ifs_exe_file=amt_test.exe
#ifs_numproc=3
#ifs_key="-v ecmwf -e"

# =============================================================================
# *** END of User configuration
# =============================================================================

# =============================================================================
# *** This is where the code begins ...
# =============================================================================

# -----------------------------------------------------------------------------
# *** Create the run dir if necessary and go there
#     Everything is done from here.
# -----------------------------------------------------------------------------
if [ ! -d ${run_dir} ]
then
    mkdir -p ${run_dir}
fi
cd ${run_dir}

# -----------------------------------------------------------------------------
# *** Determine the time span of this run and whether it's a restart leg
# -----------------------------------------------------------------------------

# Regularise the format of the start and end date of the simulation
run_start_date=$(absolute_date_noleap "${run_start_date}")
run_end_date=$(absolute_date_noleap "${run_end_date}")

# Loop over the number of legs
for (( ; run_num_legs>0 ; run_num_legs-- ))
do

    # Check for restart information file and set the current leg start date
    #   Ignore restart information file if force_run_from_scratch is true
    if ${force_run_from_scratch} || ! [ -r ${nem_info_file} ]
    then
        leg_is_restart=false
        leg_start_date=${run_start_date}
        leg_number=1
    else
        leg_is_restart=true
        . ./${nem_info_file}
        leg_start_date=${leg_end_date}
        leg_number=$((leg_number+1))
    fi

    # Compute the end date of the current leg
    if [ -n "${rst_freq}" ]
    then
        leg_end_date=$(absolute_date_noleap "${leg_start_date} + ${rst_freq}")
    else
        leg_end_date=${run_end_date}
    fi

    if [ $(date -d "${leg_end_date}" +%s) -gt $(date -d "${run_end_date}" +%s) ]
    then
        leg_end_date=${run_end_date}
    fi

    # Some time variables needed later
    leg_length_sec=$(( $(date -d "${leg_end_date}" +%s) - $(date -d "${leg_start_date}" +%s) ))
    leg_start_sec=$(( $(date -d "${leg_start_date}" +%s) - $(date -d "${run_start_date}" +%s) ))
    leg_end_sec=$(( $(date -d "${leg_end_date}" +%s) - $(date -d "${run_start_date}" +%s) ))
    leg_start_date_yyyymmdd=$(date -u -d "${leg_start_date}" +%Y%m%d)
    leg_start_date_yyyy=$(date -u -d "${leg_start_date}" +%Y)
    leg_end_date_yyyy=$(date -u -d "${leg_end_date}" +%Y)

    # Correct for leap days because NEMO standalone uses no-leap calendar
    leg_length_sec=$(( leg_length_sec - $(leap_days "${leg_start_date}" "${leg_end_date}")*24*3600 ))
    leg_start_sec=$(( leg_start_sec - $(leap_days "${run_start_date}" "${leg_start_date}")*24*3600 ))
    leg_end_sec=$(( leg_end_sec - $(leap_days "${run_start_date}" "${leg_end_date}")*24*3600 ))

    # Check whether there's actually time left to simulate - exit otherwise
    if [ ${leg_length_sec} -le 0 ]
    then
        info "Leg start date equal to or after end of simulation."
        info "Nothing left to do. Exiting."
        exit 0
    fi

    # -------------------------------------------------------------------------
    # *** Prepare the run directory for a run from scratch
    # -------------------------------------------------------------------------
    if ! $leg_is_restart
    then
        # ---------------------------------------------------------------------
        # *** Check if run dir is empty. If not, and if we are allowed to do so
        #     by ${force_run_from_scratch}, remove everything
        # ---------------------------------------------------------------------
        if $(ls * >& /dev/null)
        then
            if ${force_run_from_scratch}
            then
                rm -fr ${run_dir}/*
            else
                error "Run directory not empty and \$force_run_from_scratch not set."
            fi
        fi

        # ---------------------------------------------------------------------
        # *** Copy executables of model components
        # *** Additionally, create symlinks to the original place for reference
        # ---------------------------------------------------------------------
        cp    ${nem_exe_file} .
        ln -s ${nem_exe_file} $(basename ${nem_exe_file}).lnk

        cp    ${xio_exe_file} .
        ln -s ${xio_exe_file} $(basename ${xio_exe_file}).lnk

        # ---------------------------------------------------------------------
        # *** Files needed for NEMO (linked)
        # ---------------------------------------------------------------------

        # Link initialisation files for matching ORCA grid ?? put these files somewhere? rundir? 
        for f in \
            bathy_meter.nc coordinates.nc \
            ahmcoef.nc \
            K1rowdrg.nc M2rowdrg.nc mask_itf.nc \
            decay_scale_bot.nc decay_scale_cri.nc \
            mixing_power_bot.nc mixing_power_cri.nc mixing_power_pyc.nc \
            runoff_depth.nc
        do
            [ -f ${ini_data_dir}/nemo/initial/${nem_grid}/$f ] && ln -s ${ini_data_dir}/nemo/initial/${nem_grid}/$f
        done

        # Link geothermal heating file (independent of grid) and matching weight file
        ln -s ${ini_data_dir}/nemo/initial/Goutorbe_ghflux.nc
        ln -s ${ini_data_dir}/nemo/initial/weights_Goutorbe1_2_orca${nem_res_hor}_bilinear.nc

        # Link either restart files or climatology files for the initial state
        if $(has_config nemo:start_from_restart)
        then
            # When linking restart files, we accept three options:
            # (1) Merged files for ocean and ice, i.e.
            #     restart_oce.nc and restart_ice.nc
            # (2) One-file-per-MPI-rank, i.e.
            #     restart_oce_????.nc and restart_ice_????.nc
            #     No check is done whether the number of restart files agrees
            #     with the number of MPI ranks for NEMO!
            # (3) One-file-per-MPI-rank with a prefix, i.e.
            #     <exp_name>_<time_step>_restart_oce_????.nc (similar for the ice)
            #     The prefix is ignored.
            # The code assumes that one of the options can be applied! If more
            # options are applicable, the first is chosen. If none of the
            # options apply, NEMO will crash with missing restart file.
            if   ls -U ${nem_restart_file_path}/restart_[oi]ce.nc > /dev/null 2>&1
            then
                 ln -s ${nem_restart_file_path}/restart_[oi]ce.nc ./

            elif ls -U ${nem_restart_file_path}/restart_[oi]ce_????.nc > /dev/null 2>&1
            then
                 ln -s ${nem_restart_file_path}/restart_[oi]ce_????.nc ./

            else
                for f in ${nem_restart_file_path}/????_????????_restart_[oi]ce_????.nc
                do
                    ln -s $f $(echo $f | sed 's/.*_\(restart_[oi]ce_....\.nc\)/\1/')
                done
            fi
        else

            # Temperature and salinity files for initialisation
            ln -s ${ini_data_dir}/nemo/climatology/absolute_salinity_WOA13_decav_Reg1L75_clim.nc
            ln -s ${ini_data_dir}/nemo/climatology/conservative_temperature_WOA13_decav_Reg1L75_clim.nc
            ln -s ${ini_data_dir}/nemo/climatology/weights_WOA13d1_2_orca${nem_res_hor}_bilinear.nc

            # Grid dependent runoff files
            case ${nem_grid} in
            ORCA1*)   ln -s ${ini_data_dir}/nemo/climatology/runoff-icb_DaiTrenberth_Depoorter_ORCA1_JD.nc ;;
            ORCA025*) ln -s ${ini_data_dir}/nemo/climatology/ORCA_R025_runoff_v1.1.nc ;;
            esac
        fi

        # Write fake file for previous fresh water budget adjustment (nn_fwb==2 in namelist)
        echo "                               0  0.0000000000000000E+00  0.0000000000000000E+00" > EMPave_old.dat

        # Link NEMO CoreII forcing files (only set supported out-of-the-box)
        for v in u_10 v_10 t_10 q_10 ncar_precip ncar_rad
        do
            f="${ini_data_dir}/nemo/forcing/CoreII/${v}.15JUNE2009_fill.nc"
            [ -f "$f" ] && ln -s $f
        done

        # Link CoreII weight files for corresponding grid
        ln -s ${ini_data_dir}/nemo/forcing/CoreII/weights_coreII_2_orca${nem_res_hor}_bilinear.nc
        ln -s ${ini_data_dir}/nemo/forcing/CoreII/weights_coreII_2_orca${nem_res_hor}_bicubic.nc

        # XIOS files
        # ${ctrl_file_dir}/iodef.xml.sh > iodef.xml #changed 150318 by Ygong
	ln -s ${ctrl_file_dir}/iodef.xml
        ln -s ${ctrl_file_dir}/context_nemo.xml
        ln -s ${ctrl_file_dir}/domain_def_nemo.xml
        ln -s ${ctrl_file_dir}/field_def_nemo-lim.xml
        ln -s ${ctrl_file_dir}/field_def_nemo-opa.xml
        ln -s ${ctrl_file_dir}/field_def_nemo-pisces.xml
        #ln -s ${ctrl_file_dir}/file_def_nemo-lim3.xml file_def_nemo-lim.xml
	ln -s ${ctrl_file_dir}/file_def_nemo-lim.xml
        ln -s ${ctrl_file_dir}/file_def_nemo-opa.xml
        ln -s ${ctrl_file_dir}/file_def_nemo-pisces.xml

        # ---------------------------------------------------------------------
        # *** Files needed for TOP/PISCES (linked)
        # ---------------------------------------------------------------------
        if $(has_config pisces)
        then
            ln -fs ${ini_data_dir}/pisces/dust_INCA_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/ndeposition_Duce_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/pmarge_etopo_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/river_global_news_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/Solubility_T62_Mahowald_ORCA_R1.nc

            ln -fs ${ini_data_dir}/pisces/par_fraction_gewex_clim90s00s_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/DIC_GLODAP_annual_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/Alkalini_GLODAP_annual_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/O2_WOA2009_monthly_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/PO4_WOA2009_monthly_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/Si_WOA2009_monthly_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/DOC_PISCES_monthly_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/Fer_PISCES_monthly_ORCA_R1.nc
            ln -fs ${ini_data_dir}/pisces/NO3_WOA2009_monthly_ORCA_R1.nc
        fi

    else # i.e. $leg_is_restart == true

        # ---------------------------------------------------------------------
        # *** Remove all leftover output files from previous legs
        # ---------------------------------------------------------------------

        # NEMO output files
        rm -f ${exp_name}_??_????????_????????_{grid_U,grid_V,grid_W,grid_T,icemod,SBC,scalar,SBC_scalar,diad_T}.nc

    fi # ! $leg_is_restart

    # -------------------------------------------------------------------------
    # *** Create some control files
    # -------------------------------------------------------------------------

    # Remove land grid-points
    if $(has_config nemo:elpin)
    then
        jpns=($(${nemctrl_scr_dir}/util/ELPiN/ELPiNv2.cmd ${nem_numproc}))
        info "nemo domain decompostion from ELpIN: ${jpns[@]}"
        nem_numproc=${jpns[0]}
        nem_jpni=${jpns[1]}
        nem_jpnj=${jpns[2]}
    else
        info "nemo original domain decomposition (not using ELPiN)"
    fi

    # NEMO and LIM namelists 

   . ${ctrl_file_dir}/namelist.nemo.ref.sh                        > namelist_ref
   . ${ctrl_file_dir}/namelist.nemo-${nem_grid}-standalone.cfg.sh > namelist_cfg
   . ${ctrl_file_dir}/namelist.lim3.ref.sh                        > namelist_ice_ref
   . ${ctrl_file_dir}/namelist.lim3-${nem_grid}.cfg.sh            > namelist_ice_cfg

    # NEMO/TOP+PISCES namelists # !!! need to change this in the future
    has_config pisces && . ${ctrl_file_dir}/namelist.nemo.top.ref.sh    > namelist_top_ref
    has_config pisces && . ${ctrl_file_dir}/namelist.nemo.top.cfg.sh    > namelist_top_cfg
    has_config pisces && . ${ctrl_file_dir}/namelist.nemo.pisces.ref.sh > namelist_pisces_ref
    has_config pisces && . ${ctrl_file_dir}/namelist.nemo.pisces.cfg.sh > namelist_pisces_cfg

    # -------------------------------------------------------------------------
    # *** Link the appropriate NEMO restart files of the previous leg
    # -------------------------------------------------------------------------
    if $leg_is_restart
    then
        ns=$(printf %08d $(( leg_start_sec / nem_time_step_sec - nem_restart_offset )))
        for (( n=0 ; n<nem_numproc ; n++ ))
        do
            np=$(printf %04d ${n})
            ln -fs ${exp_name}_${ns}_restart_oce_${np}.nc restart_oce_${np}.nc
            ln -fs ${exp_name}_${ns}_restart_ice_${np}.nc restart_ice_${np}.nc
            has_config pisces && \
            ln -fs ${exp_name}_${ns}_restart_trc_${np}.nc restart_trc_${np}.nc
        done

        # Make sure there are no global restart files
        # If links are found, they will be removed. We are cautious and do
        # _not_ remove real files! However, if real global restart files are
        # present, NEMO/LIM will stop because time stamps will not match.
        [ -h restart_oce.nc ] && rm restart_oce.nc
        [ -h restart_ice.nc ] && rm restart_ice.nc
    fi

    ### !!!! okay this needs to be changed!!!!
    # -------------------------------------------------------------------------
    # *** Start the run
    # -------------------------------------------------------------------------

    # Use the launch function from the platform configuration file
    #??? maybe now use launch_oce???
    t1=$(date +%s)
    
    launch \
        ${xio_numproc} ${xio_exe_file} -- \
        ${nem_numproc} ${nem_exe_file} #-- \
	#${ifs_numproc} ${ifs_exe_file} ${ifs_key} $exp_name
    #aprun -n ${nem_numproc} ${nem_exe_file}: 
    t2=$(date +%s)

    tr=$(date -d "0 -$t1 sec + $t2 sec" +%T)

    # -------------------------------------------------------------------------
    # *** Check for signs of success
    #     Note the tests provide no guarantee that things went fine! They are
    #     just based on the IFS and NEMO log files. More tests (e.g. checking
    #     restart files) could be implemented.
    # -------------------------------------------------------------------------
    # Check for NEMO success
    if [ -f ocean.output ]
    then
        if [ "$(awk '/New day/{d=$10}END{print d}' ocean.output)" == "$(date -u -d "$(absolute_date_noleap "${leg_end_date} - 1 day")" +%Y/%m/%d)" ]
        then
            info "Leg successfully completed according to NEMO log file 'ocean.output'."
        else
            error "Leg not completed according to NEMO log file 'ocean.output'."
        fi

    else
        error "NEMO log file 'ocean.output' not found after run."
    fi

    # -------------------------------------------------------------------------
    # *** Move NEMO output files to archive directory
    # -------------------------------------------------------------------------
    outdir="output/nemo/$(printf %03d $((leg_number)))"
    mkdir -p ${outdir}

    for v in grid_U grid_V grid_W grid_T icemod SBC scalar SBC_scalar diad_T ptrc_T
    do
        for f in ${exp_name}_*_????????_????????_${v}.nc
        do
            test -f $f && mv $f $outdir/
        done
    done

    # -------------------------------------------------------------------------
    # *** Move NEMO restart files to archive directory
    # -------------------------------------------------------------------------
        
    outdir="restart/nemo/$(printf %03d $((leg_number)))"
    mkdir -p ${outdir}

    ns=$(printf %08d $(( leg_start_sec / nem_time_step_sec - nem_restart_offset )))

    for f in oce ice trc
    do
	for i in ${exp_name}_${ns}_restart_${f}_????.nc
	do
	    test -f $i && mv $i $outdir/
	done 
    done

  
    # -------------------------------------------------------------------------
    # *** Move log files to archive directory
    # -------------------------------------------------------------------------
    outdir="log/$(printf %03d $((leg_number)))"
    mkdir -p ${outdir}

    for f in \
        ocean.output time.step solver.stat
    do
        test -f ${f} && mv ${f} ${outdir}
    done

    # -------------------------------------------------------------------------
    # *** Write the restart control file
    # -------------------------------------------------------------------------

    # Now nem_info_file is created in the run dir
    # Compute CPMIP performance
    sypd="$(cpmip_sypd $leg_length_sec $(($t2 - $t1)))"
    chpsy="$(cpmip_chpsy  $leg_length_sec $(($t2 - $t1)) $(($nem_numproc + $xio_numproc)))"

    echo "#"                                             | tee -a ${nem_info_file}
    echo "# Finished leg at `date '+%F %T'` after ${tr} (hh:mm:ss)" \
                                                         | tee -a ${nem_info_file}
    echo "# CPMIP performance: $sypd SYPD   $chpsy CHPSY"| tee -a ${nem_info_file}
    echo "leg_number=${leg_number}"                      | tee -a ${nem_info_file}
    echo "leg_start_date=\"${leg_start_date}\""          | tee -a ${nem_info_file}
    echo "leg_end_date=\"${leg_end_date}\""              | tee -a ${nem_info_file}

    # Need to reset force_run_from_scratch in order to avoid destroying the next leg
    force_run_from_scratch=false

done # loop over legs

# -----------------------------------------------------------------------------
# *** Platform dependent finalising of the run
# -----------------------------------------------------------------------------
finalise \
   $SLURM_JOB_NAME #give the name of the job. remember to name the job as the name of this script

exit 0 
