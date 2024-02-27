function jdb_cleartable(conn, table, varargin)
%JDB_CLEARTABLE  Deletes all contents from a table
%
%   function NOT TESTED for Oracle
%
%   Deletes all contents from a table and resets the primary key counter.
%
%   Syntax:
%   jdb_cleartable(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table to be cleared
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   jdb_cleartable(conn, 'someTable');
%
%   See also jdb_getpk, jdb_gettables


%% delete contents
jdb_exec(conn, sprintf('DELETE FROM %s', pg_quote(table)));

%% reset sequence
pk  = char(jdb_getpk(conn, table));
sql = sprintf('SELECT setval(''"%s_%s_seq"'', 1, FALSE)', table, pk);
jdb_exec(conn, sql);


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       bas.hoonhout@deltares.nl
%       ronald.vanderhout@vanoord.com
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

% $Id: jdb_cleartable.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_cleartable.m $
% $Keywords: $
