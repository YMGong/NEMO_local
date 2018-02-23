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

#Your user name used for registering to nemo user wiki
USER="ygong"

# Load system I/O libraries
# now use xios2.0 by default

module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/


# Create the main NEMO directory

mkdir -p $USERAPPL/nemo_test
cd $USERAPPL/nemo_test


# Checkout source

svn --username $USER co http://forge.ipsl.jussieu.fr/nemo/svn/branches/2015/nemo_v3_6_STABLE/NEMOGCM




