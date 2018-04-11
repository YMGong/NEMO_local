#!/bin/bash

set -ex
#####################################
# 2018-04-11, yongmei.gong@helsinki.fi
# more details go there
#https://matplotlib.org/basemap/users/installing.html#installation
#####################################


# !!!login to taito-login4
# load modules needed
module load python-env/intelpython3.5 geos/3.6.1 proj4/4.9.3 hdf5-par netcdf4

##############
# set up python
pip install --upgrade pip --user # first upgrade pip
pip list --outdated --format=freeze | xargs -n1 pip install # then upgrade python modules
pip install netCDF4 --user # install netCDF module
pip install pyproj --user # install pyproj
pip install pyshp --user

#############
# install basemap

# get the code
wget https://github.com/matplotlib/basemap/archive/v1.1.0.tar.gz
# untar
tar -zxf v1.1.0.tar.gz
# tell it where to find geos
export GEOS_DIR=/appl/earth/geos/3.6.1
# install
cd basemap-1.1.0/
python3.5 setup.py install --user
# test
cd examples/
python3.5 test_rotpole.py