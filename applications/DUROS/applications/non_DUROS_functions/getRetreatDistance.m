function varargout = getRetreatDistance(result, varargin)
%GETRETREATDISTANCE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getRetreatDistance(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getRetreatDistance
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

% Created: 14 Jan 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: getRetreatDistance.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/non_DUROS_functions/getRetreatDistance.m $

%%
OPT = struct(...
    'zRef', 5);

OPT = setproperty(OPT, varargin{:});

[xInitial zInitial] = deal([result(1).xLand; result(1).xActive; result(1).xSea],...
    [result(1).zLand; result(1).zActive; result(1).zSea]);

xRef = max(findCrossings(xInitial, zInitial, [min(xInitial) max(xInitial)]', ones(2,1)*OPT.zRef));

for i = 1:length(result)
    RD(i) = xRef - result(i).xActive(1);
end

varargout = {RD};
