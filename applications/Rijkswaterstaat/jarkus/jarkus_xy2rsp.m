function rsp = jarkus_xy2rsp(x, y, varargin)
%JARKUS_XY2RSP  Convert RD coordinates to Rijksstrandpalen coordinates.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_xy2rsp(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_xy2rsp() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_xy2rsp
%
%   See also jarkus_rsp2xy, jarkus_rsp2lonlat

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 10 Jan 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: jarkus_xy2rsp.m 9222 2013-09-16 08:43:00Z heijer $
% $Date: 2013-09-16 16:43:00 +0800 (Mon, 16 Sep 2013) $
% $Author: heijer $
% $Revision: 9222 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_xy2rsp.m $
% $Keywords: $

%%
OPT = struct(...
    'id', []);
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
if isempty(OPT.id)
    error('Transect id of concern should be provided (option to automatically detect will be added later)')
elseif ~isscalar(OPT.id)
    error('Transect id should be a scalar')
end

tr = jarkus_transects('id', OPT.id,...
    'output', {'x', 'y', 'cross_shore'});

csx = interp1(tr.x, tr.cross_shore, x);
csy = interp1(tr.y, tr.cross_shore, y);

rsp = mean([csx; csy]);