function muppet_datasetGUI(varargin)

makewindow=0;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'makewindow'}
                makewindow=1;
            case{'filename'}
                filename=varargin{ii+1};
            case{'filetype'}
                filetype=varargin{ii+1};
            case{'adddataset'}
                addDataset;
            case{'selectparameter'}
                selectParameter;
            case{'selectsubfield'}
                selectSubfield;
            case{'selectucomponent'}
                selectParameter('u');
            case{'selectvcomponent'}
                selectParameter('v');
            case{'selectcomponent'}
                refreshDatasetName;
            case{'selectxcoordinate'}
                selectXCoordinate;
            case{'editstation'}
                editStation(varargin{ii+1});
            case{'edittime'}
                editTime(varargin{ii+1});
            case{'editm'}
                editM(varargin{ii+1});
            case{'editn'}
                editN(varargin{ii+1});
            case{'editk'}
                editK(varargin{ii+1});
            case{'selectblock'}
                refreshDatasetName;
            case{'selectquantity'}
                refreshDatasetName;                
            case{'selecttidestation'}
                selectTideStation(varargin{ii+1});
        end
    end
end

if makewindow
    makeGUI(filetype,filename)
end

%%
function makeGUI(filetype,filename)

handles=getHandles;

dataset.name='';
dataset=muppet_setDefaultDatasetProperties(dataset);

% Find file type
ift=muppet_findIndex(handles.filetype,'filetype','name',filetype);
dataset.filetype=filetype;
if isfield(handles.filetype(ift).filetype,'elementgroup')
    elementgroup=handles.filetype(ift).filetype.elementgroup;
else
    elementgroup=[];
end
%elementgroup=handles.datapropertyelementgroup;
callback=str2func(handles.filetype(ift).filetype.callback);
dataset.callback=callback;

% Get info from file (load parameter dimensions)
dataset.filename=filename;

wb = waitbox('Reading file ...');
try
    dataset=feval(callback,'read',dataset);
    close(wb);
catch
    close(wb);
    muppet_giveWarning('text','An error occured while reading data file!');
    return
end

% Check if parameters are present, otherwise make parameters structure
if ~isfield(dataset,'parameters')
    dataset.parameters(1).parameter=dataset;
    dataset.parameters(1).parameter.active=1;
    dataset.parameters(1).parameter.size=[0 0 0 0 0];
    dataset.parameters(1).parameter=muppet_setDefaultParameterProperties(dataset.parameters(1).parameter);
end

% Make list of parameter names
for j=1:length(dataset.parameters)
    dataset.parameternames{j}=dataset.parameters(j).parameter.name;
end

if isempty(dataset.parameter)
    dataset.parameter=dataset.parameters(1).parameter.name;
    if isempty(dataset.activeparameter)
        dataset.activeparameter=1;
    end
else
    dataset.activeparameter=strmatch(dataset.parameter,dataset.parameternames,'exact');
end

dataset.size=[0 0 0 0 0];
dataset.quantity='scalar';

% GUI stuff
dataset.previousm=1;
dataset.mtext='';
dataset.mmaxtext='';
dataset.selectallm=0;
dataset.previousn=1;
dataset.ntext='';
dataset.nmaxtext='';
dataset.selectalln=0;
dataset.previousk=1;
dataset.ktext='';
dataset.kmaxtext='';
dataset.selectallk=0;
dataset.showtimes=0;
dataset.selectalltimes=0;
dataset.previoustimestep=1;
dataset.timesteptext='';
dataset.timestepsfromlist=1;
dataset.tmaxtext='';
dataset.timelist={''};
dataset.stationnumber=1;
dataset.previousstationnumber=1;
dataset.selectallstations=0;
dataset.stationsfromlist=1;

dataset.plotcoordinate='pathdistance';
dataset.component=[];
dataset.stations={''};

% Build GUI

height=0;
width=0;
% First determine width and height of gui
for ii=1:length(elementgroup)
    % Find corresponding gui element
    id=muppet_findIndex(handles.datapropertyelementgroup,'datapropertyelementgroup','name',elementgroup(ii).elementgroup);
    if ~isempty(id)
        % Include in gui
        height=height+handles.datapropertyelementgroup(id).datapropertyelementgroup.height+10;
        width=max(handles.datapropertyelementgroup(id).datapropertyelementgroup.width,width);
    end
