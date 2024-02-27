function fh = xb_plot_spectrum(xb, varargin)
%XB_PLOT_SPECTRUM  Create uniform spectrum plots
%
%   Create uniform spectrum plots from XBeach spectrum structure. Creates a
%   subplot per location.
%
%   Syntax:
%   fh = xb_plot_spectrum(xb, varargin)
%
%   Input:
%   xb        = XBeach spectrum structure
%   varargin  = measured:   Measured spectra
%               units:      Units used for x- and z-axis
%               units2:     Units used for secondary z-axis
%
%   Output:
%   fh        = Figure handle
%
%   Example
%   fh = xb_plot_spectrum(xb)
%
%   See also xb_plot_hydro, xb_plot_morpho, xb_get_spectrum

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

% $Id: xb_plot_spectrum.m 7876 2013-01-04 12:39:29Z hoonhout $
% $Date: 2013-01-04 20:39:29 +0800 (Fri, 04 Jan 2013) $
% $Author: hoonhout $
% $Revision: 7876 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot_spectrum.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'measured',         [], ...
    'units',            'Hz', ...
    'units2',           'm^2/Hz' ...
);

OPT = setproperty(OPT, varargin{:});

if ~xs_exist(xb, 'Snn') || ~xs_exist(xb, 'f')
    error('No spectrum data found');
end

%% plot

fh = figure; hold on;

f   = xs_get(xb,'f');
S   = xs_get(xb,'Snn');

l   = size(S,2);
n   = ceil(sqrt(l));
m   = ceil(l/n);

sp  = nan(1,l);
for i = 1:l
    sp(i) = subplot(m,n,i); hold on;
    
    if ~isempty(S);     plot(f,S  (:,i),'-b');  end;

    yl = ylim;

    title(num2str(i));
    xlabel(['f [' OPT.units ']']);
    ylabel(['S_{\eta\eta} [' OPT.units2 ']']);
    
    if xs_exist(xb, 'SETTINGS.fsplit')
        fsplit = xs_get(xb, 'SETTINGS.fsplit');
        plot([fsplit fsplit],[0 max(yl)],'--k');
        set(gca, 'YLim', yl);
    end
end

linkaxes(sp, 'x');

mS = max(S,[],2);
mf = f(find(mS>=.1*mean(mS),1,'last'));
set(gca, 'XLim', [0 mf]);