function varargout = pg_getpk(conn, table, varargin)
%PG_GETPK  Retrieve name of primary key for given table
%
%   Retrieve name of primary key for given table in current database and
%   returns its name.
%
%   Syntax:
%   pk_name = pg_getpk(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Name of table for which primary key is requested
%   varargin  = none
%
%   Output:
%   pk_name   = Name of primary key
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   pk = pg_getpk(conn, 'someTable');
%
%   See also pg_getid, pg_gettables, pg_getcolumns, pg_connectdb

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

% $Id: pg_getpk.m 7713 2012-11-22 12:31:11Z boer_g $
% $Date: 2012-11-22 20:31:11 +0800 (Thu, 22 Nov 2012) $
% $Author: boer_g $
% $Revision: 7713 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_getpk.m $
% $Keywords: $

%% read options

OPT = struct();

OPT = setproperty(OPT,varargin{:});

%% list tables
%  http://wiki.postgresql.org/wiki/Retrieve_primary_key_columns
%  http://postgresql.1045698.n5.nabble.com/how-to-find-primary-key-field-name-td4893701.html

strSQL = sprintf('SELECT pg_attribute.attname FROM pg_index, pg_class, pg_attribute WHERE pg_class.oid = ''%s''::regclass AND indrelid = pg_class.oid AND pg_attribute.attrelid = pg_class.oid AND pg_attribute.attnum = any(pg_index.indkey) AND indisprimary', pg_quote(table));

rs = pg_fetch(conn, strSQL);

varargout = {rs};
