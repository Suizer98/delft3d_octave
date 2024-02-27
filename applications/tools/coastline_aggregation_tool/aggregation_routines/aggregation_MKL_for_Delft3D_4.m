function [c_ini c_end] = aggregation_MKL_for_Delft3D_4(map_file,c_ini_ori,c_end_ori,ldb,offshore_orientation,varargin)

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

bed_levels = qpread(d3d_handle,'bed level in water level points','griddata',[OPT.time_inds(1) OPT.time_inds(2)]); % Cell center data
% Remove NaN's from the data (needed for interpolation):
bed_levels.Y(isnan(bed_levels.X)) = 0; bed_levels.Val(1,isnan(bed_levels.X)) = 0; bed_levels.Val(2,isnan(bed_levels.X)) = 0; bed_levels.X(isnan(bed_levels.X)) = 0;

coastline.offshore_orientation = offshore_orientation;
coastline.ldb                  = ldb;

c_ini = nan(size(coastline.offshore_orientation,1),2);
c_end = nan(size(coastline.offshore_orientation,1),2);

disp('   Starting an MCL analysis, this may take a moment..');

for kk=find(isnan(coastline.offshore_orientation)==0)'
    
    % Cross-shore axis for this coastline point
    dist_dx = 1;
    dist_ax = [-1000:1000];
    dist_x = coastline.ldb(kk,1) + (dist_ax.*sind(coastline.offshore_orientation(kk)));
    dist_y = coastline.ldb(kk,2) + (dist_ax.*cosd(coastline.offshore_orientation(kk)));
    
    % Lets filter the contour lines:
    
    % First step (50 times dx to speed stuff up)
    
    c_ini_ori_filter_1 = []; c_ini_ori_filter_2 = [];
    c_end_ori_filter_1 = []; c_end_ori_filter_2 = [];
    
    first_step_factor = 50;
    
    for ii = 1:first_step_factor:length(dist_ax)
        
        c_ini_ori_filter_1 = [c_ini_ori_filter_1; find(sqrt(((c_ini_ori{1}(:,1) - dist_x(ii)).^2) + ((c_ini_ori{1}(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
        c_ini_ori_filter_2 = [c_ini_ori_filter_2; find(sqrt(((c_ini_ori{2}(:,1) - dist_x(ii)).^2) + ((c_ini_ori{2}(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
        
        c_end_ori_filter_1 = [c_end_ori_filter_1; find(sqrt(((c_end_ori{1}(:,1) - dist_x(ii)).^2) + ((c_end_ori{1}(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
        c_end_ori_filter_2 = [c_end_ori_filter_2; find(sqrt(((c_end_ori{2}(:,1) - dist_x(ii)).^2) + ((c_end_ori{2}(:,2) - dist_y(ii)).^2)) <= (dist_dx .* first_step_factor))];
    end
    
    c_ini_ori_filter_1 = sort(unique(c_ini_ori_filter_1));
    c_ini_ori_filter_2 = sort(unique(c_ini_ori_filter_2));
    c_end_ori_filter_1 = sort(unique(c_end_ori_filter_1));
    c_end_ori_filter_2 = sort(unique(c_end_ori_filter_2));
    
    c_ini_1st{1} = c_ini_ori{1}(c_ini_ori_filter_1,:);
    c_ini_1st{2} = c_ini_ori{2}(c_ini_ori_filter_2,:);
    c_end_1st{1} = c_end_ori{1}(c_end_ori_filter_1,:);
    c_end_1st{2} = c_end_ori{2}(c_end_ori_filter_2,:);
    
    % Second step (full dx resolution)
    
    c_ini_ori_filter_1 = []; c_ini_ori_filter_2 = [];
    c_end_ori_filter_1 = []; c_end_ori_filter_2 = [];
    
    for ii = 1:length(dist_ax)
        
        c_ini_ori_filter_1 = [c_ini_ori_filter_1; find(sqrt(((c_ini_1st{1}(:,1) - dist_x(ii)).^2) + ((c_ini_1st{1}(:,2) - dist_y(ii)).^2)) <= dist_dx)];
        c_ini_ori_filter_2 = [c_ini_ori_filter_2; find(sqrt(((c_ini_1st{2}(:,1) - dist_x(ii)).^2) + ((c_ini_1st{2}(:,2) - dist_y(ii)).^2)) <= dist_dx)];
        
        c_end_ori_filter_1 = [c_end_ori_filter_1; find(sqrt(((c_end_1st{1}(:,1) - dist_x(ii)).^2) + ((c_end_1st{1}(:,2) - dist_y(ii)).^2)) <= dist_dx)];
        c_end_ori_filter_2 = [c_end_ori_filter_2; find(sqrt(((c_end_1st{2}(:,1) - dist_x(ii)).^2) + ((c_end_1st{2}(:,2) - dist_y(ii)).^2)) <= dist_dx)];
    end
    
    c_ini_ori_filter_1 = sort(unique(c_ini_ori_filter_1));
    c_ini_ori_filter_2 = sort(unique(c_ini_ori_filter_2));
    c_end_ori_filter_1 = sort(unique(c_end_ori_filter_1));
    c_end_ori_filter_2 = sort(unique(c_end_ori_filter_2));
    
    c_ini_used{1} = c_ini_1st{1}(c_ini_ori_filter_1,:);
    c_ini_used{2} = c_ini_1st{2}(c_ini_ori_filter_2,:);
    c_end_used{1} = c_end_1st{1}(c_end_ori_filter_1,:);
    c_end_used{2} = c_end_1st{2}(c_end_ori_filter_2,:);
    
    % Below a figure if you wish to check the filtering:
    
%     figure;
%     plot(dist_x,dist_y,'k.-')
%     hold on; grid on; box on; axis equal;
%     plot(c_ini_ori{1}(:,1),c_ini_ori{1}(:,2),'c.-');
%     plot(c_ini_ori{2}(:,1),c_ini_ori{2}(:,2),'c.-');
%     plot(c_end_ori{1}(:,1),c_end_ori{1}(:,2),'y.-');
%     plot(c_end_ori{2}(:,1),c_end_ori{2}(:,2),'y.-');
%     
%     plot(c_ini_1st{1}(:,1),c_ini_1st{1}(:,2),'b.-');
%     plot(c_ini_1st{2}(:,1),c_ini_1st{2}(:,2),'b.-');
%     plot(c_end_1st{1}(:,1),c_end_1st{1}(:,2),'g.-');
%     plot(c_end_1st{2}(:,1),c_end_1st{2}(:,2),'g.-');
%     
%     plot(c_ini_used{1}(:,1),c_ini_used{1}(:,2),'k.-');
%     plot(c_ini_used{2}(:,1),c_ini_used{2}(:,2),'k.-');
%     plot(c_end_used{1}(:,1),c_end_used{1}(:,2),'k.-');
%     plot(c_end_used{2}(:,1),c_end_used{2}(:,2),'k.-');
    
    % Determine ini coastline:
    c_ini_inds = []; c_ini_dists = []; c_ini_x = []; c_ini_y = [];
    for c_ind = 1:2
        
        if isempty(c_ini_used{c_ind})
            
            c_ini_dists(1,c_ind) = NaN;
            c_ini_x(1,c_ind)     = NaN;
            c_ini_y(1,c_ind)     = NaN;
            
        else

            smaller  = 1; ind = ((length(dist_ax)+1)/2); addition = 1;
            old_dist = min(sqrt(((c_ini_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_ini_used{c_ind}(:,2) - dist_y(ind)).^2)));
            ind      = ind + addition;
            new_dist = min(sqrt(((c_ini_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_ini_used{c_ind}(:,2) - dist_y(ind)).^2)));
            if new_dist > old_dist
                addition = -1;
            end
            while smaller == 1
                old_dist = new_dist;
                ind      = ind + addition;
                new_dist = min(sqrt(((c_ini_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_ini_used{c_ind}(:,2) - dist_y(ind)).^2)));
                if new_dist>old_dist
                    ind = ind - addition;
                    smaller = 0;
                end
            end

            if old_dist < dist_dx
                c_ini_inds(1,c_ind)  = ind;
                if diff(c_ini_inds) == 0
                    c_ini_inds(1) = c_ini_inds(1) - 1;
                    c_ini_inds(2) = c_ini_inds(2) + 1;
                elseif diff(c_ini_inds) < 0
                    error('Contact developer with error code 3458734598');
                end
                c_ini_dists(1,c_ind) = dist_ax(ind);
                c_ini_x(1,c_ind)     = dist_x(ind);
                c_ini_y(1,c_ind)     = dist_y(ind);
            else
                c_ini_dists(1,c_ind) = NaN;
                c_ini_x(1,c_ind)     = NaN;
                c_ini_y(1,c_ind)     = NaN;
            end
        end
    end
    
    % Determine end coastline:
    c_end_inds = []; c_end_dists = []; c_end_x = []; c_end_y = [];
    for c_ind = 1:2
        
        if isempty(c_end_used{c_ind})
            c_end_dists(1,c_ind) = NaN;
            c_end_x(1,c_ind)     = NaN;
            c_end_y(1,c_ind)     = NaN;
        else
            smaller  = 1; ind = ((length(dist_ax)+1)/2); addition = 1;
            old_dist = min(sqrt(((c_end_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_end_used{c_ind}(:,2) - dist_y(ind)).^2)));
            ind      = ind + addition;
            new_dist = min(sqrt(((c_end_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_end_used{c_ind}(:,2) - dist_y(ind)).^2)));
            if new_dist > old_dist
                addition = -1;
            end
            while smaller == 1
                old_dist = new_dist;
                ind      = ind + addition;
                new_dist = min(sqrt(((c_end_used{c_ind}(:,1) - dist_x(ind)).^2)+((c_end_used{c_ind}(:,2) - dist_y(ind)).^2)));
                if new_dist>old_dist
                    ind = ind - addition;
                    smaller = 0;
                end
            end

            if old_dist < dist_dx
                c_end_inds(1,c_ind)  = ind;
                if diff(c_end_inds) == 0
                    c_end_inds(1) = c_end_inds(1) - 1;
                    c_end_inds(2) = c_end_inds(2) + 1;
                elseif diff(c_end_inds) < 0
                    error('Contact developer with error code 3458734598');
                end
                c_end_dists(1,c_ind) = dist_ax(ind);
                c_end_x(1,c_ind)     = dist_x(ind);
                c_end_y(1,c_ind)     = dist_y(ind);
            else
                c_end_dists(1,c_ind) = NaN;
                c_end_x(1,c_ind)     = NaN;
                c_end_y(1,c_ind)     = NaN;
            end
        end
    end
    
    % Determine c_ini locations:
    if ~isnan(c_ini_x(1,1)) && ~isnan(c_ini_x(1,2))
    
        MKL_num_pts = 20;
        MKL_ax.x = c_ini_x(1):diff(c_ini_x)./(MKL_num_pts-1):c_ini_x(2);
        MKL_ax.y = c_ini_y(1):diff(c_ini_y)./(MKL_num_pts-1):c_ini_y(2);

        MKL_ax.z = min(OPT.z_level(2),max(OPT.z_level(1),griddata(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(1,:,:)),MKL_ax.x,MKL_ax.y)));

        MKL_ax.height = MKL_ax.z - OPT.z_level(1);

        MKL_ax.dist = (sum(mean([MKL_ax.height(1:end-1); MKL_ax.height(2:end)]) .* sqrt(diff(MKL_ax.x([1 2])).^2 + diff(MKL_ax.y([1 2])).^2))) ./ diff(OPT.z_level);

        MKL_ax.pos_x  = interp1([0 sqrt((cumsum(diff(MKL_ax.x)).^2)+(cumsum(diff(MKL_ax.y)).^2))],MKL_ax.x,MKL_ax.dist);
        MKL_ax.pos_y  = interp1([0 sqrt((cumsum(diff(MKL_ax.x)).^2)+(cumsum(diff(MKL_ax.y)).^2))],MKL_ax.y,MKL_ax.dist);

        c_ini(kk,:) = [MKL_ax.pos_x MKL_ax.pos_y];
        
    end
    
    % Determine c_end locations:
    if ~isnan(c_end_x(1,1)) && ~isnan(c_end_x(1,2))
    
        MKL_num_pts = 20;
        MKL_ax.x = c_end_x(1):diff(c_end_x)./(MKL_num_pts-1):c_end_x(2);
        MKL_ax.y = c_end_y(1):diff(c_end_y)./(MKL_num_pts-1):c_end_y(2);

        MKL_ax.z = min(OPT.z_level(2),max(OPT.z_level(1),griddata(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(2,:,:)),MKL_ax.x,MKL_ax.y)));

        MKL_ax.height = MKL_ax.z - OPT.z_level(1);

        MKL_ax.dist = (sum(mean([MKL_ax.height(1:end-1); MKL_ax.height(2:end)]) .* sqrt(diff(MKL_ax.x([1 2])).^2 + diff(MKL_ax.y([1 2])).^2))) ./ diff(OPT.z_level);

        MKL_ax.pos_x  = interp1([0 sqrt((cumsum(diff(MKL_ax.x)).^2)+(cumsum(diff(MKL_ax.y)).^2))],MKL_ax.x,MKL_ax.dist);
        MKL_ax.pos_y  = interp1([0 sqrt((cumsum(diff(MKL_ax.x)).^2)+(cumsum(diff(MKL_ax.y)).^2))],MKL_ax.y,MKL_ax.dist);

        c_end(kk,:) = [MKL_ax.pos_x MKL_ax.pos_y];
        
    end
    
end

if sum(isnan(c_ini(:,1))) == size(c_ini,1)
    error('No MKL coastline constructed');
end
if sum(isnan(c_end(:,1))) == size(c_end,1)
    error('No MKL coastline constructed');
end

% Remove starting NaN's:
if isnan(c_ini(1,1))
    c_ini = c_ini(min(find(diff(isnan(c_ini(:,1)))~=0))+1:end,:);
end
if isnan(c_end(1,1))
    c_end = c_end(min(find(diff(isnan(c_end(:,1)))~=0))+1:end,:);
end
% Remove trailing NaN's:
if isnan(c_ini(end,1))
    c_ini = c_ini(1:max(find(diff(isnan(c_ini(:,1)))~=0)),:);
end
if isnan(c_end(end,1))
    c_end = c_end(1:max(find(diff(isnan(c_end(:,1)))~=0)),:);
end

end