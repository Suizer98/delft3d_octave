function result = durosduneerosionresult(varargin)
%DUNEEROSIONRESULT creates an empty dune erosion calculation struct.
%
% routine to create an empty structure containing various field which are
% relevant for a DUROS calculation
% Specific fields can be predefined by use of PropertyName-PropertyValue
% pairs.
%
% Syntax:       result = createEmptyDUROSResult
%
% Input:
% result = structure
%
% Output:
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
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

% $Id: durosduneerosionresult.m 2616 2010-05-26 09:06:00Z geer $ 
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/engines/durosduneerosionresult.m $

%%
result = struct(...
    'info', [],...
    'VTVinfo', [],...
    'Volumes', [],...
    'xLand', [],...
    'zLand', [],...
    'xActive', [],...
    'zActive', [],...
    'z2Active', [],...
    'xSea', [],...
    'zSea', []);

result.Volumes = struct(...
    'Volume',[],...
    'volumes',[],...
    'Accretion',[],...
    'Erosion',[]);

result.info = struct(...
    'time',[],...
    'ID',[],...
    'messages',[],...
    'x0',[],...
    'iter',[],...
    'precision',[],...
    'resultinboundaries',true,...
    'input',[],...
    'ToeProfile', false);

result.VTVinfo = struct(...
    'Xp',[],...
    'Zp',[],...
    'Xr',[],...
    'Zr',[],...
    'G',[],...
    'AVolume',[],...
    'TVolume',[]);

[result.Volumes varargin] = applyInput(result.Volumes, varargin{:});
[result.info varargin] = applyInput(result.info, varargin{:});
[result.VTVinfo varargin] = applyInput(result.VTVinfo, varargin{:});
result = applyInput(result, varargin{:});

%% apply predefined input
function varargout = applyInput(OPT, varargin)
% subfunction to assign values which are specified in varargin to the
% related fields of the Duros structure

id = false(size(varargin));
for i = 1:2:length(varargin)
    [id(i) id(i+1)] = deal(any(strcmpi(varargin{i}, fieldnames(OPT))));
end

varargout = {setproperty(OPT, varargin{id}) varargin(~id)};