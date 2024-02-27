function output = isfunction(filename)
%ISFUNCTION  Test if the given M-file is a function
%
%   This function checks whether an m-file is indeed a function. It tries to
%   read the ASCII content of a file. The function will therefore not work
%   in a compiled environment or on other compiled functions.
%
%   Syntax:
%   output = isfunction(filename)
%
%   Input:
%   filename  = The name of a certain mfile
%
%   Output:
%   output = true if the m-file is a function. false if not
%
%   Example
%   isfunction('plot')
%
%   See also exist regexp

% This file is inspired by isfunction.m of Roger Jang
% (http://neural.cs.nthu.edu.tw/jang/matlab/toolbox/utility/html/utility/is
% Function.html)
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% Created: 08 May 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: isfunction.m 449 2009-05-08 15:09:02Z geer $
% $Date: 2009-05-08 23:09:02 +0800 (Fri, 08 May 2009) $
% $Author: geer $
% $Revision: 449 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/isfunction.m $
% $Keywords: $

%% check input
output = false;
if nargin<1
    selfdemo
    return
end
if ~ischar(filename)
    return
end
[pth nm ext] = fileparts(filename);
if ~strcmp(ext,'.m')
    return
end

%% read first line
fid=fopen(filename);
line=fgetl(fid);
fclose(fid);
 
%% search for function
start=regexp(line, '^function','once');
output = ~isempty(start);
 
end

%% ===== Self demo
function selfdemo
fileName='isFunction.m';
output=feval(mfilename, 'isFunction.m');
if output
    fprintf('The given M-file "%s" is a function.', fileName);
else
    fprintf('The given M-file "%s" is not a function.', fileName);
end
end
