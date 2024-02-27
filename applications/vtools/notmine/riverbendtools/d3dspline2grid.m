function grd = d3dspline2grid(x,y,width,m,n);
% D3DSPLINE2GRID makes grid with a certain width based on a single spline.
%
% syntax:
% [grd] = d3dspline2grid(x,y,width,m,n)
%
% input:
% x          - vector containing x coordinates of spline (centreline)
% y          - vector containing x coordinates of spline (centreline)
% width      - width of the new grid. 
% m          - number of grid cells over the length
% n          - number of grid cells over the width
%
% output:
% grd.X   - X data of the grid.
% grd.Y   - Y data of the grid
%
% example:
% grd = d3dspline2grid([3:12].*sin([3:12]), [3:12].*cos([3:12]),1.1,50,7);
% 
% See also wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2009 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Last edited: 23-06-09
% -------------------------------------------------------------------------

%%
if nargin == 5;
   plotswitch = 0;
end
%% First interpolate points to spline.
x  = x(:); y = y(:);
l  = 1:length(x);
cx = spline(l,x);
cy = spline(l,y);
ll = 1:0.1:length(x);
xs = ppval(cx,ll);
ys = ppval(cy,ll);
dd = cumsum(sqrt([0,diff(xs).^2+diff(ys).^2]));
di = 0:dd(end)/(m-1):dd(end);
ld = interp1(dd,ll,di);
xd = ppval(cx,ld);
yd = ppval(cy,ld);
xdl = xd(1)   - diff(xd(1:2));
xdr = xd(end) + diff(xd(end-1:end));
ydl = yd(1)   - diff(yd(1:2));
ydr = yd(end) + diff(yd(end-1:end));
xde = [xdl,xd,xdr];
yde = [ydl,yd,ydr];
ang = angle((xde(3:end)-xde(1:end-2))+i*(yde(3:end)-yde(1:end-2)));

for k = 1:n
   wk = width*((k-1)-(n-1)/2)/(n-1); 
   grd.X(1:m,k) = xd + real(wk*exp(i*(ang+pi/2)));
   grd.Y(1:m,k) = yd + imag(wk*exp(i*(ang+pi/2)));
end

%%
% hold on;
% plot(grd.x,grd.y,'b-',grd.x',grd.y','b-',x,y,'ro',xs,ys,'r-');  %,xs,ys,'-',xde,yde,'-x'
% %plot3(xd,yd,ang)
% axis equal;


