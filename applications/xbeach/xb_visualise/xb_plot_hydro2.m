function xb_plot_hydro2(xb, varargin)
%XB_PLOT_HYDRO2  Create uniform wave transformation plots (advanced)
%
%   Create uniform wave transformation plots from an XBeach hydrodynamics
%   structure. Depending on the amount of information provided, different
%   plots over the x-axis are plotted. Measurements are provided in a nx2
%   matrix in which the first column is the x-axis and the second the data
%   axis. This function plots information additional to the xb_plot_hydro
%   function and can be seen as the advanced part of the hydrodynamic
%   analysis.
%
%   Syntax:
%   fh = xb_plot_hydro2(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = handles:    Figure handle or list of axes handles
%               urms_hf     Measured high frequency oribtal velocity
%               urms_lf     Measured low frequency oribtal velocity
%               urms_t      Measured total oribtal velocity
%               uavg        Measured mean undertow velocity
%               rho         Measured correlation between short wave
%                           variance and long wave surface elevation
%               SK          Measured wave skewness
%               AS          Measured wave asymmetry
%               B           Measured wave nonlinearity
%               beta        Measured wave phase
%               units_dist: Units used for x- and z-axis
%               units_corr: Units used for correlation z-axis
%               units_skas: Units used for wave shape z-axis
%               units_b:    Units used for wave nonlinearity z-axis
%               units_vel:  Units used for flow velocity z-axis
%               showall:    Show all data available instead of only show
%                           data matched by measurements
%
%   Output:
%   none
%
%   Example
%   xb_plot_hydro2(xb)
%   xb_plot_hydro2(xb, 'zb', zb, 'Hrms_t', H)
%
%   See also xb_plot_hydro, xb_plot_profile, xb_plot_morpho, xb_get_hydro

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
% Created: 20 Jun 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_plot_hydro2.m 11913 2015-04-24 14:15:48Z bieman $
% $Date: 2015-04-24 22:15:48 +0800 (Fri, 24 Apr 2015) $
% $Author: bieman $
% $Revision: 11913 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot_hydro2.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'handles',          [], ...
    'urms_hf',          [], ...
    'urms_lf',          [], ...
    'urms_t',           [], ...
    'uavg',             [], ...
    'rho',              [], ...
    'SK',               [], ...
    'AS',               [], ...
    'B',                [], ...
    'beta',             [], ...
    'units_dist',       'm', ...
    'units_corr',       '-', ...
    'units_skas',       '-', ...
    'units_b',          '-', ...
    'units_vel',        'm/s', ...
    'showall',          false ...
);

OPT = setproperty(OPT, varargin{:});

%% plot

% determine dimensions
x = xs_get(xb, 'DIMS.globalx_DATA');
j = ceil(xs_get(xb, 'DIMS.globaly')/2);
if size(x,2) > size(x,1)
    x       = squeeze(x(j,:));
else
    x       = x';
end

% determine available data
has_corr_m      = ~isempty(OPT.rho);
has_waveshape_m = ~isempty(OPT.SK) || ~isempty(OPT.AS);
has_waveshape2_m = ~isempty(OPT.B) || ~isempty(OPT.beta);
has_flow_m      = ~isempty(OPT.urms_hf) || ~isempty(OPT.urms_lf) || ~isempty(OPT.urms_t) || ~isempty(OPT.uavg);
has_m           = has_corr_m || has_waveshape_m || has_waveshape2_m || has_flow_m;

has_corr_c      = xs_exist(xb, 'rho');
has_waveshape_c = xs_exist(xb, 'SK') || xs_exist(xb, 'AS');
has_waveshape2_c = xs_exist(xb, 'B') || xs_exist(xb, 'beta');
has_flow_c      = xs_exist(xb, 'urms_*') || xs_exist(xb, 'uavg');

if OPT.showall; has_m = false; end;

% compute number of subplots
sp = [0 0 0 0];
if (has_m && has_corr_m) || (~has_m && has_corr_c);             sp(1) = 1;  end;
if (has_m && has_waveshape_m) || (~has_m && has_waveshape_c);   sp(2) = 1;  end;
if (has_m && has_waveshape2_m) || (~has_m && has_waveshape2_c); sp(3) = 1;  end;
if (has_m && has_flow_m) || (~has_m && has_flow_c)              sp(4) = 1;  end;

% create handles
n   = sum(sp);
ax  = xb_get_handles(n, 'handles', OPT.handles);
si  = 1;

