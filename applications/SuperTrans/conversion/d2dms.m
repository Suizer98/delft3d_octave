function varargout=d2dms(xgeo,varargin)
%D2DMS  Function to convert from degrees to deg, min, sec.
%
%   This function converts decimal degrees to degrees, minutes and seconds
%
%   Syntax:
%   [latstruct          ] = D2DMS(lat)
%   [lonstruct          ] = D2DMS(lon)
%   [lonstruct,latstruct] = D2DMS(lon,lat)
%   [latstruct,lonstruct] = D2DMS(lat,lon)
%
%   Input:
%   lat, lon    =  latitude and longtitude in decimal degrees
%
%   Output:
%   lonstruct, latstruct = structures which have fields:
%                          - degrees 'dg'
%                          - minutes 'mn'
%                          - seconds 'sc'
%
%   See also DEG2RAD, RAD2DEG, DEGREES2DMS, str2deg

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

% $Id: d2dms.m 8788 2013-06-07 19:51:36Z ormondt $
% $Date: 2013-06-08 03:51:36 +0800 (Sat, 08 Jun 2013) $
% $Author: ormondt $
% $Revision: 8788 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/SuperTrans/conversion/d2dms.m $
% $Keywords: $

%%
x.dg  = floor(xgeo);
seconds  = (xgeo - x.dg).* 3600;
x.mn  = floor(seconds./60.);
x.sc  = seconds - (x.mn.* 60);

if abs(x.sc-60)<1e-6
    x.sc=0;
    x.mn=x.mn+1;
end

if nargin==2
    
    ygeo = varargin{1};
    
    y.dg  = floor(ygeo);
    seconds  = (ygeo - y.dg).* 3600;
    y.mn  = floor(seconds./60.);
    y.sc  = seconds   - (y.mn.* 60);
    
    varargout= {x,y};
    
else
    
    varargout= {x};
    
end

