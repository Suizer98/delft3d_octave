function info = xb_nest_xbeach(varargin)
%XB_NEST_XBEACH  Obtain XBeach boundary conditions and bathymetry from another model
%
%   Obtain XBeach boundary conditions and/or bathymetry from a WW3, Delft3D
%   or another XBeach model. This information can be used for nesting an
%   XBeach model into one of these three models.
%
%   Syntax:
%   info = xb_nest_xbeach(varargin)
%
%   Input:
%   varargin  = type:   Model type to nest into (ww3/delft3d/xbeach)
%               flow:   Cell array with parameters for the flow nest
%                       procedure
%               wave:   Cell array with parameters for the wave nest
%                       procedure
%               bathy:  Cell array with parameters for the bathymetry nest
%                       procedure
%
%   Output:
%   info      = Struct with filenames of boundary condition and bathymetry
%               files
%
%   Example
%   info = xb_nest_xbeach('delft3d', 'flow', { ... })
%
%   See also xb_nest_delft3d, xb_delft3d_flow, xb_delft3d_wave, xb_delft3d_bathy

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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_nest_xbeach.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_nest_xbeach.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'delft3d', ...
    'flow', {{}}, ...
    'wave', {{}}, ...
    'bathy', {{}} ...
);

OPT = setproperty(OPT, varargin{:});

%% nest

info = struct();

switch OPT.type
    case 'ww3'
        
        error('FUNCTIONALITY STILL UNDER CONSTRUCTION');
        
    case 'delft3d'
        
        info = struct('tidefile','','sp2file','','depfile','');
        
        % nest flow
        if ~isempty(OPT.flow)
            info.tidefile = xb_delft3d_flow(OPT.flow{:}, 'type', 'xbeach');
        end

        % nest wave
        if ~isempty(OPT.wave)
            info.sp2file = xb_delft3d_wave(OPT.wave{:}, 'type', 'xbeach');
        end

        % nest bathy
        if ~isempty(OPT.bathy)
            info.depfile = xb_delft3d_bathy(OPT.bathy{:}, 'type', 'xbeach');
        end
        
    case 'xbeach'
        
        error('FUNCTIONALITY STILL UNDER CONSTRUCTION');
        
    otherwise
        error(['Unknown parent model type [' OPT.type ']']);
end
