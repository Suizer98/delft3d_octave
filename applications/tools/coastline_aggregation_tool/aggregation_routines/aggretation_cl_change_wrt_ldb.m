function [ini_dist end_dist] = aggretation_cl_change_wrt_ldb(ldb,offshore_orientation,c_ini,c_end)

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

coastline.offshore_orientation = offshore_orientation;
coastline.ldb                  = ldb;

ini_dist = nan(size(coastline.offshore_orientation));
end_dist = nan(size(coastline.offshore_orientation));

for kk=find(isnan(coastline.offshore_orientation)==0)'

    % Cross-shore axis for this coastline point
    dist_dx = 1;
    dist_ax = [-1000:1000];
    dist_x = coastline.ldb(kk,1) + (dist_ax.*sind(coastline.offshore_orientation(kk)));
    dist_y = coastline.ldb(kk,2) + (dist_ax.*cosd(coastline.offshore_orientation(kk)));

    % Lets filter the contour lines:
    
    % First step (50 times dx to speed stuff up)
    
    c_ini_filter = []; c_end_filter = [];
    
    first_step_factor = 50;
    
    for ii = 1:first_step_factor:length(dist_ax)
        
        c_ini_filter = [c_ini_filter; find(sqrt(((c_ini(:,1) - dist_x(ii)).^2) + ((c_ini(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
        c_end_filter = [c_end_filter; find(sqrt(((c_end(:,1) - dist_x(ii)).^2) + ((c_end(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
        
    end
    
    c_ini_filter = sort(unique(c_ini_filter));
    c_end_filter = sort(unique(c_end_filter));
    
    c_ini_1st = c_ini(c_ini_filter,:);
    c_end_1st = c_end(c_end_filter,:);
    
    % Second step (full dx resolution)
    
    c_ini_filter = []; c_end_filter = [];
    
    for ii = 1:length(dist_ax)
        
        c_ini_filter = [c_ini_filter; find(sqrt(((c_ini_1st(:,1) - dist_x(ii)).^2) + ((c_ini_1st(:,2) - dist_y(ii)).^2)) <= dist_dx)];
        c_end_filter = [c_end_filter; find(sqrt(((c_end_1st(:,1) - dist_x(ii)).^2) + ((c_end_1st(:,2) - dist_y(ii)).^2)) <= dist_dx)];
        
    end
    
    c_ini_filter = sort(unique(c_ini_filter));
    c_end_filter = sort(unique(c_end_filter));
    
    c_ini_used = c_ini_1st(c_ini_filter,:);
    c_end_used = c_end_1st(c_end_filter,:);
    
    % Below a figure if you wish to check the filtering:
    
%     figure;
%     plot(dist_x,dist_y,'k.-')
%     hold on; grid on; box on; axis equal;
%     plot(c_ini(:,1),c_ini(:,2),'c.-');
%     plot(c_end(:,1),c_end(:,2),'y.-');
%     
%     plot(c_ini_1st(:,1),c_ini_1st(:,2),'b.-');
%     plot(c_end_1st(:,1),c_end_1st(:,2),'g.-');
%     
%     plot(c_ini_used(:,1),c_ini_used(:,2),'k.-');
%     plot(c_end_used(:,1),c_end_used(:,2),'k.-');
    
    % Determine distance for ini coastline
    if ~isempty(c_ini_used)
        smaller  = 1; ind = ((length(dist_ax)+1)/2); addition = 1;
        old_dist = min(sqrt(((c_ini_used(:,1) - dist_x(ind)).^2)+((c_ini_used(:,2) - dist_y(ind)).^2)));
        ind      = ind + addition;
        new_dist = min(sqrt(((c_ini_used(:,1) - dist_x(ind)).^2)+((c_ini_used(:,2) - dist_y(ind)).^2)));
        if new_dist > old_dist
            addition = -1;
        end
        while smaller == 1
            old_dist = new_dist;
            ind      = ind + addition;
            new_dist = min(sqrt(((c_ini_used(:,1) - dist_x(ind)).^2)+((c_ini_used(:,2) - dist_y(ind)).^2)));
            if new_dist>old_dist
                ind = ind - addition;
                smaller = 0;
            end
        end

        if old_dist < dist_dx
            ini_dist(kk) = dist_ax(ind);
        end
    end

    % Determine distance for final coastline
    if ~isempty(c_end_used)
        smaller  = 1; ind = ((length(dist_ax)+1)/2); addition = 1;
        old_dist = min(sqrt(((c_end_used(:,1) - dist_x(ind)).^2)+((c_end_used(:,2) - dist_y(ind)).^2)));
        ind      = ind + addition;
        new_dist = min(sqrt(((c_end_used(:,1) - dist_x(ind)).^2)+((c_end_used(:,2) - dist_y(ind)).^2)));
        if new_dist > old_dist
            addition = -1;
        end
        while smaller == 1
            old_dist = new_dist;
            ind      = ind + addition;
            new_dist = min(sqrt(((c_end_used(:,1) - dist_x(ind)).^2)+((c_end_used(:,2) - dist_y(ind)).^2)));
            if new_dist>old_dist
                ind = ind - addition;
                smaller = 0;
            end
        end

        if old_dist < dist_dx
            end_dist(kk) = dist_ax(ind);
        end
    end

end

end