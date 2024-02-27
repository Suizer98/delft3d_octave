function [x1 y1] = degN2xy(degN,normVectors)
%degN2xy Convert vectors given by their angle with respect to the north and norm to cartesian coordinates.
%
%   Syntax:
%   [x1 y1]=degN2xy(degN,normVectors)
%
%   Input:
%   degN 		= [mxn double] angle vector with respect to the north
%   normVector  = [mxn double] Eulerian norm of the vector
%
%   Output:
%   x1			= [mxn double] x-coordinate tip vector
%	y1			= [mxn double] y-coordinate tip vector
%
%   Example
%   [x y]=degN2xy(90,1); 
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%		Arcadis Zwolle, The Netherlands
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
% Created: 18 Jun 2013
% Created with Matlab version: 7.5.0 (2007b)

% $Id: degN2xy.m 8828 2013-06-18 15:29:19Z ivo.pasmans.x $
% $Date: 2013-06-18 23:29:19 +0800 (Tue, 18 Jun 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8828 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/degN2xy.m $
% $Keywords: $

%% PREPROCESSING

%Convert scalars to matrices
if prod(size(degN))==1
	degN=degN*ones(size(normVectors)); 
end
if prod(size(normVectors))==1
	normVectors=normVectors*ones(size(degN)); 
end

%Check dimensions matrices
if sum( size(degN)~=size(normVectors) )>0
	error('degN and normVectors must be either scalars or matrices of the same size.'); 
end

%% CALCULATION

%convert angles to angles in rad
degN=deg2rad(degN); 

%calculate x
x1=normVectors.*sin(degN); 

%calculate y
y1=normVectors.*cos(degN); 
