function xs_show(xs, varargin)
%XS_SHOW  Shows contents of a XStruct
%
%   WHOS-like display of the contents of a XStruct
%
%   Syntax:
%   xs_show(xs)
%
%   Input:
%   xs          = XStruct array
%   varargin    = Variables to be included, by default all variables are
%                 included. Filters can be used select multiple variables
%                 at once (exact match, dos-like, regexp, see strfilter).
%                 If a nested XStruct array is specifically
%                 requested (exact match), an extra xs_show is fired
%                 showing the contents of the nested struct.
%
%   Output:
%   none
%
%   Example
%   xs_show(xs)
%   xs_show(xs, 'zb', 'zs')
%   xs_show(xs, 'z*')
%   xs_show(xs, '/^z')
%   xs_show(xs, 'bcfile')
%   xs_show(xs, 'bcfile', 'zs')
%
%   See also xs_set, xs_get, xs_empty, strfilter

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
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_show.m 7931 2013-01-18 16:34:36Z hoonhout $
% $Date: 2013-01-19 00:34:36 +0800 (Sat, 19 Jan 2013) $
% $Author: hoonhout $
% $Revision: 7931 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_show.m $
% $Keywords: $

%% show structure contents

if ~xs_check(xs); error('Invalid XStruct'); end;

% show structure array
if length(xs)>1
    for i = 1:length(xs)
        xs_show(xs(i), varargin{:});
    end
    return;
end

% determine namespace
namespace = regexp(xs.function,'^(.+?)_','tokens');
namespace = namespace{1}{1};

idx = strcmpi('-passive',varargin);
is_interactive = ~any(idx);
varargin = varargin(~idx);

% determine variables to be showed, show xs_show for specifically requested
% XSstruct sub-structures
if ~isempty(varargin)
    vars = {};
    for i = 1:length(varargin)
        if xs_exist(xs, varargin{i}) == 1
            val = xs_get(xs, varargin{i});
            if xs_check(val)
                if length(val)>1
                    for j = 1:length(val)
                        val(j).path = sprintf('%s.%s[%d]', inputname(1), varargin{i}, j);
                    end
                else
                    val.path = [inputname(1) '.' varargin{i}];
                end
                xs_show(val);
            else
                vars = [vars{:} varargin(i)];
            end
        else
            vars = [vars{:} varargin(i)];
        end
    end
else
    vars = {xs.data.name};
end

% parse path in substructure
path = struct('root', inputname(1), 'self', '', 'parent', '', 'obj', inputname(1), ...
    'fullself', inputname(1), 'fullparent', '');
if isfield(xs, 'path')
    if iscell(xs.path)
        xs.path = concat(xs.path, '.');
    end
    p = regexp(xs.path, '\.', 'split');
    
    path.root     = p{1};
    path.self     = sprintf('.%s', p{2:end});
    path.self     = path.self(2:end);
    path.fullself = sprintf('%s, ''%s''', path.root, path.self);
    path.obj      = sprintf('xs_get(%s, ''%s'')', path.root, path.self);
    
    path.parent     = path.root;
    path.fullparent = path.root;
    
    if length(p) > 2
        path.parent     = sprintf('.%s', p{2:end-1});
        path.parent     = path.parent(2:end);
        path.fullparent = sprintf('%s, ''%s''', path.root, path.parent);
    end
end

if ~isempty(vars)
    
    % identify data
    f = fieldnames(xs);
    idx = strcmpi('data',f);

    % determine max fieldname length
    max_length = max(cellfun(@length, f));

    % show meta data
    for i = find(~idx)'
        nr_blanks = max_length - length(f{i});
        value = regexprep(xs.(f{i}), '\n', ['\n' blanks(max_length+3)]);
        fprintf('%s%s : %s\n', f{i}, blanks(nr_blanks), value);
    end

    fprintf('\n');

    % show data
    format = '%-15s %-10s %-10s %-10s %-10s %-30s %-30s';
    fprintf([format '\n'], 'variable', 'size', 'bytes', 'class', 'units', 'value', 'dimensions');
    for i = 1:length(xs.data)
        if ~any(strfilter(xs.data(i).name, vars)); continue; end;

        var = xs_get(xs, xs.data(i).name);
        info = whos('var');

        % determine display of value
        if ~isstruct(var) && ~iscell(var) && (isscalar(var) || isvector(var))
            if size(var,1) > size(var,2)
                var = var';
            end
            if isnumeric(var) || islogical(var)
                value = num2str(var);
            else
                value = var;
            end
        else
            value = '';
        end
        
        maxl = 30;

        % remove multiple spaces
        if length(value) > 2*maxl
            value = regexprep(value(1:2*maxl), '\s+', ' ');
        else
            value = regexprep(value, '\s+', ' ');
        end

        % maximize length
        if length(value) > maxl
            value = [value(1:(maxl/2-2)) ' .. ' value(end-(maxl/2-3):end)];
        end
        
        % determine current child
        if isempty(path.self)
            child = xs.data(i).name;
        else
            child = [path.self '.' xs.data(i).name];
        end

        % link xseach substructs
        if xs_check(var)
            if ~isempty(path.root) && is_interactive
                cmd = sprintf('matlab:xs_show(%s, ''%s'');', path.root, child);
                class = ['<a href="' cmd '">nested</a>    '];
            else
                class = 'nested    ';
            end
        else
            class = info.class;
        end
        
        % determine dimensions
        dimensions = '';
        if isfield(xs.data(i), 'dimensions')
            if iscell(xs.data(i).dimensions)
                dimensions = sprintf('%s ',xs.data(i).dimensions{:});
            else
                dimensions = xs.data(i).dimensions;
            end
        end
        
        % determine units
        units = '';
        if isfield(xs.data(i), 'units')
            units = xs.data(i).units;
        end
        
        % add commands
        menu = {};
        if ~isempty(path.root) && is_interactive
            cmd = sprintf('matlab:xs_get(%s, ''%s'')', path.root, child);
            menu = [menu{:} {['<a href="' cmd '">get</a>']}];
            
            cmd = sprintf('matlab:%s = xs_set(%s, ''%s''); xs_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">set</a>']}];
            
            cmd = sprintf('matlab:%s = xs_del(%s, ''%s''); xs_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">del</a>']}];
            
            cmd = sprintf('matlab:%s = xs_rename(%s, ''%s''); xs_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">ren</a>']}];
        end
        cmds = sprintf(' %s', menu{:});

        fprintf([format cmds '\n'], xs.data(i).name, ...
            regexprep(num2str(info.size),'\s+','x'), ...
            num2str(info.bytes), ...
            class, ...
            units, ...
            value, ...
            dimensions);
    end
    
    fprintf('\n');
    
    % add action menu
    if ~isempty(path.root) && is_interactive
        menu = {};

        if ~isempty(path.fullparent)
            cmd = sprintf('matlab:xs_show(%s);', path.fullparent);
            menu = [menu{:} {['<a href="' cmd '">parent</a>']}];
        end

        % add custom menu options
        fname = sprintf('xs_options_%s',namespace);
        if exist(fname,'file')
            menu = [menu feval(fname,xs,path)];
        end

        if ~isempty(menu)
            fprintf('%-14s: %s\n\n', 'options', sprintf('%s ', menu{:}));
        end
    end
end