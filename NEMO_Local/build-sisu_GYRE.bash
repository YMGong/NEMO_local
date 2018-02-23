#!/bin/bash

set -ex

# NEMO 3.6 STABLE + XIOS-1 build instructions for sisu.csc.fi
#
# 2018-02-20, juha.lento@csc.fi

# NEMO is "research code", which for NEMO means that:
# - "install" in the NEMO documentation actually is what is usually referred as "build"

# The following build instructions are based on:
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInstall#ExtracttheNEMOcode
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInterfacing/InputsOutputs#ExtractingandinstallingXIOS

# Load system I/O libraries
# might change to xios2.0

#module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.0.990


# Declare your NEMO code directory

NEMOBUILD="$USERAPPL/nemo_test3"

# NEMO build

cd $NEMOBUILD/NEMOGCM
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
# Declare your configuration for the simulation, e.g. the GYRE experiment 
cd CONFIG
./makenemo -t $TMPDIR -m XC40-SISU -r GYRE -n MY_GYRE

# NEMO test
#
# For a quick test, only! For actual experiments:
# - submit jobs through SLURM batch queue system, and
# - use $WRKDIR for input and output files

# cd MY_GYRE/EXP00
# cp $TMPDIR/MY_GYRE/BLD/bin/nemo.exe .
# aprun -n 4 nemo.exe
## aprun -n 4 ./opa


