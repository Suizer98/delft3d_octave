function ddb_Delft3DWAVE_saveObstacleFile(handles)

inp=handles.model.delft3dwave.domain;

%% Obstacle file

obs.ObstacleFileInformation.FileVersion.value        = '02.00';
obs.ObstacleFileInformation.PolylineFile.value       = inp.obstaclepolylinesfile;

for iob=1:inp.nrobstacles
    obs.Obstacle(iob).Name.value               = inp.obstacles(iob).name;
    obs.Obstacle(iob).Type.value               = inp.obstacles(iob).type;
    switch lower(inp.obstacles(iob).type)
        case{'dam'}
            obs.Obstacle(iob).Height.value             = inp.obstacles(iob).height;
            obs.Obstacle(iob).Height.type              = 'real';
            obs.Obstacle(iob).Alpha.value              = inp.obstacles(iob).alpha;
            obs.Obstacle(iob).Alpha.type               = 'real';
            obs.Obstacle(iob).Beta.value               = inp.obstacles(iob).beta;
            obs.Obstacle(iob).Beta.type                = 'real';
        case{'sheet'}
            obs.Obstacle(iob).TransmCoef.value               = inp.obstacles(iob).transmcoef;
            obs.Obstacle(iob).TransmCoef.type                = 'real';
    end
    obs.Obstacle(iob).Reflections.value        = inp.obstacles(iob).reflections;
    switch lower(inp.obstacles(iob).reflections)
        case{'no'}
        otherwise
            obs.Obstacle(iob).ReflecCoef.value               = inp.obstacles(iob).refleccoef;
            obs.Obstacle(iob).ReflecCoef.type                = 'real';
    end
end

ddb_saveDelft3D_keyWordFile(inp.obstaclefile,obs);

% Now save obstacle polylines files
fid=fopen(inp.obstaclepolylinesfile,'wt');
for iob=1:inp.nrobstacles
    fprintf(fid,'%s\n',inp.obstacles(iob).name);
    fprintf(fid,'%i %i\n',length(inp.obstacles(iob).x),2);
    for ip=1:length(inp.obstacles(iob).x)
        fprintf(fid,'%14.6e %14.6e\n',inp.obstacles(iob).x(ip),inp.obstacles(iob).y(ip));
    end    
end
fclose(fid);
