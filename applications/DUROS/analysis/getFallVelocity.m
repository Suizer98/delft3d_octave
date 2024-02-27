function w = getFallVelocity(varargin)
%GETFALLVELOCITY  routine to compute fall velocity of sediment in water
%
%   This routine returns the fall velocity of sediment with 
%   grain size D50 in water
%
%   Syntax:
%   w = getFallVelocity(varargin)
%   backward compatible with old syntax: w = getFallVelocity(D50, a, b, c)
%
%   Input:
%   varargin = 'PropertyName' - PropertyValue pairs:
%       D50 - Grain size D50 [m]
%       a   - coefficient in fall velocity formulation (default = 0.476, corrosponding with fresh water 5 degrees)
%       b   - coefficient in fall velocity formulation (default = 2.18, corrosponding with fresh water 5 degrees)
%       c   - coefficient in fall velocity formulation (default = 3.226, corrosponding with fresh water 5 degrees)
%
%   Output:
%   w   = fall velocity [m/s]
%
%   Example
%   getFallVelocity
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: getFallVelocity.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/getFallVelocity.m $
% $Keywords:

%% check input / set defaults
% backward compatible with old syntax: w = getFallVelocity(D50, a, b, c)
idPropName = cellfun(@ischar, varargin);
id = nargin;
if any(idPropName)
    id = find(idPropName, 1, 'first')-1;
end
OPT = struct(...
    'D50', 225e-6,...
    'a', 0.476,... % coefficient for 5 degrees celcius
    'b', 2.18,...  % coefficient for 5 degrees celcius
    'c', 3.226);   % coefficient for 5 degrees celcius

varNames = fieldnames(OPT)';

% create propertyName propertyValue cell array (varargin like) with empty
% values for the first input arguments where propertyNames are omitted
OPTstructArgs = reshape([varNames(1:id); repmat({[]}, 1, id)], 1, 2*id);

% add the actual input arguments in the cell array
OPTstructArgs(2:2:2*id) = varargin(1:id);

% extend the cell array with the propertyName propertyValue pairs part of
% the input
OPTstructArgs = [OPTstructArgs varargin(id+1:end)];

% include the input in the OPT-structure
OPT = setproperty(OPT, OPTstructArgs{:});

%% fall velocity formulation
% $$^{10} \log \left( {{1 \over w}} \right) = a\left( {^{10} \log D_{50} } \right)^2  + b\left( ^{10} \log D_{50} \right)  + c$$
w = 1 ./ (10.^(OPT.a * (log10(OPT.D50)).^2 + OPT.b * log10(OPT.D50) + OPT.c));