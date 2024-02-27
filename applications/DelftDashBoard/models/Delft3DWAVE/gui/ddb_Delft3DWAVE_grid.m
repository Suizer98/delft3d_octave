function ddb_Delft3DWAVE_grid(varargin)

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addGrid;
        case{'delete'}
            deleteGrid;
        case{'selectgrid'}
            selectGrid;
    end
end

%%
function addGrid

handles=getHandles;
nrgrids = handles.model.delft3dwave.domain.nrgrids+1;
filename = handles.model.delft3dwave.domain.newgrid;
[pathstr,name,ext] = fileparts(filename);
% Set grid values in handles
handles.model.delft3dwave.domain.nrgrids = nrgrids;
handles.model.delft3dwave.domain.domains=ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,nrgrids);
handles.model.delft3dwave.domain.gridnames{nrgrids}=name;
handles.activeWaveGrid=nrgrids;
id=nrgrids;

[x,y,enc,coord]=ddb_wlgrid('read',filename);

% handles.model.delft3dwave.domain.domains(id).coordsyst = coord;
% handles.model.delft3dwave.domain.domains(id).grid=filename;
handles.model.delft3dwave.domain.domains(id).bedlevelgrid=filename;
handles.model.delft3dwave.domain.domains(id).gridname=filename;

handles.model.delft3dwave.domain.domains(id).gridx=x;
handles.model.delft3dwave.domain.domains(id).gridy=y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.delft3dwave.domain.domains(id).depth=nans;

handles.model.delft3dwave.domain.domains(id).mmax=size(x,1);
handles.model.delft3dwave.domain.domains(id).nmax=size(x,2);

% Set NestGrids
if handles.model.delft3dwave.domain.nrgrids>1
   handles.model.delft3dwave.domain.domains(nrgrids).nestgrid=handles.model.delft3dwave.domain.gridnames{1};
else
    handles.model.delft3dwave.domain.domains(nrgrids).nestgrid='';
end
handles = ddb_Delft3DWAVE_setNestGrids(handles);
% Plot new domain
handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);
setHandles(handles);
% Refresh all domains
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);

%%
function deleteGrid

handles=getHandles;
for ii=1:handles.model.delft3dwave.domain.nrgrids
    nestgrids{ii} = handles.model.delft3dwave.domain.domains(ii).nestgrid;
end
if ~isempty(strmatch(handles.model.delft3dwave.domain.domains(awg).gridname,nestgrids,'exact'))
    ddb_giveWarning('text','Cannot delete grid because other grid is nested in it')
    return
else
    % Delete domain from map
    handles=ddb_Delft3DWAVE_plotGrid(handles,'delete','wavedomain',awg,'active',1);
    % Delete domain from struct
    handles.model.delft3dwave.domain.domains = removeFromStruc(handles.model.delft3dwave.domain.domains, awg);
    handles.model.delft3dwave.domain.nrgrids=length(handles.model.delft3dwave.domain.domains);
    handles.model.delft3dwave.domain.gridnames={''};
    for jj=1:length(handles.model.delft3dwave.domain.domains)
        handles.model.delft3dwave.domain.gridnames{jj}=handles.model.delft3dwave.domain.domains(jj).gridname;
    end
    handles.activeWaveGrid=min(handles.model.delft3dwave.domain.nrgrids,awg);
    % Initialize Domain if isempty
    if isempty(handles.model.delft3dwave.domain.domains)
        handles.model.delft3dwave.domain.nrgrids = 0;
        handles.activeWaveGrid=1;
        handles.model.delft3dwave.domain.gridnames={''};
        handles.model.delft3dwave.domain.domains=ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,1);
    end
    % Set NestGrids    
    handles = ddb_Delft3DWAVE_setNestGrids(handles);
    setHandles(handles);
    % Refresh all domains
    ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
end
%%
function selectGrid
% Set NestGrids
handles = getHandles;
handles = ddb_Delft3DWAVE_setNestGrids(handles);
setHandles(handles);
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
