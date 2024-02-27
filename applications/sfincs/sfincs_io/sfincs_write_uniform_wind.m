function sfincs_write_uniform_wind(filename,vt,vmag,vdir)
% Spatially uniform wind
%%%%%
%.wnd
% t0 vmag0 vdir0 
% t1 vmag1 vdir1
%%%%%
fid = fopen(filename,'wt');
A = [vt; vmag; vdir]; 
fprintf(fid, '%f %f %f\n', A);
fclose(fid);
