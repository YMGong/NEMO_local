# namelist.nemo-ORCA1L46.cfg.sh writes the NEMO namelist for ORCA1L46 in
# coupled mode to standard output. This namelist will overwrite the reference
# namelist (namelist.nemo.ref.sh). Hence, only parameters specific to the
# ORCA1L46/coupled configuration should be specified here.

cat << EOF
!!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
!! NEMO/OPA  Configuration namelist : used to overwrite defaults values defined in SHARED/namelist_ref
!!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

!!======================================================================
!!                   ***  Run management namelists  ***
!!======================================================================
!!   namrun       parameters of the run
!!======================================================================
!
!-----------------------------------------------------------------------
&namrun        !   parameters of the run
!-----------------------------------------------------------------------
   nn_leapy      =  0             !  Leap year calendar (1) or not (0)
/
!
!!======================================================================
!!                      ***  Domain namelists  ***
!!======================================================================
!!   namcfg       parameters of the configuration
!!   namzgr       vertical coordinate
!!   namzgr_sco   s-coordinate or hybrid z-s-coordinate
!!   namdom       space and time domain (bathymetry, mesh, timestep)
!!   namtsd       data: temperature & salinity
!!======================================================================
!
!-----------------------------------------------------------------------
&namcfg        !   parameters of the configuration
!-----------------------------------------------------------------------
   cp_cfg      =   "orca"              !  name of the configuration
   jp_cfg      =       1               !  resolution of the configuration
   jpidta      =     362               !  1st lateral dimension ( >= jpi )
   jpjdta      =     292               !  2nd    "         "    ( >= jpj )
   jpkdta      =      75               !lolo  number of levels      ( >= jpk )
   jpiglo      =     362               !  1st dimension of global domain --> i =jpidta
   jpjglo      =     292               !  2nd    -                  -    --> j  =jpjdta
   jperio      =       6               !  lateral cond. type (between 0 and 6)
                                       !  = 0 closed                 ;   = 1 cyclic East-West
                                       !  = 2 equatorial symmetric   ;   = 3 North fold T-point pivot
                                       !  = 4 cyclic East-West AND North fold T-point pivot
                                       !  = 5 North fold F-point pivot
                                       !  = 6 cyclic East-West AND North fold F-point pivot
/
!-----------------------------------------------------------------------
&namzgr        !   vertical coordinate
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzgr_sco    !   s-coordinate or hybrid z-s-coordinate
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namdom        !   space and time domain (bathymetry, mesh, timestep)
!-----------------------------------------------------------------------
   rn_hmin     =    20.    !  min depth of the ocean (>0) or min number of ocean level (<0)
   rn_rdt      = ${nem_time_step_sec} !  time step for the dynamics (and tracer if nn_acc=0)
   ppglam0     =  999999.0             !  longitude of first raw and column T-point (jphgr_msh = 1)
   ppgphi0     =  999999.0             ! latitude  of first raw and column T-point (jphgr_msh = 1)
   ppe1_deg    =  999999.0             !  zonal      grid-spacing (degrees)
   ppe2_deg    =  999999.0             !  meridional grid-spacing (degrees)
   ppe1_m      =  999999.0             !  zonal      grid-spacing (degrees)
   ppe2_m      =  999999.0             !  meridional grid-spacing (degrees)
   ppsur       =   -3958.951371276829  !  ORCA r4, r2 and r05 coefficients
   ppa0        =     103.9530096000000 ! (default coefficients)
   ppa1        =       2.415951269000000   !
   ppkth       =      15.35101370000000    !
   ppacr       =       7.0             !
   ppdzmin     =  999999.0             !  Minimum vertical spacing
   pphmax      =  999999.0             !  Maximum depth
   ldbletanh   =   .TRUE.              !  Use/do not use double tanf function for vertical coordinates
   ppa2        =     100.7609285000000 !  Double tanh function parameters
   ppkth2      =      48.02989372000000    !
   ppacr2      =      13.00000000000   !
