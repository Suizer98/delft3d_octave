function res = stat_freqexc_combine(res, varargin)
%STAT_FREQEXC_COMBINE  Combines the empirical and fitted exceedance data to a single frequency of exceedance line
%
%   Combines the fitted data from stat_freqexc_fit with the original high
%   frequency data obtained from the stat_freqexc_get function into a
%   single description of the frequency of exceedance.
%
%   The result is the original result structure with an extra field
%   containing the description of the combined frequency of exceedance.
%
%   Syntax:
%   res = stat_freqexc_combine(res, varargin)
%
%   Input:
%   res       = Result structure from the stat_freqexc_fit function
%   varargin  = f:          computational grid for frequencies to be
%                           returned
%               split:  	split frequency between empirical and fitted
%                           data
%
%   Output:
%   res       = Modified result structure with extra field combined:
%
%               f:          computational grid for frequencies
%               y:          levels corresponding to computational grid
%               split:      split frequency used
%
%   Example
%   res = stat_freqexc_combine(res, 'f', [1e0 1e-1 1e-2], 'split', 5e-2);
%
%   See also stat_freqexc_fit, stat_freqexc_plot, stat_freqexc_logplot

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
% Created: 07 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_combine.m 6189 2012-05-14 10:03:20Z hoonhout $
% $Date: 2012-05-14 18:03:20 +0800 (Mon, 14 May 2012) $
% $Author: hoonhout $
% $Revision: 6189 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_combine.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'f',        [1e1 1e0 1e-1 1e-2 1e-3 1e-4 1e-5], ...
    'split',    .1                                  ...
);

OPT = setproperty(OPT, varargin{:});

if ~isfield(res, 'filter')
    error('No data selected, please use stat_freqexc_filter first');
end

if ~isfield(res, 'fit')
    error('No fit made, please use stat_freqexc_fit first');
end

if isnan(res.filter.threshold)
    error('No empircial distribution found, please use PoT method');
end

%% combine data and fit

f = [res.peaks.frequency]./res.fraction;
x = [res.peaks.threshold];

idx = x>=min(x(f==max(f)));
f = f(idx);
x = x(idx);

[x xi] = sort(x,'ascend');
[f fi] = unique(f(xi),'last');

yc1 = interp1(log(f(f>0)),x(fi(f>0)),log(OPT.f(OPT.f>=OPT.split)),'linear','extrap');

f = res.fit.f;
[f fi] = unique(log(f(f>0)));
yc2 = interp1(f,res.fit.y(fi),log(OPT.f(OPT.f<OPT.split)),'linear','extrap');

res.combined.f      = OPT.f(:)';
res.combined.y      = [yc1(:);yc2(:)]';
res.combined.split  = OPT.split;

