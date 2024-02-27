clear all;close all;

OBSTR_OFFSET=1;

boundary='full';
ref_dir='d:\programs\wavewatch3\gridgen\reference_data\';

inpdir='d:\temp\ww3_test\swindian\newgrd\';
grd=ww3_read_grid_inp([inpdir 'ww3_grid.inp']);

lon1d = grd.x0:grd.dx:grd.x0+(grd.nx-1)*grd.dx;
lat1d = grd.y0:grd.dy:grd.y0+(grd.ny-1)*grd.dy;
[lon,lat] = meshgrid(lon1d,lat1d);

bot=ww3_read_bottom_depth_file([inpdir grd.bottom_depth_filename],grd.nx,grd.ny,grd.bottom_depth_scaling_factor);
mask=zeros(size(bot));
mask(bot<-1)=1;

% Read WVS data
bound=load([ref_dir 'coastal_bound_' boundary '.mat']); 
bound=bound.bound;
N = length(bound);
coord = [lat1d(1) lon1d(1) lat1d(end) lon1d(end)];
[b,N1] = compute_boundary(coord,bound);
b_split = split_boundary(b,5*max([grd.dx grd.dy]));

[sx1,sy1] = create_obstr(lon,lat,b,mask,OBSTR_OFFSET,OBSTR_OFFSET);

pcolor(lon,lat,sy1);shading flat;axis equal;colorbar