end

width=width+40;
height=height+140;

width=max(width,350);

% And now build the elements
posy=height-10;
nelm=0;

for ii=1:length(elementgroup)
    % Find corresponding gui element
    id=muppet_findIndex(handles.datapropertyelementgroup,'datapropertyelementgroup','name',elementgroup(ii).elementgroup);
    if ~isempty(id)
        % Include in gui
        elgroup=handles.datapropertyelementgroup(id).datapropertyelementgroup;
        posy=posy-elgroup.height-10;
        for jj=1:length(elgroup.element)
            nelm=nelm+1;
            el=elgroup.element(jj).element;
            pos=str2num(el.position);
            el.position=[pos(1)+20 posy+pos(2) pos(3) pos(4)];
            element(nelm).element=el;
        end
    end
end

% Dataset name
nelm=nelm+1;
element(nelm).element.style='edit';
element(nelm).element.position=[60 60 width-80 20];
element(nelm).element.variable='name';
element(nelm).element.text='Name';
element(nelm).element.dependency.dependency.action='enable';
element(nelm).element.dependency.dependency.checkfor='all';
element(nelm).element.dependency.dependency.checks.check.variable='parameters(s.activeparameter).parameter.active';
element(nelm).element.dependency.dependency.checks.check.value='1';
element(nelm).element.dependency.dependency.checks.check.operator='eq';

% Cancel
nelm=nelm+1;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-250 20 70 25];

% Add
nelm=nelm+1;
element(nelm).element.style='pushbutton';
element(nelm).element.position=[width-170 20 70 25];
element(nelm).element.text='Add';
element(nelm).element.callback='muppet_datasetGUI';
element(nelm).element.option1='adddataset';
element(nelm).element.dependency.dependency.action='enable';
element(nelm).element.dependency.dependency.checkfor='all';
element(nelm).element.dependency.dependency.check.check.variable='parameters(s.activeparameter).parameter.active';
element(nelm).element.dependency.dependency.check.check.value='1';
element(nelm).element.dependency.dependency.check.check.operator='eq';

% OK
nelm=nelm+1;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-90 20 70 25];

xml.element=element;

xml=gui_fillXMLvalues(xml);

