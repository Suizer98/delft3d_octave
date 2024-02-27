function varargout = poly_bi_plot(bi,x,y,varargin)
%poly_bi_plot plot set of 2-node line segments
%
%   poly_bi_plot(bi,x,y,...)
%
%   plots index arrays of two-vertex line segments. x 
%   and y are a collection of vertices, bi is a [n x 2]
%   array that subsets n two-vertex lin segments
%   with integer pointers into vectors x(:) and y(:).
%
%   [x,y] = meshgrid(1:2,1:2)
%   bi = [1 2;1 3;2 3];
%   poly_bi_plot(bi,x,y,'r','linewidth',2)
%
%see also: trisurf, poly_bi_unique

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

% $Id: poly_bi_plot.m 8343 2013-03-18 10:33:04Z boer_g $
% $Date: 2013-03-18 18:33:04 +0800 (Mon, 18 Mar 2013) $
% $Author: boer_g $
% $Revision: 8343 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_bi_plot.m $
if  ~ishold
   hold on
   holdstate = 'off';
else
   holdstate = 'on';
end
   
if nargout > 0
varargout = {plot(x(bi'),y(bi'),varargin{:})};
else
plot(x(bi'),y(bi'),varargin{:});
end

hold(holdstate)
