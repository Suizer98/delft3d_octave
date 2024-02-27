function tables = pg_gettables(conn, varargin)
%PG_GETTABLES  List all tables in current database
%
%   List all tables in current database. Return a list with table names in
%   given database connection. Ignores system tables like pg_catalog and
%   information_schema.
%
%   Syntax:
%   tables = pg_gettables(conn, varargin)
%
%   Input:
%   conn      = Database connection object
%   varargin  = none
%
%   Output:
%   tables    = Cell array with table names
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   tables = pg_gettables(conn);
%
%   See also pg_connectdb, pg_getcolumns, pg_table2struct

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

% $Id: pg_gettables.m 7573 2012-10-24 13:13:55Z boer_g $
% $Date: 2012-10-24 21:13:55 +0800 (Wed, 24 Oct 2012) $
% $Author: boer_g $
% $Revision: 7573 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_gettables.m $
% $Keywords: $

%% read options

OPT = struct();

OPT = setproperty(OPT,varargin{:});

%% list tables

tables = pg_fetch(conn, 'SELECT tablename FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')');