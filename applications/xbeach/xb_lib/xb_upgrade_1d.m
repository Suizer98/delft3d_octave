function xb = xb_upgrade_1d(xb, varargin)
%XB_UPGRADE_1D  Converts an old 1D model to a superfast 1D model
%
%   Converts an old 1D model with 2 lateral grids to a superfast 1D model
%   withou lateral grids. An XBeach input structure or path to an XBeach
%   model can be supplied. In the latter case, the model is overwritten
%   with the new setup.
%
%   Syntax:
%   xb = xb_upgrade_1d(xb, varargin)
%
%   Input:
%   xb        = XBeach input structure or path to XBeach model
%   varargin  = none
%
%   Output:
%   xb        = modified XBeach input structure
%
%   Example
%   xb = xb_upgrade_1d(xb)
%   xb = xb_upgrade_1d(path)
%
%   See also xb_write_input

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 04 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_upgrade_1d.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_upgrade_1d.m $
% $Keywords: $

%% settings

OPT = struct(...
);

OPT = setproperty(OPT, varargin{:});

%% read model

fname = '';

if ~xs_check(xb)
    fname = xb;
    xb = xb_read_input(fname);
end

%% modify grid

[x, y, z, ne] = xb_input2bathy(xb);

if (size(z,1)==size(x,1) || isempty(x)) && ...
   (size(z,1)==size(y,1) || isempty(y)) && ...
   (size(z,1)==size(ne,1) || isempty(ne))

    i = round(size(z,1)/2);

    z = z(i,:);
	if ~isempty(x); x = x(i,:); end;
    if ~isempty(y); y = y(i,:); end;
    if ~isempty(ne); ne = ne(i,:); end;

    xb = xb_bathy2input(xb, x, y, z, ne);
end

%% modify params

xb = xs_set(xb, 'ny', 0);
xb = xs_del(xb, 'yfile');

%% write model

if ~isempty(fname)
    xb_write_input(fname, xb);
end