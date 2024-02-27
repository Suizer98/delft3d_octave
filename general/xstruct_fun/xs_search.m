function result = xs_search(xs,varargin)
%XS_SEARCH  Simple search routine for XStructs
%
%   Searches names and values in an XStruct for certain patterns. Uses
%   strfilter for the pattern matching, so supports plain text matching,
%   asterix matching and regular expressions. Displays an interactive list
%   with matches and returns matched indices and a filtered version of the
%   original XStruct.
%
%   Syntax:
%   [xsf m mn] = xs_search(xs,varargin)
%
%   Input:
%   xs        = XStruct to be searched
%   varargin  = filters according to the strfilter specifications
%
%   Output:
%   xsf       = Filtered XStruct with only matching fields
%   m         = Top-level variable indexes of original XStruct containing
%               matches. This is an array containing booleans indicating if
%               top-level fields matches.
%   mn        = Nested variable indexes of original XStruct containing
%               matches. This is a cell array containing booleans
%               indicating if a field matches or other cell arrays
%               indicating substructures matches.
%
%   Example
%   xs_search(xs,'1234')
%   xs_search(xs,'*test*')
%   xs_search(xs,'/[A-Z].*[0-9]')
%   xs_search(xs,'*test*','1234')
% 
%   xsf = xs_search(xs,'*test*')
%   xs_show(xsf)
%
%   [xsf m mn] = xs_search(xs,'*test*')
%   {xs.data(m).name}
%
%   See also xs_set, xs_show, strfilter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 May 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: xs_search.m 7431 2012-10-11 07:10:15Z hoonhout $
% $Date: 2012-10-11 15:10:15 +0800 (Thu, 11 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7431 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_search.m $
% $Keywords: $

%% read options

if ~xs_check(xs); error('Invalid XStruct'); end;

xsf = xs;
dbs = dbstack;

if ~isfield(xs,'path'); xs.path = {inputname(1)}; end;

%% search XStruct

% store unique values and fields
vdu = {};
ndu = {};

% intialize index vectors
m  = false(1,length(xs.data));
mn = num2cell(m);

% loop through fields
for i = 1:length(xs.data)

    % create breadcrumb
    b1 = sprintf('%s.',xs.path{1:end});
    b2 = sprintf('%s.',xs.path{2:end});
    b  = sprintf('<a href="matlab:xs_show(%s, ''%s'');">%s</a>', xs.path{1}, b2(1:end-1), b1(1:end-1));

    % read name/value pair for current field
    n = xs.data(i).name;
    v = xs.data(i).value;
    
    % determine variable class and convert to string representation
    if xs_check(v)
        vd = sprintf('<a href="matlab:xs_show(%s, ''%s'');">nested</a>', xs.path{1}, [b2 n]);
    else
        switch class(v)
            case {'logical' 'single' 'double' 'int8' 'int16' 'int32' 'int64'}
                vd = num2str(v(:)');
            case 'char'
                vd = v;
            case 'cell'
                vd = sprintf('%s ',v{:});
            otherwise
                vd = [];
        end
    end

    % match field name
    if strfilter(n,varargin)
        ndu = unique([ndu {n}]);
        if ~xs_check(v)
            vdu = unique([vdu {vd}]);
        end
        fprintf('%-20s: %s\n',[b '.' n],vd);
        mn{i} = true;
    end

    % search substructure, if available
    if xs_check(v)
        v.path     = [xs.path{:} {n}];
        subresult = xs_search(v,varargin{:});
        xsf.data(i).value = subresult.filtered;
        if ~isempty(subresult) && any(subresult.indices)
            mn{i}             = subresult.indices_nested;
            vdu               = unique([vdu subresult.values]);
            ndu               = unique([ndu subresult.names]);
        end
    else

        % if variable class is supported, search for matches
        if ~isempty(v)
            if strfilter(v,varargin)
                ndu = unique([ndu {n}]);
                vdu = unique([vdu {vd}]);
                fprintf('%-20s: %s\n',[b '.' n],vd);
                mn{i} = true;
            end
        end
    end
end

% convert nested indices to top-level indices
m = cellfun(@(x)~islogical(x)||x,mn);

% finalize filtered structure
if length(dbs)<=1 || ~strcmpi(dbs(end-1).name, mfilename)
    xsf.data = xsf.data(m);
end

% build result structure
result = struct( ...
    'filtered',         xsf,     ...
    'indices',          find(m), ...
    'indices_nested',   {mn},    ...
    'names',            {ndu},   ...
    'values',           {vdu}       );