function varargout = ddb_computeNourishment(varargin)
%COMPUTENOURISHMENT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = computeNourishment(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   computeNourishment
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ormondt
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 May 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ddb_computeNourishment.m 12949 2016-10-24 13:51:52Z nederhof $
% $Date: 2016-10-24 21:51:52 +0800 (Mon, 24 Oct 2016) $
% $Author: nederhof $
% $Revision: 12949 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nourishments/ddb_computeNourishment.m $
% $Keywords: $

%%

handles=getHandles;

%% Parameters

% Numerical and physical parameters
par.cE=handles.toolbox.nourishments.equilibriumConcentration;
par.nfac=2;
par.d=handles.toolbox.nourishments.diffusionCoefficient; % Diffusion
par.ws=handles.toolbox.nourishments.settlingVelocity; % Diffusion
par.morfac=1000;
par.cdryb=1600;

% Time parameters
nyear=handles.toolbox.nourishments.nrYears;
toutp=handles.toolbox.nourishments.outputInterval; % years
t0=0;
t1=nyear*365*86400/par.morfac;

tmorph=0;
dt=60; % seconds
t=t0:dt:t1;
nt=length(t);
par.dt=dt;

ntout=round(toutp*365*86400/dt/par.morfac);

%% Grid and bathymetry

xlim=handles.toolbox.nourishments.xLim;
ylim=handles.toolbox.nourishments.yLim;
dx=handles.toolbox.nourishments.dX;
dy=handles.toolbox.nourishments.dX;
xx=xlim(1):dx:xlim(2);
yy=ylim(1):dy:ylim(2);
[xg,yg]=meshgrid(xx,yy);

[xb,yb,zb,ok]=ddb_getBathymetry(handles.bathymetry,xlim,ylim,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dx);

zz=interp2(xb,yb,zb,xg,yg);

[grd,dps]=getgridinfo('gridx',xg,'gridy',yg,'depth',zz);

%% Apply nourishments

nourdep=zeros(size(dps));

for ipol=1:handles.toolbox.nourishments.nrNourishments
    
    xpol=handles.toolbox.nourishments.nourishments(ipol).polygonX;
    ypol=handles.toolbox.nourishments.nourishments(ipol).polygonY;
    inpol=inpolygon(grd.xg,grd.yg,xpol,ypol);
    polarea=polyarea(xpol,ypol);
    
    switch handles.toolbox.nourishments.nourishments(ipol).type
        case{'volume'}
            nourhgt=handles.toolbox.nourishments.nourishments(ipol).volume/polarea;
            nourdep(inpol)=nourhgt;
        case{'height'}
            nourdep(inpol)=handles.toolbox.nourishments.nourishments(ipol).height-dps(inpol);
        case{'thickness'}
            nourdep(inpol)=handles.toolbox.nourishments.nourishments(ipol).thickness;
    end
    
end

sedthick=nourdep;

%% Equilibrium concentration
par.cE=zeros(size(grd.xg))+par.cE;
for ipol=1:handles.toolbox.nourishments.nrConcentrationPolygons
    xpol=handles.toolbox.nourishments.concentrationPolygons(ipol).polygonX;
    ypol=handles.toolbox.nourishments.concentrationPolygons(ipol).polygonY;
    inpol=inpolygon(grd.xg,grd.yg,xpol,ypol);
    par.cE(inpol)=handles.toolbox.nourishments.concentrationPolygons(ipol).concentration;    
end
ceplot=par.cE; % Only used for plotting

%% Residual currents

switch lower(handles.toolbox.nourishments.currentSource)
    case{'file'}
        % Load mat file with currents
        s=load(handles.toolbox.nourishments.currentsFile);        
        xx=s.x(~isnan(s.x));
        yy=s.y(~isnan(s.y));
        uu=s.u(~isnan(s.u));
        vv=s.v(~isnan(s.v));
        % Interpolate onto grid
        u=griddata(xx,yy,uu,grd.xg,grd.yg);
        v=griddata(xx,yy,vv,grd.xg,grd.yg);
        u(isnan(u))=0;
        v(isnan(v))=0;        
    otherwise
        u=zeros(size(grd.xg))+handles.toolbox.nourishments.currentU;
        v=zeros(size(grd.xg))+handles.toolbox.nourishments.currentV;        
end

ug=u;
vg=v;

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
nourdep=reshape(nourdep,[1 np]);
wl=zeros(size(c))+0;

par.cE=reshape(par.cE,[1 np]);

%% Initial equilibrium water depth

dps=dps-2;

he=wl-dps;
he=max(he,0.01);

dps=dps+nourdep;


sedthick0=sedthick;

xl=[min(min(grd.xg))+handles.toolbox.nourishments.dX max(max(grd.xg))];
yl=[min(min(grd.yg))+handles.toolbox.nourishments.dX max(max(grd.yg))];


figure(999)
clf;

mxthick=ceil(max(max(nourdep)));
mndep=floor(min(min(dps)));
mxdep=ceil(max(max(dps)));

output.time=[];
output.bedlevel=[];
output.concentration=[];
output.concentration=[];

output.datasets(1).name='bed level';
output.datasets(1).unit='m';
output.datasets(1).location='cellcentres';
output.datasets(1).data.x=grd.xg;
output.datasets(1).data.y=grd.yg;
output.datasets(1).data.val=[];
output.datasets(1).data.time=[];

output.datasets(2).name='concentration';
output.datasets(2).unit='g/l';
output.datasets(2).location='cellcentres';
output.datasets(2).data.x=grd.xg;
output.datasets(2).data.y=grd.yg;
output.datasets(2).data.val=[];
output.datasets(2).data.time=[];

output.datasets(3).name='nourishment thickness';
output.datasets(3).unit='m';
output.datasets(3).location='cellcentres';
output.datasets(3).data.x=grd.xg;
output.datasets(3).data.y=grd.yg;
output.datasets(3).data.val=[];
output.datasets(3).data.time=[];

output.datasets(4).name='sedimentation/erosion';
output.datasets(4).unit='m';
output.datasets(4).location='cellcentres';
output.datasets(4).data.x=grd.xg;
output.datasets(4).data.y=grd.yg;
output.datasets(4).data.val=[];
output.datasets(4).data.time=[];

output.datasets(5).name='residual currents';
output.datasets(5).unit='m/s';
output.datasets(5).location='cellcorners';
output.datasets(5).data.x=grd.xg;
output.datasets(5).data.y=grd.yg;
output.datasets(5).data.u=ug;
output.datasets(5).data.v=vg;
output.datasets(5).data.time=[];

%% Start of computational code

itout=0;

tref=datenum(2012,1,1);
refvec=datevec(tref);

for it=1:nt
%    disp([num2str(it) ' of ' num2str(nt)])
    t(it)=(it-1)*dt;
    updbed=0;
    if t(it)>=tmorph
        updbed=1;
    end
    if t(it)==tmorph
        cmorphstart=c;
        sedvol0=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb;
        thckvol0=10000*nansum(sedthick);
    end
    
    [c,dps,sedthick,srcsnk]=difu4(c,wl,dps,sedthick,he,u,v,grd,par,updbed);

    if it==1 || round(it/ntout)==it/ntout || it==nt
        
        itout=itout+1;
    
        figure(999)
        
        c1=reshape(c,[grd.ny grd.nx]);
        dps1=reshape(dps,[grd.ny grd.nx])+2;
        dps2=dps-par.morfac*c.*-dps/par.cdryb;
        dps2=dps;
        
        if it==1
            dps0=dps2;
            dps0=reshape(dps0,[grd.ny grd.nx])+2;
        end
        
        dps2=reshape(dps2,[grd.ny grd.nx])+2;
%        dps2=reshape(dps2,[grd.ny grd.nx]);
        
        sedthick1=reshape(sedthick,[grd.ny grd.nx]);
        
        sedthick2=sedthick+par.morfac*(c-par.cE).*-dps/par.cdryb;
        sedthick2=reshape(sedthick2,[grd.ny grd.nx]);
        srcsnk1=reshape(srcsnk,[grd.ny grd.nx]);
        
        tyear=round(t(it)*par.morfac/86400/365);
                
        subplot(2,2,1)        
        pcolor(grd.xg,grd.yg,dps2-dps0);shading flat;axis equal; clim([-mxthick-0.1 mxthick+0.1]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        for ipol=1:handles.toolbox.nourishments.nrNourishments
            pol=plot(handles.toolbox.nourishments.nourishments(ipol).polygonX,handles.toolbox.nourishments.nourishments(ipol).polygonY,'r');
            set(pol,'LineWidth',2);
        end
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['Sedimentation / erosion - ' num2str(tyear,'%i') ' years']);
%        drawnow;
        
%         subplot(2,2,2)        
%         pcolor(grd.xg,grd.yg,c1);shading flat;axis equal;clim([0 1]);colorbar;
%         hold on;
%         quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
%         pol=plot(handles.toolbox.nourishments.polygonX,handles.toolbox.nourishments.polygonY,'r');
%         set(pol,'LineWidth',2);
%         axis equal;
%         set(gca,'xlim',xl,'ylim',yl);
%         title(['concentration - ' num2str(tyear,'%i') ' years']);
        
        subplot(2,2,2)        
        pcolor(grd.xg,grd.yg,sedthick2);shading flat;axis equal;clim([0 mxthick]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        for ipol=1:handles.toolbox.nourishments.nrNourishments
            pol=plot(handles.toolbox.nourishments.nourishments(ipol).polygonX,handles.toolbox.nourishments.nourishments(ipol).polygonY,'r');
            set(pol,'LineWidth',2);
        end
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['Nourishment thickness - ' num2str(tyear,'%i') ' years']);

        subplot(2,2,3)
        pcolor(grd.xg,grd.yg,dps2);shading flat;axis equal;clim([-5 2]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        for ipol=1:handles.toolbox.nourishments.nrNourishments
            pol=plot(handles.toolbox.nourishments.nourishments(ipol).polygonX,handles.toolbox.nourishments.nourishments(ipol).polygonY,'r');
            set(pol,'LineWidth',2);
        end
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['Bed level - ' num2str(tyear,'%i') ' years']);

        subplot(2,2,4)        
        pcolor(grd.xg,grd.yg,ceplot);shading flat;axis equal;clim([0 0.05]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        for ipol=1:handles.toolbox.nourishments.nrNourishments
            pol=plot(handles.toolbox.nourishments.nourishments(ipol).polygonX,handles.toolbox.nourishments.nourishments(ipol).polygonY,'r');
            set(pol,'LineWidth',2);
        end
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title('Equilibrium concentration');
                
        drawnow;

        tvec=refvec;
        tvec(1)=tvec(1)+tyear;

        output.datasets(1).data.val(itout,:,:)=dps2;
        output.datasets(1).data.time(itout)=datenum(tvec);
        
        output.datasets(2).data.val(itout,:,:)=ceplot;
        output.datasets(2).data.time(itout)=datenum(tvec);

        output.datasets(3).data.val(itout,:,:)=sedthick2;
        output.datasets(3).data.time(itout)=datenum(tvec);

        output.datasets(4).data.val(itout,:,:)=dps2-dps0;
        output.datasets(4).data.time(itout)=datenum(tvec);

    end
end

fname='nour.mat';
save(fname,'-struct','output');

sedvol1=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb
thckvol1=10000*nansum(sedthick)
dvol=10000*nansum(sedthick-sedthick0)+nansum((c-cmorphstart).*-dps)*par.morfac*10000/par.cdryb
