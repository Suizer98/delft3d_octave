#!/bin/bash
#$ -cwd
#$ -m bea
#$ -q normal-e3-c7

# NOTES:
#	-do a dos2unix
# 	-call as qsub ./run_matlab_in_p

module load matlab/2018a
#matlab -nodisplay -r main_sedtrans
matlab -r main_sedtrans
