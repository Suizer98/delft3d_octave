function f = pg_quote(f)
%PG_QUOTE wrap identifiers (table, column names) in " quotes to enable mixed upper/lower case
%
% f = pg_quote(f) where f is a cellstr of a char. This is
% needed to deal with case-sensitive table and column names known
% as quoted or delimited indentifiers.
%
% Quoting an identifier makes it case-sensitive, whereas unquoted names are 
% always folded to lower case. For example, the identifiers FOO, foo, and 
% "foo" are considered the same by PostgreSQL, but "Foo" and "FOO" are 
% different from these three and each other. (The folding of unquoted names to
% lower case in PostgreSQL is incompatible with the SQL standard, which says 
% that unquoted names should be folded to upper case. Thus, foo should be 
% equivalent to "FOO" not "foo" according to the standard. If you want to 
% write portable applications you are advised to always quote a particular name
% or never quote it.). With PG_QUOTE you can always quote them.
%
%See also: postgresql

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id: pg_quote.m 7391 2012-10-05 07:31:30Z boer_g $
% $Date: 2012-10-05 15:31:30 +0800 (Fri, 05 Oct 2012) $
% $Author: boer_g $
% $Revision: 7391 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_quote.m $
% $Keywords: $

if ischar(f)
   f = ['"',f,'"'];
else
   f = cellfun(@(x) ['"',x,'"'],f,'Uniform',0); % needed to deal with case-sensitive column names
end