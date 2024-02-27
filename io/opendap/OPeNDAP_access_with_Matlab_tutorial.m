%OPENDAP_ACCESS_WITH_MATLAB_TUTORIAL  how to use OPeNDAP from within matlab
%
% This tutorial is also available for Python and R
%
%See also: OPeNDAP_subsetting_with_Matlab_tutorial 

% $Id: OPeNDAP_access_with_Matlab_tutorial.m 12019 2015-06-19 13:08:12Z gerben.deboer.x $
% $Date: 2015-06-19 21:08:12 +0800 (Fri, 19 Jun 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12019 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/OPeNDAP_access_with_Matlab_tutorial.m $
% $Keywords: $

% This document is also posted on a wiki: http://public.deltares.nl/display/OET/OPeNDAP+access+with+matlab

%%
%run('..\..\oetsettings.m')

%% Read data from an opendap server
url_grid = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4544.nc'
url_time = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_water/id410-DELFZBTHVN.nc'

%%
ncdisp(url_grid)
ncdisp(url_time)

%% Get grid data 
G.x = ncread(url_grid,'x');
G.y = ncread(url_grid,'y');
G.z = ncread(url_grid,'z',[1 1 1],[Inf Inf 1]); % get only one timestep (here: 1st), but all x and y, note: nc_varget is zero based.

%% Get time series data
figure
T.t   = ncread_cf_time(url_time,'time'); % adapt reference date of 1970 in netCDF to Matlab reference date of 0000
T.eta = ncread(url_time,'concentration_of_suspended_matter_in_water');

%% plot grid data
pcolorcorcen(G.x,G.y,G.z')
axis equal
axis tight
tickmap('xy')
grid on
xlabel('x')
ylabel('y')
colorbarwithtitle('z')

%% plot timeseries data
figure
plot(T.t,T.eta)
datetick('x')
grid on
