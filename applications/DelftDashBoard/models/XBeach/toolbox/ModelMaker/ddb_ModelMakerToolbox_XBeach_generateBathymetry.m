function handles=ddb_ModelMakerToolbox_XBeach_generateBathymetry(handles,datasets,varargin)

icheck=1;
overwrite=1;
filename=[];
id=ad;
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
    if handles.model.xbeach.domain(id).nx==0
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
    if ~strcmpi(handles.model.xbeach.domain(id).depfile,'file')
        handles.model.xbeach.domain(id).depfile=[handles.model.xbeach.domain(id).attname '.dep'];
    end
    [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.xbeach.domain(id).depfile);
    if ~ok
        return
    end
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.xbeach.domain(id).depth));
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
xg=handles.model.xbeach.domain(id).grid.x;
yg=handles.model.xbeach.domain(id).grid.y;
zg=handles.model.xbeach.domain(id).depth;
gridtype='structured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%% Update model data
handles.model.xbeach.domain(id).depth=zg;
% Fill borders

% Depth file
handles.model.xbeach.domain(id).depfile=filename;
%handles.model.xbeach.domain(id).depthsource='file';
ddb_wldep('write',filename,zg);
%% Plot
handles=ddb_XBeach_plotBathymetry(handles,'plot','domain',id);

