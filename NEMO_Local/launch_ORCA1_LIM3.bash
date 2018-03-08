#!/bin/bash

set -ex

# NEMO 3.6 STABLE + XIOS-2 build instructions for sisu.csc.fi
#
# 2018-02-20, juha.lento@csc.fi
# modified 2018-03-06, yongmei.gong@helsinki.fi

# NEMO is "research code", which for NEMO means that:
# - "install" in the NEMO documentation actually is what is usually referred as "build"

# The following build instructions are based on:
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInstall#ExtracttheNEMOcode
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInterfacing/InputsOutputs#ExtractingandinstallingXIOS

# Load system I/O libraries
# might change to xios2.0

module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.0.990


# Declare your NEMO code directory

NEMOBUILD="$USERAPPL/nemo_test3"

# NEMO build

# There is no ORCA1 experiment, which means the spaceial resolution now is 1 degree in the standard distribution therefore we need to creat it ourselves
 
cd $NEMOBUILD/NEMOGCM/CONFIG
mkdir ORCA1
cd ORCA1 

# put the cpp file here
cp /homeappl/home/ygong/appl_sisu/NEMO/NEMO_local/ORCA1_cfg/cpp_ORCA1_LIM3.fcm .

# creat a experiment dir and put all the xml and namelist files and data there
# make sure that you have all the files (you don't need *pisces.xml files if you don't want to couple with biochemistry) and field xml files listed in context_nemo.xml
# you can put the line 'nn_msh      =    0      !  create (=1) a mesh file or not (=0)' under &namdom in namelist_cfg. This prevents nemo to creat the mesh files, which will cause trouble when you re-launch the experiment in the same directory as they cannot be over-written
# data includes all the data describing the boundray and initial conditions and the climatology in NetCDF format. And a samll *.dat file describing the humidity

mkdir EXP00
cp /homeappl/home/ygong/appl_sisu/NEMO/NEMO_local/ORCA1_cfg/*xml .
cp /homeappl/home/ygong/appl_sisu/NEMO/NEMO_local/ORCA1_cfg/namelist* .
cp /homeappl/home/ygong/appl_sisu/NEMO/NEMO_local/ORCA1_data/* .

# Here you compile a executable for the experiment ORCA1 in $TMPDIR 
cd ..
./makenemo -t $TMPDIR -m XC40-SISU -r ORCA1 -n MY_ORCA1



# NEMO test
# now the experiment gets bigger so we do it in $WRKDIR
cd $WRKDIR/DONOTREMOVE/
mkdir MY_ORCA1
cd ORCA1
cp $NEMOBUILD/NEMOGCM/CONFIG/ORCA1/EXP00 .
cp $TMPDIR/MY_ORCA2_LIM3/BLD/bin/nemo.exe .

# now creat a batch job script
cat > batch_job.sh <<EOF
#!/bin/bash -l
#SBATCH -t 12:00:00
#SBATCH -J ORCA1
#SBATCH -p small
#SBATCH -o ORCA1.%j
#SBATCH -e ORCA1_err.%j
#SBATCH -N 4

aprun -n 24 nemo.exe
EOF

# submit the job
sbatch batch_job.sh
