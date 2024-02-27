function identical = compvar(v1, v2)
%COMPVAR  Compare two arbritrary variables
%
%   Compare two arbritrary variables, possibly of different size and type.
%
%   Syntax:
%   identical = compvar(v1, v2)
%
%   Input:
%   v1          = First variable to compare
%   v2          = Second variable to compare
%
%   Output:
%   identical   = Boolean indicating if the two variables are identical
%
%   Example
%   if compvar(v1, v2); disp('Identical!'); end;
%
%   See also is_binary

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 01 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: compvar.m 4136 2011-03-01 12:57:56Z hoonhout $
% $Date: 2011-03-01 20:57:56 +0800 (Tue, 01 Mar 2011) $
% $Author: hoonhout $
% $Revision: 4136 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/compvar.m $
% $Keywords: $

%% compare two variables

c1 = class(v1);
c2 = class(v2);

identical = true;

if ~strcmpi(c1, c2)
    identical = false;
else
    switch c1
        case 'logical'
            if v1 ~= v2
                identical = false;
            end
        case {'single' 'double' ...
                'int8' 'int16' 'int32' 'int64' ...
                'uint8' 'uint16' 'uint32' 'uint64' ...
                'function_handle'}
            
            if ndims(v1) == ndims(v2)
                if all(size(v1) == size(v2))
                    i = all(v1 == v2 | (isnan(v1) & isnan(v2)));
                    while ~isscalar(i)
                        i = all(i);
                    end
                    
                    if ~i; identical = false; end;
                else
                    identical = false;
                end
            else
                identical = false;
            end
        case 'char'
            identical = strcmp(v1, v2);
        case 'struct'
            f = unique(cat(1,fieldnames(v1),fieldnames(v2)));
            for i = 1:length(f)
                if isfield(v1, f{i}) && isfield(v2, f{i})
                    if ~compvar(v1.(f{i}), v2.(f{i}))
                        identical = false;
                        break;
                    end
                end
            end
        case 'cell'
            i = all(cellfun(@compvar, v1, v2));
            while ~isscalar(i)
                i = all(i);
            end
            
            if ~i; identical = false; end;
    end
end