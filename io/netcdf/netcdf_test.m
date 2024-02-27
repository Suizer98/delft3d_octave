function OK =  netcdf_test
%NETCDF_TEST   integration tst for snctools + netcdf dependencies (java, mex, mathworks native netcdf library)
%
%See also: netcdf_settings, netcdf

%%
disp([mfilename,' test 1'])
test_snctools

%%
disp([mfilename,' test 2'])
test_opendap_local_system

%% java heap space has by default  130,875,392 bytes
disp([mfilename,' test 3'])
f = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';

try
   z  = nc_varget(f,'altitude',[0 0 0],[1 -1 -1]);
   OK = 1;
catch   
   OK = 0;
   disp('		UNEXPECTED: java.lang.OutOfMemoryError: Java heap space')
end

try
   z  = nc_varget(f,'altitude',[0 0 0],[2 -1 -1]);
   disp('		EXPECTED: java.lang.OutOfMemoryError: Java heap space')
   OK = 1;
catch   
   OK = 1;
end
   disp(['		java.lang.Runtime.getRuntime.maxMemory = ',num2str(java.lang.Runtime.getRuntime.maxMemory/2^20),' Mb'])
   disp('		For increasing java heap space see:')
   disp('		http://www.mathworks.com/support/solutions/en/data/1-18I2C/')

%% was SLOW, but not any more after snctools getpref updates !!
disp([mfilename,' test 4'])
disp('		please be patient: testing 1000 times')
test_local_system % load opendap vars, save as local netcdf3, load it again & compare

%% test basic authentication (with pre-operational Rijkswaterstaat server, TA in OTAP (=DTAP <uk>))
try
   
   [user,passwd]=matroos_user_password;
   
   nc_dump(['https://',user,':',passwd,'@opendap-matroos.deltares.nl/thredds/dodsC/maps/normal/test_adaguc/dcsm_v6_hirlam_201112270600.nc'])
   nc_dump([ 'http://',user,':',passwd,'@opendap-matroos.deltares.nl/thredds/dodsC/maps/normal/test_adaguc/dcsm_v6_hirlam_201112270600.nc'])
   
end