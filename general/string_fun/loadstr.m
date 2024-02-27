function L = loadstr(fname,varargin)
%LOADSTR   load ASCII file in cellstr
%
%   string = LOADSTR(filename)
%
% where each line becomes a cellstr.
%
%See also: SAVESTR, CHAR

%   --------------------------------------------------------------------
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
%   -------------------------------------------------------------------

% $Id: loadstr.m 8359 2013-03-20 16:16:24Z boer_g $
% $Date: 2013-03-21 00:16:24 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8359 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/loadstr.m $
% $Keywords$

OPT.strtrim = 1;

OPT = setproperty(OPT,varargin);

fid = fopen(fname);
L   = textscan(fid,'%s','Delimiter',''); % EOL will always be Delimiter
L   = L{1};
fclose(fid);

if OPT.strtrim
   L = cellfun(@(x) strtrim(x),L,'UniformOutput',false);
end