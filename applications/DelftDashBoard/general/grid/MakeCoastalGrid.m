function [x y z] = MakeCoastalGrid(xs, ys, xb, yb, zb, yoff, dx, dymin, dymax, dt, c, nsmooth, drel)
%MAKECOASTALGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x y z] = MakeCoastalGrid(xs, ys, xb, yb, zb, yoff, dx, dymin, dymax, dt, c, nsmooth, drel)
%
%   Input:
%   xs      =
%   ys      =
%   xb      =
%   yb      =
%   zb      =
%   yoff    =
%   dx      =
%   dymin   =
%   dymax   =
%   dt      =
%   c       =
%   nsmooth =
%   drel    =
%
%   Output:
%   x       =
%   y       =
%   z       =
%
%   Example
%   MakeCoastalGrid
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

dy=2;

ny=floor(yoff/dy)+1;

pd=pathdistance(xs,ys);
xp=pd(1):dx:pd(end)+dx;
xc = spline(pd,xs,xp);
yc = spline(pd,ys,xp);

pd=pathdistance(xc,yc);
xp=pd(1):dx:pd(end);
xc = spline(pd,xc,xp);
yc = spline(pd,yc,xp);

nx=length(xc);

% Compute coastline angle
for i=2:nx-1;
    anga=atan2(yc(i+1)-yc(i),  xc(i+1)-xc(i));
    angb=atan2(yc(i)  -yc(i-1),xc(i  )-xc(i-1));
    ang(i)=0.5*(anga+angb)+0.5*pi;
end
ang(1)=ang(2);
ang(nx)=ang(nx-1);

for i=1:nx
    for j=1:ny
        xg(i,j)=xc(i)+cos(ang(i))*dy*(j-1);
        yg(i,j)=yc(i)+sin(ang(i))*dy*(j-1);
    end
end


z=interp2(xb,yb,zb,xg,yg);

for j=1:ny
    %    davg(j)=mean(z(:,j));
    davg(j)=nanmean(z(:,j));
    davg(j)=max(-davg(j),1);
    % Depth relation
    dy1(j)=davg(j)*drel;
    % Courant criterion
    v=sqrt(9.81*davg(j));
    dy1(j)=min(c*dt/v,dy1(j));
    % Set limits
    dy1(j)=min(dy1(j),dymax);
    dy1(j)=max(dy1(j),dymin);
end

y0=0:dy:(ny-1)*dy;

yy=0;
j=0;
while yy<yoff
    j=j+1;
    ddy(j)=interp1(y0,dy1,yy);
    if j>1
        % Ensure smoothness
        ddy(j)=min(ddy(j),ddy(j-1)*nsmooth);
    end
    yy=yy+ddy(j);
end
ny=j;

xg=xg(:,1);
yg=yg(:,1);

for i=1:nx
    for j=2:ny
        xg(i,j)=xg(i,j-1)+cos(ang(i))*ddy(j);
        yg(i,j)=yg(i,j-1)+sin(ang(i))*ddy(j);
    end
end

x=xg;
y=yg;
z=interp2(xb,yb,zb,x,y);

