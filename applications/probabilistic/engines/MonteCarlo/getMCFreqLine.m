function [zValues freqs bins P] = getMCFreqLine(result, freqs, varargin)
% getMCFreqLine: Determines the Z-value for given failure frequencies based on interpolation of Monte Carlo results
%
%   Determines the Z-values by interpolation of Monte Carlo results of the
%   point in failure space with teh given frequencies of occurrence
%
%   BASED ON FUNCTION WRITTEN BY F.DIERMANSE DELTARES
%
%   Syntax:
%   [zValues freqs] = getMCFreqLine(result, freqs, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   freqs       = array with requested frequencies
%   varargin    = [for future use]
%
%   Output:
%   zValues     = array with resulting Z-values
%   freqs       = array with original requested frequencies
%   bins        = array with all Z-values from Monte Carlo result
%   P           = array with all frequencies corresponding to Z-values
%
%   Example
%   result = getMCFreqLine(result, freqs)
%
%   See also MC plotMCResult

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 29 juli 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getMCFreqLine.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/getMCFreqLine.m $

%% settings
OPT = struct(...
);

OPT = setproperty(OPT, varargin{:});

%% determine z-values

zValues = [];
bins = [];
P = [];

Z = -1 * result.Output.z + result.settings.Resistance;

% check if correction factors are necessary and available
if ~isfield(result.Output, 'Pcor') || isempty(result.Output.Pcor)
    if result.settings.f1 < Inf || result.settings.f2 > 0
        disp('Error: advanced importance sampling enabled, but correction factors not given');
        return
    else
        result.Output.Pcor = ones(length(Z), 1);
    end
end

if length(Z) >= 2
    [bins idx] = sort(Z, 'ascend');
    
    % calculate probabilities in bins
    for i = 1:length(bins)
        bin = bins(i);
        P(i) = sum((Z>=bin) .* result.Output.Pcor(idx)) / (max(1, result.settings.NrSamples) * max(1, result.settings.W));
    end
    
    % interpolate probabilities at requested frequencies
    for i = 1:length(freqs)
        freq = freqs(i);
        [zValue, errors] = interp1_log(P, bins, freq);

        zValues(i) = zValue;
    end
end

%% function P2f

function f = P2f(P)

idxZero = P == 0;
idxInf = P > 1-1e-9;
idx = ~idxZero & ~idxInf;

f(idxZero) = Inf;
f(idxInf) = 0;
f(idx) = -1 * log(1 - P(idx));