function ZI = griddata_gridfit(X, Y, Z, XI, YI, varargin)
%GRIDDATA_GRIDFIT uses gridfit to estimate a surface through scattered data
%
%   Syntax:
%   ZI = griddata_remap(X, Y, Z, XI, YI)
%
%   Input:
%   X  = 1D vectore with coordinates
%   Y  = 1D vectore with coordinates
%   Z  = 1D vectore with coordinates
%   XI = XI must be either a 1D vector, or a 2D array made with meshgrid
%   YI = YI must be either a 1D vector, or a 2D array made with meshgrid
%
%   Output:
%   ZI = 2D array
%
%   Example
%   griddata_remap
%
%   See also: GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_AVERAGE, GRIDDATE_REMAP,
%   INTERP2, BIN2 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
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
% Created: 21 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: griddata_gridfit.m 3056 2010-09-14 16:31:13Z tda@vanoord.com $
% $Date: 2010-09-15 00:31:13 +0800 (Wed, 15 Sep 2010) $
% $Author: tda@vanoord.com $
% $Revision: 3056 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/griddata_gridfit.m $
% $Keywords: $
%% set properties

OPT.errorCheck = true;
OPT.smoothness  = 2;
OPT.Rmax        = [];

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% vectorize data
x=X(:);
y=Y(:);
z=Z(:);

nans = isnan(z+x+y);

x(nans) = [];
y(nans) = [];
z(nans) = [];

%% input check
if OPT.errorCheck
    dimx = size(XI);
    dimy = size(YI);
    if length(dimx) ~= 2
        error('XI must be a 1D or 2D array')
    end
    
    dimx(dimx == 1) = [];
    dimy(dimy == 1) = [];
end
    
XI = unique(XI(:));
YI = unique(YI(:));
    
if OPT.errorCheck    
    if all(dimx ~= length(XI))||all(dimy ~= length(YI))
        error(['XI and YI must be either 1D vectors, or 2D vectors made with'...
            'meshgrid. Also, no duplicate values are allowed in XI or YI'])
    end
end
dx = median(diff(XI));
dy = median(diff(YI));

XI2 = horzcat(XI(  1) - ceil ((XI(  1) - min(X))/dx)*dx:dx:XI(1),XI',XI(end):dx:XI(end) - floor((XI(end) - max(X))/dx)*dx);
YI2 = horzcat(YI(  1) - ceil ((YI(  1) - min(Y))/dy)*dy:dy:YI(1),YI',YI(end):dy:YI(end) - floor((YI(end) - max(Y))/dy)*dy);
XI2 = unique(XI2(:));
YI2 = unique(YI2(:));
ZI2 = gridfit(x,y,z,XI2,YI2,'autoscale','off','tilesize',500,'smoothness',OPT.smoothness);

ZI = ZI2(ismember(YI2,YI),ismember(XI2,XI));

if ~isempty(OPT.Rmax)
    [XI,YI] = meshgrid(XI,YI);
    temp1           = griddata_nearest(X, Y, Z, XI, YI,'Rmax',OPT.Rmax,'quiet',1);
    ZI(isnan(temp1)) = nan;
end