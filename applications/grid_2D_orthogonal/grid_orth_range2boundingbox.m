function [x_box,y_box]=grid_orth_range2boundingbox(x_range,y_range)
%GRID_ORTH_RANGE2BOUNDINGBOX get bounding box from ranges
%
%  [x_box,y_box]=grid_orth_range2boundingbox(x_range,y_range)
%
% where x_range,y_range are 2-element vectors,
% or cells with 2-element vectors.
%
% x_box,y_box cells can be turned into na-separated polygons
% with poly_join.
%
%See also: GRID_2D_ORTHOGONAL, POLY_JOIN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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

% $Id: grid_orth_range2boundingbox.m 5293 2011-10-03 12:57:38Z boer_g $
% $Date: 2011-10-03 20:57:38 +0800 (Mon, 03 Oct 2011) $
% $Author: boer_g $
% $Revision: 5293 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_range2boundingbox.m $
% $Keywords: $

if iscell(x_range) & iscell(y_range)

   x_box = cellfun(@(p) bbx(p),x_range,'UniformOutput',0);
   y_box = cellfun(@(p) bby(p),y_range,'UniformOutput',0);
   
else

   x_box = bbx(x_range);
   y_box = bby(y_range);

end

%% 

function p = bbx(q)

p = q([1 2 2 1 1]);

function p = bby(q)

p = q([1 1 2 2 1]);
