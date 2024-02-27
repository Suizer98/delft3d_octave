function xb = xb_generate_model(varargin)
%XB_GENERATE_MODEL  Generates a XBeach structure with a full model setup
%
%   Generates a XBeach structure with a full model setup. By default this
%   is a minimal setup with default bathymetry, boundary conditions and
%   settings. The defaults can be overwritten by supplying cell arrays with
%   settings for either the bathymetry, waves, tide or model settings. The
%   result is a XBeach structure, which can be written to disk easily.
%
%   Syntax:
%   varargout = xb_generate_model(varargin)
%
%   Input:
%   varargin  = bathy:      cell array of name/value pairs of bathymetry
%                           settings supplied to xb_generate_grid
%               waves:      cell array of name/value pairs of waves
%                           settings supplied to xb_generate_waves
%               tide:       cell array of name/value pairs of tide
%                           settings supplied to xb_generate_tide
%               wavegrid:   cell array of name/value pairs of tide
%                           settings supplied to xb_generate_wavedirgrid
%               settings:   cell array of name/value pairs of model
%                           settings supplied to xb_generate_settings
%               write:      boolean that indicates whether model setup
%                           whould be written to disk (default: false)
%               path:       destination directory of model setup, if
%                           written to disk
%               createwavegrid: bool used to determine whether this
%                           function calls the xb_generate_wavegrid
%                           function. In case of long crested waves one can
%                           think of turning off automatic generation of
%                           the wave grid.
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_model();
%   xb = xb_generate_model('write', false);
%   xb = xb_generate_model('bathy', {'x', [ ... ], 'z', [ ... ]}, 'waves', {'Hm0', 9, 'Tp', 18});
%
%   See also xb_generate_settings, xb_generate_bathy, xb_generate_waves,
%   xb_generate_tide, xb_write_input

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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_generate_model.m 14069 2018-01-04 14:20:37Z arvid.dujardin.x.1 $
% $Date: 2018-01-04 22:20:37 +0800 (Thu, 04 Jan 2018) $
% $Author: arvid.dujardin.x.1 $
% $Revision: 14069 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_generate_model.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'bathy', {{}}, ...
    'waves', {{}}, ...
    'tide', {{}}, ...
    'wavegrid', {{}}, ...
    'settings', {{}}, ...
    'createwavegrid',true,...
    'write', false, ...
    'path', '' ...
);

OPT = setproperty(OPT, varargin{:});

xb_verbose(0,'---');
xb_verbose(0,'Start generation of XBeach model structure');

%% create settings

settings = xb_generate_settings(OPT.settings{:});

%% create boundary conditions

waves = xb_generate_waves(OPT.waves{:}); % waves.data(1).value = 'jons_table';
tide = xb_generate_tide(OPT.tide{:});

%% create grid

xb_verbose(0,'---');
xb_verbose(0,'Determine representative hydraulic conditions');

% couple hydraulics and bathymetry
tp = xb_bc_extracttp(waves);
wl = xb_bc_extractwl(tide);

xb_verbose(1,'Water level',wl);
xb_verbose(1,'Peak wave period',tp);

xgrid = get_optval('xgrid', OPT.bathy);
if isempty(get_optval('Tm', xgrid))
    xgrid = set_optval('Tm', tp, xgrid);
end
if isempty(get_optval('wl', xgrid))
    xgrid = set_optval('wl', wl, xgrid);
end
OPT.bathy = set_optval('xgrid', xgrid, OPT.bathy);

bathy = xb_generate_bathy(OPT.bathy{:});

%% create wavedir grid

wavegrid = xs_empty();
if (OPT.createwavegrid)
    wavegrid = xb_generate_wavedirgrid(waves, OPT.wavegrid{:});
end

%% create model

% create xbeach structure
xb = xs_empty();

% add data
xb = xs_join(xb, bathy, waves, tide, settings, wavegrid);

% set start and stop times
%xb = xb_set_start_time(xb, 'waterlevel', wl);

% add meta data
xb = xs_meta(xb, mfilename, 'input');
if strcmp(xs_get(xb, 'instat'),'jons_table')
    xb = xs_del(xb, 'rt');
    xb = xs_del(xb, 'dtbc');
end

%% write model

if OPT.write
    fpath = fullfile(OPT.path, 'params.txt');
    xb_write_input(fpath, xb);
    
    xb_verbose(0,'---');
    xb_verbose(0,'Write model to disk');
    xb_verbose(1,'File',fpath);
end

%% end verbose

xb_verbose(0,'---');

