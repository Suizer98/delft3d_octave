function [match_idx]=interp_tri2grid(x,y,z,n1,n2,n3,lon,lat,wb_h,pct_h)

n_t = length(n1);

pt1_x = x(n1);
pt2_x = x(n2);
pt3_x = x(n3);

pt1_y = y(n1);
pt2_y = y(n2);
pt3_y = y(n3);

pt1_z = z(n1);
pt2_z = z(n2);
pt3_z = z(n3);

% note: These values indicate the direction of each line on the triangle to 
% the third point of the triangle (not on the original triangle)

y_int_1 =  pt2_x.*pt1_y - pt1_x.*pt2_y;
y_int_2 =  pt3_x.*pt2_y - pt2_x.*pt3_y;
y_int_3 =  pt1_x.*pt3_y - pt3_x.*pt1_y;


dir_1 = sign((pt2_x - pt1_x).*pt3_y - (pt2_y - pt1_y).*pt3_x - y_int_1);
dir_2 = sign((pt3_x - pt2_x).*pt1_y - (pt3_y - pt2_y).*pt1_x - y_int_2);
dir_3 = sign((pt1_x - pt3_x).*pt2_y - (pt1_y - pt3_y).*pt2_x - y_int_3);

match_idx = nan(size(lat));

lon_val = lon(1,:);
lat_val = lat(:,1);
nr = length(lat_val);


% define the planes for each triangle:
v1 = pt2_x - pt1_x; % first vector on each plane
v2 = pt2_y - pt1_y;
v3 = pt2_z - pt1_z;

u1 = pt3_x - pt1_x; % second vector on each plane
u2 = pt3_y - pt1_y;
u3 = pt3_z - pt1_z;
            
A = v2.*u3 - v3.*u2; % cross product to the two vectors is the normal of 
B = v3.*u1 - v1.*u3; % the plane
C = v1.*u2 - v2.*u1;

% "intercept" of the plane calculated from any point on the plane. Use pt1.
M = A.*pt1_x + B.*pt1_y + C.*pt1_z;


for c=1:n_t  % or n_t 
    if rem(c,200) == 1
        wb_label = sprintf('Completed on %d triangles out of %d\n',c-1,n_t);
        pct_ratio = (c-1)/n_t;
        pct_v = pct_h(1) + pct_ratio*(diff(pct_h));
        waitbar(pct_v,wb_h,wb_label)
    end
    min_x = min([pt1_x(c),pt2_x(c),pt3_x(c)]);
    max_x = max([pt1_x(c),pt2_x(c),pt3_x(c)]);
    min_y = min([pt1_y(c),pt2_y(c),pt3_y(c)]);
    max_y = max([pt1_y(c),pt2_y(c),pt3_y(c)]);
    
    min_lon_idx = find(lon_val >= min_x,1,'first');
    max_lon_idx = find(lon_val <= max_x,1,'last');
    
    min_lat_idx = find(lat_val >= min_y,1,'first');
    max_lat_idx = find(lat_val <= max_y,1,'last');
    if ~(isempty(min_lat_idx)||isempty(max_lat_idx)||isempty(min_lon_idx)||isempty(max_lon_idx))
        
        cur_lat = lat(min_lat_idx:max_lat_idx,min_lon_idx:max_lon_idx);
        cur_lon = lon(min_lat_idx:max_lat_idx,min_lon_idx:max_lon_idx);
        
        
        line_1 = sign((pt2_x(c) - pt1_x(c))*cur_lat - (pt2_y(c) - pt1_y(c))*cur_lon - y_int_1(c));
        line_2 = sign((pt3_x(c) - pt2_x(c))*cur_lat - (pt3_y(c) - pt2_y(c))*cur_lon - y_int_2(c));
        line_3 = sign((pt1_x(c) - pt3_x(c))*cur_lat - (pt1_y(c) - pt3_y(c))*cur_lon - y_int_3(c));
        
        [cur_idx_r,cur_idx_c] = find(line_1*dir_1(c)>=0 & line_2*dir_2(c)>=0 & line_3*dir_3(c)>=0);
        
        
        if ~isempty(cur_idx_c)
            
            %interpolate any found points to the current plane (c)
            
            cur_idx_r = cur_idx_r + min_lat_idx-1;
            cur_idx_c = cur_idx_c + min_lon_idx-1;
            
            loc_idx = cur_idx_r + (cur_idx_c-1)*nr;
            
            lat_pos = lat(loc_idx);
            lon_pos = lon(loc_idx);
            
            match_idx(loc_idx) = (M(c) - A(c)*lon_pos - B(c)*lat_pos)./C(c);
            
            
            % now interpolate
            
            %match_idx(loc_idx) = c;
        end
    end
end

clear pt* y_* dir_* u* v* lat lon n* A B C M *_val cur_* x y z
waitbar(pct_h(2),wb_h,'Completed interpolation of triangles onto the grid')



return