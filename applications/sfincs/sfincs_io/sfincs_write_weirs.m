function sfincs_write_weirs(filename,weirs)
% Weir file
%%%%%
%.weir
% NAME
% 2 4  % size data
% xloc1a yloc1a zloc1a Cdloc1a % start polyline
% xloc1b yloc1b zloc1b Cdloc1b % end polyline
%%%%%

fid=fopen(filename,'wt');

for ip = 1:weirs.length
    fprintf(fid,'%s\n',weirs.name{ip});
    fprintf(fid,'%i %i\n',2,4);        
    fprintf(fid,'%10.1f %10.1f %10.1f %10.1f\n',weirs.x1(ip),weirs.y1(ip),weirs.h1(ip),weirs.Cd1(ip));
    fprintf(fid,'%10.1f %10.1f %10.1f %10.1f\n',weirs.x2(ip),weirs.y2(ip),weirs.h2(ip),weirs.Cd2(ip));    
end
fclose(fid);
