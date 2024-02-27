function DBF = dbf_read_struct(varargin)
%DBF_READ_STRUCT  Reads a DBF file into a struct
%
%   Reads a DBF file into a struct. Same behavior as the dbf_read function,
%   but returns a single struct instead of two seperate variables.
%
%   Syntax:
%   DBF = dbf_read_struct(varargin)
%
%   Input:
%   varargin  = see <dbf_read>
%
%   Output:
%   DBF       = Structure with two fields:
%                   headers:    Cell array with column headers
%                   data:       Matrix with table data
%
%   Example
%   DBF = dbf_read_struct('someDatabase.DBF');
%
%   See also dbf_read, dbf_get

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

% $Id: dbf_read_struct.m 7083 2012-07-31 13:08:30Z hoonhout $
% $Date: 2012-07-31 21:08:30 +0800 (Tue, 31 Jul 2012) $
% $Author: hoonhout $
% $Revision: 7083 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/dbf/dbf_read_struct.m $
% $Keywords: $

%% read DBF into struct

[data headers] = dbf_read(varargin{:});

DBF = struct( ...
    'data',     {data}, ...
    'headers',  {headers});