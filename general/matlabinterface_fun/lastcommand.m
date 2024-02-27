function last = lastcommand()
%LASTCOMMAND  Returns the last command executed in the Command Window
%
%   Returns the last command executed in the Command Window based on the
%   history.m file.
%
%   Syntax:
%   last = lastcommand()
%
%   Input:
%   none
%
%   Output:
%   last    = last command
%
%   Example
%   last = lastcommand
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: lastcommand.m 3814 2011-01-04 13:54:04Z hoonhout $
% $Date: 2011-01-04 21:54:04 +0800 (Tue, 04 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3814 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/matlabinterface_fun/lastcommand.m $
% $Keywords: $

%% open history file to obtain last command

fid = fopen([prefdir, '\history.m'], 'rt');
while ~feof(fid)
   last = fgetl(fid);
end
fclose(fid);