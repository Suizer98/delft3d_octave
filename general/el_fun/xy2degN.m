function [degN normVector] = xy2degN(x0, y0, x1, y1)
%XY2DEGN  find angle in degrees, positive clockwise and 0 north
%
%   Syntax:
%   [degN normVector] = xy2degN(x0, y0, x1, y1)
%
%   Input:
%   x0   = x-coordinate of starting point of vector(s)
%   y0   = y-coordinate of starting point of vector(s)
%   x1   = x-coordinate of end point of vector(s)
%   y1   = y-coordinate of end point of vector(s)
%
%   Output:
%   degN = angle in degrees, positive clockwise and 0 north
%   normVector = Euler norm of vectors
%
%   Example
%   [degN normVector]=xy2degN(0,0,2,1); 
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: xy2degN.m 8827 2013-06-18 15:28:38Z ivo.pasmans.x $
% $Date: 2013-06-18 23:28:38 +0800 (Tue, 18 Jun 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8827 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/xy2degN.m $
% $Keywords: $

%% PREPROCESSING

%Converting scalar to matrix
if prod(size(x0))==1
	x0=x0*ones(size(x1)); 
end
if prod(size(y0))==1
	y0=y0*ones(size(y1)); 
end
if prod(size(x1))==1
	x1=x1*ones(size(x0)); 
end
if prod(size(y1))==1
	y1=y1*ones(size(y0)); 
end

%Test if matrices are of the same dimension
if sum( size(x0)~=size(x1) )>0 | sum( size(y0)~=size(y1) )>0 | sum( size(x0)~=size(y0) )>0
			error('x0,y0,x1,y1 must either be matrices of the same size or scalars.'); 
end

%% 	CALCULATION

dx = x1 - x0; % derive horizontal distance
dy = y1 - y0; % derive vertical distance

normVector=hypot(dx,dy); %L2-norm vectors

quadr2or3 = dy < 0; % second and third quadrant
quadr4 = dx < 0 & dy >= 0; % fourth quadrant

degN = atand(dx ./ dy); % derive angle
degN(quadr2or3) = degN(quadr2or3) + 180; % modify second and third quadrant
degN(quadr4) = degN(quadr4) + 360; % modify fourth quadrant
