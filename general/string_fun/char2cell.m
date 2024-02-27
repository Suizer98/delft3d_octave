function stringArray=char2cell(charArray)
%CHAR2CELL Convert a char array into a cell-array of string. Each row in
%the char array is converted into one cell. 
%
%Syntax:
% stringArray=char2cell(charArray)
%Input:
% charArray=     [mxn char] char array for conversion
%Output: 
% stringArray=  [1xm cell] cell with string of each row as entry
%Example:
% test=char2cell(['tekst1';'tekst2'])

%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS 
%
%       Ivo Pasmans
%       ivo.pasmans@arcadis.nl
%
%       Arcadis, Zwolle, The Netherlands
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

%convert char to string
stringArray=mat2cell(charArray,ones(1,size(charArray,1)),size(charArray,2)); 
stringArray=strtrim(stringArray); 

end %end function char2cell