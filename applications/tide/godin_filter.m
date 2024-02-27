function data = godin_filter(data,varargin)
%GODIN_FILTER  GODIN low-pass tide filter for time series
%
%   This function applies a three step low-pass filter according to Godin
%   (1972) to a timeseries in order to remove tidal and higher frequency
%   signals and obtain the residual signal. The filter applies a moving
%   average over respectively 24, 24 and 25 hours.
%
%   Syntax:
%   data = godin_filter(data,varargin)
%
%   Input: 
%   data      = timeseries data to be filtered [values time]
%   varargin  = plot:   generate automatic plot of original and final 
%                       filtered signal (default = 0)
%               plot2:  generate automatic plot of original signal and
%                       signals obtained in every filtering step (def = 0)
%               intnan: interpolate over nan-values if timeseries contains
%                       any (default = 1)
%               full  : if true fill series with last valid value at the
%                       begin and end of the series
%
%   Output:
%   data      = Godin-filtered timeseries 
%
%   Example
%   timeser_filt = godin_filter(timeser,'plot2',1)
%
%   See also: godin, thompson_1983


%% Copyright notice
%   Function is based on a script made by Bas van Maren (Deltares) and
%   Gerben Ruessink (Utrecht University).
%   --------------------------------------------------------------------
%   Copyright (C) 2013 DELTARES
%       rooijen
%
%       arnold.vanrooijen@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 13 Jun 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: godin_filter.m 15355 2019-04-17 15:24:33Z kaaij $
% $Date: 2019-04-17 23:24:33 +0800 (Wed, 17 Apr 2019) $
% $Author: kaaij $
% $Revision: 15355 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tide/godin_filter.m $
% $Keywords: $

%% Settings/Input
% Sampling frequency in data
if length(varargin{1}) == 1 % input is sampling frequency [Hz]
    FS = varargin{1};
else % input is time array
    FS   = 1/((varargin{1}(2)-varargin{1}(1))*24*60*60);
    time = varargin{1};
end
% Options
OPT.plot    = 0;
OPT.plot2   = 0;
OPT.intnan  = 1;
OPT.full    = false;
OPT         = setproperty(OPT, varargin{2:end});
data        = data(:);

% Interpolate data for NaN-values
if OPT.intnan
    tmp = 1:length(data);
    data = interp1(tmp(~isnan(data)),data(~isnan(data)),tmp);
    clear tmp
end

% Settings per filter window
Twin = [24,24,25];

%% Filter
tmp.orig = data;
for iw = 1:length(Twin)
    N = fix(Twin(iw)*60*60*FS);% number of data points within avg window
    
    % Check if amount of points per avg window even/odd is
    if mod(N,2)~=0, odd = 1;else, odd= 0; end;
    
    % Now apply filter
    for i = 1:length(data)
        if odd,
            lb = i - fix(N/2);
            rb = i + fix(N/2);
        else
            lb = i - fix(N/2);
            rb = i + fix(N/2)-1;
        end;
        % Fix left and right bounds if they are outside of data array
        if lb < 1, lb = 1; end;
        if rb > length(data), rb = length(data); end;
        
        % Now average over the window
        if isnan(data(i)),
            tmp.(['res' num2str(iw)])(i) = NaN;
        else
            tmp.(['res' num2str(iw)])(i) = nanmean(data(lb:rb));
        end;
    end;
    data = tmp.(['res' num2str(iw)]);
    clear N odd lb rb
end

% Throw away data at begin + end or fill with first/last valid value
if ~OPT.full
    data(1:fix(25*60*60*FS))      = NaN;
    data(end-fix(25*60*60*FS):end)= NaN;
else
    data(1:fix(25*60*60*FS))      = data(fix(25*60*60*FS) + 1);
    data(end-fix(25*60*60*FS):end)= data(end-fix(25*60*60*FS) - 1);
end

% Make plot (optional)
if OPT.plot || OPT.plot2
    figure()
    if length(varargin{1}) == 1
        plot(tmp.orig,'k'); hold on
        if OPT.plot2
            plot(tmp.res1,'r');
            plot(tmp.res2,'g');
            leg = {'orig','res1','res2','res3'};
        else
            leg = {'orig','res3'};
        end
        plot(tmp.res3,'b')
    else
        plot(time,tmp.orig,'k'); hold on
        if OPT.plot2
            plot(time,tmp.res1,'r');
            plot(time,tmp.res2,'g');
            leg = {'orig','res1','res2','res3'};
        else
            leg = {'orig','res3'};
        end
        plot(time,tmp.res3,'b')
        if time(1)>7e+04
            datetick('x')
        end
    end
    legend(leg)
end
    


