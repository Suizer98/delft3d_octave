function handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateBathymetry(handles,datasets,varargin)

icheck=1;
overwrite=1;
filename=[];
id=awg;
modeloffset=0;

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'check'}
                icheck=varargin{i+1};
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'filename'}
                filename=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'modeloffset'}
                modeloffset=varargin{i+1};
        end
    end
end

%% Check should NOT be performed when called by CSIPS toolbox
if icheck
    % Check if there is already a grid
    if isempty(handles.model.delft3dwave.domain.domains(awg).gridx)
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
    if isempty(handles.model.delft3dwave.domain.domains(awg).bedlevel)
        [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.delft3dwave.domain.domains(awg).bedlevel);
    else
        handles.model.delft3dwave.domain.domains(awg).bedlevel=[handles.model.delft3dwave.domain.attName '.dep']; ok = 1
    end
    if ~ok
        return
    end
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.delft3dwave.domain.domains(awg).depth));
    if isnan(dmax)
        overwrite=1;
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                overwrite=0;
            case 'Yes',
                overwrite=1;
        end
    end
end

%% Grid coordinates and type
xg=handles.model.delft3dwave.domain.domains(id).gridx;
yg=handles.model.delft3dwave.domain.domains(id).gridy;
zg=handles.model.delft3dwave.domain.domains(id).depth;
gridtype='structured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%% Update model data
handles.model.delft3dwave.domain.domains(id).depth=zg;
% Depth file
handles.model.delft3dwave.domain.domains(id).bedlevel=filename;
handles.model.delft3dwave.domain.domains(id).depthsource='file';
ddb_wldep('write',filename,handles.model.delft3dwave.domain.domains(id).depth);
% Workaround
handles.model.delft3dwave.domain.domains(id).bedlevel=filename;
handles.model.delft3dwave.domain.domains(id).depthsource='file';
% Plot
handles=ddb_Delft3DWAVE_plotBathy(handles,'plot','wavedomain',id);

