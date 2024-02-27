function handles=ddb_openXBeachModel(handles,pathname,filename)

DeleteAllObjects;

cd(pathname);

handles=ddb_initialize(handles,'all');
handles=ReadXBeachParams(handles,filename);

setHandles(handles);
set(gca,'XLim',handles.ScreenParameters.XLim,'YLim',handles.ScreenParameters.YLim);

