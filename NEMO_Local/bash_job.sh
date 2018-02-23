#!/bin/bash -l
#SBATCH -t 00:29:00
#SBATCH -J gyre_xios
#SBATCH -p test
#SBATCH -o gyre_xios.%j
#SBATCH -e gyre_xios_err.%j
#SBATCH -N 4

aprun -n 4 nemo.exe

