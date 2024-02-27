%% 3D Distance determination

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

% Distance depends on the Euclidean distances
%
%   Input:
%           X = Matrix (N x 3) with observations [Hs dir Tp]
%           v = Matrix (k x 3) with centroids [Hs dir Tp]
%   Output:
%           D = matrix (Nxk) with distance per observation till every
%           centroid [D_v1 D_v2 ... D_vk]

function D = Dist_3D(X,v)

%% Initialization
N = size(X,1);
k = size(v,1);
D = NaN(N,k);

%% Finding distances per centroid

for i = 1:k
    
    D(:,i)   = sqrt(((X(:,1) - v(i,1)*ones(N,1))).^2 ...                                               % Distance between Hs
             + (X(:,2) - v(i,2)*ones(N,1)).^2 ...                                               % Distance between Tp
             + (min([abs(X(:,3)-v(i,3)*ones(N,1)) 2-abs(X(:,3)-v(i,3)*ones(N,1))],[],2)).^2);    % Distance between Dir
end
     
    
