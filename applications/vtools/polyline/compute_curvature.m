%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: compute_curvature.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/compute_curvature.m $
%
%This is based on Willem's work. It computes the curvature. 
%
%
%INPUT
%   -
%
%E.G. 
% curved.X=x_c;
% curved.Y=y_c;
% 
% curved.S = [0;cumsum(sqrt(diff(curved.X).^2+diff(curved.Y).^2))];
% 
% st = 0:curved.S(end)/423:curved.S(end);
% sx = spline(curved.S,curved.X,st);
% sy = spline(curved.S,curved.Y,st);
% 
% [sC0, iR0, ang0] = getcurv2(sx,sy,sx,sy);

function [sC0, iR0, angC0] = compute_curvature(xL,yL,xR,yR)

degree = 4;
halfwin = 11;
intnum = 1;

l = [0,0.5*cumsum(sqrt(diff(xL).^2+diff(yL).^2))+0.5*cumsum(sqrt(diff(xR).^2+diff(yR).^2))];

cx = spline(l,xR);
cy = spline(l,yR);
    %ll = 1:0.05:length(Dx);
for k = 2:length(l)
   ll(intnum*(k-2)+1:intnum*(k-1)+1)=l(k-1):(l(k)-l(k-1))/intnum:l(k); 
end
xcR = ppval(cx,ll);
ycR = ppval(cy,ll);

cx = spline(l,xL);
cy = spline(l,yL);
    %ll = 1:0.05:length(Dx);
for k = 2:length(l)
   ll(intnum*(k-2)+1:intnum*(k-1)+1)=l(k-1):(l(k)-l(k-1))/intnum:l(k); 
end
xcL = ppval(cx,ll);
ycL = ppval(cy,ll);
xC = 0.5*xcL+0.5*xcR;
yC = 0.5*ycL+0.5*ycR;
sC=[0,cumsum(sqrt(diff(xC).^2+diff(yC).^2))];
[xC0,xC1,xC2,xm0] = sgolayirreg(sC,xC,degree,halfwin);
[yC0,yC1,yC2,ym0] = sgolayirreg(sC,yC,degree,halfwin);
% plot(xC(1:end),yC(1:end),'.',xC0,yC0,'r.',xm0,ym0,'rx')
sC0=sC;%[0,cumsum(sqrt(diff(xC0).^2+diff(yC0).^2))];
zt = (xC1.^2 + yC1.^2);
iR0 = sign(yC1.*xC2 - xC1.*yC2).*sqrt(zt.*(xC2.^2 + yC2.^2)-((xC1.*xC2+yC1.*yC2).^2))./(zt.^(3/2));
angC0 = angle((yC1-i*xC1));
%plot(sC0,iR0)
