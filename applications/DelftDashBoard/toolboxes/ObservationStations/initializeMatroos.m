clear variables;close all;

% matroos_server;
[locs,sources,units] = matroos_list;

stationNames={''};
nstat=0;
nsrc=0;
for i=1:length(locs)
    if strcmpi(sources{i},'observed') && ~isempty(locs{i})
        ii=strmatch(locs{i},stationNames,'exact');
        if isempty(ii)
            % New station
            nstat=nstat+1;
            stationNames{nstat}=locs{i};
            ii=nstat;
            station(ii).name=locs{i};
            station(ii).parameters.name=[];
            station(ii).parameters.status=[];
        end
        npar=length(station(ii).parameters.name);
        npar=npar+1;
        station(ii).parameters.name{npar}=units{i};
        station(ii).parameters.status(npar)=1;        
    end
end

k=0;
for i=1:length(station)
%    for j=1:length(station(i).parameters.name)
    for j=1:1
    try
        disp(station(i).name);
        disp(station(i).parameters.name{j});
%        [ t, values , metainfo] = matroos_get_series('loc',station(i).name,'unit',station(i).parameters.name{j},'source','observed','tstart',now-5,'tstop',now-1,'check','s');
        D = matroos_get_series('loc',station(i).name,'unit',station(i).parameters.name{j},'source','observed','tstart',now-5,'tstop',now-1,'check','s');
        k=k+1;
        s.name{k}=station(i).name;
        s.x(k)=D.lon;
        s.y(k)=D.lat;
        for j=1:length(station(i).parameters.name)
            s.parameters(k).name{j}=station(i).parameters.name{j};
            s.parameters(k).status(j)=1;
        end
        D
        break        
    catch
%         a=lasterror
%         a.stack(1)
%         disp('failed!')
    end
    end
end
