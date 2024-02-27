function xbo = xb_get_hydro_nh(xb,varargin)
%XB_GET_HYDRO  Compute hydrodynamic parameters from XBeach output structure
%
%   Compute hydrodynamic parameters like RMS wave heights over a
%   cross-section split in low and high freqnecy waves. The same is done
%   for orbital velocities and mean velocities. Also the water level setup
%   is computed, if possible. The results are stored in an XBeach
%   hydrodynamics structure and can be plotted with xb_plot_hydro.
%
%   Syntax:
%   xbo = xb_get_hydro(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = Trep:   repesentative wave period
%               nonh:   non-hydrostatic mode
%
%   Output:
%   xbo       = XBeach hydrodynamics structure
%
%   Example
%   xbo = xb_get_hydro(xb)
%   xbo = xb_get_hydro(xb, 'Trep', 12)
%
%   See also xb_plot_hydro, xb_get_morpho, xb_get_spectrum

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
% Created: 18 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_hydro.m 11884 2015-04-22 12:44:52Z bieman $
% $Date: 2015-04-22 14:44:52 +0200 (Wed, 22 Apr 2015) $
% $Author: bieman $
% $Revision: 11884 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_hydro.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'Trep',            12,      ...
    'morfac',           1,      ...
    'nonh',             0       ...
);

OPT = setproperty(OPT, varargin{:});

%% initialize input

% xb      = xb_get_transect(xb); %change: outcomment
if OPT.nonh == 0
nx      = xs_get(xb, 'DIMS.globalx');
t       = xs_get(xb, 'DIMS.globaltime_DATA');
elseif OPT.nonh == 1
nx      = xs_get(xb, 'DIMS.points');
t       = xs_get(xb, 'DIMS.pointtime_DATA');
end

dt      = min([mean(diff(t)) t(end)]);
df      = 1/dt;
frep    = 1/OPT.Trep;

f       = {xb.data.name};
re      = regexp(f,'^(.+)_mean$','tokens');
idx     = find(~cellfun(@isempty, re));

for i = idx
    xb  = xs_rename(xb, f{i}, re{i}{1}{1});
end

if ~isempty(idx)
    t   = xs_get(xb, 'DIMS.meantime_DATA');
    if isscalar(t)
        tm = t;
        t  = xs_get(xb, 'DIMS.globaltime_DATA');
        t = [t(1) tm];
    end
    dt  = min([mean(diff(t)) t(end)]);
end

%% initialize output

zb_i    = 0;
zb_f    = 0;
Hrms_hf = 0;
Hrms_lf = 0;
Hrms_t  = 0;
s       = 0;
urms_hf = 0;
urms_lf = 0;
urms_t  = 0;
umean   = 0;
vmean   = 0;

% advanced
rho     = 0;
SK      = 0;
AS      = 0;
B       = 0;
beta    = 0;
uavg    = 0;

%% compute wave transformation characteristics

% determine bathymetry
if xs_exist(xb, 'zb')
    zb      = xs_get(xb,'zb');
    zb_i    = zb(1,1,:);
    zb_f    = zb(end,1,:);
end

% split HF and LF waves
if xs_exist(xb, 'hh_var') && OPT.nonh == 0
    hh = mean(xs_get(xb,'hh_var'),1);

    Hrms_lf = sqrt(8*abs(hh));
elseif xs_exist(xb, 'zs')
    zs      = xs_get(xb,'zs');

    if xs_exist(xb, 'zb') && OPT.nonh == 0 %own comment: nonh has to be 0 otherwise timeseries is smoothed and HFs are lost
        h       = zs-xs_get(xb,'zb');
        hm      = nan(size(h));

        windowSize = ceil(40*OPT.Trep/dt);
        for i = 1:size(h,1)
            ws        = min([windowSize i-1 size(h,1)-i]);
            hm(i,:,:) = mean(h(i-ws:i+ws,:,:),1);
        end
        zs = h-hm;
    end

    Hrms_lf = sqrt(8).*std(zs,0,1);

% end

if xs_exist(xb, 'u')
    u       = xs_get(xb,'u');
    urms_lf = std(u,0,1);
end
end

% compute HF waves
if xs_exist(xb, 'H') && OPT.nonh == 0
    Hrms_hf = sqrt(mean(xs_get(xb,'H').^2,1)+Hrms_hf.^2);                  % high frequency component from low frequency waves is
                                                                           % added to the high frequency waves here. the component
                                                                           % is set to zero until consensus is reached about
                                                                           % whether this is useful or not.
    if xs_exist(xb, 'zs')
        zs = xs_get(xb,'zs');
        H = xs_get(xb,'H');

        if size(zs,1)>1
            rho = zeros(nx,1);
            for i = 1:nx
                R       = corrcoef(detrend(zs(:,i)),H(:,i).^2);
                rho(i)  = R(1,2);
            end
        end
    end
% end

% compute total waves
Hrms_t = sqrt(Hrms_lf.^2+Hrms_hf.^2);
end

% spectral analysis needed in case of nonh computations of Hrms
if xs_exist(xb, 'point_zs') && OPT.nonh == 1
    zs      = xs_get(xb,'point_zs');
    if xs_exist(xb, 'point_zb') && OPT.nonh == 1 
        h       = zs-xs_get(xb,'point_zb');
        if df*2 < 4*frep; warning('dt is too large, increase ''tint'' in params.txt'); end
        h_spec = xb_get_spectrum_u(h,'sfreq',df*OPT.morfac,'fsplit',frep/2,'correction',   true);%,'filter','hann','correction',   true
        Hrms_t = xs_get(h_spec,'Hrms_t');
        Hrms_hf = xs_get(h_spec,'Hrms_hf');
        Hrms_lf = xs_get(h_spec,'Hrms_lf');
