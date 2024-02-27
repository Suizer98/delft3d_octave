function stat_freqexc_plotduration(res, varargin)
%STAT_FREQEXC_PLOTDURATION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_plotduration(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_plotduration
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 16 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_plotduration.m 5634 2011-12-21 11:31:12Z hoonhout $
% $Date: 2011-12-21 19:31:12 +0800 (Wed, 21 Dec 2011) $
% $Author: hoonhout $
% $Revision: 5634 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_plotduration.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'n', 5 ...
);

OPT = setproperty(OPT, varargin{:});

figure; hold on;

th   = [res.peaks.threshold];
dpp  = [res.peaks.duration_pp];
dpp(isnan(dpp)) = 0;

xlim = max(dpp).*[-1 1];
ylim = minmax(th);

%% plot frequency of exceedance

c  = 0;
dx = 0;

plot(dpp,th,'xb','LineWidth',2,'DisplayName','duration')

for i = 3:length(dpp)
    dpp(i) = min(min(dpp(1:i-1))-1e-6,dpp(i));
end

plot(dpp,th,'-b','LineWidth',2,'DisplayName','duration (fit)')

if isfield(res,'filter')
    th0 = res.filter.threshold;
    top = max([res.peaks([res.peaks.nmax]>=OPT.n).threshold]);
    
    plot(xlim, top.*[1 1], 'r', 'DisplayName', 'top');
    plot(xlim, th0.*[1 1], 'r', 'DisplayName', 'threshold');
    
    c1  = max(findCrossings(dpp,th,xlim,th0.*[1 1]));
    c2  = max(findCrossings(dpp,th,xlim,top.*[1 1]));
    
    plot([-c1 -c2 c2 c1],[th0 top top th0],'k','LineWidth',2,'DisplayName','trapezium');
end

box on;
grid on;
xlabel('duration [days]');
ylabel('value');
legend show;

title(sprintf('top = %d ; base = %d', round(c2), round(c1)));

set(gca,'XLim',xlim,'YLim',ylim);