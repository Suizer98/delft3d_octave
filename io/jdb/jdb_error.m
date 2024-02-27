function jdb_error(rs)
%JDB_ERROR  Checks a SQL query result for errors
%
%   Checks a SQL query result from exec and/or fetch function for errors
%   and displays the executed query and the corresponding error if one is
%   found.
%
%   Syntax:
%   jdb_error(rs)
%
%   Input:
%   rs        = SQL query result
%
%   Output:
%   none
%
%   Example
%   rs = exec(conn, 'SELECT * FROM someTable');
%   jdb_error(rs);
%
%   See also jdb_exec, jdb_fetch


%% display error
%  ingore return message of comment lines
%  this message is instalation-dependend (dutch) so 
%  we catch it by checking for comment in the matlab client here

if isstruct(rs) | isobject(rs)
    %if isprop(rs, 'Message') && isprop(rs, 'SQLQuery')
        if ~isempty(rs.Message) & ...
            ~strcmp(strtok(rs.SQLQuery),'--') % Geen resultaten werden teruggegeven door de query.
            fprintf(2,rs.SQLQuery);
            error(rs.Message);
        end
    %end
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: jdb_error.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_error.m $
% $Keywords: $
