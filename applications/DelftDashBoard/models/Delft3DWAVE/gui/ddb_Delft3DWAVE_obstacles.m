function ddb_Delft3DWAVE_obstacles(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotObstacles(handles,'update');
    if handles.model.delft3dwave.domain.nrobstacles>0
        setInstructions({'','','Drag obstacle vertices to change its location'});
    end
else
    opt=varargin{1};
    switch lower(opt)
        case{'addobstacle'}
            drawObstacle;
        case{'selectobstacle'}
            ddb_Delft3DWAVE_plotObstacles(handles,'update');
        case{'changeobstacle'}
            x=varargin{2};
            y=varargin{3};
            h=varargin{4};
            changeObstacle(x,y,h);
        case{'editobstacletable'}
            editObstacleCoordinates;
        case{'loadobsfile'}
            loadObstaclesFile;
        case{'saveobsfile'}
            saveObstaclesFile;
        case{'loadpolylinesfile'}
            loadObstaclePolylinesFile;
        case{'savepolylinesfile'}
            saveObstaclePolylinesFile;
        case{'deleteobstacle'}
            deleteObstacle;
        case{'selecttype'}
            selectObstacleType;
        case{'selectreflections'}
            selectReflections;
        case{'selectreflectioncoefficient'}
            selectReflectionCoefficient;
        case{'selecttransmissioncoefficient'}
            selectTransmissionCoefficient;
        case{'selectheight'}
            selectHeight;
        case{'selectalpha'}
            selectAlpha;
        case{'selectbeta'}
            selectBeta;
        case{'copyfromflow'}
            copyFromFlow;
    end
end

%%
function selectObstacleType
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).type;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).type=val;
end
setHandles(handles);

%%
function selectReflections
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).reflections;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).reflections=val;
end
setHandles(handles);

%%
function selectReflectionCoefficient
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).refleccoef;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).refleccoef=val;
end
setHandles(handles);

%%
function selectTransmissionCoefficient
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).transmcoef;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).transmcoef=val;
end
setHandles(handles);

%%
function selectHeight
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).height;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).height=val;
end
setHandles(handles);

%%
function selectAlpha
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).alpha;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).alpha=val;
end
setHandles(handles);

%%
function selectBeta
handles=getHandles;
val=handles.model.delft3dwave.domain.obstacles(handles.model.delft3dwave.domain.activeobstacle).beta;
iac=handles.model.delft3dwave.domain.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.obstacles(n).beta=val;
end
setHandles(handles);

%%
function drawObstacle

ddb_zoomOff;

setInstructions({'','','Draw obstacle on grid'});

gui_polyline('draw','tag','delft3dwaveobstacle','Marker','o','createcallback',@addObstacle,'changecallback',@changeObstacle,'closed',0, ...
    'color','r','markeredgecolor','r','markerfacecolor','r');

%%
function addObstacle(h,x,y,nr)

setInstructions({'','','Drag obstacle vertices to change the obstacle location'});

handles=getHandles;
handles.model.delft3dwave.domain.nrobstacles=handles.model.delft3dwave.domain.nrobstacles+1;
nrobs=handles.model.delft3dwave.domain.nrobstacles;
handles.model.delft3dwave.domain.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.model.delft3dwave.domain.obstacles,nrobs);
handles.model.delft3dwave.domain.obstacles(nrobs).name=['Obstacle ' num2str(nrobs)];
handles.model.delft3dwave.domain.obstacles(nrobs).handle=h;
handles.model.delft3dwave.domain.activeobstacle=nrobs;
handles.model.delft3dwave.domain.activeobstacles=handles.model.delft3dwave.domain.activeobstacle;
handles.model.delft3dwave.domain.obstaclenames{nrobs}=handles.model.delft3dwave.domain.obstacles(nrobs).name;
handles.model.delft3dwave.domain.obstacles(nrobs).x=x;
handles.model.delft3dwave.domain.obstacles(nrobs).y=y;
setHandles(handles);

ddb_Delft3DWAVE_plotObstacles(handles,'update');

gui_updateActiveTab;

%%
function changeObstacle(h,x,y,nr)

iac=[];
handles=getHandles;
for ii=1:length(handles.model.delft3dwave.domain.obstacles)
    if handles.model.delft3dwave.domain.obstacles(ii).handle==h
        iac=ii;
        break
    end
end
if ~isempty(iac)
    handles.model.delft3dwave.domain.activeobstacle=iac;
    handles.model.delft3dwave.domain.obstacles(iac).x=x;
    handles.model.delft3dwave.domain.obstacles(iac).y=y;
end

setHandles(handles);

ddb_Delft3DWAVE_plotObstacles(handles,'update');

gui_updateActiveTab;

%%
function deleteObstacle

handles=getHandles;
if handles.model.delft3dwave.domain.nrobstacles>0
    iac=handles.model.delft3dwave.domain.activeobstacle;
    try
        delete(handles.model.delft3dwave.domain.obstacles(iac).handle);
    end
    handles.model.delft3dwave.domain.obstacles=removeFromStruc(handles.model.delft3dwave.domain.obstacles,iac);
    handles.model.delft3dwave.domain.obstaclenames=removeFromCellArray(handles.model.delft3dwave.domain.obstaclenames,iac);
    handles.model.delft3dwave.domain.nrobstacles=handles.model.delft3dwave.domain.nrobstacles-1;
    handles.model.delft3dwave.domain.activeobstacle=max(min(handles.model.delft3dwave.domain.activeobstacle,handles.model.delft3dwave.domain.nrobstacles),1);
    handles.model.delft3dwave.domain.activeobstacles=handles.model.delft3dwave.domain.activeobstacle;
    if handles.model.delft3dwave.domain.nrobstacles==0
        handles.model.delft3dwave.domain.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.model.delft3dwave.domain.obstacles,1);
    end
    setHandles(handles);
    gui_updateActiveTab;
    ddb_Delft3DWAVE_plotObstacles(handles,'update');
