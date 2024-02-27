function res = stat_freqexc_filter(res, varargin)
%STAT_FREQEXC_FILTER  Selects the maxima corresponding to a single threshold value from a stat_freqexc_get result struct and filters them
%
%   Selects a single threshold value from the computational grid used by
%   the stat_freqexc_get function based on the result structure from this
%   function. If no threshold is given, the treshold with the maximum
%   number of maxima is used. The corresponding maxima are filtered
%   according to their time axis value using datestr formatting. From all
%   points with the same value resulting from the datestr formatted mask,
%   the maximum is chosen and the others are discarded. This function is
%   useful to determine monthly or yearly maxima.
%
%   The original result structure is returned with an extra field
%   containing the filtered subset from the original peaks field.
%
%   Syntax:
%   res = stat_freqexc_filter(res, varargin)
%
%   Input:
%   res       = Result structure from the stat_freqexc_get function
%   varargin  = mask:       datestr formatted mask
%               threshold:  threshold above which maxima are determined
%               
%
%   Output:
%   res       = Modified result structure with extra field filter with
%               similar fields to the peak field
%
%   Example
%   % determine yearly maxima
%   res = stat_freqexc_filter(res, 'mask', 'yyyy');
%   % determine monthly maxima
%   res = stat_freqexc_filter(res, 'mask', 'mm-yyyy');
%   % determine yearly maxima above a specified threshold
%   res = stat_freqexc_filter(res, 'mask', 'yyyy', 'threshold', -.2);
%
%   See also stat_freqexc_get, stat_freqexc_fit, stat_freqexc_plot

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
% Created: 06 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_filter.m 6188 2012-05-14 09:50:49Z hoonhout $
% $Date: 2012-05-14 17:50:49 +0800 (Mon, 14 May 2012) $
% $Author: hoonhout $
% $Revision: 6188 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_filter.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'mask',         [], ...
    'threshold',    nan     ...
);

OPT = setproperty(OPT, varargin{:});

%% filter maxima

if ~isnan(OPT.threshold)
    [n ni] = closest(OPT.threshold,[res.peaks.threshold]);
elseif isfield(res, 'threshold')
    [n ni] = closest(res.threshold,[res.peaks.threshold]);
else
    [n ni] = max([res.peaks.nmax]);
end

th = res.peaks(ni).threshold;

if ~isempty(OPT.mask)
    y      = num2cell(datestr([res.peaks(ni).maxima.time],OPT.mask),2);
    ids    = unique(y);
    
    mis    = nan(size(ids));

    for i = 1:length(ids)
        idx    = find(ismember(y,ids(i)));
        [m mi] = max([res.peaks(ni).maxima(idx).value]);
        mis(i) = idx(mi);
    end
else
    mis    = 1:length(res.peaks(ni).maxima);
end

%% save peaks

res.filter = struct(                    ...
    'mask',         OPT.mask,           ...
    'threshold',    th,                 ...
    'probability',  sum([res.peaks(ni).maxima(mis).duration])/res.duration, ...
    'frequency',    length(mis)/res.duration, ...
    'nmax',         length(mis),        ...
    'maxima',       res.peaks(ni).maxima(mis)   );
