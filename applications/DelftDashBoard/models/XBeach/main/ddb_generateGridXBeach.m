function handles=ddb_generateGridXBeach(handles,id,x,y,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

%if isempty(filename)
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Grid File Name',[handles.model.xbeach.domain(ad).attname '.grd']);
%end

if pathname==0
    return
end

attname=filename(1:end-4);

ddb_plotXBeach(handles,'delete',id);
handles=ddb_initializeXBeach(handles,'griddependentinput',id,handles.model.xbeach.domain.runid);

set(gcf,'Pointer','arrow');

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end    

ddb_wlgrid('write','FileName',filename,'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

% fid=fopen(grdx,'wt');
% nrows=size(x,1);
% fprintf(fid,[repmat('%15.7e ',1,nrows) '\n'],x);
% fclose(fid);
% 
% fid=fopen(grdy,'wt');
% nrows=size(x,1);
% fprintf(fid,[repmat('%15.7e ',1,nrows) '\n'],y);
% fclose(fid);

handles.model.xbeach.domain(id).xfile='file';
handles.model.xbeach.domain(id).yfile='file';
handles.model.xbeach.domain(id).xyfile='grid.grd';

handles.model.xbeach.domain(id).gridx=x;
handles.model.xbeach.domain(id).gridy=y;

handles.model.xbeach.domain(id).gridform='delft3d';

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.xbeach.domain(id).depth=nans;
handles.model.xbeach.domain(id).depthz=nans;
% 
handles.model.xbeach.domain(id).nx=size(x,1);
handles.model.xbeach.domain(id).ny=size(x,2);

% handles=ddb_determineKCS(handles,id);

ddb_plotXBeachGrid('plot',handles,ad);

%ddb_plotGrid(x,y,id,'XBeachGrid','plot');
