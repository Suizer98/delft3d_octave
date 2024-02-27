function d = strdiff(s)
%STRDIFF  boolean diff for char or cellstr
%
% checks whether consecutive chars or cellstr are equal
%
% Example: % [0 0 1 0 1] at transitions a -> b -> c
% strdiff({'a','a','a','b','b','c'}) 
%
%See also: diff, unique, cumunique

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: strdiff.m 7231 2012-09-12 07:08:16Z boer_g $
% $Date: 2012-09-12 15:08:16 +0800 (Wed, 12 Sep 2012) $
% $Author: boer_g $
% $Revision: 7231 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strdiff.m $
% $Keywords: $

%% check input

if ischar(s)
   d = not(all(diff(     s ,[],1)==0,2))';
else
   d = not(all(diff(char(s),[],1)==0,2))';
end