end

%% 
function editObstacleCoordinates
handles=getHandles;
% Re-plot all obstacles
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
setHandles(handles);



%%
function loadObstaclePolylinesFile
handles=getHandles;

nrobs=handles.model.delft3dwave.domain.nrobstacles;

if nrobs>0
    ButtonName = questdlg('Overwrite existing obstacles?', ...
        'Overwrite existing obstacles', ...
        'No', 'Yes', 'Yes');
    switch ButtonName,
        case 'No'
            nrobs=handles.model.delft3dwave.domain.nrobstacles;
        case 'Yes'
            nrobs=0;
            handles=ddb_Delft3DWAVE_plotObstacles(handles,'delete');
    end
end

obs=[];
obs=ddb_Delft3DWAVE_readObstaclePolylineFile(obs,handles.model.delft3dwave.domain.obstaclepolylinesfile);
handles.model.delft3dwave.domain.nrobstacles=nrobs+length(obs);
if nrobs==0
    handles.model.delft3dwave.domain.obstacles=[];
    handles.model.delft3dwave.domain.obstaclenames={''};
end
handles.model.delft3dwave.domain.activeobstacle=1;
handles.model.delft3dwave.domain.activeobstacles=1;
for ii=1:length(obs)
    handles.model.delft3dwave.domain.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.model.delft3dwave.domain.obstacles,nrobs+ii);
    handles.model.delft3dwave.domain.obstacles(nrobs+ii).name=obs(ii).name;
    handles.model.delft3dwave.domain.obstacles(nrobs+ii).x=obs(ii).x;
    handles.model.delft3dwave.domain.obstacles(nrobs+ii).y=obs(ii).y;
    handles.model.delft3dwave.domain.obstaclenames{nrobs+ii}=obs(ii).name;
end
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
setHandles(handles);

%%
function loadObstaclesFile

handles=getHandles;

obs=[];
[obs,plifile]=ddb_Delft3DWAVE_readObstacleFile(obs,handles.model.delft3dwave.domain.obstaclefile);
handles.model.delft3dwave.domain.obstaclepolylinesfile=plifile;
handles.model.delft3dwave.domain.obstacles=obs;
handles.model.delft3dwave.domain.nrobstacles=length(obs);
handles.model.delft3dwave.domain.activeobstacle=1;
for ii=1:length(obs)
    handles.model.delft3dwave.domain.obstaclenames{ii}=obs(ii).name;
end
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');

setHandles(handles);
gui_updateActiveTab;

%%
function saveObstaclesFile
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.pli','Select Obstacles Polylines File',handles.model.delft3dwave.domain.obstaclepolylinesfile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.model.delft3dwave.domain.obstaclepolylinesfile=filename;
    setHandles(handles);
else
    return
end
ddb_Delft3DWAVE_saveObstacleFile(handles);

%%
function copyFromFlow

handles=getHandles;

if handles.model.delft3dflow.domain(1).nrThinDams>0

    xg=handles.model.delft3dflow.domain(1).gridX;
    yg=handles.model.delft3dflow.domain(1).gridY;
    for ii=1:length(handles.model.delft3dflow.domain(1).thinDams)
        
        m1=handles.model.delft3dflow.domain(1).thinDams(ii).M1;
        m2=handles.model.delft3dflow.domain(1).thinDams(ii).M2;
        n1=handles.model.delft3dflow.domain(1).thinDams(ii).N1;
        n2=handles.model.delft3dflow.domain(1).thinDams(ii).N2;
        x(1)=xg(m1,n1);
        x(2)=xg(m2,n2);
        y(1)=yg(m1,n1);
        y(2)=yg(m2,n2);
        
        nrobs=handles.model.delft3dwave.domain.nrobstacles;
        handles.model.delft3dwave.domain.nrobstacles=nrobs+1;
        if nrobs==0
            handles.model.delft3dwave.domain.obstacles=[];
            handles.model.delft3dwave.domain.obstaclenames={''};
        end
        handles.model.delft3dwave.domain.activeobstacle=1;
        handles.model.delft3dwave.domain.activeobstacles=1;
        
        handles.model.delft3dwave.domain.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.model.delft3dwave.domain.obstacles,nrobs+1);
        handles.model.delft3dwave.domain.obstacles(nrobs+1).name=['Obstacle from FLOW ' num2str(ii)];
        handles.model.delft3dwave.domain.obstacles(nrobs+1).x=x;
        handles.model.delft3dwave.domain.obstacles(nrobs+1).y=y;
        handles.model.delft3dwave.domain.obstaclenames{nrobs+1}=handles.model.delft3dwave.domain.obstacles(nrobs+1).name;
        
    end
    
    handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
    
    setHandles(handles);

else
    ddb_giveWarning('text','There are no thin dams in current flow model');
end
