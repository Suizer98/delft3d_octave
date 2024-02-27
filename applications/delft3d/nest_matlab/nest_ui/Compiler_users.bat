@echo off
N:\Applications\FLEXlm\bin\lmutil lmstat -c N:\Applications\FLEXlm\Matlab\license.dat -f Compiler > "N:\My Documents\Matlab_Compiler_users.txt"
echo "N:\My Documents\Matlab_Compiler_users.txt"
type "N:\My Documents\Matlab_Compiler_users.txt"

echo N:\My Documents\Matlab_Compiler_users.txt

pause
