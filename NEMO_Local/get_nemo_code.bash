#!/bin/bash

set -ex

# 2018-02-20, juha.lento@csc.fi'
# modified 2018-03-08, yongmei.gong@helsinki.fi

# NEMO is "research code", which for NEMO means that:
# - "install" in the NEMO documentation actually is what is usually referred as "build"

# The following build instructions are based on:
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInstall#ExtracttheNEMOcode
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInterfacing/InputsOutputs#ExtractingandinstallingXIOS

#Your user name used for registering to nemo user wiki
USER="YOUR_USER_NAME"

# Load system I/O libraries (that is how we use an existing software on Sisu)
# now use xios2.0 by default

module load cray-hdf5-parallel cray-netcdf-hdf5parallel xios/


# Create the main NEMO directory (a folder) where you want to store the source code
# Here I put in in the user application directory in Sisu, $USERAPPL, where you can build (install) your own software 

mkdir -p $USERAPPL/nemo_test
cd $USERAPPL/nemo_test


# Checkout (download) the source code 
# Type your password on the screen and type yes when asked. 

svn --username $USER co http://forge.ipsl.jussieu.fr/nemo/svn/branches/2015/nemo_v3_6_STABLE/NEMOGCM





