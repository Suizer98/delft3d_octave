function varargout = pg_getid(conn, table, varargin)
%PG_GETID  Retrieves primary key value for specific record in given table
%
%   Retrieves primary key value for specific record in given table in
%   current database. The record is specified by a set of name/value pairs
%   that describe a WHERE clause in the SQL query or a structure describing
%   the same WHERE clause. If the WHERE clause is not too specific it may
%   return multiple ID's, which are returned as multiple result variables.
%
%   Syntax:
%   varargout = pg_getid(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table from which a primary key value is needed
%   varargin  = structure or name/value pairs of table columns and
%               corresponding values that describe the WHERE clause in the
%               SQL query
%
%   Output:
%   varargout = Unique primary key value for each returned record
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   id = pg_getid(conn, 'someTable', 'description', 'The One');
%   id = pg_getid(conn, 'someTable', 'x', x, 'y', y);
%   id = pg_getid(conn, 'someTable', struct('x', x, 'y', y));
%
%   See also pg_getpk, pg_gettables, pg_getcolumns, pg_connect_db

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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: pg_getid.m 7083 2012-07-31 13:08:30Z hoonhout $
% $Date: 2012-07-31 21:08:30 +0800 (Tue, 31 Jul 2012) $
% $Author: hoonhout $
% $Revision: 7083 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_getid.m $
% $Keywords: $

%% read options

OPT = struct();

if ~isempty(varargin)
    if isstruct(varargin{1})
        OPT = varargin{1};
    else
        if odd(length(varargin))
            varargin = varargin(1:end-1);
        end

        OPT = cell2struct(varargin(2:2:end)', varargin(1:2:end));
    end
end

varargout = num2cell(zeros(1,nargout));

%% get id

ids = pg_select_struct(conn, table, OPT, pg_getpk(conn, table));

if ~isempty(ids)
    varargout(1:length(ids)) = ids;
end
