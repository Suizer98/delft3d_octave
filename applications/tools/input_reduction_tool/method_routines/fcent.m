%% Representive wave determination

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

% Determines the representive wave conditions of a set of observations
% Input:
%       X   =   Input matrix of the observations [N x [Hs dim-1]]
%       type=   Type of procedure that has to be performed
%               Type 1: Takes the mean of all variables
%               Type 2: Uses a non-linear function to determine the wave
%                       height
%           m       =   The power on non-linearity 
%           info_dir =   Information about the range of variation of the angle
%                        info_dir = 1 means range of variation of 0 to 360 
%                        info_dir = 0 means angle relative to the shore-normal, contains negative and positive values.
% Output:
%       v   =   Value of your representing wave conditions [1 x dim]

function v = fcent(X,type,m,info_dir)
    N = size(X,1);
    if type == 1
        v = [mean(X(:,1)) mean(X(:,2)) mean_angle(X(:,3))];
    elseif type == 2
        v = [(sum(X(:,1).^m)/N)^(1/m) mean(X(:,2)) mean_angle(X(:,3))];
    end
    
     if info_dir == 1
        v(find(v(:,3)<0),2)=v(find(v(:,3)<0),2)+360;
    end
    