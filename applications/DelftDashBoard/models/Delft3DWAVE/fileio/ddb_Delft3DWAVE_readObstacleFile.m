function [obs,plifile]=ddb_Delft3DWAVE_readObstacleFile(obs,filename)

s = ddb_readDelft3D_keyWordFile(filename);

plifile=s.obstaclefileinformation.polylinefile;

if isempty(obs)
    % First initialize obstacles
    for ii=1:length(s.obstacle)
        obs=ddb_initializeDelft3DWAVEObstacle(obs,ii);
    end    
end

for ii=1:length(s.obstacle)
    flds={'name','type','height','alpha','beta','reflections','refleccoef'};
    for kk=1:length(flds)
        if isfield(s.obstacle(ii),flds{kk})
            if ~isempty(s.obstacle(ii).(flds{kk}))
                obs(ii).(flds{kk})=s.obstacle(ii).(flds{kk});
            end
        end
    end
end

% If polyline file exists, read it now
if exist(plifile,'file')
    obs=ddb_Delft3DWAVE_readObstaclePolylineFile(obs,plifile);    
end
