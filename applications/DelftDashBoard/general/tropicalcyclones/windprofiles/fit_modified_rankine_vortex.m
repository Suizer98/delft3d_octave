function [xopt,aopt,theta0opt]=fit_modified_rankine_vortex(vmax,rmax,robs,tobs,vobs)

% clear variables;close all;
% 
% 
% rmax=20;
% vmax=60;
% 
% a=10;
% theta0=30;
% x=2;
% 
% 
% robs=[100 150 150 100];
% tobs=[45 135 225 315];
% vobs=[20 20 20 20];

r=robs;
theta=tobs*pi/180;

rmsemax=1e9;
np=10000;
xi=rand(1,np)*3;
ai=rand(1,np)*50;
theta0i=rand(1,np)*360;
for ii=1:np
    x=xi(ii);
    a=ai(ii);
    theta0=theta0i(ii);
%     theta=theta*pi/180;
    vr=modified_rankine_vortex(r,theta,vmax,rmax,x,a,theta0);
    rmse=sqrt(mean((vr-vobs).^2));
    if rmse<rmsemax
        imin=ii;
        rmsemax=rmse;
    end
end

% r=0:1:500;
% theta=0:10:360;
% theta=theta*pi/180;
% [r,theta]=meshgrid(r,theta);
% xx=r.*cos(theta);
% yy=r.*sin(theta);
% 
% vr=modified_rankine_vortex(r,theta,vmax,rmax,xi(imin),ai(imin),theta0i(imin));

xopt=xi(imin);
aopt=ai(imin);
theta0opt=theta0i(imin);

% figure(1)
% pcolor(xx,yy,vr);shading flat;axis equal;colorbar;
% 
% xobs=robs.*cos(tobs*pi/180);
% yobs=robs.*sin(tobs*pi/180);
% hold on
% p=scatter(xobs,yobs,50,vobs,'filled');
% set(p,'MarkerEdgeColor','k');
% %plot(r,vr);