[dataset,ok]=gui_newWindow(dataset,'element',xml.element,'tag','datasetgui','width',width,'height',height, ...
    'createcallback',@selectParameter,'title',handles.filetype(ift).filetype.longname,'modal',0, ...
    'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

%%
function selectParameter(varargin)

dataset=gui_getUserData;

%if isempty(varargin{1})
    ipar=dataset.activeparameter;
% else
%     switch varargin{1}
%         case{'u'}
%             ipar=strcmpi(dataset.ucomponent,dataset.parameternames);
%     end
% end

oldsize=dataset.size;
oldquantity=dataset.quantity;
oldnrblocks=dataset.nrblocks;
oldcoordinatesystem=dataset.coordinatesystem;

% Copy entire parameter structure (of selected parameter) to dataset
% structure (but skip name subfield)
fldnames=fieldnames(dataset.parameters(ipar).parameter);
for ii=1:length(fldnames)
    switch fldnames{ii}
        case{'name'}
        otherwise
            dataset.(fldnames{ii})=dataset.parameters(ipar).parameter.(fldnames{ii});
    end
end

% if isempty(varargin{1})
     dataset.parameter=dataset.parameters(ipar).parameter.name;
% else
%     switch varargin{1}
%         case{'u'}
%             dataset.parameter=[];
%     end
% end


% Time step
if dataset.size(1)>0
    if dataset.size(1)~=oldsize(1)
        dataset.tmaxtext=num2str(dataset.size(1));
        if ~isempty(dataset.times)
            dataset.showtimes=1;
        else
            dataset.showtimes=0;
        end
        if dataset.size(3)==0 && dataset.size(4)==0
            % Time series
            dataset.timestep=[];
            dataset.timestepsfromlist=1;
            dataset.previoustimestep=1;
            dataset.timesteptext='1';
            dataset.selectalltimes=1;
        else
            % Map
            dataset.timestep=1;
            dataset.timestepsfromlist=1;
            dataset.previoustimestep=1;
            dataset.timesteptext='1';
            dataset.selectalltimes=0;
        end
        if dataset.size(1)>0
            if ~isempty(dataset.times)
                if length(dataset.times)<1000
                    timelist=datestr(dataset.times,0);
                    dataset.timelist=[];
                    for it=1:length(dataset.times)
                        dataset.timelist{it}=timelist(it,:);
                    end
                end
            end
        end
    end
else
    dataset.time=[];
    dataset.timestep=[];
    dataset.timestepsfromlist=1;
    dataset.timelist={''};
    dataset.timetext='';
    dataset.selectalltimes=0;
    dataset.tmaxtext='';
end

% Stations
if dataset.size(2)>0
    if dataset.size(2)~=oldsize(2)
        dataset.stationnumber=1;
        dataset.previousstationnumber=1;
        dataset.selectallstations=0;
        dataset.station=dataset.stations{1};
        dataset.stationfromlist=1;
    end
else
    dataset.stationnumber=[];
    dataset.previousstationnumber=1;
    dataset.selectallstations=0;
    dataset.station=[];
    dataset.stationfromlist=1;
end

% M 
if dataset.size(3)>0
    if dataset.size(3)~=oldsize(3)
        dataset.m=[];
        dataset.previousm=1;
        dataset.mtext='1';
        dataset.mmaxtext=num2str(dataset.size(3));
        dataset.selectallm=1;
        dataset.n=0;
        dataset.previousn=1;
        dataset.ntext='1';
        dataset.nmaxtext=num2str(dataset.size(4));
        dataset.selectalln=1;
    end
else
    dataset.m=[];
    dataset.mtext='';
    dataset.selectallm=0;
    dataset.mmaxtext='';
end

% N
if dataset.size(4)>0
    if dataset.size(4)~=oldsize(4)
        dataset.n=[];
        dataset.previousn=1;
        dataset.ntext='1';
        dataset.nmaxtext=num2str(dataset.size(4));
        dataset.selectalln=1;
    end
else
    dataset.n=[];
    dataset.ntext='';
    dataset.selectalln=0;
    dataset.nmaxtext='';
end

% K
if dataset.size(5)>1
    if dataset.size(5)~=oldsize(5)
        dataset.k=1;
        dataset.previousk=1;
        dataset.ktext='1';
        dataset.kmaxtext=num2str(dataset.size(5));
        dataset.selectallk=0;
    end
else
    dataset.k=[];
    dataset.ktext='';
    dataset.selectallk=0;
    dataset.kmaxtext='';
end

% Quantity
if ~strcmpi(dataset.quantity,oldquantity)
    switch lower(dataset.quantity)
        case{'vector2d','vector3d'}
            dataset.component='vector';
        otherwise
            dataset.component=[];
    end
end

%dataset.selectedquantity=dataset.quantity;

% % Block
% if dataset.nrblocks>0
%     if dataset.nrblocks~=oldnrblocks
%         dataset.block=dataset.blocks{1};
%     end
% else
%     dataset.block=[];
% end
    
% dataset.ucomponent='';
% dataset.vcomponent='';
% if dataset.nrquantities>1
%     dataset.component='vector';
%     dataset.ucomponent=dataset.parameters(1).parameter.name;
%     dataset.vcomponent=dataset.parameters(1).parameter.name;
% end

dataset.previousxcoordinate='pathdistance';

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editStation(opt)

dataset=gui_getUserData;

switch opt
    case{'select'}
        dataset.station=dataset.stations{dataset.stationfromlist};
        dataset.stationnumber=dataset.stationfromlist;
        dataset.previousstationnumber=dataset.stationnumber;
    case{'selectall'}
        if dataset.selectallstations
            dataset.stationnumber=[];
            dataset.station=[];
        else
            dataset.stationnumber=dataset.previousstationnumber;
            dataset.station=dataset.stations{dataset.stationnumber};
        end
end

% Tidal components
if isfield(dataset.parameters(dataset.activeparameter).parameter,'data')
    if isempty(dataset.stationnumber)
        dataset.tidalcomponentlist=dataset.parameters(dataset.activeparameter).parameter.data.station(dataset.previousstationnumber).component;
    else
        dataset.tidalcomponentlist=dataset.parameters(dataset.activeparameter).parameter.data.station(dataset.stationnumber).component;
    end
end

gui_setUserData(dataset);

refreshDatasetName;

%%
function selectSubfield

refreshDatasetName;

%%
function editTime(opt)

dataset=gui_getUserData;

switch opt
    case{'edit'}        
        it=indexstring('read',dataset.timesteptext);
        if it>dataset.size(1) || it<1 || isnan(it)
            dataset.timesteptext=indexstring('write',dataset.timestep);
            it=dataset.timestep;
        end
        dataset.timestep=it;
        dataset.previoustimestep=dataset.timestep;
        dataset.timestepsfromlist=dataset.timestep;
    case{'select'}
        dataset.timestep=dataset.timestepsfromlist;
        dataset.previoustimestep=dataset.timestep;
        dataset.timesteptext=indexstring('write',dataset.timestep);
    case{'selectall'}        
        if dataset.selectalltimes
            dataset.timestep=[];
            dataset.timesteptext=indexstring('write',dataset.previoustimestep);
        else
            dataset.timestep=dataset.previoustimestep;
            dataset.timesteptext=indexstring('write',dataset.timestep);            
        end
    case{'showtimes'}
        if isempty(dataset.times)
            wb = waitbox('Reading times ...');
            try
                times=feval(dataset.callback,'gettimes');                
                % Copy times
                if ~isempty(times)
                    for ipar=1:length(dataset.parameters)
                        if isempty(dataset.parameters(ipar).parameter.times)
                            if dataset.size(1)==dataset.parameters(ipar).parameter.size(1)
                                dataset.parameters(ipar).parameter.times=times;
                            end
                        end
                    end
                end
                close(wb);
            catch
                close(wb);
                times=[];
                muppet_giveWarning('text','An error occured while reading times!');
            end
            dataset.times=times;
            for it=1:length(times)
                dataset.timelist{it}=datestr(times(it),0);
            end
            dataset.timelist=dataset.timelist;
        end
end

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editM(opt)

dataset=gui_getUserData;

switch opt
    case{'edit'}
        dataset.m=indexstring('read',dataset.mtext);
        dataset.previousm=dataset.m;
    case{'selectall'}        
        if dataset.selectallm
            dataset.m=[];
            dataset.mtext=indexstring('write',dataset.previousm);
        else
            dataset.m=dataset.previousm;
            dataset.mtext=indexstring('write',dataset.m);
        end
end

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function selectXCoordinate
dataset=gui_getUserData;
dataset.previousxcoordinate=dataset.xcoordinate;
gui_setUserData(dataset);

%%
function editN(opt)

dataset=gui_getUserData;

switch opt
    case{'edit'}
        dataset.n=indexstring('read',dataset.ntext);
        dataset.previousn=dataset.n;
    case{'selectall'}        
        if dataset.selectalln
            dataset.n=[];
            dataset.ntext=indexstring('write',dataset.previousn);
        else
            dataset.n=dataset.previousn;
            dataset.ntext=indexstring('write',dataset.n);
        end
end

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editK(opt)

dataset=gui_getUserData;

switch opt
    case{'edit'}
        dataset.k=indexstring('read',dataset.ktext);
        dataset.previousk=dataset.k;
    case{'selectall'}        
        if dataset.selectallk
            dataset.k=[];
            dataset.ktext=indexstring('write',dataset.previousk);
        else
            dataset.k=dataset.previousk;
            dataset.ktext=indexstring('write',dataset.k);
        end
end

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function updateDimensions

dataset=gui_getUserData;

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k);

