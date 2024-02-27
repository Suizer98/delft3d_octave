function handles = ddb_Delft3DWAVE_readAttributeFiles(handles)

for ib=1:handles.model.delft3dwave.domain.nrdomains
    if ~isempty(handles.model.delft3dwave.domain.domains(ib).grid)
        [x,y,enc]=ddb_wlgrid('read',handles.model.delft3dwave.domain.domains(ib).grid);
        handles.model.delft3dwave.domain.domains(ib).gridx=x;
        handles.model.delft3dwave.domain.domains(ib).gridy=y;
        nans=zeros(size(handles.model.delft3dwave.domain.domains(ib).gridx));
        nans(nans==0)=NaN;
        handles.model.delft3dwave.domain.domains(ib).depth=nans;
        handles.model.delft3dwave.domain.domains(ib).mmax=size(x,1);
        handles.model.delft3dwave.domain.domains(ib).nmax=size(x,2);
        if ~isempty(handles.model.delft3dwave.domain.domains(ib).bedlevel)
            mmax=handles.model.delft3dwave.domain.domains(ib).mmax;
            nmax=handles.model.delft3dwave.domain.domains(ib).nmax;
            dp=ddb_wldep('read',handles.model.delft3dwave.domain.domains(ib).bedlevel,[mmax+1 nmax+1]);
            handles.model.delft3dwave.domain.domains(ib).depth=-dp(1:end-1,1:end-1);
        end
    end
end

if ~isempty(handles.model.delft3dwave.domain.obstaclefile)
    obs=[];
    [obs,plifile]=ddb_Delft3DWAVE_readObstacleFile(obs,handles.model.delft3dwave.domain.obstaclefile);
    for ii=1:length(obs)
        handles.model.delft3dwave.domain.obstaclenames{ii}=obs(ii).name;
    end
    handles.model.delft3dwave.domain.obstaclepolylinesfile=plifile;
    handles.model.delft3dwave.domain.obstacles=obs;
    handles.model.delft3dwave.domain.nrobstacles=length(obs);    
end

if ~isempty(handles.model.delft3dwave.domain.locationfile)
    if ~isempty(handles.model.delft3dwave.domain.locationfile{1})
        for ii=1:length(handles.model.delft3dwave.domain.locationfile)
            xy=load(handles.model.delft3dwave.domain.locationfile{ii});
            handles.model.delft3dwave.domain.locationsets(ii).x=xy(:,1)';
            handles.model.delft3dwave.domain.locationsets(ii).y=xy(:,2)';
            handles.model.delft3dwave.domain.locationsets(ii).nrpoints=length(handles.model.delft3dwave.domain.locationsets(ii).x);
            handles.model.delft3dwave.domain.locationsets(ii).activepoint=1;
            for jj=1:handles.model.delft3dwave.domain.locationsets(ii).nrpoints
                handles.model.delft3dwave.domain.locationsets(ii).pointtext{jj}=num2str(jj);
            end
        end
        handles.model.delft3dwave.domain.activelocationset=1;
        handles.model.delft3dwave.domain.nrlocationsets=length(handles.model.delft3dwave.domain.locationfile);
    end
end
