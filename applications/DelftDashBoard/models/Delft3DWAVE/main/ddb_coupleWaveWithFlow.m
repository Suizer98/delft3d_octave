function handles=ddb_coupleWaveWithFlow(handles)
% Function can also be called from CSIPS toolbox
handles.model.delft3dwave.domain.referencedate=handles.model.delft3dflow.domain(1).itDate;
handles.model.delft3dwave.domain.mapwriteinterval=handles.model.delft3dflow.domain(1).mapInterval;
handles.model.delft3dwave.domain.comwriteinterval=handles.model.delft3dflow.domain(1).comInterval;
handles.model.delft3dwave.domain.writecom=1;
handles.model.delft3dwave.domain.coupling='ddbonline';
handles.model.delft3dwave.domain.mdffile=handles.model.delft3dflow.domain(1).mdfFile;
handles.model.delft3dwave.domain.domains(1).flowbedlevel=1;
handles.model.delft3dwave.domain.domains(1).flowwaterlevel=1;
handles.model.delft3dwave.domain.domains(1).flowvelocity=1;
if handles.model.delft3dflow.domain(1).wind
    handles.model.delft3dwave.domain.domains(1).flowwind=1;
end
handles.model.delft3dflow.domain(1).waves=1;
handles.model.delft3dflow.domain(1).onlineWave=1;