switch lower(dataset.plane)
    case{'xz','xv','tx'}
        dataset.plotcoordinate=dataset.previousxcoordinate;
    otherwise
        dataset.plotcoordinate=[];
end

gui_setUserData(dataset);

%%
function addDataset

handles=getHandles;
dataset=gui_getUserData;

ii=strmatch(lower(dataset.name),lower(handles.datasetnames),'exact');
if ~isempty(ii)
    % Dataset already exists
    muppet_giveWarning('text','A dataset with this name already exists!');
    return
end

% Remove parameters structure
dataset=rmfield(dataset,'timelist');

% Check if selected station occurs multiple times in list
if ~isempty(dataset.station)
    istation=strmatch(dataset.station,dataset.stations,'exact');
    if length(istation)==1
        % Just one station found, set station number to be empty because we
        % don't want it in the mup file
        dataset.stationnumber=[];
    end
end

% Check dimensions
dims=[0 0 0 0];
if dataset.size(3)>0
    if isempty(dataset.m) || length(dataset.m)>1
        dims(1)=1;
    end
end
if dataset.size(4)>0
    if isempty(dataset.n) || length(dataset.n)>1
        dims(2)=1;
    end
end
if dataset.size(5)>1
    if isempty(dataset.k) || length(dataset.k)>1
        dims(3)=1;
    end
