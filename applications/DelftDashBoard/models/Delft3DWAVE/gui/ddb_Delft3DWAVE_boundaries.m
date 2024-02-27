function ddb_Delft3DWAVE_boundaries(varargin)


handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotBoundaries(handles,'update');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectboundary'}
            ddb_Delft3DWAVE_plotBoundaries(handles,'update');
        case{'add'}
            addBoundary;
        case{'delete'}
            deleteBoundary;
        case{'editboundaryconditions'}
            editBoundaryConditions;
        case{'editspectralspace'};
            editSpectralSpace;
        case{'drawxyboundary'}
            drawXYBoundary;
        case{'changexyboundary'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            nr=varargin{5};
            changeXYBoundary(h,x,y,nr);
        case{'editxycoordinates'}
            editXYCoordinates;
        case{'editmncoordinates'}
            editMNCoordinates;
        case{'selectdefinition'}
            selectDefinition;
    end
end

%%
function addBoundary
clearInstructions;

handles=getHandles;
nr=handles.model.delft3dwave.domain.nrboundaries;
nr=nr+1;
handles.model.delft3dwave.domain.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.model.delft3dwave.domain.boundaries,nr);
handles.model.delft3dwave.domain.boundaries(nr).name=['Boundary ' num2str(nr)];
handles.model.delft3dwave.domain.boundarynames{nr}=['Boundary ' num2str(nr)];
if nr>1
    % Copy from existing boundary
    handles.model.delft3dwave.domain.boundaries(nr).definition=handles.model.delft3dwave.domain.boundaries(handles.model.delft3dwave.domain.activeboundary).definition;
end
handles.model.delft3dwave.domain.nrboundaries=nr;
handles.model.delft3dwave.domain.activeboundary=nr;
setHandles(handles);

ddb_Delft3DWAVE_plotBoundaries(handles,'update');

%%
function deleteBoundary
clearInstructions;
handles=getHandles;
if handles.model.delft3dwave.domain.nrboundaries>0
    iac=handles.model.delft3dwave.domain.activeboundary;
    try
        delete(handles.model.delft3dwave.domain.boundaries(iac).plothandle);
    end
    handles.model.delft3dwave.domain.boundaries=removeFromStruc(handles.model.delft3dwave.domain.boundaries,iac);
    handles.model.delft3dwave.domain.boundarynames=removeFromCellArray(handles.model.delft3dwave.domain.boundarynames,iac);
    handles.model.delft3dwave.domain.nrboundaries=handles.model.delft3dwave.domain.nrboundaries-1;
    handles.model.delft3dwave.domain.activeboundary=max(min(handles.model.delft3dwave.domain.activeboundary,handles.model.delft3dwave.domain.nrboundaries),1);
    handles.model.delft3dwave.domain.activeboundaries=handles.model.delft3dwave.domain.activeboundary;
    if handles.model.delft3dwave.domain.nrboundaries==0
        handles.model.delft3dwave.domain.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.model.delft3dwave.domain.boundaries,1);
    end
    setHandles(handles);
    gui_updateActiveTab;
    ddb_Delft3DWAVE_plotBoundaries(handles,'update');
end

%%
function editBoundaryConditions
clearInstructions;

ddb_zoomOff;
handles=getHandles;

% Make new GUI
h=handles;

iac=handles.model.delft3dwave.domain.activeboundary;
xmldir=handles.model.delft3dwave.xmlDir;

