%%  Normalization 3D

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

%   Normalizes 3 dimentional data
%   Input:
%         data  =   Matrix (N x 3) with observations [Hs Tp Dir]
%         type = type of normalization - it's associated with the distance
%                   Type = 1: 3D Euclidean distance (Hs Tp Dir)
%                   Type = 2: 3D Mahler Distance (Hs Tp Dir)
%                   Type = 3: 3D Euclidean distance (Hs Dir [Day of the year])
%                   Type = 4: 4D Euclidean distance (Hs Tp Dir [Day of the year])  
%         Org_Data = Matrix (N x 3) with your original observations [Hs Tp Dir]

function [X] = Norma_3D(Data,type,Org_Data)

N = size(Data,1);
Dim = size(Data,2);

if type == 1 || type == 2
H_min = min(Org_Data(:,1));
H_max = max(Org_Data(:,1));
T_min = min(Org_Data(:,2));
T_max = max(Org_Data(:,2));
Dir = Data(:,3)*(pi/180); % Changing direction from degrees to radians

X = NaN(N,Dim);
X(:,1) = (Data(:,1)-H_min)./(H_max-H_min);
X(:,2) = (Data(:,2)-T_min)./(T_max-T_min);
X(:,3) = Dir/pi;

elseif type == 3
    H_min = min(Org_Data(:,1));
    H_max = max(Org_Data(:,1));
    Dir = Data(:,3)*(pi/180); % Changing direction from degrees to radians
    num_dat = size(unique(Org_Data(:,4)),1);
    
    X = NaN(N,Dim);
    X(:,1) = (Data(:,1)-H_min)./(H_max-H_min);
    X(:,2) = Dir/pi;
    X(:,3) = (Data(:,4)-1).*(2/(num_dat-1));
elseif type == 4
    H_min = min(Org_Data(:,1));
    H_max = max(Org_Data(:,1));
    T_min = min(Org_Data(:,2));
    T_max = max(Org_Data(:,2));
    Dir = Data(:,3)*(pi/180); % Changing direction from degrees to radians
    num_dat = size(unique(Org_Data(:,4)),1);
    
    X = NaN(N,Dim);
    X(:,1) = (Data(:,1)-H_min)./(H_max-H_min);
    X(:,2) = (Data(:,2)-T_min)./(T_max-T_min);
    X(:,3) = Dir/pi;
    X(:,4) = (Data(:,4)-1).*(2/(num_dat-1));   
end