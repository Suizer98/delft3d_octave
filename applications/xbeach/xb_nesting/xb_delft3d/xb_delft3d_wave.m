function varargout = xb_delft3d_wave(sp2files, varargin)
%XB_DELFT3D_WAVE  Nest Delft3D-WAVE or XBeach model in another Delft3D-WAVE model
%
%   Nests a Delft3D-WAVE model by simply joining the output SP2 files into
%   a single input SP2 file.
%
%   Syntax:
%   varargout = xb_delft3d_wave(sp2files, varargin)
%
%   Input:
%   sp2files  = Path to SP2 files to be joined
%   varargin  = type:           Type of output (delft3d/xbeach)
%               file:           Path to output file
%               coordsys_in     Coordinate system of input
%               coordtype_in    Coordinate system type of input
%               coordsys_out    Coordinate system of output
%               coordtype_out   Coordinate system type of output
%               tstart:         Datenum indicating simulation start time
%               tlength:        Datenum indicating simulation length
%
%   Output:
%   varargout   = Path to output file
%
%   Example
%   file = xb_delft3d_wave(sp2files)
%   file = xb_delft3d_wave('pet.loct*.sp2')
%
%   See also xb_nest_xbeach, xb_nest_delft3d, xb_delft3d_flow, xb_delft3d_bathy, xb_sp22xb

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

% $Id: xb_delft3d_wave.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_delft3d_wave.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'delft3d', ...
    'file', [], ...
    'coordsys_in', [], ...
    'coordsys_out', [], ...
    'coordtype_in', [], ...
    'coordtype_out', [], ...
    'tstart', 0, ...
    'tlength', Inf ...
);

OPT = setproperty(OPT, varargin{:});

%% determine paths

% determine runid
[~, fname] = fileparts(sp2files);
m = regexp(fname, '^(?<runid>\w+)', 'names');
runid = m.runid;

%% nest waves

switch OPT.type
    case 'delft3d'
        if isempty(OPT.file); OPT.file = [runid '.sp2']; end;

        sp2 = xb_swan_read(sp2files);
        sp2 = xb_swan_join(sp2);

        % convert coordinates
        sp2 = xb_swan_coords(sp2, OPT.coordsys_in, OPT.coordtype_in, OPT.coordsys_out, OPT.coordsys_out);
        
        xb_swan_write(OPT.file, sp2);
        varargout{1} = OPT.file;
        
    case 'xbeach'
        if isempty(OPT.file); OPT.file = 'waves.txt'; end;
        
        wavefile = xb_sp22xb(sp2files, 'tstart', OPT.tstart, 'tlength', OPT.tlength, 'wavefile', OPT.file);
        
        varargout{1} = wavefile;
        
    otherwise
        error(['Unknown target model type [' OPT.type ']']);
end
