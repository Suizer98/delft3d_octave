function sfincs_write_coastline(filename,coastline)

fid=fopen(filename,'wt');
for ip=1:coastline.length
    x=coastline.x(ip);
    y=coastline.y(ip);
    itype=coastline.type(ip);
    phi=coastline.orientation(ip);
    slope=coastline.slope(ip);
    dean=coastline.dean(ip);
    reef_width=coastline.reef_width(ip);
    reef_height=coastline.reef_height(ip);
    fprintf(fid,'%11.1f %11.1f %2i %6.1f %10.7f %10.7f %8.1f %8.2f\n',x,y,itype,phi,slope,dean,reef_width,reef_height);
end
fclose(fid);