/
!-----------------------------------------------------------------------
&namsplit      !   time splitting parameters  ("key_dynspg_ts") !lolo compiled with!
!-----------------------------------------------------------------------
   ln_bt_fw      =    .TRUE.           !  Forward integration of barotropic equations
   ln_bt_av      =    .TRUE.           !  Time filtering of barotropic variables
   ln_bt_nn_auto =    .TRUE.           !  Set nn_baro automatically to be just below
                                       !  a user defined maximum courant number (rn_bt_cmax)
   nn_baro       =    30               !  Number of iterations of barotropic mode
                                       !  during rn_rdt seconds. Only used if ln_bt_nn_auto=F
   rn_bt_cmax    =    0.8              !  Maximum courant number allowed if ln_bt_nn_auto=T
   nn_bt_flt     =    1                !  Time filter choice
                                       !  = 0 None
                                       !  = 1 Boxcar over   nn_baro barotropic steps
                                       !  = 2 Boxcar over 2*nn_baro     "        "
/
!-----------------------------------------------------------------------
&namcrs        !   Grid coarsening for dynamics output and/or
               !   passive tracer coarsened online simulations
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namtsd    !   data : Temperature  & Salinity
!-----------------------------------------------------------------------
!          !  file name                          ! frequency (hours) ! variable  ! time interp. !  clim  ! 'yearly'/ ! weights     ! rotation ! land/sea mask !
!          !                                     ! (if <0  months)   !  name     ! (logical)    !  (T/F) ! 'monthly' ! filename    ! pairing  ! filename      !
   sn_tem  = 'conservative_temperature_WOA13_decav_Reg1L75_clim', -1 ,'votemper' , .true. , .true. , 'yearly' , 'weights_WOA13d1_2_orca1_bilinear.nc' , '' , ''
   sn_sal  = 'absolute_salinity_WOA13_decav_Reg1L75_clim'       , -1 ,'vosaline' , .true. , .true. , 'yearly' , 'weights_WOA13d1_2_orca1_bilinear.nc' , '' , ''
/
!-----------------------------------------------------------------------
&namsbc        !   Surface Boundary Condition (surface module)
!-----------------------------------------------------------------------
   nn_fsbc     = $(( lim_time_step_sec / nem_time_step_sec )) !  frequency of surface boundary condition computation
                           !     (also = the frequency of sea-ice model call)
   ln_ana      = .false.   !  analytical formulation                    (T => fill namsbc_ana )
   ln_flx      = .false.   !  flux formulation                          (T => fill namsbc_flx )
   ln_blk_clio = .false.   !  CLIO bulk formulation                     (T => fill namsbc_clio)
   ln_blk_core = .true.    !  CORE bulk formulation                     (T => fill namsbc_core)
   ln_blk_mfs  = .false.   !  MFS bulk formulation                      (T => fill namsbc_mfs )
   ln_apr_dyn  = .false.   !  Patm gradient added in ocean & ice Eqs.   (T => fill namsbc_apr )
   nn_ice      = 2         !  =0 no ice boundary condition   ,
                           !  =1 use observed ice-cover      ,
                           !  =2 ice-model used                         ("key_lim3" or "key_lim2")
   nn_ice_embd = 1         !  =0 levitating ice (no mass exchange, concentration/dilution effect)
                           !  =1 levitating ice with mass and salt exchange but no presure effect
                           !  =2 embedded sea-ice (full salt and mass exchanges and pressure)
   ln_dm2dc    = .true.    !lolo  daily mean to diurnal cycle on short wave
   ln_rnf      = .true.    !  runoffs                                   (T   => fill namsbc_rnf)
   nn_isf      = 0         !  ice shelf melting/freezing                (/=0 => fill namsbc_isf)
                           !  0 =no isf                  1 = presence of ISF
                           !  2 = bg03 parametrisation   3 = rnf file for isf
                           !  4 = ISF fwf specified
                           !  option 1 and 4 need ln_isfcav = .true. (domzgr)
   ln_ssr      = .false.   !  Sea Surface Restoring on T and/or S       (T => fill namsbc_ssr)
   nn_fwb      = 2         !  FreshWater Budget: =0 unchecked
                           !     =1 global mean of e-p-r set to zero at each time step
                           !     =2 annual global mean of e-p-r set to zero
   ln_wave = .false.       !  Activate coupling with wave (either Stokes Drift or Drag coefficient, or both)  (T => fill namsbc_wave)
   ln_cdgw = .false.       !  Neutral drag coefficient read from wave model (T => fill namsbc_wave)
   ln_sdw  = .false.       !  Computation of 3D stokes drift                (T => fill namsbc_wave)
   nn_lsm  = 0             !  =0 land/sea mask for input fields is not applied (keep empty land/sea mask filename field) ,
                           !  =1:n number of iterations of land/sea mask application for input fields (fill land/sea mask filename field)
   nn_limflx = -1          !  LIM3 Multi-category heat flux formulation (use -1 if LIM3 is not used)
                           !  =-1  Use per-category fluxes, bypass redistributor, forced mode only, not yet implemented coupled
                           !  = 0  Average per-category fluxes (forced and coupled mode)
                           !  = 1  Average and redistribute per-category fluxes, forced mode only, not yet implemented coupled
                           !  = 2  Redistribute a single flux over categories (coupled mode only)
