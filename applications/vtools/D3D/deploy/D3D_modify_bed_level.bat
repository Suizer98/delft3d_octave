@echo off

rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem %%%                 VTOOLS                 %%%
rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem % 
rem %Victor Chavarrias (victor.chavarrias@deltares.nl)
rem %
rem %$Revision: 17760 $
rem %$Date: 2022-02-14 17:51:28 +0800 (Mon, 14 Feb 2022) $
rem %$Author: chavarri $
rem %$Id: D3D_modify_bed_level.bat 17760 2022-02-14 09:51:28Z chavarri $
rem %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/deploy/D3D_modify_bed_level.bat $
rem %
rem %Modifies the bed elevation of a Delft3D-FM grid based on the 
rem %values along a polyline referenced to the river kilometer.
rem %
rem %Optionally, it first projects the input data to the river axis.
rem %
rem %Optionally, it modifies points only inside certain polygons. 
rem %
rem %Optionally, it modifies points only outside certain polygons. 
rem %
rem %INPUT:
rem %   -fpath_grd: full path to the grid to be modified [string]
rem %   -fpath_bedchg: full path to the ascii-file with bed elevation change data [string]
rem %       -column 1: river kilometer [km]
rem %       -column 2: river branch [string]. The branch name must match the naming in <fpath_rkm>.
rem %       -column 3: bed elevation change [m]
rem %   -fpath_rkm: full path to the file relating river kilometers, branches, and x-y coordinates [string]. See documentation of function <convert2rkm> for more input information. 
rem %
rem %OPTIONAL (pair input):
rem %   -axis: full path to an ascii-file with x-y coordinates of the river axis [string].
rem %   -polygon_in: full path to the shp-file or directory containing shp-files with poygons in which only points inside are to be modified [string]. 
rem %   -polygon_out: full path to the shp-file or directory containing shp-files with poygons in which only points outside are to be modified [string]. 
rem %   -factor: factor multiplying the input data of bed elevation change [-]. Default=1;
rem %   -fdir_output: full path to the folder where to save the output. [string]. Default is current directory. 
rem %   -plot: flag for plotting results [logical]. ATTENTION! this is a very crude plot. 
rem %   -save: flag for saving modified grid [logical].
rem %
rem %OUTPUT:
rem %   -

set fdir_output="d:\temporal\220131_irm_2D\02_output\02_maas"
set fpath_bedchg="d:\temporal\220131_irm_2D\01_input\01_maas\bodemverandering.txt"
set fpath_axis="d:\temporal\220131_irm_2D\01_input\01_maas\axis.txt"
set fpath_rkm="d:\temporal\220131_irm_2D\01_input\01_maas\rkm.csv"
set fpath_grd="d:\temporal\220131_irm_2D\01_input\01_maas\mknov19_6-w7_net.nc"
set fpath_pol_in="d:\temporal\220131_irm_2D\01_input\01_maas\merged_polygons_buffered.shp"
set fpath_pol_out=""
set trend_factor=1.032258064516129

set flg_plot=1
set flg_save=1

rem CALL

@echo on

D3D_modify_bed_level %fpath_grd% %fpath_bedchg% %fpath_rkm% axis %fpath_axis% polygon_in %fpath_pol_in% polygon_out %fpath_pol_out% factor %trend_factor% plot %flg_plot% save %flg_save% fdir_output %fdir_output%

@echo off
pause