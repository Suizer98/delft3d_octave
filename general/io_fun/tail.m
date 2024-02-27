function lines = tail(fname, varargin)
%TAIL  Unix-like tail command
%
%   Returns the last few files of a file. Suitable for large files because
%   of the use of fseek.
%
%   Syntax:
%   lines = tail(fname, varargin)
%
%   Input:
%   fname     = Filename to read
%   varargin  = n:      Number of lines to read
%
%   Output:
%   lines     = String containing the last lines of the file
%
%   Example
%   text = tail;
%   text = tail('n', 10)
%
%   See also fseek

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
% Created: 15 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: tail.m 4279 2011-03-15 15:09:03Z hoonhout $
% $Date: 2011-03-15 23:09:03 +0800 (Tue, 15 Mar 2011) $
% $Author: hoonhout $
% $Revision: 4279 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/tail.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'n', 5, ...
    'skip', [10 13] ...
);

OPT = setproperty(OPT, varargin{:});

if ~exist(fname, 'file')
    error(['File not found [' fname ']']);
end

%% read last line

fid = fopen(fname, 'r');
fseek(fid, 0, 'eof');

i = 0; n = 1;
lines = ''; 

while true
   
   if fseek(fid, -1, 'cof') == -1; break; end;
   
   c = fscanf(fid, '%c', 1);
   
   if ismember(c, char([10 13])) && i ~= 0
       lines(n,1:i) = fliplr(lines(n,1:i));
       
       if n >= OPT.n
           break;
       else
           i = 0;
           n = n + 1;
       end
   end
   
   if ~ismember(c, char(OPT.skip))
       i = i + 1;
       lines(n,i) = c;
   end
   
   if fseek(fid, -1, 'cof') == -1; break; end;
end 

lines = flipud(lines);

if isempty(lines); lines = ''; end;

fclose(fid); 
