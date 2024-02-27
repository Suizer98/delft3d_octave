clear variables;close all;

coastfile='shorelinepoints.txt';
trackfile='katrina2005.cyc';
outputfolder='e:\work\empirical_surge_formula\applications\katrina\output\';

t0=datenum(2005,08,28, 00,00,00);
t1=datenum(2005,08,30, 6, 00,00);
dt=60; % minutes
lon=[-91.6961 -81.8055];
lat=[ 29.4963  26.1126];
landdecay=0;

[t,xx,lon,lat,stot,snor,spar,srad,sekm,sibe]=sessp_simulate_track(coastfile,trackfile,outputfolder,t0,t1,dt,'manning',0.012,'max_omega',20000,'include_tide',0,'lon',lon,'lat',lat,'landdecay',landdecay);

