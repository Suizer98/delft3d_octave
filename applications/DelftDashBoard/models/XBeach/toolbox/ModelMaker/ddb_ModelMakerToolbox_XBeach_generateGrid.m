function handles=ddb_ModelMakerToolbox_XBeach_generateGrid(handles,id,varargin)

filename=[];
pathname=[];
for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
    end
end

if isempty(filename)
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Grid File Name',[handles.model.xbeach.domain(id).attname '.grd']);
end

if pathname==0
    return
end

wb = waitbox('Generating grid ...');pause(0.1);
[x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles);
close(wb);

%% Now start putting things into the Delft3D-FLOW model

ddb_plotXBeach('delete','domain',id);

handles=ddb_XBeach_initializeDomain(handles,1,handles.model.xbeach.domain(id).runid);

set(gcf,'Pointer','arrow');

attname=filename(1:end-4);

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end

ddb_wlgrid('write','FileName',[attname '.grd'],'X',x,'Y',y,'CoordinateSystem',coord);

handles.model.xbeach.domain(id).gridform='delft3d';
handles.model.xbeach.domain(id).xyfile=filename;
handles.model.xbeach.domain(id).xfile='file';
handles.model.xbeach.domain(id).yfile='file';

handles.model.xbeach.domain(id).grid.x=x;
handles.model.xbeach.domain(id).grid.y=y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.xbeach.domain(id).depth=nans;

handles.model.xbeach.domain(id).nx=size(x,1);
handles.model.xbeach.domain(id).ny=size(x,2);

handles=ddb_XBeach_plotGrid(handles,'plot','domain',ad);

