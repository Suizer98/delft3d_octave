function [sumzi,zi]=optiGriddata(this,x,y,z,lx,ly);

%OPTIGRIDDATA - transect interpolation based on griddata

d=1e4;
xi=lx(1):diff(lx)/d:lx(2);
yi=ly(1):diff(ly)/d:ly(2);
dxy=sqrt((diff(lx)/d).^2+(diff(ly)/d).^2);

idnan=(isnan(x)|isnan(y));

% zi=griddata(x(~idnan),y(~idnan),z(~idnan),xi,yi)/dxy;
zi=griddata(x(~idnan),y(~idnan),z(~idnan),xi,yi);
%Multiply by section length
zi=zi*dxy;
%And sum
sumzi=sum(zi);