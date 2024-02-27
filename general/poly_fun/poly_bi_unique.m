function bi = poly_bi_unique(bi)
%POLY_BI_UNIQUE  sorts and gets unique two-point polygon segments
%
%     bi = poly_bi_unique(bi)
%
%  where bi are [n x 2] integer arrays just like 
%  the tri in tri = delaunay() are [n x 3] integer arrays
%
% Example:
%
%    bi0 =[1 2; 2 3;2 1;2 3;3 1; 3 2];
%    bi = poly_bi_unique(bi0) % is [1 2;1 3;2 3]
%
%See also: poly_fun, poly_bi_plot

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: poly_bi_unique.m 7453 2012-10-11 15:14:37Z boer_g $
% $Date: 2012-10-11 23:14:37 +0800 (Thu, 11 Oct 2012) $
% $Author: boer_g $
% $Revision: 7453 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_bi_unique.m $

   bi =     sort(bi,2); % lowest point per segment 1 col
   bi = sortrows(bi,[1 2]); % sort on point so we can use diff to trace doubles
   d            = diff(bi,[],1);
   d = find(d(:,1)==0 & d(:,2)==0);
   bi(d,:)=[];
