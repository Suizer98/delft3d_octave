function grid_orth_getSandBalance_test1_exclude
%GRID_ORTH_GETSANDBALANCE_TEST1_EXCLUDE  This script tests the sediment budget script.

% $Id: grid_orth_getSandBalance_test1_exclude.m 5075 2011-08-17 10:32:38Z boer_g $
% $Date: 2011-08-17 18:32:38 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5075 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getSandBalance_test1_exclude.m $
% $Keywords: $

clc

%% NB: first put polygons in a directory called polygons
%% next run sand balance
OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         =  pwd;
OPT.polygondir      = [pwd,'\polygons\'];
OPT.searchinterval  = -730;                             % acceptable interval to include data from (in days)
OPT.min_coverage    = [50 75 90];                       % coverage percentage (can be several, e.g. [50 75 90]
OPT.urls = {'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB127_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB129_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB126_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB113_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB130_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB133_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_2726.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_2524.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB109_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB131_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB133_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB126_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB131_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB111_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB129_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB127_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB109_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2726.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB128_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB109_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB130_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB113_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB131_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB140_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB129_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB127_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB126_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB128_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB111_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_2726.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB110_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB128_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB131_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB133_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_2524.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2524.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB113_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB133_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB110_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB130_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB120_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB126_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB111_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_0908.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB133_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB126_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB127_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB123_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB139_0504.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB132_0706.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB118_5150.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB113_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB111_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB137_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB114_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB125_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB117_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB110_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB115_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB124_2322.nc'};
x_ranges = [90000 96460 % turn into cell below
	40000 50000
	60000 70000
	160000 170000
	180000 190000
	270000 280000
	130000 140000
	130000 140000
	270000 280000
	280000 290000
	150000 160000
	140000 150000
	20000 30000
	40000 50000
	110000 120000
	100000 110000
	190000 191020
	130000 140000
	90000 90700
	220000 230000
	70000 80000
	90000 100000
	210000 220000
	90000 100000
	-20000 -10000
	210000 215800
	50000 60000
	30000 40000
	50000 60000
	270000 280000
	110000 120000
	200000 210000
	240000 250000
	220000 230000
	105000 110000
	150000 160000
	250000 260000
	10000 20000
	50000 60000
	80000 82720
	205260 210000
	230000 240000
	270000 280000
	0 10000
	240000 250000
	240000 250000
	110000 120000
	180000 190000
	50000 60000
	60000 70000
	40000 50000
	160000 170000
	-20000 -10000
	100000 104680
	67600 70000
	170000 180000
	70000 80000
	250000 260000
	90000 100000
	-20000 -10000
	70000 80000
	190000 200000
	20000 30000
	240000 250000
	70000 80000
	110000 120000
	80000 90000
	250000 260000
	80000 90000
	10000 20000
	201160 210000
	30000 40000
	290000 300000
	180000 190000
	280000 290000
	70000 80000
	120000 130000
	10000 20000
	50000 60000
	160000 166000
	150000 156840
	260000 270000
	170000 180000
	0 10000
	30000 40000
	40000 50000
	210000 220000
	70000 80000
	120000 130000
	140000 150000
	50000 60000
	100000 110000
	97640 100000
	260000 270000
	75040 80000
	120000 130000
	90000 100000
	100000 100540
	260000 270000
	81200 90000
	-10000 0
	230000 240000
	230000 240000
	170000 180000
	230000 240000
	200000 210000
	220000 230000
	30000 40000
	60000 70000
	123920 130000
	87400 90000
	100000 108100
	50000 60000
	20000 30000
	250000 260000
	220000 230000
	120000 130000
	-10000 0
	60000 70000
	60000 70000
	92080 100000
	260000 270000
	100000 110000
	50000 60000
	10000 20000
	280000 290000
	60000 70000
	270000 280000
	190000 200000
	260000 270000
	100000 103000
	70000 80000
	80000 90000
	80000 90000
	210000 220000
	280000 290000
	94900 100000
	40000 50000
	210000 220000
	280000 290000
	30000 40000
	250000 260000
	30000 40000
	71840 80000
	130000 140000
	80000 90000
	40000 50000
	150000 160000
	0 10000
	260000 270000
	220000 230000
	250000 260000
	150000 160000
	160000 170000
	80000 90000
	73560 80000
	120000 130000
	140000 146500
	280000 290000
	280000 290000
	210000 220000
	270000 280000
	140920 150000
	70000 80000
	140000 150000
	20000 30000
	230000 240000
	130000 140000
	0 10000
	10000 20000
	260000 270000
	240000 250000
	110000 120000
	40000 50000
	30000 40000
	140000 150000
	60000 70000
	-10000 0
	40000 50000
	130000 130400];
y_ranges = [475000 487500
	412500 425000
	362500 375000
	587500 600000
	612500 620020
	612500 625000
	550000 562500
	575000 587500
	625000 637500
	587500 600000
	587500 600000
	587500 600000
	375000 387500
	375000 387500
	550000 562500
	562500 575000
	599720 600000
	587500 600000
	473720 475000
	612500 625000
	425000 437500
	512500 525000
	650000 662500
	525000 537500
	387500 400000
	591980 600000
	400000 412500
	425000 437500
	412500 425000
	650000 662500
	575000 587500
	600000 612500
	625000 637500
	650000 662500
	575000 587480
	575000 587500
	587500 600000
	400000 412500
	450000 462500
	459340 462500
	592080 600000
	625000 637500
	575000 587500
	375000 387500
	650000 662500
	612500 625000
	544900 550000
	600000 612500
	437500 450000
	450000 462500
	362500 375000
	612500 620000
	362500 375000
	512500 525000
	462500 469660
	600000 612500
	375000 387500
	637500 650000
	500000 512500
	375000 387500
	387500 400000
	600000 612500
	400000 412500
	637500 650000
	400000 412500
	587500 596980
	475000 487500
	612500 625000
	462500 475000
	375000 387500
	625000 628880
	437500 450000
	575000 587500
	595940 600000
	637500 650000
	437500 450000
	562500 575000
	362500 375000
	375000 387500
	582260 587500
	564940 575000
	650000 662500
	591360 600000
	387500 400000
	362500 375000
	387500 400000
	612500 625000
	450000 462500
	550000 562500
	562500 575000
	387500 400000
	537500 550000
	562500 567200
	612500 625000
	500000 510060
	575000 587500
	487500 500000
	498400 500000
	587500 600000
	512500 525000
	362500 375000
	637500 650000
	650000 662500
	612500 620020
	612500 625000
	612500 625000
	625000 637500
	412500 425000
	425000 437500
	600000 605500
	525000 530320
	525000 537500
	362500 375000
	387500 400000
	650000 662500
	600000 612500
	544640 550000
	387500 400000
	375000 387500
	400000 412500
	537500 550000
	637500 650000
	550000 562500
	425000 437500
	412500 425000
	625000 637500
	437500 450000
	637500 650000
	612500 624520
	575000 587500
	500000 512500
	462500 475000
	400000 412500
	412500 425000
	600000 612500
	575000 587500
	550000 562500
	450000 462500
	625000 637500
	550000 562500
	400000 412500
	625000 637500
	375000 387500
	475000 487500
	562500 575000
	500000 512500
	400000 412500
	612500 619980
	362500 375000
	625000 637500
	637500 650000
	600000 612500
	600000 612500
	600000 612500
	487500 500000
	487500 500000
	587500 600000
	556920 562500
	562500 575000
	650000 662500
	637500 650000
	587500 600000
	612500 616300
	362500 375000
	600000 612500
	412500 425000
	600000 612500
	600000 612100
	400000 412500
	387500 400000
	600000 612500
	600000 612500
	562500 575000
	437500 450000
	387500 400000
	575000 587500
	387500 400000
	375000 387500
	425000 437500
	549740 550000];

for i=1:size(y_ranges,1)
  OPT.x_ranges{i}            = x_ranges(i,:);
  OPT.y_ranges{i}            = y_ranges(i,:);
end

if 0
    try rmdir(fullfile(OPT.workdir, 'coverage'),  's'); end
    try rmdir(fullfile(OPT.workdir, 'datafiles'), 's'); end
    try rmdir(fullfile(OPT.workdir, 'results'),   's'); end
end

grid_orth_getSandBalance(OPT);