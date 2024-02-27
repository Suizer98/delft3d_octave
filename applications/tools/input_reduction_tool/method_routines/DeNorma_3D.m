%%  Denormalization 3D

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

%   Denormalizes 3 dimentional data
%   Input:
%         Org_Data  =   Matrix (N x 3) with your original observations [Hs dir Tp]
%         Norm_Data =   Normalized results [Hs dir Tp] that has to be
%                       denormalized
%         type = type of normalization - it's associated with the distance
%                   Type = 1: 3D Euclidean distance (Hs Dir Tp)
%                   Type = 2: 3D Mahler Distance (Hs Dir Tp)
%                   Type = 3: 3D Euclidean distance (Hs Dir [Day of the year])
%                   Type = 4: 4D Euclidean distance (Hs Dir Tp [Day of the year])


function [DeNorm_data] = DeNorma_3D(Org_data,Norm_data,type)

if type == 1 || type == 2
N = size(Org_data,1);
Dim = size(Org_data,2);
H_min = min(Org_data(:,1));
H_max = max(Org_data(:,1));
T_min = min(Org_data(:,2));
T_max = max(Org_data(:,2));

DeNorm_data(:,1) = Norm_data(:,1).*(H_max-H_min)+H_min;
DeNorm_data(:,2) = Norm_data(:,2).*(T_max-T_min)+T_min;
DeNorm_data(:,3) = Norm_data(:,3).*pi;
DeNorm_data(:,3) = DeNorm_data(:,3).*(180/pi); % Changing direction from radians to degrees

elseif type == 3
N = size(Org_data,1);
Dim = size(Org_data,2);
H_min = min(Org_data(:,1));
H_max = max(Org_data(:,1));
num_dat = size(unique(Org_data(:,4)),1);


DeNorm_data(:,1) = Norm_data(:,1).*(H_max-H_min)+H_min;
DeNorm_data(:,2) = Norm_data(:,3).*pi;
DeNorm_data(:,2) = DeNorm_data(:,3).*(180/pi); % Changing direction from radians to degrees
DeNorm_data(:,3) = 1+(Norm_data(:,4).*(num_dat/2));

elseif type == 4
N = size(Org_data,1);
Dim = size(Org_data,2);
H_min = min(Org_data(:,1));
H_max = max(Org_data(:,1));
T_min = min(Org_data(:,2));
T_max = max(Org_data(:,2));
num_dat = size(unique(Org_data(:,4)),1);


DeNorm_data(:,1) = Norm_data(:,1).*(H_max-H_min)+H_min;
DeNorm_data(:,2) = Norm_data(:,2).*(T_max-T_min)+T_min;
DeNorm_data(:,3) = Norm_data(:,3).*pi;
DeNorm_data(:,3) = DeNorm_data(:,3).*(180/pi);
DeNorm_data(:,4) = 1+(Norm_data(:,4).*(num_dat/2));

end