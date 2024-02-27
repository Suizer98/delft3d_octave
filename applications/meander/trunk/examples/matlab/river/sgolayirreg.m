function [y0,y1,y2,y0m] = sgolayirreg(x,y,degree,halfwindowsize);
% [y0,y1,y2,y0m] = SGOLAYIRREG(x,y,degree,halfwin);
% Perform Savitsky-Golay filtering for irregularly spaced data
%
% Example usage:
% x=[0:0.01:2]+0.025*rand(size([0:0.05:2]));
% y=sin(pi*[0:0.05:2])+0.025*rand(size([0:0.05:2]));
%
% [y0,y1,y2,y0m] = sgolayirreg(x,y,3,7);
% plot(x,y,'r.',x,y0)
%
% Output: 0-th, 1-st and 2nd derivative of y with respect to x. 
% 
% Copyright (C) 2016 Willem Ottevanger
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.

nmax =length(x);
xe = [x(1)+[-halfwindowsize:-1]*(x(2)-x(1)),x,x(end)+[1:halfwindowsize]*(x(end)-x(end-1))];
ye = [y(1)+[-halfwindowsize:-1]*(y(2)-y(1)),y,y(end)+[1:halfwindowsize]*(y(end)-y(end-1))];
for k = 1+halfwindowsize:nmax+halfwindowsize;
    nl = k-halfwindowsize;%max(1,k-halfwin);
    nr = k+halfwindowsize;%min(nmax+halfwin,k+halfwin);
    p = polyfit(xe(nl:nr),ye(nl:nr),degree);
    y0(k-halfwindowsize) = polyval(p,xe(k));
    p1 = polyder(p);
    p2 = polyder(p1);
    y1(k-halfwindowsize) = polyval(p1,xe(k));
    y2(k-halfwindowsize) = polyval(p2,xe(k));
    y0L(k-halfwindowsize) = polyval(p,xe(k)-0.5*(xe(k)-xe(k-1)));
    y0R(k-halfwindowsize) = polyval(p,xe(k)+0.5*(xe(k+1)-xe(k)));
end
y0m=0.5*(y0L(2:nmax)+y0R(1:nmax-1));
% figure(1);
% plot(x,y,'b-',x,ps,'r-')
% %
% figure(2);
% xm = 0.5*x(1:end-1)+0.5*x(2:end);
% %plot(x,ps,x,ps1,x,ps2);
% plot(xm,diff(y)./diff(x),x,ps1,'r-')
% figure(3);
% xmm = 0.5*xm(1:end-1)+0.5*xm(2:end);
% plot(xmm,diff(diff(y)./diff(x))./diff(xm),x,ps2,'r-')

