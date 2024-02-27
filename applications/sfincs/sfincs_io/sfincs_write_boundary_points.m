function sfincs_write_boundary_points(filename,points)

fid=fopen(filename,'wt');
for ip=1:points.length
    fprintf(fid,'%10.1f %10.1f\n',points.x(ip),points.y(ip));
end
fclose(fid);