end
if dataset.size(1)>0
    if isempty(dataset.timestep) || length(dataset.timestep)>1
        dims(4)=1;
    end
end

ndims=sum(dims);

if ndims>2
    muppet_giveWarning('text',['It is not possible to import ' num2str(ndims) '-dimensional datasets !']);
    return
end

% Now import the dataset

% Remove timestep from dataset structure (use actual time instead)
if isempty(dataset.time) && ~isempty(dataset.times)
    dataset.time=dataset.times(dataset.timestep);
    dataset.timestep=[];
end

% Import data
dataset.from_gui=1;

wb = waitbox('Reading data ...');
try
    dataset=feval(dataset.callback,'import',dataset);
    close(wb);
catch
    close(wb);
    muppet_giveWarning('text','An error occured while reading data!');
end

nrd=handles.nrdatasets+1;
handles.nrdatasets=nrd;

handles.datasetnames{nrd}=dataset.name;

handles.activedataset=nrd;
handles.datasets(nrd).dataset=dataset;

setHandles(handles);

%%
function refreshDatasetName

dataset=gui_getUserData;

if dataset.adjustname
    
    if dataset.active

        parstr=dataset.parameter;
        if dataset.nrquantities>1
            if strcmpi(dataset.quantity,'vector2d') || strcmpi(dataset.quantity,'vector3d')
                parstr=[dataset.ucomponent '-' dataset.vcomponent];
            end
        end
        
        subfstr='';
        compstr='';
        tstr='';
        statstr='';
        mstr='';
        nstr='';
        kstr='';
        runidstr='';

        if dataset.nrsubfields>0
            subfstr=[ ' - ' dataset.subfields{dataset.subfieldnumber}];            
        end
        
        switch dataset.quantity
          case{'vector2d','vector3d'}
            if ~isempty(dataset.component)
              if ~strcmpi(dataset.component,'vector')
                switch dataset.component
                  case{'vector'}
                    str='vector';
                  case{'vectorsplitxy'}
                    str='vector (split x,y)';
                  case{'vectorsplitmn'}
                    str='vector (split m,n)';
                  case{'magnitude'}
                    str='magnitude';
                  case{'angleradians'}
                    str='angle (radians)';
                  case{'angledegrees'}
                    str='angle (degrees)';
                  case{'xcomponent','x component'}
                    str='x component';
                  case{'ycomponent','y component'}
                    str='y component';
                  case{'m component'}
                    str='m component';
                  case{'n component'}
                    str='n component';
                end                
                compstr=[ ' - ' str];
              end
            end
        end
        
        if dataset.size(1)>0
            if length(dataset.timestep)==1 
                if ~isempty(dataset.times)
                    tstr=[' - ' datestr(dataset.times(dataset.timestep),0)];
                end
            end
        end
        
        if ~isempty(dataset.station)
            statstr=[ ' - ' dataset.stations{dataset.stationnumber}];
        end
        
        if dataset.size(3)>0
            if length(dataset.m)==1 
                mstr=[' - M=' num2str(dataset.m)];
            end
        end
        
        if dataset.size(4)>0
            if length(dataset.n)==1 
                nstr=[' - N=' num2str(dataset.n)];
            end
        end
        
        if dataset.size(5)>0
            if length(dataset.k)==1 
                kstr=[' - K=' num2str(dataset.k)];
            end
        end
        
        if ~isempty(dataset.runid)
            runidstr=[' - ' runid];
        end
        
        dataset.name=[parstr subfstr compstr statstr tstr mstr nstr kstr runidstr];
        
    else
        dataset.name='';
    end
    
    gui_setUserData(dataset);
    
end