if strcmpi(handles.model.delft3dwave.domain.boundaries(iac).spectrumspec,'parametric')
    
    switch lower(handles.model.delft3dwave.domain.boundaries(iac).periodtype)
        case{'peak'}
            h.model.delft3dwave.domain.periodtext='Wave Period Tp (s)';
        case{'mean'}
            h.model.delft3dwave.domain.periodtext='Wave Period Tm (s)';
    end
    
    switch lower(handles.model.delft3dwave.domain.boundaries(iac).dirspreadtype)
        case{'power'}
            h.model.delft3dwave.domain.dirspreadtext='Directional Spreading (-)';
        case{'degrees'}
            h.model.delft3dwave.domain.dirspreadtext='Directional Spreading (degrees)';
    end
    
    switch lower(handles.model.delft3dwave.domain.boundaries(iac).alongboundary)
        case{'uniform'}
            xmlfile='model.delft3dwave.editboundaryconditionsuniform.xml';
            [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
        case{'varying'}
            xmlfile='model.delft3dwave.editboundaryconditionsvarying.xml';
            [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',0);
    end
    
else
    xmlfile='model.delft3dwave.editboundaryconditionsspectrum.xml';
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
end

if ok
    handles=h;
    setHandles(handles);
end

%% 
function editSpectralSpace
clearInstructions;

ddb_zoomOff;
handles=getHandles;

% Make new GUI
h=handles;

xmldir=handles.model.delft3dwave.xmlDir;
% switch lower(handles.model.delft3dwave.domain.boundaries(iac).alongboundary)
%     case{'uniform'}
        xmlfile='model.delft3dwave.editspectralspace.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
%     case{'varying'}
%         xmlfile='Delft3DWAVE.editboundaryconditionsvarying.xml';
%         [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',0);
% end

if ok
    handles=h;
    setHandles(handles);
end

%%
function drawXYBoundary
setInstructions({'','','Draw boundary section on grid'});
ddb_zoomOff;
handles=getHandles;
xg=handles.model.delft3dwave.domain.domains(1).gridx;
yg=handles.model.delft3dwave.domain.domains(1).gridy;
gui_dragLine('callback',@addXYBoundary,'method','alonggridline','gridx',xg,'gridy',yg);

%%
function addXYBoundary(x,y,m,n)
clearInstructions;
handles=getHandles;
h=gui_polyline('plot','x',x,'y',y,'tag','delft3dwaveboundary','Marker','o','changecallback',@changeXYBoundary,'closed',0, ...
    'color','r','markeredgecolor','r','markerfacecolor','r');
iac=handles.model.delft3dwave.domain.activeboundary;
% Delete existing plot handle
if isfield(handles.model.delft3dwave.domain.boundaries(iac),'plothandle')
    if ~isempty(handles.model.delft3dwave.domain.boundaries(iac).plothandle)
        try
            delete(handles.model.delft3dwave.domain.boundaries(iac).plothandle);
        end
    end
end

handles.model.delft3dwave.domain.boundaries(iac).plothandle=h;
handles.model.delft3dwave.domain.boundaries(iac).startcoordx=x(1);
handles.model.delft3dwave.domain.boundaries(iac).endcoordx=x(2);
handles.model.delft3dwave.domain.boundaries(iac).startcoordy=y(1);
handles.model.delft3dwave.domain.boundaries(iac).endcoordy=y(2);
handles.model.delft3dwave.domain.boundaries(iac).startcoordm=m(1)-1;
handles.model.delft3dwave.domain.boundaries(iac).endcoordm=m(2)-1;
handles.model.delft3dwave.domain.boundaries(iac).startcoordn=n(1)-1;
handles.model.delft3dwave.domain.boundaries(iac).endcoordn=n(2)-1;
setHandles(handles);

ddb_Delft3DWAVE_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function changeXYBoundary(h,x,y,nr)
clearInstructions;
handles=getHandles;
% First find boundary that was changed 
for ii=1:handles.model.delft3dwave.domain.nrboundaries
    if handles.model.delft3dwave.domain.boundaries(ii).plothandle==h
        
        % Find nearest grid points
        xg=handles.model.delft3dwave.domain.domains(1).gridx;
        yg=handles.model.delft3dwave.domain.domains(1).gridy;
        [m1,n1]=findcornerpoint(x(1),y(1),xg,yg);
        [m2,n2]=findcornerpoint(x(2),y(2),xg,yg);
        if strcmpi(handles.model.delft3dwave.domain.boundaries(ii).definition,'grid-coordinates')
            handles.model.delft3dwave.domain.boundaries(ii).startcoordx=xg(m1,n1);
            handles.model.delft3dwave.domain.boundaries(ii).endcoordx=xg(m2,n2);
            handles.model.delft3dwave.domain.boundaries(ii).startcoordy=yg(m1,n1);
            handles.model.delft3dwave.domain.boundaries(ii).endcoordy=yg(m2,n2);
            
            x(1)=handles.model.delft3dwave.domain.boundaries(ii).startcoordx;
            x(2)=handles.model.delft3dwave.domain.boundaries(ii).endcoordx;
            y(1)=handles.model.delft3dwave.domain.boundaries(ii).startcoordy;
            y(2)=handles.model.delft3dwave.domain.boundaries(ii).endcoordy;
            h=handles.model.delft3dwave.domain.boundaries(ii).plothandle;
            gui_polyline(h,'change','x',x,'y',y);

        else
            handles.model.delft3dwave.domain.boundaries(ii).startcoordx=x(1);
            handles.model.delft3dwave.domain.boundaries(ii).endcoordx=x(2);
            handles.model.delft3dwave.domain.boundaries(ii).startcoordy=y(1);
            handles.model.delft3dwave.domain.boundaries(ii).endcoordy=y(2);
        end
        handles.model.delft3dwave.domain.boundaries(ii).startcoordm=m1-1;
        handles.model.delft3dwave.domain.boundaries(ii).endcoordm=m2-1;
        handles.model.delft3dwave.domain.boundaries(ii).startcoordn=n1-1;
        handles.model.delft3dwave.domain.boundaries(ii).endcoordn=n2-1;

        handles.model.delft3dwave.domain.activeboundary=ii;
        break
    end
end
setHandles(handles);
ddb_Delft3DWAVE_plotBoundaries(handles,'update');
gui_updateActiveTab;

%%
function editXYCoordinates
clearInstructions;
handles=getHandles;
iac=handles.model.delft3dwave.domain.activeboundary;
h=handles.model.delft3dwave.domain.boundaries(iac).plothandle;
x(1)=handles.model.delft3dwave.domain.boundaries(iac).startcoordx;
x(2)=handles.model.delft3dwave.domain.boundaries(iac).endcoordx;
y(1)=handles.model.delft3dwave.domain.boundaries(iac).startcoordy;
y(2)=handles.model.delft3dwave.domain.boundaries(iac).endcoordy;
gui_polyline(h,'change','x',x,'y',y);

%%
function editMNCoordinates
clearInstructions;

handles=getHandles;

iac=handles.model.delft3dwave.domain.activeboundary;
xg=handles.model.delft3dwave.domain.domains(1).gridx;
yg=handles.model.delft3dwave.domain.domains(1).gridy;
m1=handles.model.delft3dwave.domain.boundaries(iac).startcoordm;
m2=handles.model.delft3dwave.domain.boundaries(iac).endcoordm;
n1=handles.model.delft3dwave.domain.boundaries(iac).startcoordn;
n2=handles.model.delft3dwave.domain.boundaries(iac).endcoordn;

x(1)=xg(m1+1,n1+1);
x(2)=xg(m2+1,n2+1);
y(1)=yg(m1+1,n1+1);
y(2)=yg(m2+1,n2+1);

handles.model.delft3dwave.domain.boundaries(iac).startcoordx=x(1);
handles.model.delft3dwave.domain.boundaries(iac).endcoordx=x(2);
handles.model.delft3dwave.domain.boundaries(iac).startcoordy=y(1);
handles.model.delft3dwave.domain.boundaries(iac).endcoordy=y(2);

h=handles.model.delft3dwave.domain.boundaries(iac).plothandle;
gui_polyline(h,'change','x',x,'y',y);

setHandles(handles);

%%
function selectDefinition
clearInstructions;
handles=getHandles;
iac=handles.model.delft3dwave.domain.activeboundary;
% Delete existing plot handles
if ~isempty(handles.model.delft3dwave.domain.boundaries(iac).plothandle)
    if ishandle(handles.model.delft3dwave.domain.boundaries(iac).plothandle)
        delete(handles.model.delft3dwave.domain.boundaries(iac).plothandle);
        handles.model.delft3dwave.domain.boundaries(iac).plothandle=[];
    end
end
switch handles.model.delft3dwave.domain.boundaries(iac).definition
    case{'xy-coordinates','grid-coordinates'}
        x(1)=handles.model.delft3dwave.domain.boundaries(iac).startcoordx;
        x(2)=handles.model.delft3dwave.domain.boundaries(iac).endcoordx;
        y(1)=handles.model.delft3dwave.domain.boundaries(iac).startcoordy;
        y(2)=handles.model.delft3dwave.domain.boundaries(iac).endcoordy;        
        h=gui_polyline('plot','x',x,'y',y,'tag','delft3dwaveboundary','Marker','o','changecallback',@changeXYBoundary,'closed',0, ...
            'color','r','markeredgecolor','r','markerfacecolor','r');
        handles.model.delft3dwave.domain.boundaries(iac).plothandle=h;        
end
setHandles(handles);
