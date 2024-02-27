function res = stat_freqexc_get(t, x, varargin)
%STAT_FREQEXC_GET  Determines the frequency of exceedance of a timeseries
%
%   Determines the frequency of exceedance of a timeseries over the entire
%   range of this timeseries. A computational grid with a given resolution
%   running from the minimum value to the maximum value of the timeseries
%   is used as threshold values. For each level in this grid, the number of
%   exceedances is counted and the corresponding time, duration and maximum
%   level determined. A given time horizon is used to differ between two
%   succeeding maxima and a single maximum that temporarily drops below the
%   exceedance level.
%
%   Time series may contain nan values. Sections not interrupted by nan's
%   are considered continuous periods. In case such section starts or ends
%   above the threshold value, it is assumed that at some point outside the
%   continuous period the level drops below the threshold value. A section
%   entirely above the treshold value is therefore also interpreted as a
%   single exceedance.
%
%   The result is a structure containing generic information on the
%   timeseries and a description of all maxima found for each threshold in
%   the computational grid. This result is translated in probabilities and
%   frequencies of exceedance.
%
%   Syntax:
%   res = stat_freqexc_get(t, x, varargin)
%
%   Input:
%   t         = time axis of timeseries (datenum format)
%   x         = level axis of time series
%   varargin  = dx:         resolution of computational grid
%               horizon:    horizon in days in which multiple maxima are
%                           considered to be a single maximum
%               margin:     safety margin used in threshold determination
%               method:     analysis method Peaks-over-Threshold (PoT) or
%                           Annual Maxima (AM) (default: PoT)
%
%   Output:
%   res       = result structure with exceedance information:
%
%               time:       original time axis
%               data:       original level axis
%               duration:   total length of timeseries in days
%               dt:         average sample frequency in days
%               fraction:   fraction of non-nan values in time series
%               peaks:      structure array with maxima for each level in
%                           computational grid:
%
%                           threshold:      computational grid value
%                           nmax:           number of found maxima
%                           probability:    probability of exceedance [-]
%                           frequency:      frequency of exceedance [1/yr]
%                           duration:       duration of exceedance [day/yr]
%                           duration_pp:    duration per peak [day/1]
%                           maxima:         structure array with maxima for
%                                           current level in computational
%                                           grid:
%
%                                           time:       time of maximum
%                                           value:      level of maximum
%                                           start:      start time of peak
%                                           end:        end time of peak
%                                           duration:   duration of peak
%
%   Example
%   res = stat_freqexc_get(t,x,'horizon',15);
%
%   idx = closest(0,[res.peaks.threshold]);
%
%   figure; hold on;
%   plot(res.time,res.data,'-b');
%   plot([res.peaks(idx).maxima.time],[res.peaks(idx).maxima.value],'or');
%
%   stat_freqexc_plot(res);
%
%   See also stat_freqexc_mask, stat_freqexc_filter, stat_freqexc_plot

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
% Created: 15 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_get.m 6188 2012-05-14 09:50:49Z hoonhout $
% $Date: 2012-05-14 17:50:49 +0800 (Mon, 14 May 2012) $
% $Author: hoonhout $
% $Revision: 6188 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_get.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'dx', .01, ...
    'horizon', 15, ...
    'margin', .05, ...
    'method', 'PoT' ...
);

OPT = setproperty(OPT, varargin{:});

%% output structure

dt              = mean(diff(t));
duration        = range(t);

res = stat_freqexc_struct;

res.time        = t(:);
res.data        = x(:);
res.duration    = duration;
res.dt          = dt;
res.fraction    = sum(isfinite(x))/length(x);

years           = res.duration/365.2425;

%% find maxima

switch upper(OPT.method)
	case 'POT'
            
        % create computational grid
        mn = min(round(x(isfinite(x))/OPT.dx)*OPT.dx);
        mx = max(round(x(isfinite(x))/OPT.dx)*OPT.dx);

        g  = mn:OPT.dx:mx;
        
    case 'AM'
        
        g  = nan;
        
        OPT.horizon = -Inf;
end

