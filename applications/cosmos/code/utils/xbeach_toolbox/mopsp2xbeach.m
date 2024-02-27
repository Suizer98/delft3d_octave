function mopsp2xbeach(mopid,monthid,pnum,sdur,tstep,dr,FileRoot)

% mopsp2xbeach.m: reads in the 2d spectral timeseries that was generated from
% read_mopsp_mult.m and writes out formatted density spectral files that
% can be input into Xbeach using the 'instat = 6' command.  Since this is
% time-varying spectra it also writes a list of the individual spectral
% files that is read in by the 'bcfile' command.  This program needs the 
% alfa value from Xbeach that represents the angle of the grid in order to 
% convert the angles in the spectral file to the Xbeach coordinate system 
% (it calculates this from profile data).
%
%   Inputs:
%     mopid = mop station id (ex: 'VE338')
%     monthid = year and month of data (ex: '200904')
%     pnum = profile number that corresponds with mopid (ex: 3401)
%     sdur = duration of each wave spectrum condition in seconds (ex: 3600)
%     tstep = required time step in boundary condition file in seconds 
%            (ex:1.0)
%     dr - directory path where the profile data is 
%            (ex: 'M:\Coastal_Hazards\Xbeach\Ventura_XBeach\DEM_bathy\')
%     FileRoot - name of profile data file (ex:'ve4xlines3mFinal')
%__________________________________________________________________________
% The timeseries of input 2D spectral data is stored in the following
% format.
%
% out2d = array with 2D spectral data
% out2d.time = matlab datenumber
% out2d.f = frequencies 
% out2d.d = directions (nautical, based on CDIP output)
% out2d.s = variance densities
% size(out2d.s) = [length(out2d.f) length(out2d.dir) length(out2d.time)]   
%__________________________________________________________________________
% JLE 9/25/09
%
% Load in the profile data from excel file.
fname = [dr,FileRoot,'.xls'];
[pdata] = xlsread(fname);
mid = pdata(:,1);
east = pdata(:,3);
north = pdata(:,4);
elev = pdata(:,5);
p= find(mid==pnum);
x=east(p);
y=north(p);

%Estimate alpha for profile so that it is in a cross-shore positive
%coordinate system. 
xdif = x(end) - x(1);
ydif = y(end) - y(1);
if (xdif > 0 && ydif > 0)
    alfa = round(atan((y(end)-y(1))/(x(end)-x(1)))*(180/pi()));
elseif (xdif < 0 && ydif > 0)
    alfa = round((atan((y(end)-y(1))/(x(end)-x(1)))*(180/pi())) + 180);
elseif (xdif < 0 && ydif < 0)    
    alfa = round((atan((y(end)-y(1))/(x(end)-x(1)))*(180/pi())) + 270);   
elseif (xdif > 0 && ydif < 0)  
    alfa = round((atan((y(end)-y(1))/(x(end)-x(1)))*(180/pi())) + 360);
end

%__________________________________________________________________________
% Read in the 2d spectral time series and convert angles from nautical
% convention to the Xbeach coordinate system using the alfa value.
load([mopid,'_',monthid,'_2dspec.mat']);

% Convert directions from nautical format to Xbeach Cartesian coordinate 
% system.  Keep these as positive angles for now.
Dpn=out2d.d;
Dpc=(360-Dpn)+270;
for jj=1:length(Dpc)
  if(Dpc(jj)>360)
            Dpc(jj)=Dpc(jj)-360;
  end
end

% Now rotate the cartesian xbeach coordinate system by alfa.
for jj=1:length(Dpc)
    if(Dpc(jj)>alfa)
        Dpc2(jj)=Dpc(jj)-alfa;
    else
        Dpc2(jj)=Dpc(jj)+360-alfa;
    end
end

% Now sort the modified angles to be increasing.
[Dpc_fix,sind] = sort(Dpc2');

% Fix the 2d spectral file for each timestep.
for jj=1:length(out2d.t)
    for ii=1:length(Dpc_fix)
        Sfix(:,ii,jj)=out2d.s(:,sind(ii),jj);
    end
end

% Change the angles to be -180 to +180 for Xbeach formatted variance 
% density spectrum input and sort S accordingly. 
% Define directions in degrees.  First column is
% centered at 1 degree, last column is centered at 360 deg.
dxb=[(1:1:180) (-179:1:0)]; 

% Now sort the modified angles to be increasing for Xbeach file input 
% (required Xbeach manual p.43).
[dxb_fix,xbind] = sort(dxb');

% Fix the 2d spectral file for each timestep.
for jj=1:length(out2d.t)
    for ii=1:length(dxb_fix)
        Sxb(:,ii,jj)=Sfix(:,xbind(ii),jj);
    end
end

SS = struct('t',out2d.t,'f',out2d.f,'d',dxb_fix,'S',Sxb); 

% Write formatted variance density spectrum file for each time and overall 
% FILELIST to be read in with the 'bcfile' command.
write2DXbeachSpec(SS,mopid,sdur,tstep);

