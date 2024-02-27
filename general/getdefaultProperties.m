function varargout = getdefaultProperties(varargin)
% GETDEFAULTPROPERTIES   routine to find default properties
%
% Routine finds the default properties corresponding to the specified type.
% The type can either be specified as a string or as a handle
%
% Syntax:
% varargout = getdefaultProperties(varargin)
%
% Input:
% varargin  = either a handle or a string
%
% Output:
% varargout = structure containing the default properties
%
% See also: get

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

% $Id: getdefaultProperties.m 99 2008-12-11 21:49:00Z heijer $ 
% $Date: 2008-12-12 05:49:00 +0800 (Fri, 12 Dec 2008) $
% $Author: heijer $
% $Revision: 99 $

%%
for iargin = 1:length(varargin)
    if ishandle(varargin{iargin})
        % derive Type based on handle
        Type = get(varargin{iargin}, 'Type');
    elseif ischar(varargin{iargin})
        % Type is specified as a char
        Type = varargin{iargin};
        % make sure that the Type-string starts with a capital
        Type = [upper(Type(1)) lower(Type(2:end))];
    else
        error([upper(mfilename) ':UnknownType'], 'Wrong input or unknown Type')
    end
    warning off
    % get the factory defaults for the specified Type
    factoryDefaults = get(0, ['Factory' Type]);
    warning on
    % remove the first part of the fieldnames to only keep the property
    % names
    PropertyNames = cellfun(@(x) strrep(x, ['factory' Type], ''), fieldnames(factoryDefaults),...
        'UniformOutput', false);
    % isolate the property values
    PropertyValues = struct2cell(factoryDefaults);
    % create a combined cell array of property names and property values
    factoryDefaults = [PropertyNames PropertyValues]';
    % create property structure
    varargout{iargin} = struct(factoryDefaults{:});
end
