function strSQL = pg_query(type, table, varargin)
%PG_QUERY  Builts a SQL query string from structures
%
%   Builts a SQL query string from structures specifying the different
%   clauses in the query. Each structure should have fields that match the
%   column names of the given table. The values are automatically casted
%   and escaped to the necessary string representations. The only
%   non-structure input is for the field list of the SELECT query, which is
%   a cell array.
%
%   Syntax:
%   strSQL = pg_query(type, table, <sqlWhere>)
%
%   Input:
%   type      = Type of query (SELECT/INSERT/UPDATE/DELETE)
%   table     = Table name
%   sqlWhere  = optional SELECT query.
%                   1:  Cell array with field list (empty = *)
%                   2:  Structure for WHERE clause (for '==' requests)
%                   3:  character with SQL code ( for '<' and '>' requests)
%               INSERT query:
%                   1:  Structure for VALUES clause
%               UPDATE query:
%                   1:  Structure for VALUES clause
%                   2:  Structure for WHERE clause
%               DELETE query:
%                   1:  Structure for WHERE clause
%
%   Output:
%   strSQL    = SQL query string
%
%   Example
%   strSQL = pg_query('SELECT', 'someTable', struct('id', 2));
%   strSQL = pg_query('SELECT', 'someTable', struct('id', 2), {'Column_1' 'Column_2'});
%   strSQL = pg_query('INSERT', 'someTable', struct('Column_1', 1, 'Column_2', 'someValue'));
%   strSQL = pg_query('UPDATE', 'someTable', struct('Column_1', 1, 'Column_2', 'someValue'), struct('id', 2));
%   strSQL = pg_query('DELETE', 'someTable', struct('id', 2));
%
%   See also pg_select_struct, pg_insert_struct, pg_update_struct

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
% Created: 30 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: pg_query.m 10720 2014-05-21 15:03:51Z boer_g $
% $Date: 2014-05-21 23:03:51 +0800 (Wed, 21 May 2014) $
% $Author: boer_g $
% $Revision: 10720 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_query.m $
% $Keywords: $

%% prepare input

m = 3;
n = length(varargin);
varargin(n+1:m) = cell(1,m-n);

if ischar(varargin{1})
    varargin{1} = cellstr(varargin{1});
end

if ~iscell(varargin{1})
    error('argument 2 is not a char or cell: requested ')
end

if ~isstruct(varargin{2})
    error('argument 3 is not a struct.')
end

%% built query

switch upper(type)
    case 'SELECT'
        strSQLSelect    = builtSQLSelect(varargin{1});
        strSQLWhere     = builtSQLWhere(varargin{2});
        
        strSQL = sprintf('SELECT %s FROM "%s" %s', strSQLSelect, table, strSQLWhere);
        
    case 'INSERT'
        strSQLInsert    = builtSQLInsert(varargin{1});
        
        strSQL = sprintf('INSERT INTO "%s" %s', table, strSQLInsert);
        
    case 'UPDATE'
        strSQLUpdate    = builtSQLUpdate(varargin{1});
        strSQLWhere     = builtSQLWhere(varargin{2});
        
        strSQL = sprintf('UPDATE "%s" %s %s', table, strSQLUpdate, strSQLWhere);
        
    case 'DELETE'
        strSQLWhere     = builtSQLWhere(varargin{1});
        
        strSQL = sprintf('DELETE FROM "%s" %s', table, strSQLWhere);
end

function strSQL = builtSQLSelect(fields)

strSQL = '*';
fields = pg_quote(fields);

if ~isempty(fields)
    if iscell(fields{1})
        strSQL = concat(fields{1}, ',');
    else
        strSQL = concat(fields, ',');
    end
    
    strSQL = sprintf(' %s ', strSQL);
end

function strSQL = builtSQLWhere(where)

strSQL = '';

if isstruct(where)
    
    f = pg_quote(fieldnames(where));

    if ~isempty(where) && ~isempty(f)

        v           = struct2cell(where);

        [v{:}]      = pg_value2sql(v{:});

        % determine comparison type
        fv          = cell(size(f));
        for i = 1:length(f)
            if regexp(v{i}, '^''.*%.*''$')
                fv{i} = concat([f(i) v(i)], ' LIKE ');
            elseif regexp(v{i}, '^\s*IN\s+\(')
                fv{i} = concat([f(i) v(i)], ' ');
            else
                fv{i} = concat([f(i) v(i)], ' = ');
            end
        end
        
        strSQL      = sprintf(' WHERE %s ', concat(fv,' AND '));
    end
    
elseif ischar(where)

   strSQL = where;

end

function strSQL = builtSQLInsert(insert)

strSQL = '';

if isstruct(insert)
    
    f = fieldnames(insert);
    
    % make column vectors, to unify numeric and char(date) variables
    for i=1:length(f)
        if isnumeric(insert.(f{i}))
            insert.(f{i}) = insert.(f{i})(:);
        end
    end
    
    f = pg_quote(f);

    if ~isempty(insert) && ~isempty(f)

        v           = struct2cell(insert);
        
        % make loop for inserting combined numeric-char column vectors
        % (instead of scalars)
        for i=1:size(v{1},1)
           v1 = cellfun(@(x) x(i,:),v,'UniformOutput',0);
           [v1{:}]      = pg_value2sql(v1{:});
           if i==1
           strSQL      =  sprintf(' (%s) VALUES (%s) ', concat(f,', '), concat(v1, ', '));
           else
           strSQL      = [strSQL, sprintf(',(%s) ', concat(v1, ', '))];
           end
        end

    end
end

function strSQL = builtSQLUpdate(update)

strSQL = '';

if isstruct(update)
    
    f = pg_quote(fieldnames(update));

    if ~isempty(update) && ~isempty(f)

        v           = struct2cell(update);

        [v{:}]      = pg_value2sql(v{:});

        strSQL      = sprintf(' SET %s ', concat(concat([f v],' = '),', '));
    end
end