function [z ErosionVolume result] = x2z_DUROS(varargin)
%X2Z_DUROS  Limit state function
%
%   More detailed description goes here.
%
%   Syntax:
%   [z ErosionVolume] = x2z_DUROS(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   x2z_DUROS
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: x2z_DUROS.m 13138 2017-01-20 15:31:34Z bieman $
% $Date: 2017-01-20 23:31:34 +0800 (Fri, 20 Jan 2017) $
% $Author: bieman $
% $Revision: 13138 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/Z/x2z_DUROS.m $

%%
OPT = struct();

try
    OPT = struct(...
        'Resistance', 50,...
        'xInitial', [-250; -24.375; 5.625; 55.725; 230.625; 1950],...
        'zInitial', [15; 15; 3; 0; -3; -14.4625],...
        'WL_t', [],...
        'Hsig_t', [],...
        'Tp_t', [],...
        'D50', [],...
        'Duration', [],...
        'Accuracy', [],...
        'Angle', 0,...
        'AngleFcn', @(Angle) interp1(50:-10:0, [0.2809 0.3011 0.2686 0.188 0.074 0], Angle),...
        'R', [],...
        'zRef', 5);

    OPT = setproperty(OPT, varargin{:});
catch
    f = fieldnames(OPT);
    
    error('OET:DUROS:deprecated', [ ...
            'The argument list of the x2z_DUROS function has changed to meet the ' ...
            'new standards of the probabilistics toolbox. Please adjust the ' ...
            'argument list to use name/value pairs with the following names: ' ...
            sprintf('%s ',f{:})]);
end

%% cross-shore profile
xInitial = OPT.xInitial(~isnan(OPT.zInitial));
zInitial = OPT.zInitial(~isnan(OPT.zInitial));

% reference for retreat distance
xRef = max(findCrossings(xInitial, zInitial, [min(xInitial) max(xInitial)]', ones(2,1)*OPT.zRef));

if isscalar(OPT.Angle) && ~isscalar(OPT.D50)
    OPT.Angle = repmat(OPT.Angle, size(OPT.D50));
end

for i = 1:length(OPT.D50)
%     try
        %% set calculation values for additional volume
        DuneErosionSettings('set',...
            'AdditionalErosionMax', false,...
            'AdditionalVolume', [num2str(OPT.Duration(i)) '*Volume + ' num2str(OPT.AngleFcn(OPT.Angle(i))) '*Volume + ' num2str(OPT.Accuracy(i)) '*Volume'],... % string voor het bepalen van het toeslagvolume gedurende de berekening (afslagvolume is negatief)
            'BoundaryProfile', false,...       % Grensprofiel berekenen is niet nodig, gebruiken we niet
            'FallVelocity', {@getFallVelocity 'a' 0.476 'b' 2.18 'c' 3.226 'D50'});

        % set coastal curvature, if provided
        if ~isempty(OPT.R) && numel(OPT.R) >= i
            DuneErosionSettings('set', 'Bend', 180 / (pi * OPT.R(i)) * 1000);
        else
            DuneErosionSettings('set', 'Bend', 0);
        end

        %% carry out DUROS+ computation
        [resultTemp messages] = DUROS(xInitial, zInitial, OPT.D50(i), OPT.WL_t(i), OPT.Hsig_t(i), OPT.Tp_t(i));
        result{i} = resultTemp;

        %% derive z-value

        [RD(i) ErosionVolume(i)] = getRetreatDistance(resultTemp, messages, xRef);

        if length(resultTemp) > 1
            OPT.Duration(i) = -resultTemp(2).Volumes.Volume*OPT.Duration(i);
            OPT.Accuracy(i) = -resultTemp(2).Volumes.Volume*OPT.Accuracy(i);
            OPT.Angle(i) = -resultTemp(2).Volumes.Volume*OPT.Angle(i);
        end

        z(i,:) = OPT.Resistance - RD(i);
end