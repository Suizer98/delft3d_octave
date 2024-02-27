%% JarKus volume calculations
% This tutorial demonstrates how to calculate the volume of a certain
% JarKus profile. 

%% Read some data
% See the previous JarKus tutorial for a detailed explanation

url         = jarkus_url;
id          = nc_varget(url,'id');
transect_nr = find(id==8005700)-1;
year        = 1970 + floor(nc_varget(url,'time')/365);
year_nr     = find(year == 1979)-1;
xRSP        = nc_varget(url,'cross_shore');
z           = nc_varget(url,'altitude',[year_nr,transect_nr,0],[1,1,-1]);
x    = xRSP(~isnan(z));
z    =    z(~isnan(z));

%% Available options
% First we want an overview of available jarkus functions

help jarkus

%% 
% Apparently, there are two (competing) functions in the toolbox that can
% calculate volumes: jarkus_getVolume and jarkus_getVolumeFast 
% to find out differences, click on the help links

%% jarkus_getVolumeFast
% Firs an example using jarkus_getVolumeFast
%
% We need to define a box within which the volume can be computed, as
% volume if not defined for a line.

UpperBoundary       =  1000;
LowerBoundary       =     3;
LandwardBoundary    =     0;
SeawardBoundary     = max(x);

%%
% and the we call the function. We use the additional 'plot' argument to
% get a plot of the result. 

[Volume] = jarkus_getVolumeFast(x, z, UpperBoundary, LowerBoundary,...
    LandwardBoundary, SeawardBoundary,'plot')

%% jarkus_getVolume
% to be added...

%% Volume difference between two transects
% to be added...
