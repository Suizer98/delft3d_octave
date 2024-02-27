function adcircTri2Delfttiles(varargin)
out_flag = true;
switch nargin 
    case {1,2}
        file = varargin{1};
        % load data:
        [x,y,z,n1,n2,n3]=read_adcirc_fort14(file);
        out_file = varargin{2};
        z=-z;
    case 3
        x=varargin{1};
        y=varargin{2};
        z=varargin{3};
        n1=varargin{4};
        n2=varargin{5};
        n3=varargin{6};
        out_flag = 0;
        
    case 4
        x=varargin{1};
        y=varargin{2};
        z=varargin{3};
        out_flag = true;
        out_file = varargin{4};
        
end

min_lat = min(y);
max_lat = max(y);
min_lon = min(x);
max_lon = max(x);

%find a good grid resolution:
dx = guess_grid_resolution(x,y);
fprintf('Old Resolution: %f\n',dx)

dx = 1/1200.0;
% dx = 1/100.0;
fprintf('New Resolution: %f\n',dx)
% create grid
[lon_grd,lat_grd]=meshgrid(min_lon:dx:max_lon,min_lat:dx:max_lat);

% fill in the triangles method:
z_grd = nan(size(lon_grd));

match_idx=interp_grid_to_triangles(x,y,z,n1,n2,n3,lon_grd,lat_grd);
    


%%% old way, "Delaunay Triangulation" method
% z_from_xy = TriScatteredInterp(x',y',z');
% z_grd = z_from_xy(lon_grd,lat_grd);

% for now:

% plot grid
if out_flag
    z_to_d3dgrid(out_file,match_idx',lat_grd',lon_grd',dx,dx,5);

else
    pcolor(lon_grd(1:30:end,1:30:end),lat_grd(1:30:end,1:30:end),match_idx(1:30:end,1:30:end))
    shading flat
end


return


function dx = guess_grid_resolution(x,y)

nx = length(x);
% preliminary guess: 100 pts in x direction
% dx = (max(x)-min(x))/100;
% idea, keep roughly the same number of points, make into a rectangular box
% with equally sized dx/dy intervals:

% note that the ratio nLAT/nLON  == LAT_range/LON_range
% and that n_pts = nLAT*nLON
% It follows that nLON = sqrt(n_pts*LON_range/LAT__range)

lat_range = max(y)-min(y);
lon_range = max(x)-min(x);

nLON = sqrt(nx*lon_range/lat_range);

dx = lon_range / nLON;

% %now find the distance between neighbors
% d_list = zeros(1,nx);
% for c=1:nx
%     if ~rem(c,100)
%         fprintf('%d\n',c)
%     end
%     x_pt = x(c);
%     y_pt = y(c);
%     tmp_dist = (x_pt - x).^2 + (y_pt - y).^2;
%     tmp_dist(c)=NaN;
%     d_list(c) = min(tmp_dist);
%     
% end
% dx = mean(d_list);
% fprintf('Mean Dist %.2f' , dx);

return

