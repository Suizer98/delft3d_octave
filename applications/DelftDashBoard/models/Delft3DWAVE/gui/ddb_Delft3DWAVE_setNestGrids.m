function handles = ddb_Delft3DWAVE_setNestGrids(handles)

if handles.activeWaveGrid>1
    handles.model.delft3dwave.domain.nestgrids=[];
    for ii=1:handles.activeWaveGrid-1
        handles.model.delft3dwave.domain.nestgrids{ii}=handles.model.delft3dwave.domain.domains(ii).gridname;
    end
else
    handles.model.delft3dwave.domain.nestgrids={''};
end
