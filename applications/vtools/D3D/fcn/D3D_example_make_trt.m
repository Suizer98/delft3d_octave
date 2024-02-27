gridfile = 'Grid_net.nc'
gridccfile = 'Grid_cc_net.nc'
D3D_grd2map(gridfile, ...
        'fpath_map', gridccfile, ... 
        'fpath_exe', "c:\Program Files\Deltares\D-HYDRO Suite 1D2D (1.0.0.53506)\plugins\DeltaShell.Dimr\kernels\x64\dimr\scripts\run_dimr.bat"); 
    
%%
xu = ncread('Grid_cc_net.nc', 'mesh2d_edge_x');
yu = ncread('Grid_cc_net.nc', 'mesh2d_edge_y');

%%
rough_code = 1;
rough_fraction = 1; 

fid = fopen('trachy.arl','w'); 
for k = 1:length(xu); 
    fprintf(fid, '%20.6f %20.6f 0.0 %5i %5.2f\n', xu(k), xu(k), rough_code, rough_fraction);
end 
fclose (fid);