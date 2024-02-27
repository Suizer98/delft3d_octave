function [timestep,istation,m,n,k,idomain]=muppet_findDataIndices(dataset)

% Determines indices. Used in dataset gui 

timestep=[];
istation=[];
m=[];
n=[];
k=[];
idomain=[];

%% Time can be defined by timestep and by actual time
if isempty(dataset.time) && ~isempty(dataset.timestep)
    % time step
    timestep=dataset.timestep;
elseif ~isempty(dataset.time) && isempty(dataset.timestep)
    % time
    % Find time step that is closest to requested time
%    timestep=find(abs(dataset.times-dataset.time)<1/864000);
    tmp = abs(dataset.times-dataset.time);
    [dummy,timestep] = min(tmp);
    if dummy*86400>0.1 % If time step is more
        disp(['Time step ' datestr(dataset.time,'yyyymmdd HHMMSS') ' not found! Taking the closest value!']);
    end
elseif isempty(dataset.time) && isempty(dataset.timestep)
    % both empty
    if dataset.size(1)>0
        timestep=1:dataset.size(1);
    else
        timestep=1;
    end
else
    % this should never happen
    timestep=dataset.timestep;
end

%% Station
if ~isempty(dataset.station)
    istation=strmatch(dataset.station,dataset.stations,'exact');
    if length(istation)>1
        if ~isempty(dataset.stationnumber)
            istation=dataset.stationnumber;
        else
            istation=istation(1);
            disp('Warning! Multiple stations with this name found! First station picked!');
        end
    end
else
    istation=1:dataset.size(2);
end

%% M
if isempty(dataset.m)
    if dataset.size(3)>0
        m=1:dataset.size(3);
%     else
%         m=1;
    end
else
    m=dataset.m;
end

%% N
if isempty(dataset.n)
    if dataset.size(4)>0
        n=1:dataset.size(4);
%     else
%         n=1;
    end
else
    n=dataset.n;
end

%% K
if isempty(dataset.k)
    if dataset.size(5)>0
        k=1:dataset.size(5);
%     else
%         k=1;
    end
else
    k=dataset.k;
end

%% Domain
idomain=1;
if isfield(dataset,'domain')
    if ~isempty(dataset.domain)
        idomain=strmatch(dataset.domain,dataset.domains,'exact');
    end
end