for i = 1:length(g)

    % initialize values
    res.peaks(i).threshold  = g(i);
    res.peaks(i).maxima     = struct('time', {}, 'value', {}, 'duration', {});

    % determine up- and down crossings
    switch upper(OPT.method)
        case 'POT'
            uc = find((x(1:end-1)<=g(i)|isnan(x(1:end-1)))&x(2:end)>g(i));
            dc = find((x(2:end)<=g(i)|isnan(x(2:end)))&x(1:end-1)>g(i));

            startidx = 1;

            if isempty(uc) && isempty(dc)
                if x(1) >= g(i)
                    uc = startidx;
                    dc = length(x);
                end
            elseif isempty(uc)
                uc = startidx;
            elseif isempty(dc)
                dc = length(x);
            else
                if uc(1) > dc(1)
                    uc = [startidx;uc(:)];
                end
                if uc(end) > dc(end)
                    dc = [dc(:);length(x)];
                end
            end
        case 'AM'
            y  = str2num(datestr(t,'yyyy'));
            
            uc = [1 find(y(1:end-1)~=y(2:end))'+1];
            dc = [uc(2:end)-1 length(y)];
    end

    % determine wave maxima
    c = 1;
    for j = 1:length(uc)

        tj      = uc(j):dc(j);
        [m k]   = max(x(tj));
        idx     = find(abs(t(tj(k))-[res.peaks(i).maxima.time])<OPT.horizon,1);

        % add waves to result structure if distant enought from previous
        % peak, otherwise merge with previous peak
        if ~isempty(idx)

            if res.peaks(i).maxima(idx).value < m
                res.peaks(i).maxima(idx).time   = t(tj(k));
                res.peaks(i).maxima(idx).value  = m;
            end

            res.peaks(i).maxima(c).start        = min(res.peaks(i).maxima(idx).start, t(uc(j)));
            res.peaks(i).maxima(c).end          = max(res.peaks(i).maxima(idx).end,   t(dc(j)));
            res.peaks(i).maxima(idx).duration   = res.peaks(i).maxima(idx).duration+(dc(j)-uc(j))*dt;
        else
            res.peaks(i).maxima(c).time         = t(tj(k));
            res.peaks(i).maxima(c).value        = m;
            res.peaks(i).maxima(c).start        = t(uc(j));
            res.peaks(i).maxima(c).end          = t(dc(j));
            res.peaks(i).maxima(c).duration     = (dc(j)-uc(j))*dt;

            c = c+1;
        end
    end

    res.peaks(i).nmax           = length(res.peaks(i).maxima);
    res.peaks(i).probability    = sum([res.peaks(i).maxima.duration])/duration;
    res.peaks(i).frequency      = [res.peaks(i).nmax]/years;
    res.peaks(i).duration       = sum([res.peaks(i).maxima.duration])/years;
    res.peaks(i).duration_pp    = res.peaks(i).duration./res.peaks(i).frequency;
    
    % GPD fit
    if strcmpi(OPT.method,'POT')
        if exist('gpfit')
            data                    = [res.peaks(i).maxima.value];
            mu                      = min(data)-eps;

            if length(data)>1
                fit                 = gpfit(data-mu);
            else
                fit                 = nan(1,2);
            end

            res.peaks(i).GPD        = struct(           ...
                'mu',                 mu,               ...
                'xi',                 fit(1),           ...
                'sigma',              fit(2));
        end
    end
end

%% determine threshold

if strcmpi(OPT.method,'POT')
    if isfield(res.peaks, 'GPD')

        GPD          = [res.peaks.GPD];

        sigma        = [GPD.sigma];
        sigma_var    = nan(size(sigma));

        sigma(isnan(sigma)) = 0;

        for i = length(sigma):-1:1
            sigma_var(i) = var(sigma    (i:end));
        end

        dsigma_var = diff(sigma_var);
        dsigma_var(abs(dsigma_var)<eps) = [];

        n = length(dsigma_var);

        idx = find(dsigma_var==max(dsigma_var(1:round(.5*n)))>0,1,'first');

        if length(idx) == 1
            res.threshold = (1+OPT.margin)*res.peaks(idx).threshold;
        end
    end

    if ~isfield(res, 'threshold')
        res.threshold = (1+OPT.margin)*max(cellfun(@length,{res.peaks.maxima}));
    end
end
