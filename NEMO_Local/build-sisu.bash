#!/bin/bash

set -ex

# NEMO 3.6 STABLE + XIOS-2 build instructions for sisu.csc.fi
#
# 2018-02-20, juha.lento@csc.fi

# NEMO is "research code", which for NEMO means that:
# - "install" in the NEMO documentation actually is what is usually referred as "build"

# The following build instructions are based on:
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInstall#ExtracttheNEMOcode
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInterfacing/InputsOutputs#ExtractingandinstallingXIOS

#Your user name used for registering to nemo user wiki
USER="ygong"

# Load system I/O libraries
# now use xios2.0 by default

module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.0.990


# Create the main NEMO directory

mkdir -p $USERAPPL/nemo_test3
cd $USERAPPL/nemo_test3


# Checkout source

svn --username $USER co http://forge.ipsl.jussieu.fr/nemo/svn/branches/2015/nemo_v3_6_STABLE/NEMOGCM

# NEMO build

cd ./NEMOGCM
cat > ARCH/arch-XC40-SISU.fcm <<EOF
%NCDF_HOME           $NETCDF_DIR
%HDF5_HOME           $HDF5_DIR
%XIOS_HOME           $(pkg-config --variable=CRAY_prefix xios)
%NCDF_INC            -I%NCDF_HOME/include -I%HDF5_HOME/include
%NCDF_LIB            -L%HDF5_HOME/lib -L%NCDF_HOME/lib -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
%XIOS_INC            -I%XIOS_HOME/inc
%XIOS_LIB            -L%XIOS_HOME/lib -lxios
%CPP                 cpp
%FC                  ftn
%FCFLAGS             -emf -s real64 -s integer32  -O2 -hflex_mp=intolerant -Rb
%FFLAGS              -emf -s real64 -s integer32  -O0 -hflex_mp=strict -Rb
%LD                  ftn
%FPPFLAGS            -P -E -traditional-cpp
%LDFLAGS             -hbyteswapio 
%AR                  ar 
%ARFLAGS             -r
%MK                  gmake
%USER_INC            %XIOS_INC
%USER_LIB            %XIOS_LIB
%CC                  cc
%CFLAGS              -O0
EOF

# Here you compile a executable for the experiment GYRE in either $TMPDIR 

#cd CONFIG
#./makenemo -t $TMPDIR -m XC40-SISU -r GYRE -n MY_GYRE

# NEMO test
#
# For a quick test, only! 

# cd MY_GYRE/EXP00
# cp $TMPDIR/MY_GYRE/BLD/bin/nemo.exe .
# aprun -n 4 nemo.exe

#For actual experiments:
# - submit jobs through SLURM batch queue system, and
# - use $WRKDIR for input and output files



