function grid_orth_getSandBalance_test2_exclude
%GRID_ORTH_GETSANDBALANCE_TEST2_EXCLUDE  This script tests the sediment budget script.

% $Id: grid_orth_getSandBalance_test2_exclude.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getSandBalance_test2_exclude.m $
% $Keywords: $

clc;
fclose all;

%% NB: first put polygons in a directory called polygons ... next run sand balance
OPT.dataset         = 'd:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\nc_files\elevation_data\multibeam\';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\';
OPT.polygondir      = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\polygons\';
OPT.searchinterval  = 0;                                % acceptable interval to include data from (in days)
OPT.min_coverage    = [50 90];                          % coverage percentage (can be several, e.g. [50 75 90]

if 1
    try rmdir(fullfile(OPT.workdir, 'coverage'),  's'); end
    try rmdir(fullfile(OPT.workdir, 'datafiles'), 's'); end
    try rmdir(fullfile(OPT.workdir, 'results'),   's'); end
end

grid_orth_getSandBalance(OPT);