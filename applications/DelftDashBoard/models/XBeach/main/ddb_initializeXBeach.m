function handles=ddb_initializeXBeach(handles,varargin)


handles.model.xbeach.domain=[];
runid='tst';

handles.model.xbeach.attname='xbeach';

% handles.GUIData.nrXBeachDomains=1;
% handles.GUIData.nrXBeachObservationPoints=1;
% handles.GUIData.nrXBeachObservationCrossSections=1;
% handles.GUIData.nrXBeachOpenBoundaries=1;

handles=ddb_initializeXBeachInput(handles,1,runid);
handles.model.xbeach.domain(1).ParamsFile=[lower(cd) '\\'];
cd(handles.model.xbeach.domain(1).ParamsFile)
handles.model.xbeach.menuview.grid=1;
handles.model.xbeach.menuview.bathymetry=1;
