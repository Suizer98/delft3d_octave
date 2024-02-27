#! /bin/bash
#SBATCH -N 10
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=rmm
#SBATCH -t 5-00:00:00

# load modules
module load 2019
module load DFlowFM/2020.04-66357-intel-2018b

cat /proc/cpuinfo > output_cpuinfo 2>&1

# Partition model
dflowfm --partition:ndomains=240:icgsolver=6 RMM_dflowfm.mdu

date +%d-%m-%y-%H-%M-%S-%N > tstart 2>&1

srun -N 10 -n 240 dflowfm --autostartstop RMM_dflowfm.mdu

date +%d-%m-%y-%H-%M-%S-%N > tend 2>&1
