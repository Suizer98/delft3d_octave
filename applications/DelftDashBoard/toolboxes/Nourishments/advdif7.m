clear variables;close all;

%% Parameters

% Numerical and physical parameters
par.cE=0.02;
par.nfac=2;
par.d=10; % Diffusion
par.ws=0.02;
par.morfac=1000;
par.cdryb=1600;

% Time parameters
nyear=2;
toutp=1; % years
t0=0;
t1=nyear*365*86400/par.morfac;

tmorph=0;
dt=60; % seconds
t=t0:dt:t1;
nt=length(t);
itmorph=tmorph/dt;
par.dt=dt;

ntout=round(toutp*365*86400/dt/par.morfac);

%% Grid and bathymetry
% File names
grdfile='oos.grd';
depfile='oos.dep';
[grd,dps]=getgridinfo(grdfile,depfile);

%% Nourishment
polyfile='test.pol';
nourdep=zeros(size(dps));
nourdep(15:20,50:55)=2;
sedthick=nourdep;

%% Residual currents
% Interpolate onto grid
s=load('oosterschelde.mat');
xx=s.x(~isnan(s.x));
yy=s.y(~isnan(s.y));
uu=s.u(~isnan(s.u));
vv=s.v(~isnan(s.v));
u=griddata(xx,yy,uu,grd.xg,grd.yg);
v=griddata(xx,yy,uu,grd.xg,grd.yg);
u(isnan(u))=0;
v(isnan(v))=0;
% u=zeros(size(grd.xg))+0.0;
% v=zeros(size(grd.xg))+0.0;

%% Initial conditions
c=zeros(size(grd.xg))+par.cE;

%% Put everything in 1D vectors
np=grd.nx*grd.ny;
u=reshape(u,[1 np]);
v=reshape(v,[1 np]);
c=reshape(c,[1 np]);
dps=reshape(dps,[1 np]);
sedthick=reshape(sedthick,[1 np]);
grd.dx=reshape(grd.dx,[1 np]);
grd.dy=reshape(grd.dy,[1 np]);
grd.a=reshape(grd.a,[1 np]);
% volum1=reshape(volum1,[1 np]);
% kfu=reshape(kfu,[1 np]);
% kfv=reshape(kfv,[1 np]);
% kcs=reshape(kcs,[1 np]);
nourdep=reshape(nourdep,[1 np]);
wl=zeros(size(c))+0;
ce=zeros(size(c))+par.cE;

%% Initial equilibrium water depth

dps=dps-2;

he=wl-dps;
he=max(he,0.01);

dps=dps+nourdep;

dps0=dps;
sedthick0=sedthick;

xl=[min(min(grd.xg)) max(max(grd.xg))];
yl=[min(min(grd.yg)) max(max(grd.yg))];
%% Start of computational code
for it=1:nt
    disp([num2str(it) ' of ' num2str(nt)])
    t(it)=(it-1)*dt;
    updbed=0;
    if t(it)>=tmorph
        updbed=1;
    end
    if t(it)==tmorph
        cmorphstart=c;
        sedvol0=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb
        thckvol0=10000*nansum(sedthick)
    end
    
    [c,dps,sedthick,srcsnk]=difu4(c,wl,dps,sedthick,he,u,v,grd,par,updbed);
    
    if it==1 || round(it/ntout)==it/ntout || it==nt
        c1=reshape(c,[grd.ny grd.nx]);
        dps1=reshape(dps,[grd.ny grd.nx])+2;
        dps2=dps-par.morfac*c.*-dps/par.cdryb;
        dps2=reshape(dps2,[grd.ny grd.nx])+2;
        
        sedthick1=reshape(sedthick,[grd.ny grd.nx]);
        
        sedthick2=sedthick+par.morfac*(c-par.cE).*-dps/par.cdryb;
        sedthick2=reshape(sedthick2,[grd.ny grd.nx]);
        srcsnk1=reshape(srcsnk,[grd.ny grd.nx]);
        
        tyear=round(t(it)*par.morfac/86400/365);
        
        figure(1)
        subplot(2,2,1)        
        pcolor(grd.xg,grd.yg,srcsnk1);shading flat;axis equal;colorbar;
        hold on;
        quiver(s.x,s.y,s.u,s.v,'k');
        set(gca,'xlim',xl);
        title([num2str(tyear,'%i') 'years']);
        subplot(2,2,2)        
        pcolor(grd.xg,grd.yg,c1);shading flat;axis equal;clim([0 1]);colorbar;
        hold on;
        quiver(s.x,s.y,s.u,s.v,'k');
        set(gca,'xlim',xl);
        subplot(2,2,3)        
        pcolor(grd.xg,grd.yg,sedthick2);shading flat;axis equal;clim([0 1]);colorbar;
        hold on;
        quiver(s.x,s.y,s.u,s.v,'k');
        set(gca,'xlim',xl);
        subplot(2,2,4)
        pcolor(grd.xg,grd.yg,dps2);shading flat;axis equal;clim([-20 2]);colorbar;
        hold on;
        quiver(s.x,s.y,s.u,s.v,'k');
        set(gca,'xlim',xl);
        drawnow;
    end
end
sedvol1=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb
thckvol1=10000*nansum(sedthick)
dvol=10000*nansum(sedthick-sedthick0)+nansum((c-cmorphstart).*-dps)*par.morfac*10000/par.cdryb
% c=reshape(c,[grd.ny grd.nx]);
% dps=reshape(dps,[grd.ny grd.nx]);
% pcolor(grd.x,grd.y,dps);

% dmasssus=par.morfac*(tsm(end)-tsm(itmorph));
% dsedero=totsedero(end);
% 
% disp(dmasssus)
% disp(dsedero)
