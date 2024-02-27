function varargout = xb_write_bathy(xb, varargin)
%XB_WRITE_BATHY  Writes XBeach bathymetry files from XBeach structure
%
%   Writes XBeach bathymetry files x, y, depth and non-erodable layers
%   based on a XBeach structure.
%
%   Syntax:
%   [xfile yfile depfile ne_layer] = xb_write_bathy(xb, varargin)
%
%   Input:
%   xb          = XBeach structure array
%   varargin    = path:         path to output directory
%                 xfile:        filename of x definition file
%                 yfile:        filename of y definition file
%                 depfile:      filename of depth definition file
%                 ne_layerfile: filename of non-erodable layer definition
%                               file
%
%   Output:
%   varargout   = filenames of created definition files, if used
%
%   Example
%   [xfile yfile depfile ne_layer] = xb_write_bathy(xb)
%
%   See also xb_read_bathy, xb_write_input

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_write_bathy.m 13138 2017-01-20 15:31:34Z bieman $
% $Date: 2017-01-20 23:31:34 +0800 (Fri, 20 Jan 2017) $
% $Author: bieman $
% $Revision: 13138 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_bathy.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'path', pwd, ...
    'xfile', 'x.grd', ...
    'yfile', 'y.grd', ...
    'depfile', 'bed.dep', ...
    'ne_layer', 'nebed.dep' ...
);

OPT = setproperty(OPT, varargin{:});

%% write bathymetry files

f = fieldnames(OPT);

varargout = {};

c = 1;
for i = 1:length(f)
    if xs_exist(xb, f{i})
        varargout{c} = OPT.(f{i});
        data = xs_get(xb, f{i});
        fname = fullfile(OPT.path, OPT.(f{i}));
        if isnumeric(data)
           save(fname, '-ascii', 'data');
        elseif isstruct(data)
            % We have struct in a struct....
            d = xs_get(data, f{i});
            save(fname, '-ascii', 'd');    
        else
            fid = fopen(fname, 'w');
            fprintf(fid, '%s', data);
            fclose(fid);
        end
        c = c+1;
    end
end
