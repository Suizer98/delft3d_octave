function handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBathymetry(handles,id, datasets,varargin)

%% Initial settings
icheck=1;
overwrite=1;
modeloffset=0;
filename = '';

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
    if handles.model.delft3dflow.domain(id).MMax==0
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
        
%    if isempty(handles.model.delft3dflow.domain(id).depFile) && isempty(filename)
    if isempty(filename)
        [filename, pathname, filterindex] = uiputfile('*.dep', 'Dep File Name',[handles.model.delft3dflow.domain(id).attName '.dep']);
    else
        pathname = pwd;
    end

    if filename==0
        return
    end
    
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.delft3dflow.domain(id).depth));
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
switch lower(handles.model.delft3dflow.domain(id).dpsOpt)
    case{'dp'}
        xg=handles.model.delft3dflow.domain(id).gridXZ;
        yg=handles.model.delft3dflow.domain(id).gridYZ;
    otherwise
        xg=handles.model.delft3dflow.domain(id).gridX;
        yg=handles.model.delft3dflow.domain(id).gridY;
end
zg=handles.model.delft3dflow.domain(id).depth;
gridtype='structured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%% Update model data
handles.model.delft3dflow.domain(id).depth=zg;
% Fill borders
switch lower(handles.model.delft3dflow.domain(id).dpsOpt)
    case{'dp'}
        handles.model.delft3dflow.domain(id).depth(:,1)=handles.model.delft3dflow.domain(id).depth(:,2);
        handles.model.delft3dflow.domain(id).depth(1,:)=handles.model.delft3dflow.domain(id).depth(2,:);
end
% Determine depth in cell centres
handles.model.delft3dflow.domain(id).depthZ=getDepthZ(zg,handles.model.delft3dflow.domain(id).dpsOpt);
% Depth file
handles.model.delft3dflow.domain(id).depFile=filename;
handles.model.delft3dflow.domain(id).depthSource='file';
ddb_wldep('write',filename,zg);
%% Plot
handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);

