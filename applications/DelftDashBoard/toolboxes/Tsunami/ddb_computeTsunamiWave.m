function [xg yg zg] = ddb_computeTsunamiWave(xs, ys, depths, dips, wdts, sliprakes, slips)
%DDB_COMPUTETSUNAMIWAVE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [xg yg zg] = ddb_computeTsunamiWave(xs, ys, depths, dips, wdts, sliprakes, slips)
%
%   Input:
%   xs        =
%   ys        =
%   depths    =
%   dips      =
%   wdts      =
%   sliprakes =
%   slips     =
%
%   Output:
%   xg        =
%   yg        =
%   zg        =
%
%   Example
%   ddb_computeTsunamiWave
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_computeTsunamiWave.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/ddb_computeTsunamiWave.m $
% $Keywords: $

%%
degrad=pi/180;

pd=pathdistance(xs,ys);
dx=pd(end)/10;

xp=pd(1):dx:pd(end);
xc = spline(pd,xs,xp);
yc = spline(pd,ys,xp);
depth=spline(pd,depths,xp);
dip=spline(pd,dips,xp);
wdt=spline(pd,wdts,xp);
sliprake=spline(pd,sliprakes,xp);
slip=spline(pd,slips,xp);

fdtop=24;

strike(1)=atan2(yc(2)-yc(1),xc(2)-xc(1));

for i=2:length(xc)
    strike(i)=atan2(yc(i)-yc(i-1),xc(i)-xc(i-1));
end
strike=strike/degrad;
strike=90-strike;

n0=round(1000*wdt(1)/dx);
n1=length(xc);
n2=round(1000*wdt(end)/dx);

%figure(4)

for i=1:n0+n1+n2
    
    disp([num2str(i) ' of ' num2str(n0+n1+n2)]);
    
    if i<=n0
        ii=1;
        ixin=i-n0-1;
        xin=ixin*dx/1000; % km
        phirot=(90-strike(1))*degrad;
        ddx=ixin*cos(phirot)*dx; % m
        ddy=ixin*sin(phirot)*dx; % m
    elseif i>n0+n1
        ii=n1;
        ixin=i-(n0+n1);
        xin=-ixin*dx/1000; % km
        phirot=(90-strike(end))*degrad;
        ddx=ixin*cos(phirot)*dx; % m
        ddy=ixin*sin(phirot)*dx; % m
    else
        ii=i-n0;
        ixin=i-n0-1;
        xin=min(ixin*dx/1000,(n0+n1-i)*dx/1000);
        ddx=0;
        ddy=0;
    end
    
    [x,z]=okaTrans(depth(ii),dip(ii),wdt(ii),sliprake(ii),slip(ii),xin);
    
    % Convert to m
    x=x*1000;
    fw = 1000*wdt(ii)*cos(dip(ii)*degrad);
    %    fdtop=0;
    if (fdtop>0)
        fd = 1000*fdtop /sin(dip(ii)*degrad);
        %            fd = min(fd,0.5*fw);
    else
        fd = 0;
    end
    
    x=x+fd;
    % Rotate
    y=x*sin(-(strike(ii))*degrad);
    x=x*cos(-(strike(ii))*degrad);
    
    x=x+xc(ii)+ddx;
    y=y+yc(ii)+ddy;
    
    %    plot(x,y);hold on;axis equal
    
    xx(i,:)=x;
    yy(i,:)=y;
    zz(i,:)=z;
    
end

xg(1)=min(min(xx));
xg(2)=max(max(xx));
yg(1)=min(min(yy));
yg(2)=max(max(yy));
dborder=0.1*(xg(2)-xg(1));
xg(1)=xg(1)-dborder;
xg(2)=xg(2)+dborder;
yg(1)=yg(1)-dborder;
yg(2)=yg(2)+dborder;

dxg=2000;
dyg=2000;

[xg,yg]=meshgrid(xg(1):dxg:xg(2),yg(1):dyg:yg(2));
zg=griddata(xx,yy,zz,xg,yg);



