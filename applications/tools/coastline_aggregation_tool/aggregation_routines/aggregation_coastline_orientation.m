function coastline = aggregation_coastline_orientation(coastline)

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

no_perp_inds = sort(unique([cell2mat(coastline.structure_inds) cell2mat(coastline.ignore_inds)]));
coastline.offshore_orientation = NaN(size(coastline.ldb,1),1);
for ii=1:size(coastline.ldb,1)
    inds = min(size(coastline.ldb,1),max(1,ii + [-1 1]));
    if ~isempty(find(no_perp_inds == ii))
        % Check if it is on a transition location:
        if isempty(find(no_perp_inds == inds(1)))
            inds = inds - [0 1];
        elseif isempty(find(no_perp_inds == inds(2)))
            inds = inds + [1 0];
        else
            continue
        end
    end
    
    coastline.offshore_orientation(ii,1) = mod(xy2degN(coastline.ldb(inds(1),1),coastline.ldb(inds(1),2),coastline.ldb(inds(2),1),coastline.ldb(inds(2),2)) - 90,360);
end

% function end
end