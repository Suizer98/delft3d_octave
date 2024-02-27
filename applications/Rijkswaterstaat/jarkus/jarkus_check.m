function [valid message] = jarkus_check(transects, varargin)
%JARKUS_CHECK  Checks validity of jarkus result structure
%
%   Checks validity of JARKUS structure resulting from the jarkus_transects
%   function. Checks for variable type struct, existing fields and their
%   dimensions. Returns a boolean to indicate validity and a cell with
%   messages if structure is not valid.
%
%   Syntax:
%   [valid message] = jarkus_check(transects, varargin)
%
%   Input:
%   transects   = jarkus struct to be checked
%   varargin    = list of strings or cells with fields that should be
%                   present in the jarkus struct. in case of a cell, the
%                   first item is the fieldname and the second, optional
%                   item is a minimum dimension number.
%
%   Output:
%   valid       = boolean that indicates validity
%   message     = cell with messages if valid is false
%
%   Example
%   [valid message] = jarkus_check(transects, 'id', {'altitude' 3}, {'time'})
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 22 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: jarkus_check.m 2485 2010-04-26 07:44:37Z hoonhout $
% $Date: 2010-04-26 15:44:37 +0800 (Mon, 26 Apr 2010) $
% $Author: hoonhout $
% $Revision: 2485 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_check.m $
% $Keywords: $

%% basic check

im = 1;
message = {};

% check structure
if ~isstruct(transects)
    message{im} = 'Invalid transect structure given, see jarkus_transects for more information';
    im = im + 1;
end

% check fields
for i = 1:length(varargin)
    field = varargin{i};
    
    if ~iscell(field); field = {field}; end;
    
    if ~isempty(field)
        if ~isfield(transects, field{1})
            message{im} = ['Required property "' field{1} '" not given'];
            im = im + 1;
        elseif length(field) > 1
            if ndims(transects.(field{1})) < field{2}
                message{im} = ['Insufficient dimensions for property "' field{1} '" (' num2str(field{2}) ')'];
                im = im + 1;
            end
        end
    end
end

valid = isempty(message);

%% additional checks

%% display warnings

for i = 1:length(message)
    warning(message{i});
end
