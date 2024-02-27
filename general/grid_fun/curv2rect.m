function [XR,YR,ZR] = curv2rect(XC,YC,ZC,DXR,DYR)
%CURV2RECT converts a 3D curvilinear grid into a 3D rectangular grid
%
%   curv2rect converts a 3D curvilinear grid into a 3D rectangular grid
%   where the rectangular grid size depends on the minimum and maximum XC
%   and YC values and a user defined grid cell distance DXR and DYR
%
%   Syntax:
%   [XR,YR,ZR] = curv2rect(XC,YC,ZC,DXR,DYR)
%
%   Input:
%   XC = matrix of x coordinates curvilinear grid
%   YC = matrix of y coordinates curvilinear grid
%   ZC = matrix of values on curvilinear grid
%   DXR = grid cell distance rectangular grid in x direction
%   DYR = grid cell distance rectangular grid in y direction
%
%   Output:
%   XR = matrix of x coordinates rectangular grid
%   YR = matrix of y coordinates rectangular grid
%   ZR = matrix of values on rectangular grid
%
%   Example
%   yet to be made
%
%   See also triscatteredinterp, meshgrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Voorsterweg 28, 8316 PT, Marknesse, The Netherlands
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
% Created: 16 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: curv2rect.m 7957 2013-01-28 09:29:10Z ivo.pasmans.x $
% $Date: 2013-01-28 17:29:10 +0800 (Mon, 28 Jan 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 7957 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/curv2rect.m $
% $Keywords: $

%%
% OPT.keyword=value;
% OPT = setproperty(OPT,varargin{:});
% 
% if nargin==0;
%     varargout = OPT;
%     return;
% end
%% code

xv = reshape(XC,[numel(XC),1]);
yv = reshape(YC,[numel(YC),1]);
zv = reshape(ZC,[numel(ZC),1]);
mynans = isnan(xv);
xv(mynans) = [];
yv(mynans) = [];
zv(mynans) = [];
[XR,YR] = meshgrid(min(xv):DXR:max(xv),min(yv):DYR:max(yv));

try
  F = TriScatteredInterp(xv,yv,zv);
  ZR = F(XR,YR);
catch
  ZR=griddata(xv,yv,zv,XR,YR);
end

