function xb = xb_scale(xb, varargin)
%XB_SCALE  Scales XBeach model input according to Vellings (1986)
%
%   Scales XBeach model input according to Vellings (1986). All scaling
%   dependent parameters should be present in the model input structure.
%
%   Syntax:
%   xb = xb_scale(xb, varargin)
%
%   Input:
%   xb          = XBeach input structure
%   varargin    = depthscale:   depthscale nd
%                 contraction:  horizontal contraction S
%                 zmin:         minimal z-value
%
%   Output:
%   xb          = Scaled XBeach input structure
%
%   Example
%   xb = xb_scale(xb, 'depthscale', 40, 'contraction', 1.68)
%   xb = xb_scale(xb, 'depthscale', 40, 'contraction', 1.68, 'zmin', 0)
%
%   See also xb_generate_model

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
% Created: 01 Jul 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_scale.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_scale.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'depthscale', 1, ...
    'contraction', 1, ...
    'wfunc', {DuneErosionSettings('get', 'FallVelocity')}, ...
    'zmin', [] ...
);

OPT = setproperty(OPT, varargin{:});

if OPT.depthscale == 1 && OPT.contraction == 1; return; end;

%% determine constants

nd = OPT.depthscale;
nl = nd*OPT.contraction;
nt = sqrt(nd);
nw = nd^2.5/nl^2;

xb = xs_set(xb, 'depthscale', nd);

%% scale bathymetry

[x y z] = xb_input2bathy(xb);

x = x/nl;
z = z/nd;

dz = 0;
if ~isempty(OPT.zmin); dz = OPT.zmin-min(min(z)); end;

xb = xb_bathy2input(xb, x, y, z+dz);

%% scale waves

switch xs_get(xb, 'instat')
    case {'stat' 'bichrom' 0 1}
        xb = set_scale(xb,'Hrms',nd);
        xb = set_scale(xb,'Trep',nt);
    case {'jons' 'jons_table' 4 41}
        xb = set_scale(xb,'bcfile.Hm0',nd);
        xb = set_scale(xb,'bcfile.Tp',nt);
        xb = set_scale(xb,'bcfile.fp',1/nt);
    case {'vardens', 6}
        xb = set_scale(xb,'bcfile.freqs',1/nt);
        xb = set_scale(xb,'bcfile.vardens',nd,'RMSI');
    otherwise
        warning('OET:xbeach:scale', ['Cannot scale instat, unsupported value [' xs_get(xb, 'instat') ']']);
end

%% scale tide

xb = set_scale(xb,'zs0',nd);
xb = set_scale(xb,'zs0file.tide',nd);

xb = set_offset(xb,'zs0',dz);
xb = set_offset(xb,'zs0file.tide',dz);

%% scale sediment

if xs_exist(xb,'D50')
    xb = set_scale(xb,'D50',sqrt(nw));
    xb = set_scale(xb,'D90',sqrt(nw));
else
    warning('OET:xbeach:scale', 'Cannot scale D50, value not present');
end

%% scale time

if xs_exist(xb,'tstop') && xs_exist(xb,'tint','tintg','tintm','tintp','tsglobal','tsmean','tspoint')>0
    xb = set_scale(xb,'tstart',nt);
    xb = set_scale(xb,'tstop',nt);
    xb = set_scale(xb,'tint',nt);
    xb = set_scale(xb,'tintg',nt);
    xb = set_scale(xb,'tintm',nt);
    xb = set_scale(xb,'tintp',nt);
    xb = set_scale(xb,'tsglobal.data',nt);
    xb = set_scale(xb,'tsmean.data',nt);
    xb = set_scale(xb,'tspoint.data',nt);
else
    warning('OET:xbeach:scale', 'Cannot scale time, values not present');
end

%% set meta data

xb = xs_meta(xb, mfilename, 'input');

%% pricate functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xb = set_scale(xb, var, scale, varargin)

if xs_exist(xb,var)
    if ~isempty(varargin)
        switch varargin{1}
            case 'RMS'
                xb = xs_set(xb,var,sqrt(xs_get(xb,var).^2/scale));
            case 'RMSI'
                xb = xs_set(xb,var,(sqrt(xs_get(xb,var))/scale).^2);
        end
    else
        xb = xs_set(xb,var,xs_get(xb,var)/scale);
    end
end

function xb = set_offset(xb, var, offset)

if xs_exist(xb,var)
	xb = xs_set(xb,var,xs_get(xb,var)+offset);
end