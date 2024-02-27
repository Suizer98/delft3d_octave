function [c_ini c_end] = aggregation_get_coastline_Unibest_CL(PRN_file,varargin)

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

OPT.time_inds = [];
[OPT] = setproperty(OPT,varargin);

prn_data = readPRN(PRN_file);

if isempty(OPT.time_inds)
    OPT.time_inds = [1 size(prn_data.x,2)];
end

c_ini = [prn_data.x(:,OPT.time_inds(1)) prn_data.y(:,OPT.time_inds(1))];
c_end = [prn_data.x(:,OPT.time_inds(2)) prn_data.y(:,OPT.time_inds(2))];

end