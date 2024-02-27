function distances = pointdistance_pairs(a,b)
%POINTDISTANCE_PAIRS  Calculates the Euclidian distance between two sets of
%points
%
%   Calculates the distance between all combinations of points in a and b
%   (but not within a and b). If A is a [M*N] matrix, and B is a [I*N]
%   matrix, output becomes a [M*I] matrix filled with distances between
%   points A(M,:) and B(I,:).
%
%   Syntax:
%   varargout = pointdistance_pairs(varargin)
%
%   Input: Matrices A [M*N] and B [I*N] containing M and I points in N
%   dimensional space respectively
%
%   Output: matrix distances [M*I] containing the distances between A(M,:)
%   and B(I,:)
%
%   Example
%   distances = pointdistance_pairs(rand(2,7),rand(15,7))
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: pointdistance_pairs.m 7687 2012-11-14 15:16:12Z hoonhout $
% $Date: 2012-11-14 23:16:12 +0800 (Wed, 14 Nov 2012) $
% $Author: hoonhout $
% $Revision: 7687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/pointdistance_pairs.m $
% $Keywords: $

%% Dimension check
if size(a,2)~=size(b,2)
    error('a and b have to have the same number of columns');
end

%% Calculcate dimensions

n1 = size(a,1);
n2 = size(b,1);
nd = size(a,2);

%% Calculate distances

a  = repmat(reshape(a,[n1 1  nd]),[1  n2 1]);
b  = repmat(reshape(b,[1  n2 nd]),[n1 1  1]);

distances = squeeze(sqrt(sum((a-b).^2,3)));