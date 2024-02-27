%% Distance measurements

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

%  Script determines which distance function should be used:
%  Type 1: 3D Euclidean distance (Hs Tp Dir)
%  Type 2: 3D Mahler Distance
%  Type 3: 3D Euclidean distance (Hs Dir [Day of the year])
%  Type 4: 4D Euclidean distance (Hs Tp Dir [Day of the year])

function D = Dista(X,v,type,X_org)


if type == 1
    D = Dist_3D(X,v);
elseif type == 2
    covar = corr(X_org);
    D = Dist_3D_Mah(X,v,covar);
elseif type == 3
    D = Dist_3D_T(X,v);
elseif type == 4
    D = Dist_4D(X,v);
end