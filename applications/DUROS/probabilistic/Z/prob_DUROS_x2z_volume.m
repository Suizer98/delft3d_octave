function z = prob_DUROS_x2z_volume(varargin)
%PROB_DUROS_X2Z_VOLUME  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   z = prob_DUROS_x2z_volume(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   z =
%
%   Example
%   prob_DUROS_x2z_volume
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 07 Sep 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: prob_DUROS_x2z_volume.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/Z/prob_DUROS_x2z_volume.m $
% $Keywords: $

%%
[xInitial zInitial] = SimpleProfile;

OPT = struct(...
    'xInitial', xInitial,...
    'zInitial', zInitial,...
    'WL_t', [],...
    'Hsig_t', [],...
    'Tp_t', [],...
    'D50', [],...
    'Duration', [],...
    'Accuracy', [],...
    'Resistance', 0,...
    'zRef', 5);

OPT = setproperty(OPT, varargin{:});

%%
xRef = max(findCrossings(OPT.xInitial, OPT.zInitial, [min(OPT.xInitial) max(OPT.xInitial)]', ones(2,1)*OPT.zRef));

for icalc = 1:length(OPT.WL_t)
    %% set calculation values for additional volume
    DuneErosionSettings('set',...
        'AdditionalErosion', false,...
        'BoundaryProfile', false,...
        'FallVelocity', {@getFallVelocity 'a' 0.476 'b' 2.18 'c' 3.226 'D50'});
    
    %% carry out DUROS+ computation
    result = DUROS(OPT.xInitial, OPT.zInitial, OPT.D50(icalc), OPT.WL_t(icalc), OPT.Hsig_t(icalc), OPT.Tp_t(icalc));
    OPT.Tp_t(icalc) = result(1).info.input.Tp_t;
    
    %% Derive z-value
    [x2 z2 result2] = getFinalProfile(result);
    ErosionVolume(icalc) = result2.Volumes.Erosion;
    
    z(icalc,:) = OPT.Resistance - ErosionVolume(icalc);
end
