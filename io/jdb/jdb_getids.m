function ids = jdb_getids(conn, table, varargin)
%JDB_GETIDS  Retrieves primary key value for many records in given table
%
%   Retrieves primary key value for many records in given table. It
%   basically calls the jdb_getid function multiple times. However, it
%   prevents to call the same command twice. Therefore it is useful to
%   obtain a large list of id's corresponding to a list with identifiers
%   containing duplicates.
%   As for now, it only supports a WHERE clause with a single column,
%   because it cannot decide whether a combination of multiple columns is
%   unique or not. Also, absent WHERE clause is not supported. Simply use
%   jdb_getid in that case.
%
%   Syntax:
%   varargout = jdb_getids(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table from which a primary key values are needed
%   varargin  = structure or name/value pairs of table columns and
%               corresponding values that describe the WHERE clause in the
%               SQL query
%
%   Output:
%   varargout = Unique primary key value for each requested record
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   ids  = jdb_getids(conn, 'someTable', 'description', 'The One');
%   ids  = jdb_getids(conn, 'someTable', 'x', x, 'y', y);
%   ids  = jdb_getids(conn, 'someTable', struct('x', x, 'y', y));
%
%   See also jdb_getid, jdb_gettables, jdb_getcolumns, jdb_connect_db

%% Copyright notice: see below

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

%% uniquify filters
ids = {};

f = fieldnames(OPT);

if ~isempty(f)
    if length(f) == 1
        if iscell(varargin{2})
            [vals idx1 idx2] = unique(varargin{2});
        else
            OPT.(f{1})       = {OPT.(f{1})};
            vals             = OPT.(f{1});
            idx2             = 1;
        end
    else
        error('Multiple filters not yet supported');
    end

    ids     = cellfun(@(x) jdb_getid(conn, table, f{1}, x), vals, 'UniformOutput', false);
    ids     = ids(idx2);
    
else
    error('No filters not yet supported');
end


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

% $Id: jdb_getids.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_getids.m $
% $Keywords: $