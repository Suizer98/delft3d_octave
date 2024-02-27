function ddb_Delft3DWAVE_bathymetry(varargin)

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'select'}
            selectBathy;
    end
end

%%
function selectBathy

handles=getHandles;
filenm = handles.model.delft3dwave.domain.domains(awg).bedlevel;
[pathstr,name,ext] = fileparts(filenm);
% Set grid values in handles
%handles.model.delft3dwave.domain.domains(awg).bedlevelgrid=handles.model.delft3dwave.domain.domains(awg).grid;
handles.model.delft3dwave.domain.domains(awg).bedlevel=[name ext];
grid=ddb_wlgrid('read',handles.model.delft3dwave.domain.domains(awg).gridname);
try 
    z = ddb_wldep('read',[name '.dep'],grid);
    handles.model.delft3dwave.domain.domains(awg).depth = -z(1:end-1,1:end-1);
    handles.model.delft3dwave.domain.domains(awg).depth(handles.model.delft3dwave.domain.domains(awg).depth==999.999)=NaN;
    handles=ddb_Delft3DWAVE_plotBathy(handles,'plot','wavedomain',awg);
    setHandles(handles);
catch
    ddb_giveWarning('Warning','Depth does not fit grid');
end
