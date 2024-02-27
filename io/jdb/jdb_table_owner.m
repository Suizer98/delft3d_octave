function table = jdb_table_owner(table,owner)
% Constructs a tablename including the owner (Oracle specific)

    idx = ismember(owner,{'SYS' 'SYSTEM' 'MDSYS' 'XDB' 'OLAPSYS' 'APEX_030200' 'EXFSYS' 'CTXSYS' ''});
    if idx
        table = jdb_quote(table);
    else
        table = [jdb_quote(owner) , '.' ,jdb_quote(table)];
    end

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       ronald.vanderhout@vanoord.com
%
%   JDBC: Copyright (C) 2012 Deltares for Building with Nature
%       Gerben J. de Boer
%       gerben.deboer@deltares.nl
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

% $Id: jdb_table_owner.m 11149 2014-09-29 12:00:29Z rho.x $
% $Date: 2014-09-29 20:00:29 +0800 (Mon, 29 Sep 2014) $
% $Author: rho.x $
% $Revision: 11149 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_table_owner.m $
% $Keywords: $