% subplot 1
if sp(1)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('correlations');
    ylabel(['correlation \rho [' OPT.units_corr ']']);
    
    % plot measurements
    if ~isempty(OPT.rho);               xb_addplot(OPT.rho(:,1),   OPT.rho(:,2),           's',    'k',    'correlation HF variance/LF elevation (measured)'   );  end;
    
    % plot correlation
    if ~has_m || ~isempty(OPT.rho);     xb_addplot(x,              xs_get(xb, 'rho'),      '-',    'k',    'correlation HF variance/LF elevation'              );  end;
end

% subplot 2
if sp(2)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('wave shape');
    ylabel(['skewness & asymmetry [' OPT.units_skas ']']);
    
    % plot measurements
    if ~isempty(OPT.SK);            xb_addplot(OPT.SK(:,1),    OPT.SK(:,2),       '^',     'k',    'wave skewness (measured)'  );  end;
    if ~isempty(OPT.AS);            xb_addplot(OPT.AS(:,1),    OPT.AS(:,2),       'v',     'k',    'wave asymmetry (measured)' );  end;
    
    % plot computations
    if ~has_m || ~isempty(OPT.SK);  xb_addplot(x,              xs_get(xb, 'SK'),  '-',     'r',    'wave skewness'             );  end;
    if ~has_m || ~isempty(OPT.AS);  xb_addplot(x,              xs_get(xb, 'AS'),  '--',    'r',    'wave asymmetry'            );  end;
    
end

% subplot 3
if sp(3)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('wave nonlinearity');
    ylabel(['nonlinearity & phase [' OPT.units_b ']']);
    
    % plot measurements
    if ~isempty(OPT.B);                 xb_addplot(OPT.B(:,1),     OPT.B(:,2),         '^',     'k',    'wave nonlinearity (measured)' );  end;
    if ~isempty(OPT.beta);              xb_addplot(OPT.beta(:,1),  OPT.beta(:,2),      'v',     'k',    'wave phase (measured)'        );  end;
    
    % plot computations
    if ~has_m || ~isempty(OPT.B);       xb_addplot(x,              xs_get(xb, 'B'),    '-',     'g',    'wave nonlinearity'            );  end;
    if ~has_m || ~isempty(OPT.beta);    xb_addplot(x,              xs_get(xb, 'beta'), '--',    'g',    'wave phase'                   );  end;
    
end

% subplot 4
if sp(4)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('wave orbital velocity and undertow');
    ylabel(['velocity [' OPT.units_vel ']']);
    
    % plot measurements
    if ~isempty(OPT.urms_hf);           xb_addplot(OPT.urms_hf(:,1),   OPT.urms_hf(:,2),       '^',    'k',    'flow velocity (RMS,HF,measured)'   );  end;
    if ~isempty(OPT.urms_lf);           xb_addplot(OPT.urms_lf(:,1),   OPT.urms_lf(:,2),       'v',    'k',    'flow velocity (RMS,LF,measured)'   );  end;
    if ~isempty(OPT.urms_t);            xb_addplot(OPT.urms_t(:,1),    OPT.urms_t(:,2),        's',    'k',    'flow velocity (RMS,measured)'      );  end;
    if ~isempty(OPT.uavg);              xb_addplot(OPT.uavg(:,1),      OPT.uavg(:,2),          'o',    'k',    'undertow velocity (measured)'      );  end;
    
    % plot orbital velocity
    if ~has_m || ~isempty(OPT.urms_hf); xb_addplot(x,                  xs_get(xb, 'urms_hf'),  '--',  'b',    'flow velocity (RMS,HF)'             );  end;
    if ~has_m || ~isempty(OPT.urms_lf); xb_addplot(x,                  xs_get(xb, 'urms_lf'),  ':',   'b',    'flow velocity (RMS,LF)'             );  end;
    if ~has_m || ~isempty(OPT.urms_t);  xb_addplot(x,                  xs_get(xb, 'urms_t'),   '-',   'b',    'flow velocity (RMS)'                );  end;
    
    % plot undertow
    if ~has_m || ~isempty(OPT.uavg);    xb_addplot(x,                  xs_get(xb, 'uavg'),     '-.',  'b',    'undertow velocity'                  );  end;
    
end

% add labels
for i = 1:n
    axes(ax(i));

    xlabel(['distance [' OPT.units_dist ']']);

    legend
    legend('show', 'Location', 'NorthWest');

    box on;
    grid on;
end

linkaxes(ax, 'x');
end