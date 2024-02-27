%% Get data for a specific station
% Works for parcode and siteno
clear all; close all

Dir = 'e:\Alameda\01_data\discharges\';

% Load river data for Tijuana
ParCode = {'00060'};               % Parameter code, Look up in parameter-file
tstart  = '1949-12-01';             % Tbegin
tend    = '2019-01-01';             % Tend
SiteNo  = '11303500';               % Station Number (from USGS website)
data = nwi_usgs_read(SiteNo,tstart,tend,ParCode,Dir);


% https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=11303500&referred_module=sw&period=&begin_date=1950-01-01&end_date=2019-01-01
% 'http://waterdata.usgs.gov/nwis/dv?format=rdb&period=&begin_date=1949-12-01&end_date=2019-01-01&referred_module=sw&cb_00060 =on&site_no=11303500'
