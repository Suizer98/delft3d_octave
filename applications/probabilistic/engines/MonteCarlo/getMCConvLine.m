function [P diffP] = getMCConvLine(result, varargin)
% getMCConvLine: Determines development of the calculated probability of failure from Monte Carlo result set for increasing number of samples
%
%   Determines development of the calculated probability of failure from
%   Monte Carlo result set for increasing number of samples
%
%   Syntax:
%   [P diffP] = getMCConvLine(result, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'step'    = resolution of number of samples axis
%                               (default: 1)
%
%   Output:
%   P           = array with resulting probabilities of failure
%   diffP       = difference array of P
%
%   Example
%   P = getMCFreqLine(result)
%
%   See also MC

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

% Created: 28 september 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getMCConvLine.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/getMCConvLine.m $

%% settings
OPT = struct(...
    'step',1 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine z-values

P = [];

Z = result.Output.z;

% check if correction factors are necessary and available
if ~isfield(result.Output, 'Pcor') || isempty(result.Output.Pcor)
    if result.settings.f1 < Inf || result.settings.f2 > 0
        disp('Error: advanced importance sampling enabled, but correction factors not given');
        return
    else
        result.Output.Pcor = ones(length(Z), 1);
    end
end

j = 1;
for i = 1:OPT.step:length(Z)
    P(j) = sum((Z(1:i)<0) .* result.Output.Pcor(1:i)) / (i * max(1, result.settings.W));
    j = j + 1;
end

diffP = diff(P);