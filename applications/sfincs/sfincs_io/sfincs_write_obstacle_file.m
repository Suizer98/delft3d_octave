function sfincs_write_obstacle_file(filename,obst)

fid=fopen(filename,'wt');

for ii=1:length(obst)
    fprintf(fid,'%s\n',['weir' num2str(ii,'%0.4i')]);
    fprintf(fid,'%i %i\n',length(obst(ii).x),4);
    for ip=1:length(obst(ii).x)
        fprintf(fid,'%12.2f %12.2f %8.3f %8.3f %8.3f %8.3f\n',obst(ii).x(ip),obst(ii).y(ip),obst(ii).z(ip),obst(ii).par1(ip),obst(ii).par2(ip),obst(ii).par3(ip));
    end    
end

fclose(fid);
