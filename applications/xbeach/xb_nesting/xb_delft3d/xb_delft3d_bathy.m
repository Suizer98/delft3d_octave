function varargout = xb_delft3d_bathy(depfile, varargin)
%XB_DELFT3D_BATHY  Nest Delft3D or XBeach bathymetry in another Delft3D model
%
%   Nests a Delft3D bathymetry.
%
%   Syntax:
%   varargout = xb_delft3d_bathy(depfile, varargin)
%
%   Input:
%   depfile   = Path to bathymetry file
%   varargin  = type:           Type of output (delft3d/xbeach)
%               file:           Path to output file
%
%   Output:
%   varargout   = Path to output file
%
%   Example
%   file = xb_delft3d_bathy(depfile)
%
%   See also xb_nest_xbeach, xb_nest_delft3d, xb_delft3d_flow, xb_delft3d_wave

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 10 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_delft3d_bathy.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_delft3d_bathy.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'delft3d', ...
    'file', [] ...
);

OPT = setproperty(OPT, varargin{:});

%% determine paths

if isempty(OPT.file)
    [fdir fname fext] = fileparts(depfile);
    depfile = fullfile(fdir, [fname '_nested' fext]);
else
    depfile = OPT.file;
end

varargout{1} = depfile;
