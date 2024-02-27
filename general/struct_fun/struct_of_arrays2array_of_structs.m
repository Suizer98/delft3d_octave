function S2 = struct_of_arrays2array_of_structs(S1,varargin)
%STRUCT_OF_ARRAYS2ARRAY_OF_STRUCTS    merge D.fields(:,:) into D(:).fields(:)
%
%      s2 = struct_of_arrays2array_of_structs(s1)
%
% transforms a structure of arrays into an array of structures.
% The length of the fiels of s2 corresponds to the size of s1.
%
%      s2 = struct_of_arrays2array_of_structs(s1,i)
%
% only returns the ith element(s) (can be array).
%
% All fields need to be of the char or cell type, and have the same size. 
%
% Example: if s1 is a structure
%   
%     a: {2x3 cell}
%     b: [2x3] matrix
%     c: [2x3] matrix
%
% then s2(2x3) is an array of 6 structs, in which each with field looks like:
%   
%     a: 'char'
%     b: [number]
%     c: [number]
%
% and struct_of_arrays2array_of_structs(s1,1) returns only s2(1x1)
%   
%See also: STRUCTSUBS, CELL2STRUCT, STRUCT2CELL, PERMUTE, CELL2MAT, ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: struct_of_arrays2array_of_structs.m 7892 2013-01-11 09:23:04Z mol.arjan.x $
% $Date: 2013-01-11 17:23:04 +0800 (Fri, 11 Jan 2013) $
% $Author: mol.arjan.x $
% $Revision: 7892 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/struct_of_arrays2array_of_structs.m $
% $Keywords: $

fldnames = fieldnames(S1);
sizes    = structfun(@(x) (size(x)),S1,'Uniform',0);
SIZE     = sizes.(fldnames{1});
samesize = structfun(@(x) isequal(SIZE,x),sizes,'Uniform',0);

for ifld=1:length(fldnames)
   fldname = fldnames{ifld};
   if ~(samesize.(fldname)==1)
     error(['Field ',fldname,' has different size than 1st field ',fldnames{1}])
   end
end

if nargin> 1
   i = varargin{1};
else
   i = 1;
end

S2 = structfun(@(x) (element(x,i)),S1,'Uniform',0);

if nargin == 1
   S2 = repmat(S2,SIZE);
   for i=1:prod(SIZE)
      S2(i) = structfun(@(x) (element(x,i)),S1,'Uniform',0);
   end
end
