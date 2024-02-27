@echo off
rem set fpath_dir_out=p:\11208033-002-maas-mor-2d\05_reports\01_Sambeek-Grave\co\figures\simulations\
set fpath_dir_out=./simulations/
set fpath_input=./copy_figures_list.csv

@echo on
copy_files_in_folder %fpath_dir_out% %fpath_input%
@echo off
pause

