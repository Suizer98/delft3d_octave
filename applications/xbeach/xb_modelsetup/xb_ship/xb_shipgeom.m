function [xb_sg] = xb_shipgeom(iship,varargin)
%XB_SHIPGEOM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
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
% Created: 31 Mar 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: xb_shipgeom.m 10494 2014-04-07 07:04:59Z rooijen $
% $Date: 2014-04-07 15:04:59 +0800 (Mon, 07 Apr 2014) $
% $Author: rooijen $
% $Revision: 10494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_ship/xb_shipgeom.m $
% $Keywords: $
%% INPUT
OPT.L            = [];
OPT.B            = [];
OPT.D            = [];
OPT.shipdep      = 'mooredship.dep';
OPT.shipdir      = [pwd filesep];
OPT.nx           = 280;
OPT.ny           = 28;
OPT.dx           = [];
OPT.dy           = [];
OPT.track        = sprintf('track%03d.txt', iship);
OPT.flying       = 0;
OPT = setproperty(OPT,varargin{:});

%% Read ship depfile
dsh = wldep('read',[OPT.shipdir OPT.shipdep],[OPT.nx+2,OPT.ny+2]);
dsh(dsh==-999) = NaN;
dsh = dsh*OPT.D/max(dsh(:));  
dsh(isnan(dsh)) = -999;
wldep('write',sprintf('ship%03d.dep', iship),dsh,'N','9');

%% Compute ship grid
if isempty(OPT.dx) || isempty(OPT.dy)
    OPT.dx = OPT.L/OPT.nx;
    OPT.dy = OPT.B/OPT.ny;
    if isempty(OPT.dx) || isempty(OPT.dy)
        error(['Not possible to set up ship parameters; Missing either L, B, dx,dy, nx and/or ny input in ' mfilename '...']);
    end
end

%% Set parameters in xbeach structure
xb_sg = xs_empty;
xb_sg = xs_meta(xb_sg, mfilename, 'ship', 'allships.txt');
xb_sg = xs_set(xb_sg, 'nx', OPT.nx);
xb_sg = xs_set(xb_sg, 'ny', OPT.ny);
xb_sg = xs_set(xb_sg, 'dx', OPT.dx);
xb_sg = xs_set(xb_sg, 'dy', OPT.dy);
xb_sg = xs_set(xb_sg, 'shipgeom', sprintf('ship%03d.dep', iship));
xb_sg = xs_set(xb_sg, 'shiptrack', OPT.track);
xb_sg = xs_set(xb_sg, 'flying', OPT.flying);