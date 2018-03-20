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


# NEMO build
# All compiler options in NEMO are controlled using files in NEMOGCM/ARCH/arch-'my_arch'.fcm where 'my_arch' is the name of the computing architecture.
# Now we create a file to declare the compilers we use to build nemo accroding to what we have in Sisu

cd $USERAPPL/nemo_test/NEMOGCM
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