/
!-----------------------------------------------------------------------
&namsbc_ana    !   analytical surface boundary condition
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsbc_flx    !   surface boundary condition : flux formulation
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsbc_clio   !   namsbc_clio  CLIO bulk formulae
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsbc_core   !   namsbc_core  CORE bulk formulae
!-----------------------------------------------------------------------
!              !  file name  ! frequency (hours) ! variable ! time interp. !  clim  ! 'yearly'/ ! weights  ! rotation !
!              !             !  (if <0  months)  !   name   !   (logical)  !  (T/F) ! 'monthly' ! filename ! pairing  !
   sn_wndi     = 'u_10.15JUNE2009_fill'       ,         6         , 'U_10_MOD',   .true.     ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bicubic.nc'  , 'U1'
   sn_wndj     = 'v_10.15JUNE2009_fill'       ,         6         , 'V_10_MOD',   .true.     ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bicubic.nc'  , 'V1'
   sn_qsr      = 'ncar_rad.15JUNE2009_fill'   ,        24         , 'SWDN_MOD',   .false.    ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
   sn_qlw      = 'ncar_rad.15JUNE2009_fill'   ,        24         , 'LWDN_MOD',   .true.     ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
   sn_tair     = 't_10.15JUNE2009_fill'       ,         6         , 'T_10_MOD',   .false.    ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
   sn_humi     = 'q_10.15JUNE2009_fill'       ,         6         , 'Q_10_MOD',   .false.    ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
   sn_prec     = 'ncar_precip.15JUNE2009_fill',        -1         , 'PRC_MOD1',   .true.     ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
   sn_snow     = 'ncar_precip.15JUNE2009_fill',        -1         , 'SNOW'    ,   .true.     ,  .true. , 'yearly'  , 'weights_coreII_2_orca1_bilinear.nc' , ''
               !
   cn_dir      = './'      !  root directory for the location of the bulk files
   ln_taudif   = .false.   !  HF tau contribution: use "mean of stress module - module of the mean stress" data
   rn_zqt      = 10.       !  Air temperature and humidity reference height (m) (ln_bulk2z)
   rn_zu       = 10.       !  Wind vector reference height (m)                  (ln_bulk2z)
   rn_pfac     = 1.        !  multiplicative factor for precipitation (total & snow)
   rn_efac     = 1.        !  multiplicative factor for evaporation (0. or 1.)
   rn_vfac     = 0.        !  multiplicative factor for ocean/ice velocity 
                           !  in the calculation of the wind stress (0.=absolute winds or 1.=relative winds)
/
!-----------------------------------------------------------------------
&namsbc_mfs   !   namsbc_mfs  MFS bulk formulae
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsbc_cpl    !   coupled ocean/atmosphere model                       ("key_coupled")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namtra_qsr    !   penetrative solar radiation
!-----------------------------------------------------------------------
   nn_chldta   =      0    !  RGB : Chl data (=1) or cst value (=0)
