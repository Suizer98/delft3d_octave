function xb_sg = xb_generate_ships(varargin)
%XB_GENERATE_SHIPS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   xb = xb_generate_ships(varargin)
%
%   Input: For <keyword,value> pairs call xb_generate_ships() without arguments.
%   varargin =
%
%   Output:
%   xb       =
%
%   Example
%   xb_generate_ships
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 DELTARES
%       rooijen
%
%       Arnold.vanRooijen@deltares.nl
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
% Created: 25 Mar 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: xb_generate_ships.m 10469 2014-03-31 10:12:47Z rooijen $
% $Date: 2014-03-31 18:12:47 +0800 (Mon, 31 Mar 2014) $
% $Author: rooijen $
% $Revision: 10469 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_ship/xb_generate_ships.m $
% $Keywords: $

%% Input
OPT = struct( 'noships',1,...
    'shipgeom', {{}}, ...
    'shiptrack', {{}}, ...
    'path', '');
OPT = setproperty(OPT, varargin{:});
%% Create xbeach structure with ship(s) information
for i = 1%:length(OPT.noships) % TODO: Multiple ships (Only works for 1 ship now)
    % compute ship track
    xb_st  = xb_compute_shiptrack(i,OPT.shiptrack{:});
    % define ship geometry parametesr
    xb_sg  = xb_shipgeom(i,OPT.shipgeom{:});
    % add shiptrack info to xbeach ship geometry structure
    xb_sg  = xs_set(xb_sg, 'shiptrack', xb_st); 
end
xb_sg = xs_meta(xb_sg, mfilename, 'ships');
