function matrix = vector2grid(vector,sizeM,dim)
%VECTOR2GRID  Expands a vector to a matrix with uniform values in all dimension except 1. 
%
%   The function creates a matrix of size mSize. The values iin this matrix M are such that
%   M(:,:,...,k,:,..)=vector(k), where k is the index of dimension dim.
%
%   Syntax:
%   matrix = vector2grid(vector,sizeM,dim)
%
%   Input:
%   vector  = [1xn double] vector from which the values in matrix are taken.
%   sizeM   = [1xm integer] size of the output matrix
%   dim     = [integer] dimension along which the values of matrix vary.
%
%   Output:
%   matrix =  [mSize double] matrix with the values from vector
%
%   Example
%   vector=[0 1]; mSize=[2 2]; dim=2 yields
%   matrix=[0 0; 0 1]; 
%
%   See also repmat

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%       Zwolle office Arcadis
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 12 NOV 2012
% Created with Matlab version: 2009b

%% Check input

if length(vector)~=sizeM(dim)
  error('The length of vector must be equal to the size of matrix in dimension dim');
end

%% Create output

%change vector into column vector
if size(vector,1)<size(vector,2)
  vector=vector';
end

%eliminate dimension dim from sizeM
sizeM1=sizeM([1:length(sizeM)]<dim);
sizeM2=sizeM([1:length(sizeM)]>dim); 

vector=reshape(vector,[ones(1,length(sizeM1)),length(vector),ones(1,length(sizeM2))]);
matrix=repmat(vector,[sizeM1,1,sizeM2]); 

end %end function
