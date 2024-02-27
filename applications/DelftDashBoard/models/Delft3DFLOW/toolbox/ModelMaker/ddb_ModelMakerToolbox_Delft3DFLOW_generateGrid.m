function handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateGrid(handles,id,varargin)

% Function generates and plots rectangular grid can be called by ddb_ModelMakerToolbox_quickMode_Delft3DFLOW or
% ddb_CSIPSToolbox_initMode

filename=[];
pathname=[];

for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
    end
end

if isempty(filename)
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Grid File Name',[handles.model.delft3dflow.domain(id).attName '.grd']);
end

if pathname==0
    return
end

wb = waitbox('Generating grid ...');pause(0.1);
[x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles);
close(wb);

%% Now start putting things into the Delft3D-FLOW model
ddb_plotDelft3DFLOW('delete','domain',id);
handles=ddb_initializeFlowDomain(handles,'griddependentinput',ad,handles.model.delft3dflow.domain(id).runid);

set(gcf,'Pointer','arrow');
enc=ddb_enclosure('extract',x,y);
attName=filename(1:end-4);

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end

ddb_wlgrid('write','FileName',[attName '.grd'],'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);
handles.model.delft3dflow.domain(id).grdFile=[attName '.grd'];
handles.model.delft3dflow.domain(id).encFile=[attName '.enc'];
handles.model.delft3dflow.domain(id).gridX=x;
handles.model.delft3dflow.domain(id).gridY=y;
[handles.model.delft3dflow.domain(id).gridXZ,handles.model.delft3dflow.domain(id).gridYZ]=getXZYZ(x,y);

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.delft3dflow.domain(id).depth=nans;
handles.model.delft3dflow.domain(id).depthZ=nans;

handles.model.delft3dflow.domain(id).MMax=size(x,1)+1;
handles.model.delft3dflow.domain(id).NMax=size(x,2)+1;
handles.model.delft3dflow.domain(id).KMax=1;

handles.model.delft3dflow.domain(id).kcs=determineKCS(handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY);

% Put info back
setHandles(handles);

% Plot new domain
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot','domain',ad);

