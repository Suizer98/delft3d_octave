function xb = xb_resume(xb, varargin)
%XB_RESUME  Resumes XBeach model run from certain moment
%
%   Combines an existing model setup with a bathymetry from the
%   corresponding model output into a new model setup. Given a certain
%   simulation time, the bathymetry closest to this time is obtained from
%   the model output. The input bathymetry from the existing model setup is
%   replaced with this evolved bathymetry. The boundary conditions and
%   simulation times are adjusted to fit the bathymetry used.
%   If the given simulation time is not present in the model output, the
%   available simulation time closest to the given value is used.
%   
%   Syntax:
%   xb = xb_resume(xb, varargin)
%
%   Input:
%   xb        = XBeach run structure or path to model setup
%   varargin  = t:      simulation time at which bathymetry is read
%               spinup: spinup time to use in newly generated model setup
%
%   Output:
%   xb        = New model setup with evolved bathymetry
%
%   Example
%   xbm = xb_resume(xbr, 't', 1000)
%   xbm = xb_resume(xbr, 't', 1000, 'spinup', 100)
%   xbm = xb_resume('path/to/model/setup, 't', Inf)
%
%   See also xb_run, xb_run_remote, xb_read_input, xb_generate_model

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 17 Jan 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_resume.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_resume.m $
% $Keywords: $

%% read options

OPT = struct( ...
    't', Inf, ...
    'spinup', 0 ...
);

OPT = setproperty(OPT, varargin{:});

%% parse input

if xs_check(xb)
    switch xb.type
        case 'run'
            fpath = xs_get(xb, 'fpath');
        otherwise
            error('Invalid XBeach structure')
    end
elseif ischar(xb)
    fpath = xb;
else
    error('Invalid input')
end

%% read input

xb      = xb_read_input(fpath);

%% read dimensions

d       = xb_read_dims(fpath);
[t i]   = closest(OPT.t, d.t);

OPT.spinup = min([t OPT.spinup]);

%% replace bathymetry

xbo     = xb_read_output(fpath, 'vars', 'zb', 'start', i-1, 'length', 1);

if xs_exist(xbo, 'zb')
    
    nx      = xs_get(xbo, 'DIMS.nx');
    ny      = xs_get(xbo, 'DIMS.ny');
    zb      = reshape(xs_get(xbo, 'zb'), ny+1, nx+1);

    if xs_exist(xb, 'gridform')
        xb = xs_del(xb, 'xyfile');
        xb = xs_set(xb, 'gridform', 'xbeach');
    end

    xb = xs_set(xb, 'depfile.depfile', zb);
    
else
    error('No bathymetry found in output');
end

%% crop wave timeseries

if xs_exist(xb, 'bcfile')
    bc = xs_get(xb, 'bcfile');
    tw = [0 cumsum(xs_get(bc, 'duration'))];
    iw = interp1(tw, 1:length(tw), t-OPT.spinup);
    
    idx = ~cellfun(@ischar, {bc.data.value});
    len =  cellfun(@length, {bc.data.value});
    idx = find(idx & len==length(tw)-1);
    
    for i = 1:length(idx)
        k = bc.data(idx(i)).name;
        v = bc.data(idx(i)).value;
        
        v = v(floor(iw):end);
        if strcmpi(k, 'duration')
            v(1) = (1-(iw-floor(iw)))*v(1);
        end
        
        bc.data(idx(i)).value = v;
    end
    
    xb = xs_set(xb, 'bcfile', bc);
end

%% crop tide timeseries

if xs_exist(xb, 'zs0file')
    zs0 = xs_get(xb, 'zs0file');
    t0  = xs_get(zs0, 'time');
    it  = interp1(t0, 1:length(t0), t-OPT.spinup);
    
    z0  = xs_get(zs0, 'tide');
    z   = [];
    
    for i = 1:size(z0,2)
        z(:,i) = [interp1(t0, z0, t-OPT.spinup) ; z0(ceil(it):end,i)];
    end
    
    tt  = [0 ; t0(ceil(it):end)-t+OPT.spinup];
    
    zs0 = xs_set(zs0, 'time', tt);
    zs0 = xs_set(zs0, 'tide', z);
    
    xb = xs_set(xb, 'zs0file', zs0);
end

%% adjust times

xb = xs_set(xb, 'tstart', OPT.spinup, 'tstop', xs_get(xb, 'tstop') - t + OPT.spinup);

%% set meta data

xb = xs_meta(xb, mfilename, 'input', fpath);