/
!-----------------------------------------------------------------------
&namsbc_rnf    !   runoffs namelist surface boundary condition
!-----------------------------------------------------------------------
!         !  file name         ! frequency (hours) ! variable   ! time interp. ! clim  ! 'yearly'/ ! weights  ! rotation !
!         !                    !  (if <0  months)  !   name     !   (logical)  ! (T/F) ! 'monthly' ! filename ! pairing  !
   sn_rnf = 'runoff-icb_DaiTrenberth_Depoorter_ORCA1_JD.nc', -1 , 'sorunoff', .true.  , .true. , 'yearly'  , '' , '' , ''
   sn_cnf = 'runoff-icb_DaiTrenberth_Depoorter_ORCA1_JD.nc',  0 , 'socoeff' , .false. , .true. , 'yearly'  , '' , '' , ''
   sn_dep_rnf = 'runoff_depth' ,                              0 , 'rodepth' , .false. , .true. , 'yearly'  , '' , '' , ''
          !
   cn_dir       = './'       !  root directory for the location of the runoff files
   ln_rnf_mouth = .false.    !  specific treatment at rivers mouths
   rn_hrnf      =  0.        !  depth over which enhanced vertical mixing is used
   rn_avt_rnf   =  0.        !  value of the additional vertical mixing coef. [m2/s]
   rn_rfact     =   1.e0     !  multiplicative factor for runoff
   ln_rnf_depth = .true.     !  read in depth information for runoff 
   ln_rnf_tem   = .false.    !  read in temperature information for runoff
   ln_rnf_sal   = .false.    !  read in salinity information for runoff
   ln_rnf_depth_ini = .false.!  compute depth at initialisation from runoff file
   rn_rnf_max   = 0.0065     !  max value of the runoff climatologie over global domain ( ln_rnf_depth_ini = .true )
   rn_dep_max   = 150.       !  depth over which runoffs is spread ( ln_rnf_depth_ini = .true )
   nn_rnf_depth_file = 0     !  create (=1) a runoff depth file or not (=0)
/
!-----------------------------------------------------------------------
&namsbc_ssr    !   surface boundary condition : sea surface restoring
!-----------------------------------------------------------------------
   !             !filename      !freq  !variable name           !time    ! clim    ! year or    ! weights filename                   !rot
   !             !              !      !                        !interp  !         ! monthly    !                                    !pair
   !----------------------------------------------------------------------------------------------------------------------------------------
   sn_sss      = 'sss_data' ,     -1.  ,   'sss'                , .true. , .true.  , 'yearly'  , ''      , ''      , ''
   sn_sst      = 'sst_DUMMY_1m' , -1.  ,  'temp'                , .true. , .true.  , 'yearly'  , ''      , ''      , ''
   !
   cn_dir      = './'      !  root directory for the location of the runoff files  
   nn_sstr     =     0     !  add a retroaction term in the surface heat       flux (=1) or not (=0)
   nn_sssr     =     2     !lolo only for ocean standalone!  add a damping     term in the surface freshwater flux (=2)
   !                       !  or to SSS only (=1) or no damping term (=0)
   rn_dqdt     =    0.     !  magnitude of the retroaction on temperature   [W/m2/K]
   rn_deds     =  -100.    !lolo  magnitude of the damping on salinity   [mm/day]
   ln_sssr_bnd =   .true.  !  flag to bound erp term (associated with nn_sssr=2)
   rn_sssr_bnd =   5.e0    !lolo  ABS(Max/Min) value of the damping erp term [mm/day]
/
!-----------------------------------------------------------------------
&namsbc_alb    !   albedo parameters
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namberg       !   iceberg parameters
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namlbc        !   lateral momentum boundary condition
!-----------------------------------------------------------------------
   rn_shlat    =    0.0    !  shlat = 0  !  0 < shlat < 2  !  shlat = 2  !  2 < shlat
                           !  free slip  !   partial slip  !   no slip   ! strong slip
   ln_vorlat   = .false.   !  consistency of vorticity boundary condition with analytical eqs.
/
!-----------------------------------------------------------------------
&namcla        !   cross land advection
!-----------------------------------------------------------------------
   nn_cla      =    0      !  advection between 2 ocean pts separates by land