%         Snn = xs_get(h_spec,'Snn');
%         Sf = xs_get(h_spec,'f');
    end
else
    error('Invalid nonh number');
end

% compute setup
if xs_exist(xb, 'zs')
    if xs_exist(xb, 'zb') || xs_exist(xb, 'u')
        zs = xs_get(xb,'zs');

        if xs_exist(xb, 'zb')
            zb = xs_get(xb,'zb');
            k = zs-zb>0.0001;
        elseif xs_exist(xb, 'u') %own comment: only nonh == 0?
            u = xs_get(xb,'u');
            k = abs(u)>0.0001;
        end

        s = zs-mean(zs(:,1,1),1);
        s(~k) = 0;
        s = max(0,mean(s,1));
    end
end

% compute HF orbital velocity
if xs_exist(xb, 'urms') && OPT.nonh == 0
    urms_hf = sqrt(mean(xs_get(xb,'urms').^2,1)+urms_hf.^2);
% end

% compute total orbital velocity
urms_t = sqrt(urms_lf.^2+urms_hf.^2);
end

% compute velocities for nonh
if xs_exist(xb, 'point_u')&& OPT.nonh == 1
    u       = xs_get(xb,'point_u'); 
    if df*2 < 4*frep; warning('dt is too large, increase ''tint'' in params.txt'); end
    u_spec = xb_get_spectrum_u(u,'sfreq',df*OPT.morfac,'fsplit',frep/2,'u_spec',true,'correction',   true);%,'filter','hann','correction',   true own comment: suppose frep wave signal is frep velocity signal
    % current referred to 
    urms_t = xs_get(u_spec,'urms_t');
    urms_hf = xs_get(u_spec,'urms_hf');
    urms_lf = xs_get(u_spec,'urms_lf');
%     Unn = xs_get(u_spec,'Unn');
%     uf = xs_get(u_spec,'f');
%     u_maxinf = xs_get(u_spec,'maxinf');
else
    error('Invalid nonh number');
end

% compute mean velocity
if xs_exist(xb, 'ue')
    umean = mean(xs_get(xb,'ue'),1);
end

if xs_exist(xb, 'ua')
    uavg = mean(xs_get(xb,'ua'),1);
end

if xs_exist(xb, 've')
    vmean = mean(xs_get(xb,'ve'),1);
end

% skewness and asymmetry
if xs_exist(xb, 'Sk')
    SK = mean(xs_get(xb,'Sk'),1);
end

if xs_exist(xb, 'As')
    AS = mean(xs_get(xb,'As'),1);
    if xs_exist(xb, 'Sk')
        beta    = atan(AS./SK);
        B       = sqrt(AS.^2+SK.^2);
    end
end

%% create xbeach structure

xbo = xs_empty();

xbo = xs_set(xbo, 'SETTINGS', xs_set([], ...
    'Trep',  OPT.Trep                       ));

xbo = xs_set(xbo, 'DIMS', xs_get(xb, 'DIMS'));

if ~isscalar(zb_i);     xbo = xs_set(xbo, 'zb_i',       squeeze(zb_i));      end;
if ~isscalar(zb_f);     xbo = xs_set(xbo, 'zb_f',       squeeze(zb_f));      end;
if ~isscalar(Hrms_hf);  xbo = xs_set(xbo, 'Hrms_hf',    squeeze(Hrms_hf));   end;
if ~isscalar(Hrms_lf);  xbo = xs_set(xbo, 'Hrms_lf',    squeeze(Hrms_lf));   end;
if ~isscalar(Hrms_t);   xbo = xs_set(xbo, 'Hrms_t',     squeeze(Hrms_t));    end;
if ~isscalar(s);        xbo = xs_set(xbo, 's',          squeeze(s));         end;
if ~isscalar(urms_hf);  xbo = xs_set(xbo, 'urms_hf',    squeeze(urms_hf));   end;
if ~isscalar(urms_lf);  xbo = xs_set(xbo, 'urms_lf',    squeeze(urms_lf));   end;
if ~isscalar(urms_t);   xbo = xs_set(xbo, 'urms_t',     squeeze(urms_t));    end;
if ~isscalar(umean);    xbo = xs_set(xbo, 'umean',      squeeze(umean));     end;
if ~isscalar(vmean);    xbo = xs_set(xbo, 'vmean',      squeeze(vmean));     end;

% advanced
if ~isscalar(rho);      xbo = xs_set(xbo, 'rho',        squeeze(rho));       end;
if ~isscalar(SK);       xbo = xs_set(xbo, 'SK',         squeeze(SK));        end;
if ~isscalar(AS);       xbo = xs_set(xbo, 'AS',         squeeze(AS));        end;
if ~isscalar(B);        xbo = xs_set(xbo, 'B',          squeeze(B));         end;
if ~isscalar(beta);     xbo = xs_set(xbo, 'beta',       squeeze(beta));      end;
if ~isscalar(uavg);     xbo = xs_set(xbo, 'uavg',       squeeze(uavg));      end;

xbo = xs_meta(xbo, mfilename, 'hydrodynamics');
