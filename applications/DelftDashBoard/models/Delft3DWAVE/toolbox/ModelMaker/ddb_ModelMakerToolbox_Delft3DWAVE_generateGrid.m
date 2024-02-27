function handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateGrid(handles,varargin)

%% Function generates and plots rectangular grid can be called by ddb_ModelMakerToolbox_quickMode_Delft3DFLOW or
% ddb_CSIPSToolbox_initMode

filename=[];
pathname=[];
opt='new';

for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
        case{'option'}
            opt=varargin{ii+1};
    end
end

if isempty(filename)
    [filename, ok] = gui_uiputfile('*.grd', 'Grid File Name',[handles.model.delft3dwave.domain.attName '.grd']);
    if ~ok
        return
    end
end

attname=filename(1:end-4);

switch opt
    case{'new'}
        for ii=1:handles.model.delft3dwave.domain.nrgrids
            if strcmpi(attname,handles.model.delft3dwave.domain.domains(ii).gridname)
                ddb_giveWarning('text','A wave domain with this name already exists. Try again.');
                return
            end
        end
end

wb = waitbox('Generating grid ...');pause(0.1);
[x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles);
close(wb);

%% Now start putting things into the Delft3D-WAVE model
switch opt
    case{'new'}
        handles.model.delft3dwave.domain.nrgrids=handles.model.delft3dwave.domain.nrgrids+1;
        nrgrids=handles.model.delft3dwave.domain.nrgrids;
        domains = ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,nrgrids);
        handles.model.delft3dwave.domain.domains = domains;
        handles.model.delft3dwave.domain.domains(nrgrids).gridnames=filename(1:end-4);
        handles.activeWaveGrid=nrgrids;
        if nrgrids>1
            handles.model.delft3dwave.domain.domains(nrgrids).nestgrid = filename;
%             for ii=1:handles.activeWaveGrid-1
%                 handles.model.delft3dwave.domain.nestgrids{ii}=handles.model.delft3dwave.domain(ii).gridname;
%             end
        else
            handles.model.delft3dwave.domain.domains(nrgrids).nestgrid='';
        end
    case{'existing'}
        nrgrids=handles.model.delft3dwave.domain.nrgrids;
        handles.model.delft3dwave.domain.gridnames{nrgrids}=filename(1:end-4);
end

enc=ddb_enclosure('extract',x,y);
attName=filename(1:end-4);

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end

ddb_wlgrid('write','FileName',[attName '.grd'],'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

handles.model.delft3dwave.domain.domains(nrgrids).coordsyst = coord;
handles.model.delft3dwave.domain.domains(nrgrids).grid      = [attname '.grd'];
handles.model.delft3dwave.domain.domains(nrgrids).grdFile   = [attName '.grd'];
handles.model.delft3dwave.domain.domains(nrgrids).encFile   = [attName '.enc'];

handles.model.delft3dwave.domain.domains(nrgrids).gridname  = attname;
handles.model.delft3dwave.domain.domains(nrgrids).gridx     = x;
handles.model.delft3dwave.domain.domains(nrgrids).gridy     = y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.delft3dwave.domain.domains(nrgrids).depth=nans;
handles.model.delft3dwave.domain.domains(nrgrids).mmax=size(x,1);
handles.model.delft3dwave.domain.domains(nrgrids).nmax=size(x,2);

% Work around with domain.domains problem
handles.model.delft3dwave.domain.domains(nrgrids).grid      = [attname '.grd'];

% Put info back
setHandles(handles);

% Plot new domain
handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);
