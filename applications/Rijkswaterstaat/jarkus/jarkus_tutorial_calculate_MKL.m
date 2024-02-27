%% JarKus MKL calculations
% This tutorial demonstrates how to calculate the MKL for a JarKus profile

%% Read data
% See the JarKus tutorial on reading data for a detailed explanation of
% this

url         = jarkus_url;
id          = nc_varget(url,'id');
transect_nr = find(id==6001200)-1;
year        = 1970 + floor(nc_varget(url,'time')/365);
year_nr     = find(year == 1969)-1;
xRSP        = nc_varget(url,'cross_shore');
z           = nc_varget(url,'altitude',[year_nr,transect_nr,0],[1,1,-1]);
x           = xRSP(~isnan(z));
z           =    z(~isnan(z));

%%
% As we want to calculate the MKL position, we need information on the mean
% low water level. The upper boundary is the dune foot position defined as the 3m
% NAP line

MLW = nc_varget(url, 'mean_low_water',transect_nr,1)

%% Calculating the MKL
% To find out what JarKus funtions are available, just enter 'jarkus' in 
% the command prompt or text editor and press tab. Matlab gives suggestions
% to complete the line. To figure out how the funtion works use help.

help jarkus

%% 
% jarkus_getMKL will do the job

UpperBoundary = 3;
LowerBoundary = MLW-(3-MLW);
xMKL = jarkus_getMKL(x,z,UpperBoundary,LowerBoundary,'plot')