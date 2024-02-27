function stat_freqexc_logplot(res, varargin)
%STAT_FREQEXC_LOGPLOT  Plots a result structure from any of the stat_freqexc_* functions on logarithmic scale
%
%   Plots the empirical, filtered, fitted and combined frequencies of
%   exceedance from any of the stat_freqexc_* functions that return a
%   result structure alike the structure from stat_freqexc_get.
%
%   Syntax:
%   stat_freqexc_logplot(res, varargin)
%
%   Input:
%   res       = Result structure from a stat_freqexc_* function
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   stat_freqexc_logplot(res)
%
%   See also stat_freqexc_get, stat_freqexc_filter, stat_freqexc_fit,
%            stat_freqexc_combine, stat_freqexc_plot

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
% Created: 11 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_logplot.m 5634 2011-12-21 11:31:12Z hoonhout $
% $Date: 2011-12-21 19:31:12 +0800 (Wed, 21 Dec 2011) $
% $Author: hoonhout $
% $Revision: 5634 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_logplot.m $
% $Keywords: $

%% read settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

figure; hold on;

th   = [res.peaks.threshold];

xlim = [1e-1 1e5];
ylim = [min(th) 2*max(th)];

%% plot frequency of exceedance

plot(1./[res.peaks.frequency].*res.fraction,[res.peaks.threshold],'xb','LineWidth',2,'DisplayName','peaks');

if isfield(res,'filter')
    [y i]   = sort([res.filter.maxima.value],2,'descend');
    plot(1./([1:res.filter.nmax]./res.filter.nmax),y,'xg','LineWidth',2,'DisplayName','peaks (filtered)');
end

if isfield(res,'fit')
    plot(1./[res.fit.fits.f],[res.fit.fits.y],'Color',[.8 .8 .8],'DisplayName','fit');
    plot(1./res.fit.f,res.fit.y,'-r','LineWidth',2,'DisplayName','fit (average)');
    
    if isfield(res.fit,'f_GEV')
        plot(1./res.fit.f_GEV,res.fit.y,':r','DisplayName','fit (GEV)');
    end
end

if isfield(res,'combined')
    plot(1./res.combined.f,res.combined.y,'-xk','LineWidth',3,'DisplayName','combined');
    plot(1./res.combined.split.*[1 1],ylim,':k','LineWidth',3,'DisplayName','combination divide');
end

box on;
grid on;
xlabel('return period [year]');
ylabel('value');
set(legend('show'),'Location','NorthWest');

set(gca,'XLim',xlim,'YLim',ylim,'XScale','log');