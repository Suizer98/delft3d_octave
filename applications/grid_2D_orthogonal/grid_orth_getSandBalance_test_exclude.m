function grid_orth_getSandBalance_test_exclude
%GRID_ORTH_GETSANDBALANCE_TEST_EXCLUDE  This script tests the sediment budget script.

% $Id: grid_orth_getSandBalance_test_exclude.m 5075 2011-08-17 10:32:38Z boer_g $
% $Date: 2011-08-17 18:32:38 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5075 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getSandBalance_test_exclude.m $
% $Keywords: $

clc

%% NB: first put polygons in a directory called polygons
%% next run sand balance
OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         =  pwd;
OPT.polygondir      = [pwd,'\polygons\'];
OPT.polygon         = [];
OPT.cellsize        = [];                               % left empty will be determined automatically
OPT.datathinning    = 1;                                % stride with which to skip through the data
OPT.inputtimes      = datenum((2006:2008)',12, 31);     % starting points (in Matlab epoch time) 
OPT.starttime       = OPT.inputtimes(1);
OPT.searchinterval  = -365;                             % acceptable interval to include data from (in days)
OPT.min_coverage    = 25;                               % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;
OPT.warning         = 1;
OPT.postProcessing  = 1;
OPT.whattodo        = 1;
OPT.type            = 1;
OPT.counter         = 0;
OPT.urls = {'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB116_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB124_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB118_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB115_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB124_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB115_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB117_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB123_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB119_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB114_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB127_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB134_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB112_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB132_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB126_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB128_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_2726.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB116_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB115_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_2928.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB122_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB117_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB132_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB125_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB118_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB117_3938.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB133_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB123_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB130_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB127_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB119_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB114_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB129_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB116_4342.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB118_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB112_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB122_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB114_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_2524.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB126_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB119_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB118_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB124_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB117_4140.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB125_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_3332.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_2726.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB122_1716.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB123_1918.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB118_3534.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB122_1514.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB113_4948.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB119_3736.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB113_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_2524.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB114_4746.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB122_2120.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB120_2322.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB131_1312.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB113_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB121_3130.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB131_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB133_1110.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB112_4544.nc'
	'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB123_2120.nc'};
x_ranges = [50000 60000 % turn into cell below
	130000 140000
	70000 80000
	40000 50000
	130000 140000
	40000 50000
	60000 70000
	120000 130000
	80000 90000
	30000 40000
	160000 170000
	230000 240000
	10000 20000
	210000 220000
	90000 100000
	150000 160000
	170000 180000
	90000 100000
	50000 60000
	40000 50000
	100000 110000
	110000 120000
	100000 110000
	90000 100000
	60000 70000
	210000 220000
	140000 150000
	70000 80000
	90000 100000
	60000 70000
	220000 230000
	120000 130000
	190000 200000
	90000 100000
	160000 170000
	80000 90000
	30000 40000
	180000 190000
	50000 60000
	70000 80000
	10000 20000
	110000 120000
	30000 40000
	100000 110000
	100000 110000
	150000 160000
	80000 90000
	70000 80000
	100000 110000
	130000 140000
	60000 70000
	140000 150000
	90000 100000
	100000 110000
	100000 110000
	110000 120000
	120000 130000
	70000 80000
	110000 120000
	20000 30000
	80000 90000
	20000 30000
	90000 100000
	30000 40000
	110000 120000
	90000 100000
	200000 210000
	20000 30000
	100000 110000
	200000 210000
	220000 230000
	10000 20000
	120000 130000];
y_ranges = [437500 450000
	587500 600000
	487500 500000
	400000 412500
	600000 612500
	425000 437500
	450000 462500
	587500 600000
	487500 500000
	400000 412500
	587500 600000
	612500 625000
	375000 387500
	612500 625000
	500000 512500
	587500 600000
	600000 612500
	512500 525000
	425000 437500
	412500 425000
	500000 512500
	537500 550000
	550000 562500
	487500 500000
	412500 425000
	600000 612500
	587500 600000
	437500 450000
	462500 475000
	437500 450000
	600000 612500
	575000 587500
	600000 612500
	550000 562500
	600000 612500
	475000 487500
	412500 425000
	600000 612500
	412500 425000
	450000 462500
	387500 400000
	562500 575000
	375000 387500
	575000 587500
	525000 537500
	600000 612500
	462500 475000
	475000 487500
	537500 550000
	575000 587500
	425000 437500
	600000 612500
	475000 487500
	562500 575000
	512500 525000
	575000 587500
	562500 575000
	462500 475000
	587500 600000
	375000 387500
	450000 462500
	387500 400000
	525000 537500
	387500 400000
	550000 562500
	537500 550000
	600000 612500
	400000 412500
	487500 500000
	612500 625000
	612500 625000
	400000 412500
	550000 562500];
	
for i=1:size(y_ranges,1)
  OPT.x_ranges{i}            = x_ranges(i,:);
  OPT.y_ranges{i}            = y_ranges(i,:);
end

grid_orth_getSandBalance(OPT);