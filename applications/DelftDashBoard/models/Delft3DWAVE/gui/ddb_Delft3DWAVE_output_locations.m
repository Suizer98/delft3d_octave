function ddb_Delft3DWAVE_output_locations(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectpointfrommap'}
            h=varargin{2};
            nr=varargin{3};
            selectPointFromMap(h,nr);
        case{'selectpointfromlist'}
            selectPointFromList;
        case{'selectlocationset'}
            selectLocationSet;
        case{'addlocationset'}
            addLocationSet;
        case{'deletelocationset'}
            deleteLocationSet;
        case{'loadlocationfile'}
            loadLocationFile;
        case{'savelocationfile'}
            saveLocationFile;
        case{'addpoint'}
            setInstructions({'','','Click point on map to add observation point'}); 
            gui_clickpoint('xy','callback',@addPoint);
        case{'deletepoint'}
            deletePoint;
        case{'editcoordinate'}
            editCoordinates;
    end
end

%%
function selectPointFromMap(h,nr)
clearInstructions; 
handles=getHandles;
iac=[];
for ii=1:handles.model.delft3dwave.domain.nrlocationsets
    if handles.model.delft3dwave.domain.locationsets(ii).handle==h
        iac=ii;
        break
    end       
end
if ~isempty(iac)
    handles.model.delft3dwave.domain.activelocationset=iac;
    handles.model.delft3dwave.domain.locationsets(ii).activepoint=nr;
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function selectLocationSet
clearInstructions; 
handles=getHandles;
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

%%
function selectPointFromList
clearInstructions; 
handles=getHandles;
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

%%
function addLocationSet
clearInstructions; 
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.loc', 'File name new location file','');
if pathname==0
    return
end
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
n=handles.model.delft3dwave.domain.nrlocationsets+1;
handles.model.delft3dwave.domain.nrlocationsets=n;
handles.model.delft3dwave.domain.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.model.delft3dwave.domain.locationsets,n);
handles.model.delft3dwave.domain.locationfile{n}=filename;
handles.model.delft3dwave.domain.activelocationset=n;
setHandles(handles);

%%
function deleteLocationSet
clearInstructions; 
handles=getHandles;
iac=handles.model.delft3dwave.domain.activelocationset;
if handles.model.delft3dwave.domain.nrlocationsets>0
    handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'delete');
    handles.model.delft3dwave.domain.nrlocationsets=handles.model.delft3dwave.domain.nrlocationsets-1;
    handles.model.delft3dwave.domain.locationsets = removeFromStruc(handles.model.delft3dwave.domain.locationsets,iac);
    handles.model.delft3dwave.domain.activelocationset=max(min(iac,handles.model.delft3dwave.domain.nrlocationsets),1);
    handles.model.delft3dwave.domain.locationfile=removeFromCellArray(handles.model.delft3dwave.domain.locationfile,iac);
    if handles.model.delft3dwave.domain.nrlocationsets==0
        handles.model.delft3dwave.domain.locationfile={''};
    end
    handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');    
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function loadLocationFile
clearInstructions; 
handles=getHandles;
newfile=handles.model.delft3dwave.domain.newlocationfile;
try
    xy=load(newfile);
catch
    ddb_giveWarning('text','Could not load location file!');
    return
end
x=xy(:,1)';
y=xy(:,2)';
n=strmatch(newfile,handles.model.delft3dwave.domain.locationfile,'exact');
if isempty(n)
    % New file
    n=handles.model.delft3dwave.domain.nrlocationsets+1;
    handles.model.delft3dwave.domain.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.model.delft3dwave.domain.locationsets,n);
    handles.model.delft3dwave.domain.nrlocationsets=n;
end
handles.model.delft3dwave.domain.locationfile{n}=newfile;
handles.model.delft3dwave.domain.activelocationset=n;
handles.model.delft3dwave.domain.locationsets(n).activepoint=1;
handles.model.delft3dwave.domain.locationsets(n).x=x;
handles.model.delft3dwave.domain.locationsets(n).y=y;
handles.model.delft3dwave.domain.locationsets(n).nrpoints=length(x);
handles.model.delft3dwave.domain.locationsets(n).pointtext={''};
for ii=1:length(x)
    handles.model.delft3dwave.domain.locationsets(n).pointtext{ii}=num2str(ii);
end
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
setHandles(handles);

%%
function saveLocationFile
clearInstructions; 
handles=getHandles;
iac=handles.model.delft3dwave.domain.activelocationset;
handles.model.delft3dwave.domain.locationfile{iac}=handles.model.delft3dwave.domain.newlocationfile;
ddb_Delft3DWAVE_saveLocationFile(handles.model.delft3dwave.domain.locationfile{iac},handles.model.delft3dwave.domain.locationsets(iac));
setHandles(handles);

%%
function addPoint(x,y)
clearInstructions; 
handles=getHandles;
iac=handles.model.delft3dwave.domain.activelocationset;
nr=handles.model.delft3dwave.domain.locationsets(iac).nrpoints+1;
handles.model.delft3dwave.domain.locationsets(iac).nrpoints=nr;
handles.model.delft3dwave.domain.locationsets(iac).activepoint=nr;
handles.model.delft3dwave.domain.locationsets(iac).x(nr)=x;
handles.model.delft3dwave.domain.locationsets(iac).y(nr)=y;
handles.model.delft3dwave.domain.locationsets(iac).pointtext={''};
for ii=1:nr
    handles.model.delft3dwave.domain.locationsets(iac).pointtext{ii}=num2str(ii);
end
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
setHandles(handles);
gui_updateActiveTab;

%%
function deletePoint
clearInstructions; 
handles=getHandles;
iac=handles.model.delft3dwave.domain.activelocationset;
handles.model.delft3dwave.domain.locationsets(iac).nrpoints=handles.model.delft3dwave.domain.locationsets(iac).nrpoints-1;
ii=handles.model.delft3dwave.domain.locationsets(iac).activepoint;
nr=handles.model.delft3dwave.domain.locationsets(iac).nrpoints;

handles.model.delft3dwave.domain.locationsets(iac).x = removeFromVector(handles.model.delft3dwave.domain.locationsets(iac).x,ii);
handles.model.delft3dwave.domain.locationsets(iac).y = removeFromVector(handles.model.delft3dwave.domain.locationsets(iac).y,ii);

handles.model.delft3dwave.domain.locationsets(iac).activepoint=max(min(ii,nr),1);

handles.model.delft3dwave.domain.locationsets(iac).pointtext={''};
for ii=1:nr
    handles.model.delft3dwave.domain.locationsets(iac).pointtext{ii}=num2str(ii);
end

handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

setHandles(handles);
gui_updateActiveTab;

%%
function editCoordinates
clearInstructions; 
handles=getHandles;
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
setHandles(handles);
