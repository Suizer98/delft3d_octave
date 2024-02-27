function [OPT varargin_filtered Set Default] = setproperty_filter(OPT, varargin)
%SETPROPERTY_FILTER  as setproperty but only use relevant varargin elements relevant
%
%   Routine is pre-processing step before setproperty, in order to filter
%   the varargin cell array. The relevant elements are used to update the
%   settings in the OPT structure. The remaining elements are returned as
%   varargin_filtered.
%
%   Syntax:
%   varargout = setproperty_filter(varargin)
%
%   Input:
% OPT      = structure in which fieldnames are the keywords and the values are the defaults 
% varargin = series of PropertyName-PropertyValue pairs to set
%
%   Output:
% OPT     = structure, similar to the input argument OPT, with possibly
%           changed values in the fields
% varargin_filtered = as varargin cell array, but excluding the elements
%                     relevant to OPT structure
% Set     = structure, similar to OPT, values are true where OPT has been 
%           set (and possibly changed)
% Default = structure, similar to OPT, values are true where the values of
%           OPT are equal to the original OPT
%
%   Example
%   setproperty_filter
%
%   See also setproperty setpropertyInDeeperStruct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 02 Feb 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: setproperty_filter.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/setproperty_filter.m $
% $Keywords: $

%%
PropertyNames = fieldnames(OPT); % read PropertyNames from structure fieldnames

if isscalar(varargin)
    if isstruct(varargin{1})
        % apply properties of second OPT structure to the original one
        OPT2     = varargin{1};
        varargin = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
    elseif iscell(varargin{1})
        % to prevent errors when this function is called as
        % "OPT = setproperty(OPT, varargin);" instead of
        % "OPT = setproperty(OPT, varargin{:})"
       varargin = varargin{1};
    end
end

% Set is similar to OPT, initially all fields are false
Set = cell2struct(repmat({false}, size(PropertyNames)), PropertyNames);
% Default is similar to OPT, initially all fields are true
Default = cell2struct(repmat({true}, size(PropertyNames)), PropertyNames);

%%
% identify strings in varargin (omit last element because this can never be
% a keyword since there is no room for the corresponding value)
charid = find(cellfun(@ischar, varargin(1:end-1)));
% find elements in varargin matching to field names in OPT
filter_id = strcmpi(fieldnames(OPT), varargin(charid));
if any(filter_id)
    % update OPT structure
    filter_id = charid(filter_id) + [0 1];
    [OPT Set Default] = setproperty(OPT, varargin{filter_id});
    varargin(filter_id) = [];
end

varargin_filtered = varargin;