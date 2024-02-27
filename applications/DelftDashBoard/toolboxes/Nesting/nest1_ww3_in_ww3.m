function output_boundary_points=nest1_ww3_in_ww3(output_boundary_points,ww3_grid_file)

[x0,y0,dx,dy,np,ixd,iyd]=ww3_define_nesting_sections(ww3_grid_file);
nsec=length(x0);

% Store in domain structure
nobp=length(output_boundary_points);
nobp=nobp+1;
for ii=1:nsec
    output_boundary_points(nobp).line(ii).x0=x0(ii);
    output_boundary_points(nobp).line(ii).y0=y0(ii);
    output_boundary_points(nobp).line(ii).dx=dx(ii);
    output_boundary_points(nobp).line(ii).dy=dy(ii);
    output_boundary_points(nobp).line(ii).np=np(ii);
end

% Also update ww3_grid.inp file of detailed model!
grd=ww3_initialize_grid_input;
grd=ww3_read_grid_inp(ww3_grid_file,grd);
grd.boundary_points=[];
n=0;
for isec=1:size(ixd,1)
    n=n+1;
    grd.boundary_points(n).ix=ixd(isec,1);
    grd.boundary_points(n).iy=iyd(isec,1);
    grd.boundary_points(n).flag=0;
    n=n+1;
    grd.boundary_points(n).ix=ixd(isec,2);
    grd.boundary_points(n).iy=iyd(isec,2);
    grd.boundary_points(n).flag=1;
end
copyfile(ww3_grid_file,[ww3_grid_file '.backup']);
ww3_write_grid_inp(ww3_grid_file,grd);
