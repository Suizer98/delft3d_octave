function [s,iR,ang,sn] = spline2R(x,y)
% SPLINE2R returns path length and radius of curvature based on a single spline.
%
% syntax:
% [s,iR,ang,sn] = spline2R(x,y)
%
% input:
% x          - vector containing x coordinates of spline (centreline)
% y          - vector containing y coordinates of spline (centreline)
%
% output:
% s          - vector containing path distance
% iR         - vector containing inverse Radius of curvature (centreline)
% ang        - vector containing the local angle change
% sn         - vector containing the sign of the curvature
%
% example:
% [s,iR,ang,sn] = spline2R([3:12].*sin([3:12]), [3:12].*cos([3:12]));
%
% -------------------------------------------------------------------------
%  Copyright (C) 2009 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  
%    Last edited: 02-10-09
% -------------------------------------------------------------------------

%%
vc = 3;
x = x(:);
y = y(:);

[x,y,h2,q2,asR2] = spline3bc(x,y,0*x,0*x,0*x);
%[x,y] = splinebc(x,y);

ds = sqrt([diff(x).^2+diff(y).^2]);
s = cumsum([0;ds]);

cx = spapi(vc,s,x);
cy = spapi(vc,s,y);
x1 = fnval(fnder(cx,1),s);
y1 = fnval(fnder(cy,1),s);
x2 = fnval(fnder(cx,2),s);
y2 = fnval(fnder(cy,2),s);
zt = (x1.^2 + y1.^2);
iR = sqrt(zt.*(x2.^2 + y2.^2)-((x1.*x2+y1.*y2).^2))./(zt.^(3/2));
sn = sign(y1.*x2 - x1.*y2);
ang = angle((y1-i*x1).*sn);

s   = s(4:end-3)-s(4);
sn  = sn(4:end-3);
ang = ang(4:end-3);
iR  = iR(4:end-3);

%Debug test 1:
%s2 = [s(1):0.1:s(end)-0.1,s(end)];
%xp = fnval(cx,s2);
%yp = fnval(cy,s2);
%plot(xp,yp,x,y,'b.');

