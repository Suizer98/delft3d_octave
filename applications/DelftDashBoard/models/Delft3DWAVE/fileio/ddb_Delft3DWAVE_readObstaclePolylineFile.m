function obs=ddb_Delft3DWAVE_readObstaclePolylineFile(obs,filename)

info = tekal('open',filename,'loaddata');

nobs=length(obs);

if nobs>0
    % Obstacle data is already available, find matching polylines
    for ii=1:length(info.Field)
        plinames{ii}=lower(info.Field(ii).Name);
    end
    for ii=1:nobs
        jj=strmatch(lower(obs(ii).name),plinames,'exact');
        if ~isempty(jj)
            obs(ii).x=info.Field(jj).Data(:,1);
            obs(ii).y=info.Field(jj).Data(:,2);
        else
            obs(ii).x=[0 0];
            obs(ii).y=[0 0];
            ddb_giveWarning('txt',['Obstacle with name ' obs(ii).name ' not found in polyline file!']);
        end
    end
else
    % No obstacle data available
    for ii=1:length(info.Field)
        nobs=nobs+1;
        obs(nobs).name=info.Field(ii).Name;
        obs(nobs).x=info.Field(ii).Data(:,1);
        obs(nobs).y=info.Field(ii).Data(:,2);
    end    
end
