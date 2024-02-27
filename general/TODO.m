function [mfilestr]=TODO(txt,n)
%TODO  Display a TODO message while running code
%
%   This function displays a custom TODO message whenever matlab executes
%   the code where function is called. A link to the specific location of
%   the code is included (like an error message).
%
%   Syntax:
%   mfilestr = TODO(txt,n)
%
%   Input:
%   txt  = TODO message that has to be displayed
%   n   = number of frames to omit (see dbstack)
%
%   Output:
%   mfilestr = struct that follows from a dbstack call at the location
%               where the function is called.
%
%   Example
%   TODO('Edit this code');
%
%   See also warning error dbstack

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 09 Dec 2008
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: TODO.m 502 2009-06-08 08:34:41Z geer $
% $Date: 2009-06-08 16:34:41 +0800 (Mon, 08 Jun 2009) $
% $Author: geer $
% $Revision: 502 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/TODO.m $

%% process input
if nargin<2
    n=0;
end

%% Look in stack
mfilestr=dbstack(n+1,'-completenames');

CalledFromFile = ~isempty(mfilestr);

if CalledFromFile
    %% Retrieve function/m-file name and line
    mfile = mfilestr(1).name;
    fullmfile = mfilestr(1).file;
    lineno = num2str(mfilestr(1).line);
    
    %% Build string with link info
    str1 = 'TODO in ==> ';
    str2 = ['<a href="matlab: opentoline(''' strrep(fullmfile,filesep,[filesep filesep]) ''',' lineno ',0);">' mfile ' at ' lineno '</a>'];
    
    %% display message
    fprintf(2,'%s\n',cat(2,str1,str2));
    fprintf(2,'%s\n',txt);
    
%     cprintf([1 0.5 0],'%s',str1);
%     cprintf(-[1 0.5 0],'%s\n',str2);
%     cprintf([1 0.5 0],'%s\n',txt);
end