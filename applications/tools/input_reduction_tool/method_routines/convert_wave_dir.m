function dir_wave=convert_wave_dir(dir,SN_angle,transf)

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

if transf==1 %angles from cross-shore to North (nautical)

    dir_wave=dir+SN_angle;
    dir_wave(dir_wave>360)=dir_wave(dir_wave>360)-360;
    dir_wave(dir_wave<0)=dir_wave(dir_wave<0)+360;
elseif transf==2 %angles rel. to nautical North to shore-normal
    
    if SN_angle>180
        dir(dir<(SN_angle-180))=dir(dir<(SN_angle-180))+360;
    elseif SN_angle<180 && SN_angle~=0
        dir(dir<(SN_angle-180))=dir(dir>(SN_angle+180))-360;
    end
    dir_wave = dir - SN_angle;

end



