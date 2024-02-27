function clearx(varargin)
% CLEARX clear all variables in the workspace except the ones specified
%
% Syntax:
%   clearx(varargin)
%
% Input:
%   variable names NOT to be cleared in a list of input strings, i.e clear('a','b')
% Output:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2010 IBED UvA
%       Jurriaan Spaaks
%
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

%%
% 

listOfVars = evalin('caller','whos');
listOfDontClear = varargin;

for iVar=1:numel(listOfVars)

    s = listOfVars(iVar).name;
    if any(strcmp(s,listOfDontClear))
        % disp(['don''t clear ',s])
    else
        % disp(['clear ',s])
        evalin('caller',['clear ',s])
    end    
end


