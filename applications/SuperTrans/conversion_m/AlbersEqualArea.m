function [x2,y2]= AlbersEqualArea(x1,y1,a,finv,lonf,latf,lat1,lat2,fe,fn,iopt)
%TRANSVERSEMERCATOR   map between (lon,lat) and (x,y) in transverse mercator projection
%
%   This routine maps between (lon,lat) and (x,y) in transverse mercator
%   projection
%
%   Syntax:
%   [x2,y2]= transversemercator(x1,y1,a,finv,k0,FE,FN,lat0,lon0,iopt)
%
%   Input:
%   x1
%   y1
%   a
%   finv
%   k0
%   FE
%   FN
%   lat0
%   lon0
%   iopt    = set to 1 for geo2xy, else: xy2geo
%
%   Ouput:
%   x2
%   y2
%
%See also CONVERTCOORDINATES

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       <NAME>
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Oct 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: TransverseMercator.m 4722 2011-06-27 10:18:08Z thijs@damsma.net $
% $Date: 2011-06-27 12:18:08 +0200 (Mon, 27 Jun 2011) $
% $Author: thijs@damsma.net $
% $Revision: 4722 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/SuperTrans/conversion_m/TransverseMercator.m $
% $Keywords: $

%%
x2  = nan(size(x1));
y2  = nan(size(x1));

f=1/finv;
e2=2.0*f-f^2;
e=sqrt(e2);
%e4=e2^2;
%e6=e2^3;

phi1=lat1;
phi2=lat2;
labda0=lonf;
phi0=latf;

if (iopt==1) % then

    %%          geo2xy
    
    labda=x1; % lon
    phi=y1;   % lat
    alfa   = (1 - e2) * ( (sin(phi )./(1-e2*sin(phi ).^2)) - (1/(2*e)) * log( (1-e*sin(phi ))./(1+e*sin(phi ))));
    alfa0  = (1 - e2) * ( (sin(phi0)./(1-e2*sin(phi0).^2)) - (1/(2*e)) * log( (1-e*sin(phi0))./(1+e*sin(phi0))));
    alfa1  = (1 - e2) * ( (sin(phi1)./(1-e2*sin(phi1).^2)) - (1/(2*e)) * log( (1-e*sin(phi1))./(1+e*sin(phi1))));
    alfa2  = (1 - e2) * ( (sin(phi2)./(1-e2*sin(phi2).^2)) - (1/(2*e)) * log( (1-e*sin(phi2))./(1+e*sin(phi2))));
    
    m1=cos(phi1)/sqrt(1-e2*sin(phi1)^2);
    m2=cos(phi2)/sqrt(1-e2*sin(phi2)^2);
    
    n=(m1^2-m2^2)/(alfa2-alfa1);
    C=m1^2+n*alfa1;
    rho =(a*sqrt(C-n*alfa))/n;
    rho0=(a*sqrt(C-n*alfa0))/n;
    theta=n*(labda-labda0);
    
    x2 = fe + rho.*sin(theta);
    y2 = fn + rho0 - rho.*cos(theta);

else
    %%          xy2geo
    error('Reverse Albers Equal Area not yet supported !');
end

