function [x2 z2 result2] = getFinalProfile(result, varargin)
%GETFINALPROFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getFinalProfile(varargin)
%
%   Input:
%   result    = result structure obtained from getDuneErosion
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getFinalProfile
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
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

% Created: 07 Jan 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: getFinalProfile.m 1825 2009-10-22 07:57:15Z geer $
% $Date: 2009-10-22 15:57:15 +0800 (Thu, 22 Oct 2009) $
% $Author: geer $
% $Revision: 1825 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/6_Visualization/getFinalProfile.m $

%%
xInitial = [result(1).xLand; result(1).xActive; result(1).xSea];
zInitial = [result(1).zLand; result(1).zActive; result(1).zSea];

if length(result) < 3
    x2 = [result(1).xLand; result(1).xActive; result(1).xSea];
    z2 = [result(1).zLand; result(1).z2Active; result(1).zSea];
else
    x2 = [result(3).xLand; result(3).xActive; result(3).xSea];
    z2 = [result(3).zLand; result(3).z2Active; result(3).zSea];
end

if length(x2)>1
    [Volume result2] = getVolume(xInitial, zInitial, [], [], [], [], x2, z2);
else
    result2 = createEmptyDUROSResult;
    result2.Volumes.Erosion = 0;
end
%{
plotDuneErosion(result2)

result2.Volumes
%}