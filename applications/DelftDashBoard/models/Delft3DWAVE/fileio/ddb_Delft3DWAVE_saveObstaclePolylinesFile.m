function ddb_Delft3DWAVE_saveObstaclePolylinesFile(handles)

inp=handles.model.delft3dwave.domain;

%% Polyline line

fid=fopen(inp.obstaclepolylinesfile,'wt');
for iob=1:inp.nrobstacles
    fprintf(fid,'%s\n',inp.obstacles(iob).name);
    fprintf(fid,'%i %i\n',length(inp.obstacles(iob).x),2);
    for ip=1:length(inp.obstacles(iob).x)
        fprintf(fid,'%14.6e %14.6e\n',inp.obstacles(iob).x(ip),inp.obstacles(iob).y(ip));
    end    
end
fclose(fid);
