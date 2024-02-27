function [x z] = wkt_readlinestring(str)
%wkt_readlinestring  Reads a linestring represented in WKT.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x z] = readlinestring(str)
%
%   Input:
%   str     = Well Known Text format (WKT)representation of a linestring 
%
%   Output:
%   x       = array of doubles with all x values
%   z       = array of doubles with all z values
%
%   Example
%   [x y] = wkt_readlinestring('LINESTRING(0 0,1 1,2 3E-2,-2 4)')
%
%   See also <a href="matlab:web('http://en.wikipedia.org/wiki/Well-known_text','-browser');">http://en.wikipedia.org/wiki/Well-known_text</a>
%   See also regexp

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl
%
%       P.O. Box 177 
%       2600 MH Delft
%       The Netherlands 
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
% Created: 27 Mar 2012
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id: wkt_readlinestring.m 6379 2012-06-12 14:25:13Z geer $
% $Date: 2012-06-12 22:25:13 +0800 (Tue, 12 Jun 2012) $
% $Author: geer $
% $Revision: 6379 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/wkt_fun/wkt_readlinestring.m $
% $Keywords: $

%% Filter coordinates
a = regexp(str,'(?<x>[\d|\.|E|\-]+)\s(?<z>[\d|\.|E|\-]+)','names');

%% Transform coordinates to double
x = cellfun(@str2double,{a.x});
z = cellfun(@str2double,{a.z});