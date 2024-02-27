function handles=ddb_initializeDelft3DWAVE(handles,varargin)

handles.model.delft3dwave.domain=[];

runid='tst';

handles=ddb_initializeDelft3DWAVEInput(handles,runid);
