function [x,z,a,m]=dean_beach_profile(dx,zmin,zmax,beta_dry,varargin)
% Computes Dean beach profile z=Ax^m
%
% Inputs:
%   dx       : grid spacing
%   zmin     : minimum elevation, e.g. -20 m (below sea level)
%   zmax     : maximum elevation, e.g. +5 m (above sea level)
%   beta_dry : dry beach slope 
%
% Optional inputs:
%   d50  : sediment diameter (m)
%   A    : profile scale parameter
%   m    : profile exponent (default 2/3)
% Either A or d50 needs to be supplied as input
%
% Example:
% [x,z,a,m]=dean_beach_profile(1.0,-20,10,0.01,'d50',0.0002);

%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
%       Maarten van Ormondt
%
%       <maarten.vanormondt@deltares.nl>;
%
%       Deltares
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
% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Apr 2016
% Created with Matlab version: 2013b
% $Id: dean_beach_profile.m 12629 2016-03-21 05:51:10Z ormondt $
% $Date: 2016-03-21 06:51:10 +0100 (Mon, 21 Mar 2016) $
% $Author: ormondt $
% $Revision: 12629 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/dean_beach_profile.m $
% $Keywords: $

m=2/3;
a=[];
D=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'a'}
                a=varargin{ii+1};
            case{'m'}
                m=varargin{ii+1};
            case{'d50'}
                D=varargin{ii+1};
        end
    end
end

if isempty(a)
    if isempty(D)
        error('Please supply either a or D50!');
    end    
    % Compute a
    vfall=fall_velocity_vanrijn2007(D,15);
    a = 0.51 * vfall ^ 0.44;
end

x=-10000:dx:1000000;

z=-a*x.^(m);
z2=-beta_dry*x;
z(x<0)=z2(x<0);

ifirst=find(z>=zmax,1,'last');
ilast=find(z<=zmin,1,'first');
if isempty(ilast)
    ilast=length(z);
end
x=x(ifirst:ilast);
z=z(ifirst:ilast);

%%
function ws=fall_velocity_vanrijn2007(dss,temp)

% Fall velocity according to Van Rijn 2007
rhoint=1024;
rhosol=2650;
dsand=0.000064;
dgravel=0.002;
ag=9.81;
s = rhosol / rhoint;
vcmol = 4.0e-5 / (20.0 + temp);
if dss < 1.5*dsand
    ws = (s-1.0) * ag * dss^2/(18.0*vcmol);
elseif dss < 0.5*dgravel
    if dss < 2.0*dsand
        coefw = (-2.9912/dsand) * dss + 15.9824;
    else
        coefw = 10.0;
    end
    ws = coefw * vcmol / dss * (sqrt(1.0 + (s-1.0)*ag*dss^3 / (100.0*vcmol^2)) - 1.0);
else
    ws = 1.1 * sqrt((s-1.0)*ag*dss);
end
