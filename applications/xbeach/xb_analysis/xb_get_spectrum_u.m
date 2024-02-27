function xbo = xb_get_spectrum_u(ts, varargin)
%XB_GET_SPECTRUM  Computes a spectrum from a timeseries
%
%   Computes a spectrum from a timeseries. The result is stored in an
%   XBeach spectrum structure and can be plotted using the xb_plot_spectrum
%   function.
%
%   FUNCTION IS AN ADAPTED VERSION OF R.T. MCCALL'S MAKESPECTRUM FUNCTION
%               WITH MODIFICATIONS FROM HIS SPECTRUMSIMPLE FUNCTION
%
%   Syntax:
%   xbo = xb_get_spectrum(ts, varargin)
%
%   Input:
%   ts        = Timeseries in columns
%   varargin  = sfreq:          sample frequency
%               fsplit:         split frequency between high and low
%                               frequency waves
%               fcutoff:        cut-off frequency for high frequency waves
%               detrend:        boolean to determine whether timeseries
%                               should be linearly detrended before
%                               computation
%               filterlength:   smoothing window
%
%   Output:
%   xbo       = XBeach spectrum structure
%
%   Example
%   xbo = xb_get_spectrum(ts)
%
%   See also xb_plot_spectrum, xb_get_hydro, xb_get_morpho

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

% $Id: xb_get_spectrum.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 17:30:24 +0200 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_spectrum.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'sfreq',        1, ...
    'df',           0.001, ...
    'overlap',      .5, ...
    'fsplit',       .05, ...
    'fcutoff',      1e8, ...
    'detrend',      true, ...
    'strict',       false, ...
    'filter',       '', ...
    'correction',   false, ...
    'tolerance',    1e-3, ...
    'u_spec',       false ...
);

OPT = setproperty(OPT, varargin{:});

%% initialize spectrum

[n m] = size(ts);

% required number of samples
nr    = ceil(OPT.sfreq/OPT.df);

% restrict sample length to powers of 2
if OPT.strict
%     nr = 2^floor(log2(nr));
    nr = 2^nextpow2(nr);%mccall
end

% check number of samples
if nr > n
    nr = n;
    warning('OET:tolerance', 'The required frequency resolution could not be achieved');
end

% number of Welch repetitions
nw = ceil((n-nr)/(OPT.overlap*nr))+1;

% allocate matrices
Snn     = zeros(floor(nr/2),m);
hrms    = zeros(m,1);
hrmshi  = zeros(m,1);
hrmslo  = zeros(m,1);

%% compute spectrum

idxe    = round(linspace(nr,n,nw));
idxb    = idxe-nr+1;

T       = nr/OPT.sfreq;
df      = 1/T;
ff      = df*[0:1:round(nr/2) -1*floor(nr/2)+1:1:-1];
f       = ff(1:floor(nr/2));

for i = 1:m
    P   = squeeze(ts(:,i));
    % Detrend input signal
    if OPT.detrend
        P   = detrend(P);
    end
    % do Welch repetition
    for j = 1:nw
        
        Pj  = P(idxb(j):idxe(j));
        
        varP1 = var(Pj);

        % filter signal
        switch lower(OPT.filter)
            case 'hann'
                Pj = Pj.*(0.5*(1-cos(2*pi*(0:nr-1)/(nr-1))))';
                varP2 = var(Pj);
            case 'hamming'
                Pj = Pj.*(0.54-0.46*cos(2*pi*(0:nr-1)/(nr-1)))';
                varP2 = var(Pj);
            otherwise
                varP2 = varP1;
        end

        Q   = fft(Pj,[],1)/nr;
        
%         if OPT.u_spec == true
%             V   = sqrt(2*2/df*abs(Q).^2);  
%         else
            V   = 2/df*abs(Q).^2;
%         end
        
        % restore total variance
        if OPT.correction
            V = varP1/varP2*V;
        end

        Snn(:,i) = Snn(:,i) + squeeze(V(1:floor(nr/2)))/nw;
        
    end
    
    mininf      = max(floor(0.005/df),1);
    maxinf      = ceil(OPT.fsplit/df);
    maxhf       = min(ceil(OPT.fcutoff/df),length(Snn(:,i)));
    if OPT.u_spec == true
        hrms(i)     = sqrt(trapz(f(1:maxhf),Snn(1:maxhf,i)));
        hrmslo(i)   = sqrt(trapz(f(mininf:maxinf),Snn(mininf:maxinf,i)));
        hrmshi(i)   = sqrt(trapz(f(maxinf+1:maxhf),Snn(maxinf+1:maxhf,i)));
    else
        hrms(i)     = sqrt(8*trapz(f(1:maxhf),Snn(1:maxhf,i)));
        hrmslo(i)   = sqrt(8*trapz(f(mininf:maxinf),Snn(mininf:maxinf,i)));
        hrmshi(i)   = sqrt(8*trapz(f(maxinf+1:maxhf),Snn(maxinf+1:maxhf,i)));
    end
    % input/output check
    hrmsin      = 4*std(P)/sqrt(2);
    dhrms       = abs(hrms(i)-hrmsin);
    if dhrms > OPT.tolerance
        warning('OET:tolerance', 'Difference in input and output wave height (%5.4f) is greater than set tolerance (%5.4f)', dhrms, OPT.tolerance);
    end
end

Snn(f==0,:) = 0;

%% create xbeach structure

xbo = xs_empty();

settings = [];
fn       = fieldnames(OPT);
for i = 1:length(fn)
    settings  = xs_set(settings, fn{i}, OPT.(fn{i}));
end
xbo = xs_set(xbo, 'SETTINGS', settings);

xbo = xs_set(xbo, 'timeseries', ts      );
xbo = xs_set(xbo, 'f',          f       );
if OPT.u_spec == false
    xbo = xs_set(xbo, 'Snn',        Snn     );
    xbo = xs_set(xbo, 'Hrms_hf',    hrmshi  );
    xbo = xs_set(xbo, 'Hrms_lf',    hrmslo  );
    xbo = xs_set(xbo, 'Hrms_t',     hrms    );
elseif OPT.u_spec == true
    xbo = xs_set(xbo, 'Unn',        Snn     );
    xbo = xs_set(xbo, 'urms_hf',    hrmshi  );
    xbo = xs_set(xbo, 'urms_lf',    hrmslo  );
    xbo = xs_set(xbo, 'urms_t',     hrms    );
    xbo = xs_set(xbo, 'maxinf',     maxinf  );
end
xbo = xs_meta(xbo, mfilename, 'spectrum');
