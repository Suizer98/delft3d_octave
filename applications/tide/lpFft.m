function data = lpFft(data,times,varargin)
%   lpFft low-pass tide filter for time series aiming at removing tidal
%   fluctuations
%
%   This function applies a low-pass filter. The methodolgy is to 
%       1) First perform a fourier analysis (using Matlabs native fft function),
%       2) Derive ampltude and phases from the results ot the fft,
%       3) set amplitudes belonging with periods shorter than per_tstop (default 30 hours) to 0.0
%       4) leave amplitudes belonging with periods larger than per_tstart (default value 40 hours) intact
%       5) in between tstart and tstop interpolate multiplification factor from 1.0 t0 0.0
%       6) Construct filtered series as the sommation of a number of waves (cosine functions)
%
%   Syntax:
%   data = lpFft(data,times,varargin)
%
%   Input: 
%   data      = timeseries data to be filtered
%   times     = sample times belonging with the data (matlab days are advised 
%   varargin  = per_tstart: period length, periods longer are taken into account
%               per_tstop : period length, periods shortere are not taken into account
%               if per_tstop is specified as NaN a so-called cut-off filter
%               is obtained (Only taking into account periods larger than
%               per_tstop)
%
%               per_tstart and per_tstop should be specified in the unit of the times array
%
%               Default setting per_tstart = 40 and per_tstop = 30 result in the filter named fft filter 
%               in Walters and Heston 1981 (Removing Tidal Period Variations from Time-Series Data
%                                           using Low-Pass digital Filters, 
%                                           Journal of Physical Oceanography, Volume 12) 
%
%   Output:
%   data      = Low Pass filtered timeseries 
%
%% Copyright notice
%   
%   Copyright (C) 2019 DELTARES
%
%       theo.vanderkaaij@deltares.nl
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
%
%% Low Pass filter based upon fft (Wolter and Heston 1981)
%  Initialisation
OPT.per_start = 40./24; % hours
OPT.per_stop  = 30./24; % Hours
OPT           = setproperty(OPT,varargin);

%   Settings
times     = times - times(1);
fsam      = 1/((times(2) - times(1)));              % Sampling frequency in 1/unit of times
no_times  = length(times);

%% Determine amplitudes, phases and frequencies
[freq,amp,phase] = simpleFFT(data,fsam);
if size(freq ,1) == 1 freq  = freq' ; end
if size(amp  ,1) == 1 amp   = amp'  ; end
if size(phase,1) == 1 phase = phase'; end 

no_freq          = length(freq);
clear data

%% Find periods > 30 and > 40 hr
per     = 1./freq;
i_start = find(per<OPT.per_start,1,'first') - 1;
if ~isnan(OPT.per_stop)
    i_stop  = find(per<OPT.per_stop,1,'first') - 1;
else
    % cut-off at single frequency. Everything longer than per_start passes,
    % Everything shorter is eliminated
    i_stop = i_start + 1;
end

%% Remove periods < 30 hrs and create fitered series
mult_x  = [1  ; i_start; i_stop; no_freq];
mult_y  = [1.0; 1.0    ; 0.       ; 0.0 ];
mult    = interp1(mult_x,mult_y,linspace(1,no_freq,no_freq))';
amp                 = amp.*mult;
data (1:no_times,1) = 0.;
for i_freq = 1: i_stop
    data = data + amp(i_freq)*cos(2*pi*freq(i_freq)*times + phase(i_freq));
end

function [frq, amp, phase] = simpleFFT( signal, ScanRate)

no_fft = 2^nextpow2(length(signal));
frq    = ScanRate/2*linspace(0,1,no_fft/2+1);
z      = fft(signal, no_fft); %do the actual work

%(assuming that the input is a real signal)
amp(1)            = abs(z(1))./(no_fft);
amp(2:no_fft/2+1) = abs(z(2:no_fft/2+1))./(no_fft/2);
phase             = angle(z(1:no_fft/2+1));

