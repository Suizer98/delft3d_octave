function xb_plot_sedtrans(xb, varargin)
%XB_PLOT_SEDTRANS  Create uniform wave sediment transport plots
%
%   Create uniform sediment transport transformation plots from an XBeach
%   sediment transport structure. Depending on the amount of information
%   provided, different plots over the x-axis are plotted. Measurements are
%   provided in a nx2 matrix in which the first column is the x-axis and
%   the second the data axis.
%
%   Syntax:
%   fh = xb_plot_sedtrans(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = handles:    Figure handle or list of axes handles
%               c:          Measured sediment concentration
%               k_wavg:     Measured wave averaged turbulence
%               k_bavg:     Measured bore averaged turbulence
%               k_bavg_nb:  Measured bore averaged near-bed tubulence
%               S_dz:       Measured sediment transport from bed level changes
%               S_av:       Measured sediment transport from avalancing
%               S_s:        Measured suspended sediment transports
%               S_b:        Measured bedload sediment transports
%               S_lf:       Measured low frequency related sediment
%                           transports
%               S_ut:       Measured short wave undertow related sediment
%                           transports
%               S_as:       Measured sediment transports related to wave
%                           asymmetry
%               units_dist: Units used for x- and z-axis
%               units_vol:  Units used for transport z-axis
%               showall:    Show all data available instead of only show
%                           data matched by measurements
%
%   Output:
%   none
%
%   Example
%   xb_plot_sedtrans(xb)
%   xb_plot_sedtrans(xb, 'zb', zb, 'Hrms_t', H)
%
%   See also xb_plot_profile, xb_plot_morpho, xb_plot_hydro, xb_get_sedtrans

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

% $Id: xb_plot_sedtrans.m 11913 2015-04-24 14:15:48Z bieman $
% $Date: 2015-04-24 22:15:48 +0800 (Fri, 24 Apr 2015) $
% $Author: bieman $
% $Revision: 11913 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot_sedtrans.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'handles',          [], ...
    'c',                [], ...
    'k_wavg',           [], ...
    'k_bavg',           [], ...
    'k_bavg_nb',        [], ...
    'S_dz',             [], ...
    'S_av',             [], ...
    'S_s',              [], ...
    'S_b',              [], ...
    'S_lf',             [], ...
    'S_ut',             [], ...
    'S_as',             [], ...
    'units_dist',       'm', ...
    'units_c',          'g/l', ...
    'units_k',          'm^2/s^2', ...
    'units_S',          'm^3/m/s', ...
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
has_conc_m      = ~isempty(OPT.c);
has_turb_m      = ~isempty(OPT.k_wavg) || ~isempty(OPT.k_bavg) || ~isempty(OPT.k_bavg_nb);
has_sedtransm_m = ~isempty(OPT.S_dz) || ~isempty(OPT.S_av) || ~isempty(OPT.S_s) || ~isempty(OPT.S_b);
has_sedtransh_m = ~isempty(OPT.S_lf) || ~isempty(OPT.S_ut) || ~isempty(OPT.S_as);
has_m           = has_conc_m || has_turb_m || has_sedtransm_m || has_sedtransh_m;

has_conc_c      = xs_exist(xb, 'c');
has_turb_c      = xs_exist(xb, 'k_*');
has_sedtransm_c = xs_exist(xb, 'S_dz') || xs_exist(xb, 'S_av') || xs_exist(xb, 'S_s') || xs_exist(xb, 'S_b');
has_sedtransh_c = xs_exist(xb, 'S_lf') || xs_exist(xb, 'S_ut') || xs_exist(xb, 'S_as');

if OPT.showall; has_m = false; end;

% compute number of subplots
sp = [0 0 0 0];
if (has_m && has_conc_m) || (~has_m && has_conc_c);             sp(1) = 1;  end;
if (has_m && has_turb_m) || (~has_m && has_turb_c);             sp(2) = 1;  end;
if (has_m && has_sedtransm_m) || (~has_m && has_sedtransm_c);   sp(3) = 1;  end;
if (has_m && has_sedtransh_m) || (~has_m && has_sedtransh_c);   sp(4) = 1;  end;

% create handles
n   = sum(sp);
ax  = xb_get_handles(n, 'handles', OPT.handles);
si  = 1;

% subplot 1
if sp(1)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('sediment concentration');
    ylabel(['concentration [' OPT.units_c ']']);
    
    % plot measurements
    if ~isempty(OPT.c);                 xb_addplot(OPT.c(:,1),         OPT.c(:,2),             's',    'k',    'concentration (measured)'          );  end;

    % plot computations
    if ~has_m || ~isempty(OPT.c);       xb_addplot(x,                  xs_get(xb, 'c'),        '-',    'k',    'concentration'                     );  end;
    
end

% subplot 2
if sp(2)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('tubulence');
    ylabel(['tubulence [' OPT.units_k ']']);
    
    % plot measurements
    if ~isempty(OPT.k_wavg);            xb_addplot(OPT.k_wavg(:,1),    OPT.k_wavg(:,2),        '^',    'k',    'wave averaged tubulence (measured)'            );  end;
    if ~isempty(OPT.k_bavg);            xb_addplot(OPT.k_bavg(:,1),    OPT.k_bavg(:,2),        'v',    'k',    'bore averaged tubulence (measured)'            );  end;
    if ~isempty(OPT.k_bavg_nb);         xb_addplot(OPT.k_bavg_nb(:,1), OPT.k_bavg_nb(:,2),     's',    'k',    'bore averaged near-bed turbulence (measured)'  );  end;
    
    % plot tubulence
    if ~has_m || ~isempty(OPT.k_wavg);  xb_addplot(x,      xs_get(xb, 'k_wavg'),   '--',   'r',    'wave averaged tubulence'           );  end;
    if ~has_m || ~isempty(OPT.k_bavg);  xb_addplot(x,      xs_get(xb, 'k_bavg'),   ':',    'r',    'bore averaged tubulence'           );  end;
    if ~has_m || ~isempty(OPT.k_bavg_nb); xb_addplot(x,    xs_get(xb, 'k_bavg_nb'),'-',    'r',    'bore averaged near-bed turbulence' );  end;
    
end

% subplot 3
if sp(3)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('sediment transport (morphodynamics)');
    ylabel(['transport [' OPT.units_S ']']);
    
    % plot measurements
    if ~isempty(OPT.S_dz);	xb_addplot(OPT.S_dz(:,1),  OPT.S_dz(:,2),  '^',    'k',    'bed level changes (measured)'  );  end;
    if ~isempty(OPT.S_av);  xb_addplot(OPT.S_av(:,1),  OPT.S_av(:,2),  'v',    'k',    'avalanching (measured)'        );  end;
    if ~isempty(OPT.S_s);   xb_addplot(OPT.S_s(:,1),   OPT.S_s(:,2),   's',    'k',    'suspended (measured)'          );  end;
    if ~isempty(OPT.S_b);   xb_addplot(OPT.S_b(:,1),   OPT.S_b(:,2),   'o',    'k',    'bedload (measured)'            );  end;
    
    % plot computations
    if ~has_m || ~isempty(OPT.S_dz);    xb_addplot(x, 	xs_get(xb, 'S_dz'), '--',   'g',    'bed level changes' );  end;
    if ~has_m || ~isempty(OPT.S_av);    xb_addplot(x,  xs_get(xb, 'S_av'), ':',    'g',    'avalanching'       );  end;
    if ~has_m || ~isempty(OPT.S_s);     xb_addplot(x,  xs_get(xb, 'S_s'),  '-',    'g',    'suspended'         );  end;
    if ~has_m || ~isempty(OPT.S_b);     xb_addplot(x,  xs_get(xb, 'S_b'),  '-.',   'g',    'bedload'           );  end;
    
end

% subplot 4
if sp(4)
    
    axes(ax(si)); si = si + 1; hold on;
    
    title('sediment transport (hydrodynamics)');
    ylabel(['transport [' OPT.units_S ']']);
    
    % plot measurements
    if ~isempty(OPT.S_s);   xb_addplot(OPT.S_s(:,1),   OPT.S_s(:,2),   'o',    'k',    'total hydrodynamics (measured)'    );  end;
    if ~isempty(OPT.S_lf);	xb_addplot(OPT.S_lf(:,1),  OPT.S_lf(:,2),  '^',    'k',    'long waves (measured)'             );  end;
    if ~isempty(OPT.S_ut);  xb_addplot(OPT.S_ut(:,1),  OPT.S_ut(:,2),  'v',    'k',    'short wave undertow (measured)'    );  end;
    if ~isempty(OPT.S_as);  xb_addplot(OPT.S_as(:,1),  OPT.S_as(:,2),  's',    'k',    'wave asymmetry (measured)'         );  end;
    
    % plot computations
    if ~has_m || ~isempty(OPT.S_s);     xb_addplot(x, 	xs_get(xb, 'S_s'),  '-',    'b',    'total hydrodynamics'   );  end;
    if ~has_m || ~isempty(OPT.S_lf);    xb_addplot(x, 	xs_get(xb, 'S_lf'), '--',   'b',    'long waves'            );  end;
    if ~has_m || ~isempty(OPT.S_ut);    xb_addplot(x,  xs_get(xb, 'S_ut'), ':',    'b',    'short wave undertow'   );  end;
    if ~has_m || ~isempty(OPT.S_as);    xb_addplot(x,  xs_get(xb, 'S_as'), '-.',   'b',    'wave asymmetry'        );  end;
    
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