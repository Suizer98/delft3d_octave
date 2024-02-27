function [position]=UCIT_getPlotPosition(location, addBars)
%UCIT_GETPLOTPOSITION   routine returns information on prescribed plotpositions
%
% input:
%   location = 'UL' - Upper left; 'UR' - Upper right; 'LL' - Lower left; 'LR' - Lower right
%
% output:
%   position  = 1 x 4 vector with plot positions (make sure figure units are set to 'normalised') 
%
%   See also UCIT_focusOn_Window

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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



if nargin == 1
    addBars = 0;
end

switch location
    %                 x          y      width     height
    case 'UL' % Upper left
        position = [0.0000    0.5000    0.5000    0.4362+addBars*.032];
    case 'UR' % Upper right
        position = [0.5068    0.5000    0.4902    0.4362+addBars*.032];
    case 'LL' % Lower left
        position = [0.0000    0.0430    0.5000    0.3867+addBars*.032];
    case 'LR' % Lower right
        position = [0.5068    0.0430    0.4902    0.3950+addBars*.032];
end
