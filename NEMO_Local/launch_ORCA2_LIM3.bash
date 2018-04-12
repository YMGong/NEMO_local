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

# Declare your configuration for the simulation, e.g. the ORCA2_LM3 experiment 
cd $NEMOBUILD/NEMOGCM/CONFIG
#you need to add new keys in .fcm file
sed -i 's/$/ key_nosignedzero key_xios2/' ORCA2_LIM3/cpp_ORCA2_LIM3.fcm

# Here you compile a executable for the experiment ORCA2_LIM3 in $TMPDIR 

./makenemo -t $TMPDIR -m XC40-SISU -r ORCA2_LIM3 -n MY_ORCA2_LIM3


# NEMO test
#
cd ORCA2_LIM3/EXP00
# If you use XIOS2.0 you need to copy all the .xml file from GYRE_XIOS
cp $NEMOBUILD/NEMOGCM/CONFIG/GYRE_XIOS/EXP00/*xml .


# For actual experiments:
# Copy the experiments in $WRKDIR/DONOTREMOVE
cd ../..
cp ORCA2_LIM3/ $WRKDIR/DONOTREMOVE/MY_ORCA2_LIM3/
cd $WRKDIR/DONOTREMOVE/MY_ORCA2_LIM3/
cp $TMPDIR/MY_ORCA2_LIM3/BLD/bin/nemo.exe .

# now you need to download input data ORCA2_LIM_nemo_v3.6.tar from http://forge.ipsl.jussieu.fr/nemo/wiki/Users/ReferenceConfigurations/ORCA2_LIM3_PISCES
#
# Then extract them in EXP00
tar xvf ORCA2_LIM_nemo_v3.6.tar 
gzip -d *gz

# Creat a script for Using SLURM commands to execute batch jobs
 in Sisu queue 
# More about the SLURM commands can be found in 
# - https://research.csc.fi/sisu-using-slurm-commands-to-execute-batch-jobs
cat > batch_job.sh <<EOF
#!/bin/bash -l
#SBATCH -t 00:29:00
#SBATCH -J ORCA2_LIM3
#SBATCH -p test
#SBATCH -o ORCA2_LIM3.%j
#SBATCH -e ORCA2_LIM3_err.%j
#SBATCH -N 4

aprun -n 4 nemo.exe
EOF

# Then submit the job in the queue
sbatch batch_job.sh
