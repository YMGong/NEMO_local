#!//bin/bash -l

#SBATCH -t 08:00:00
#SBATCH -J barakuda
#SBATCH -o barakuda_out.%j
#SBATCH -e barakuda_err.%j
#SBATCH -p longrun
#SBATCH --mem-per-cpu=64300
#SBATCH -N 1

#cd ${WRKDIR}/DONOTREMOVE/barakuda
module load hdf5-par netcdf4 python-env/intelpython3.5

./barakuda.sh -C ORCA1_L75_YG_taito -R N157

exit 0
