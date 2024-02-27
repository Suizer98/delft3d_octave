function s = struct_flip(s, varargin)
%STRUCT_FLIP  Flips a values of a structure to the keys of a structure
%
%   Picks a field, by default the field 'Name', from a structure and uses
%   it as keys for another structure. The values are taken from another
%   field, by default the 'Value', 'Values' or 'Data' field, otherwise the
%   first field found.
%
%   Syntax:
%   s = struct_flip(s, varargin)
%
%   Input:
%   s         = structure
%   varargin  = 1:  field to be used as keys
%               2:  field to be used as values
%
%   Output:
%   s         = flipped structure
%
%   Example
%   f = struct_flip(s)
%
%   See also 

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
% Created: 22 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: struct_flip.m 3422 2010-11-24 15:05:29Z hoonhout $
% $Date: 2010-11-24 23:05:29 +0800 (Wed, 24 Nov 2010) $
% $Author: hoonhout $
% $Revision: 3422 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/struct_flip.m $
% $Keywords: $

%% read options

if ~isstruct(s)
    error('Provided parameter is no struct');
end

fieldnames = fields(s);

if ~isempty(varargin)
    key = varargin{1};
    if length(varargin)>1
        value = varargin{2};
    end
else
    keys = fieldnames(strcmpi('name', fieldnames));
    if ~isempty(keys)
        key = keys{1};
    end
end

if ~exist('key','var') || ~ismember(key, fieldnames)
    error(['Key value not found [' key ']']);
end

if ~exist('value','var')
    preferred = {'value','values','data'};
    for i = 1:length(preferred)
        values = fieldnames(strcmpi(preferred{i}, fieldnames));
        if ~isempty(values)
            value = values{1};
            break;
        end
    end
    
    if ~exist('value','var')
        values = fieldnames(~strcmp(key, fieldnames));
        if ~isempty(values)
            value = values{1};
        else
            error('No flipping material!');
        end
    end
end

%% flip struct

keys = {s.(key)};
vals = {s.(value)};

if ~isempty(keys)
    s = cell2struct(vals, keys, 2);
else
    s = struct();
end

