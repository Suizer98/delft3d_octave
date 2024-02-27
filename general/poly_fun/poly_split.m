function [xcells,ycells] = poly_split(x,y)
%POLY_SPLIT  split NaN-separated polygon into its segments
%
%   [segments.x, segments.y] = poly_split(x,y)
%    segments.x              = poly_split(x)
%
%See also: POLY_JOIN, poly_fun, polyfun

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Rijkswaterstaat Kustlijnzorg
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: poly_split.m 9064 2013-08-16 11:52:09Z boer_g $
% $Date: 2013-08-16 19:52:09 +0800 (Fri, 16 Aug 2013) $
% $Author: boer_g $
% $Revision: 9064 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_split.m $
% $Keywords: $

   separators = find(isnan(x));
   
%% insert dummy indices when dummy start/end separators are missing
   
   if ~isnan(x(1))
      separators = [0, separators(:)'];
   end
   
   if ~isnan(x(end))
      separators = [separators, length(x)+1];
   end
   
%% chunk

   n = length(separators)-1;

   xcells = cell(1,n);
   ycells = cell(1,n);
   
   for i=1:n
   
      xcells{i} = x(separators(i  )+1:...
                    separators(i+1)-1); 
      if nargin > 1
      ycells{i} = y(separators(i  )+1:...
                    separators(i+1)-1);  
      end
   
   end
   
%% EOF   