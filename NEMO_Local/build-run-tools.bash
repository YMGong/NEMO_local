#!/bin/bash

set -ex

# NEMO 3.6 STABLE + XIOS-2 build instructions for sisu.csc.fi
#
# 2018-04-04, yongmei.gong@helsinki.fi

# NEMO is "research code", which for NEMO means that:
# - "install" in the NEMO documentation actually is what is usually referred as "build"

# The following build instructions are based on:
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInstall#ExtracttheNEMOcode
# - https://forge.ipsl.jussieu.fr/nemo/wiki/Users/ModelInterfacing/InputsOutputs#ExtractingandinstallingXIOS


module load cray-hdf5-parallel cray-netcdf-hdf5parallel 

# craype-haswell is only used on the computational nodes
# craype-sandybridge can be recognised on both computational nodes and log in nodes. So inoder to run small script on login nodes you need to use sandy bridge.
module swap craype-haswell craype-sandybridge


# NEMO build
# if you don't have a file called arch-XC40-SISU.fcm in your NEMO/NEMOGCM/ARCH
# Do the following

cd /homeappl/home/ygong/appl_sisu/NEMO/NEMOGCM/
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

# Here you compile a executable 

TOOL_NAME=REBUILD_NEMO # here we build the tool called  REBUILD_NEMO

./maketools -m XC40-SISU -n $TOOL_NAME


cd $TOOL_NAME

# use the tool

#
# !!!!Manuelly change the last line 
# from
# ${script_dir}/rebuild_nemo.exe
# to
# aprun ${script_dir}/rebuild_nemo.exe 

FILE_NAME=/wrk/ygong/DONOTREMOVE/NEMOEXP/N157/N157_00607360_restart_ice  #base name of the discretized files 
NMU_PROCESS=72 #number of the partition i.e. the processors you used for NEMO

# Then run it
./rebuild_nemo $FILE_NAME $NMU_PROCESS

# if you get an error:
# 
# Do the follow
# 1.check if there is a file called nam_rebuild created
# 2.>>more nam_rebuild and check if it contains the correct info
# &nam_rebuild
# filebase=$FILE_NAME
# ndomain=$NMU_PROCESS
# /
# 3. If it is then 
# >> ls -lrt and check if there is a symbolic link created:
# rebuild_nemo.exe -> YOUR_DIR/TOOLS/REBUILD_NEMO//BLD/bin/rebuild_nemo.exe
# 4.If you use craype-haswell instead of craype-sandybridge to compile you have to change the last line in rebuld_nemo to 
# aprun ./rebuild_nemo.exe
