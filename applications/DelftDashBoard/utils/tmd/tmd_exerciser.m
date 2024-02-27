%========================================================================
% tmd_exerciser.m
%
% This file runs through a few uses of script access to TMD-formatted
%   tide models, just to see if they work, and to show the use of various
%   scripts.
%
% Inputs:   none
%
% Sample call:  tmd_exerciser;
%
% Written by:   Laurie Padman (ESR): padman@esr.org
%               September 30, 2004
%
%========================================================================

% Some routines are sensitive to the Matlab version you are running. So,
%   first interrogate Matlab for version number.
OS_info=version;
matver=OS_info(1);

% Select the model to test
[fname,fpath] = uigetfile('Model*','File to process ...');
if(~fname) % user pressed Cancel in file dialog box
    return;
end;

% Access model bathymetry (water column thickness under ice shelves)
Model=fullfile(fpath,fname);
[x,y,H]=get_bathy(Model);
long=x; latg=y; 
loc=find(H==0); H(loc)=NaN;
figure(1);
pcolor(long,latg,H');shading flat; colorbar
title(['Model bathymetry/wct for ' Model],'FontSize',15,...
    'Interpreter','none');
disp(' ');
disp('Use mouse to select point in domain for testing tide_pred')
disp('  and extract_hc.  Put cursor over point, and left-click.')
disp(' ')
[lon,lat]=ginput(1);
hold on
plot(lon,lat,'rp','MarkerSize',12);

% Speed up future plotting by only doing a small area around the selected 
%   point. Try for something like a 200 x 200 point array.
ix_max=200; iy_max=200;
ixh=round(ix_max/2); iyh=round(iy_max/2);
axlim=[min(x) max(x) min(y) max(y)];
dx=x(2)-x(1); dy=y(2)-y(1);
indx=round((lon-min(x))/dx)+1;
indy=round((lat-min(y))/dy)+1;
ix1=max([(indx-ixh) 1]); ix2=min([(indx+ixh) length(x)]); 
iy1=max([(indy-iyh) 1]); iy2=min([(indy+iyh) length(y)]); 

% Exercise EXTRACT_HC
% Grab harmonic constants for a specified Model, variable, and lat/lon
[amp,Gph,depth,constit]=extract_HC(Model,lat,lon,'z');
[r,c]=size(constit);
disp('Exercising EXTRACT_HC')
disp('Constit    Amp       Phase')
for i=1:r
    disp([constit(i,:) '      ' num2str(amp(i),'%6.2f') '    ' ...
          num2str(Gph(i),'%7.2f')]);
end
disp(' ')
disp(['Model depth = ' num2str(depth)]);
disp('If you get NaN values, check whether model lon limits at (-180,+180)')
disp('  or (0,+360).');

% Exercise TIDE_PRED
disp(' '); disp(' ');
disp('Exercising TIDE_PRED: should produce Figure 2 plot of u & v.')
% Predict model tide height or velocity components for a given time.
% Do hourly prediction for 31 days starting December 1, 2004;
t_0=datenum(2004,12,1);
time=t_0+(0:(31*24))/24;
[u,constit]=tide_pred(Model,time,lat,lon,'u');
[v,constit]=tide_pred(Model,time,lat,lon,'v');
figure(2)
subplot(2,1,1); 
plot(time-t_0,u,'r','LineWidth',2);
grid on
xlabel('Time, days since start 2004')
ylabel('u (E/W) current (cm/s)')
subplot(2,1,2); 
plot(time-t_0,v,'b','LineWidth',2);
grid on
xlabel('Time, days since start 2004')
ylabel('v (N/S) current (cm/s)')

% Exercise ELLIPSE
disp(' '); disp(' ');
disp('Exercising ELLIPSE: should return ellipse properties for K1.')
% Returns tidal current ellipse parameters for a specified location and
%   constituent
constit='k1';
[umaj,umin,uph,uinc]=ellipse(Model,lat,lon,constit);
disp(['Ellipse properties for ' constit ' at lat/lon = ' ...
      num2str(lat) '/' num2str(lon)]);
disp(['Umaj        = ' num2str(umaj)]);
disp(['Umin        = ' num2str(umin)]);
disp(['Inclination = ' num2str(uinc)]);
disp(['Phase       = ' num2str(uph)]);

% Exercise GET_COEFF
% Returns map of tidal amplitudes and phases for a specified constituent.
disp(' '); disp(' ');
disp('Exercising GET_COEFF: should create Figure 3: amplitude and phase')
disp('Note that TMD convention requires transposing grids for plotting.')
[x,y,amp,phase]=get_coeff(Model,'z','m2');
loc=find(amp<=0);
amp(loc)=NaN; phase(loc)=NaN;
% Trim grid for quicker plotting
xp    =     x(ix1:ix2); 
yp    =     y(iy1:iy2);
amp   =   amp(ix1:ix2,iy1:iy2);
phase = phase(ix1:ix2,iy1:iy2);
H     =     H(ix1:ix2,iy1:iy2);

figure(3); orient tall
subplot(2,1,1);
pcolor(xp,yp,amp'); shading flat; colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    [h,c]=contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    [h,c]=contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

subplot(2,1,2);
pcolor(xp,yp,phase'); shading flat; colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

% Exercise GET_ELLIPSE
% Returns map of tidal ellipse properties for a specified constituent.
disp(' '); disp(' ');
disp('Exercising GET_ELLIPSE: should create Figure 4: umaj, umin, orientation, phase')
disp('Note that TMD convention requires transposing grids for plotting.')
[x,y,umaj,umin,uphase,uincl]=get_ellipse(Model,'k1');

% Trim grid for quicker plotting
xp     =      x(ix1:ix2); 
yp     =      y(iy1:iy2);
umaj   =   umaj(ix1:ix2,iy1:iy2);
umin   =   umin(ix1:ix2,iy1:iy2);
uphase = uphase(ix1:ix2,iy1:iy2);
uincl  =  uincl(ix1:ix2,iy1:iy2);

loc=find(umaj<=0);    % Set land values to NaN;
umaj(loc)=NaN; umin(loc)=NaN; uphase(loc)=NaN; uincl(loc)=NaN;

figure(4); orient tall
subplot(2,2,1);
pcolor(xp,yp,umaj'); shading flat; caxis([0 20]);colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    [h,c]=contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    [h,c]=contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,2);
pcolor(xp,yp,umin'); shading flat; caxis([-20 20]);colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    [h,c]=contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    [h,c]=contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,3);
pcolor(xp,yp,uphase'); shading flat; colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    [h,c]=contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    [h,c]=contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,4);
pcolor(xp,yp,uincl'); shading flat; colorbar; hold on
clim=get(gca,'CLim');
if(matver==7);
    [h,c]=contour('v6',xp,yp,H',[500 1000 2000],'w');
else
    [h,c]=contour(xp,yp,H',[500 1000 2000],'w');
end
set(c,'LineWidth',1);
caxis(clim);

disp(' '); disp(' ');
disp('Finished TMD_EXERCISER')