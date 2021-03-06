#!/bin/bash

set -ex

# NEMO 3.6 STABLE + XIOS-2 build instructions for sisu.csc.fi
#
# 2018-02-20, juha.lento@csc.fi
# modified 2018-03-08, yongmei.gong@helsinki.fi

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

# Declare your configuration for the simulation, e.g. the GYRE_XIOS experiment 
cd $NEMOBUILD/NEMOGCM/CONFIG

#you need to add new keys in .fcm file
sed -i 's/$/ key_nosignedzero/' GYRE_XIOS/cpp_GYRE_XIOS.fcm

# Here you compile a executable for the experiment GYRE_XIOS in either $TMPDIR or $WRKDIR/DONOTREMOVE
./makenemo -t $TMPDIR -m XC40-SISU -r GYRE_XIOS -n MY_GYRE_XIOS

# NEMO test
#
# For a quick test, only! 

# cd MY_GYRE_XIOS/EXP00
# cp $TMPDIR/MY_GYRE_XIOS/BLD/bin/nemo.exe .
# aprun -n 4 nemo.exe


# For actual experiments:
# Copy the experiments in $WRKDIR/DONOTREMOVE
cp GYRE_XIOS/ $WRKDIR/DONOTREMOVE/MY_GYRE_XIOS/
cd $WRKDIR/DONOTREMOVE/MY_GYRE_XIOS/EXP00

# Copy the executable to the EXP00 directory
cp $TMPDIR/MY_GYRE_XIOS/BLD/bin/nemo.exe .

# Creat a script for Using SLURM commands to execute batch jobs
 in Sisu queue 
# More about the SLURM commands can be found in 
# - https://research.csc.fi/sisu-using-slurm-commands-to-execute-batch-jobs

cat > batch_job.sh <<EOF
#!/bin/bash -l
#SBATCH -t 00:29:00
#SBATCH -J gyre_xios
#SBATCH -p test
#SBATCH -o gyre_xios.%j
#SBATCH -e gyre_xios_err.%j
#SBATCH -N 4

aprun -n 4 nemo.exe
EOF

# Then submit the job in the queue
sbatch batch_job.sh