/
!-----------------------------------------------------------------------
&namobc        !   open boundaries parameters                           ("key_obc")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namagrif      !  AGRIF zoom                                            ("key_agrif")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nam_tide      !   tide parameters (#ifdef key_tide)
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nambdy        !  unstructured open boundaries                          ("key_bdy")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nambdy_dta      !  open boundaries - external data           ("key_bdy")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nambdy_tide     ! tidal forcing at open boundaries
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nambfr        !   bottom friction
!-----------------------------------------------------------------------
   nn_bfr      =    2      !  type of bottom friction :   = 0 : free slip,  = 1 : linear friction
                           !                              = 2 : nonlinear friction
/
!-----------------------------------------------------------------------
&nambbc        !   bottom temperature boundary condition
!-----------------------------------------------------------------------
   ln_trabbc   = .true.    !  Apply a geothermal heating at the ocean bottom
   nn_geoflx   =    2      !  geothermal heat flux: = 0 no flux
                           !     = 1 constant flux
                           !     = 2 variable flux (read in geothermal_heating.nc in mW/m2)
   sn_qgh      = 'Goutorbe_ghflux.nc', -12. , 'gh_flux' , .false. , .true. , 'yearly' , 'weights_Goutorbe1_2_orca1_bilinear.nc' , '' , ''
/
!-----------------------------------------------------------------------
&nambbl        !   bottom boundary layer scheme
!-----------------------------------------------------------------------
   nn_bbl_ldf  =  1      !  diffusive bbl (=1)   or not (=0)
   nn_bbl_adv  =  0      !  advective bbl (=1/2) or not (=0)
   rn_ahtbbl   =  1000.  !  lateral mixing coefficient in the bbl  [m2/s]
   rn_gambbl   =  10.    !  advective bbl coefficient                 [s]
/

!!======================================================================
!!                        Tracer (T & S ) namelists
!!======================================================================
!!   nameos        equation of state
!!   namtra_adv    advection scheme
!!   namtra_adv_mle   mixed layer eddy param. (Fox-Kemper param.)
!!   namtra_ldf    lateral diffusion scheme
!!   namtra_dmp    T & S newtonian damping
!!======================================================================
!
!-----------------------------------------------------------------------
&nameos        !   ocean physical parameters
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namtra_adv    !   advection scheme for tracer
!-----------------------------------------------------------------------
   ln_traadv_tvd    =  .false.  !  TVD scheme
   ln_traadv_ubs    =  .false.  !  UBS scheme
   ln_traadv_tvd_zts=  .true.   !lolo  TVD scheme with sub-timestepping of vertical tracer advection
/
!-----------------------------------------------------------------------
&namtra_adv_mle !  mixed layer eddy parametrisation (Fox-Kemper param)
!-----------------------------------------------------------------------
/
!----------------------------------------------------------------------------------
&namtra_ldf    !   lateral diffusion scheme for tracers
!----------------------------------------------------------------------------------
   !                       !  Operator type:
   ln_traldf_lap    =  .true.   !  laplacian operator
   ln_traldf_iso    =  .true.   !  iso-neutral                 (needs "key_ldfslp")
   !                       !  Coefficients
   ! Eddy-induced (GM) advection always used with Griffies; otherwise needs "key_traldf_eiv"
   ! Value rn_aeiv_0 is ignored unless = 0 with Held-Larichev spatially varying aeiv
   !                                  (key_traldf_c2d & key_traldf_eiv & key_orca_r2, _r1 or _r05)
   rn_aht_0         =  1000.    !  horizontal eddy diffusivity for tracers [m2/s]
   rn_aeiv_0        =  1000.    !  eddy induced velocity coefficient [m2/s]    (require "key_traldf_eiv")
/
!-----------------------------------------------------------------------
&namtra_dmp    !   tracer: T & S newtonian damping
!-----------------------------------------------------------------------
   ln_tradmp   =  .false.  !  add a damping termn (T) or not (F)
/
!-----------------------------------------------------------------------
&namdyn_adv    !   formulation of the momentum advection
!-----------------------------------------------------------------------
   ln_dynadv_vec = .true.  !  vector form (T) or flux form (F)
   ln_dynadv_cen2= .false. !  flux form - 2nd order centered scheme
   ln_dynadv_ubs = .false. !  flux form - 3rd order UBS      scheme
   ln_dynzad_zts = .true.  !lolo  Use (T) sub timestepping for vertical advection
/
!-----------------------------------------------------------------------
&nam_vvl    !   vertical coordinate options
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namdyn_vor    !   option of physics/algorithm (not control by CPP keys)
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namdyn_hpg    !   Hydrostatic pressure gradient option
!-----------------------------------------------------------------------
   ln_hpg_zco  = .false.   !  z-coordinate - full steps
   ln_hpg_zps  = .false.   !  z-coordinate - partial steps (interpolation)
   ln_hpg_sco  = .true.    !lolo  s-coordinate (standard jacobian formulation)
   ln_hpg_isf  = .false.   !  s-coordinate (sco ) adapted to isf
   ln_hpg_djc  = .false.   !  s-coordinate (Density Jacobian with Cubic polynomial)
   ln_hpg_prj  = .false.   !  s-coordinate (Pressure Jacobian scheme)
   ln_dynhpg_imp = .false.   !  time stepping: semi-implicit time scheme  (T)
                              !           centered      time scheme  (F)
/
!-----------------------------------------------------------------------
&namdyn_ldf    !   lateral diffusion on momentum
!-----------------------------------------------------------------------
   rn_ahm_0_lap     = 20000.    !  horizontal laplacian eddy viscosity   [m2/s]
/
!-----------------------------------------------------------------------
&namzdf        !   vertical physics
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzdf_ric    !   richardson number dependent vertical diffusion       ("key_zdfric" )
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzdf_tke    !   turbulent eddy kinetic dependent vertical diffusion  ("key_zdftke")
!-----------------------------------------------------------------------
/
!------------------------------------------------------------------------
&namzdf_kpp    !   K-Profile Parameterization dependent vertical mixing  ("key_zdfkpp", and optionally:
!------------------------------------------------------------------------ "key_kppcustom" or "key_kpplktb")
/
!-----------------------------------------------------------------------
&namzdf_gls                !   GLS vertical diffusion                   ("key_zdfgls")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzdf_ddm    !   double diffusive mixing parameterization             ("key_zdfddm")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzdf_tmx    !   tidal mixing parameterization                        ("key_zdftmx")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namzdf_tmx_new    !   new tidal mixing parameterization                ("key_zdftmx_new")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsol        !   elliptic solver / island / free surface
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nammpp        !   Massively Parallel Processing                        ("key_mpp_mpi)
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namctl        !   Control prints & Benchmark
!-----------------------------------------------------------------------
ln_ctl = .false.
nn_timing   =    0         ! timing by routine activated (=1) creates timing.output file, or not (=0)
/
!-----------------------------------------------------------------------
&namc1d        !   1D configuration options                             ("key_c1d")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namc1d_uvd    !   data: U & V currents                                 ("key_c1d")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namc1d_dyndmp !   U & V newtonian damping                              ("key_c1d")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsto       ! Stochastic parametrization of EOS
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namnc4        !   netcdf4 chunking and compression settings            ("key_netcdf4")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namtrd        !   diagnostics on dynamics and/or tracer trends         ("key_trddyn" and/or "key_trdtra")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namflo       !   float parameters                                      ("key_float")
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namptr       !   Poleward Transport Diagnostic
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namhsb       !  Heat and salt budgets
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nam_diaharm   !   Harmonic analysis of tidal constituents ('key_diaharm')
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namdct        ! transports through sections
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namobs       !  observation usage switch                               ('key_diaobs')
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&nam_asminc   !   assimilation increments                               ('key_asminc')
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namsbc_wave   ! External fields from wave model
!-----------------------------------------------------------------------
/
!-----------------------------------------------------------------------
&namdyn_nept  !   Neptune effect (simplified: lateral and vertical diffusions removed)
!-----------------------------------------------------------------------
/
EOF
