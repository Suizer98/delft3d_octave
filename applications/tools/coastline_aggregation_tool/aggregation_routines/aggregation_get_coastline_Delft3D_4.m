function [c_ini c_end] = aggregation_get_coastline_Delft3D_4(map_file,varargin)

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

OPT.z_level   = 0; % Default MSL
OPT.time_inds = [];
[OPT] = setproperty(OPT,varargin);

d3d_handle = qpfopen(map_file);

if isempty(OPT.time_inds)
    OPT.time_inds = [1 length(get_d3d_output_times(d3d_handle))];
end

bed_levels = qpread(d3d_handle,'bed level in water level points','griddata',[OPT.time_inds(1) OPT.time_inds(2)]);

tel = 0;
for z_level = fliplr(sort(unique([min(OPT.z_level(:)) max(OPT.z_level(:))])))
    tel = tel+1;
    fig = figure('visible','off');
    [c_ini{tel},~]  = contour(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(1,:,:)),[z_level z_level]);
    [c_end{tel},~]  = contour(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(2,:,:)),[z_level z_level]);
    close(fig);
    c_ini{tel} = c_ini{tel}';
    c_end{tel} = c_end{tel}';
    c_ini{tel}(find(c_ini{tel}(:,1)==z_level),:)=NaN;
    c_end{tel}(find(c_end{tel}(:,1)==z_level),:)=NaN;
    % Remove start and trailing NaN's:
    if ~isempty(find(find(isnan(c_ini{tel}(:,1))) == 1))
        c_ini{tel} = c_ini{tel}(2:end,:);
    end
    if ~isempty(find(find(isnan(c_ini{tel}(:,1))) == size(c_ini{tel},1)))
        c_ini{tel} = c_ini{tel}(2:end,:);
    end
    if ~isempty(find(find(isnan(c_end{tel}(:,1))) == 1))
        c_end{tel} = c_end{tel}(2:end,:);
    end
    if ~isempty(find(find(isnan(c_end{tel}(:,1))) == size(c_end{tel},1)))
        c_end{tel} = c_end{tel}(2:end,:);
    end
end

end