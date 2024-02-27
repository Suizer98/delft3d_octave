#! /bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=matlab_anl
#SBATCH -t 5-00:00:00


# NOTES:
#       -do a dos2unix
#       -call as sbatch ./run_matlab

# go to the folder where the script is
cd /projects/0/hisigem/11205258-016-kpp2020rmm-3d/E_Software_Scripts/rmm_plot/
# load modules
module load 2019
module load MATLAB/2019b
# call (do not add the extension to the filename or it will be interpreted as a structure)
matlab -r main_plot_all

