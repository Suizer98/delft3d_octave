function handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,id,datasets,varargin)

%% Initial settings
icheck=1;
overwrite=1;
filename=[];
% id=ad;
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
    if isempty(handles.model.dflowfm.domain.netstruc)
        ddb_giveWarning('Warning','First generate or load a mesh');
        return
    end
    % File name
%    if isempty(handles.model.dflowfm.domain(ad).netstruc.node.z)
%         handles.model.dflowfm.domain(ad).netfile=[handles.model.dflowfm.domain(ad).attName '_net.nc'];
%    end
    [filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
    if ~ok
        return
    end
    % Check if there is already data in depth matrix
    dmax=nanmax(nanmax(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z));
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
xg=handles.model.dflowfm.domain(id).netstruc.node.mesh2d_node_x;
yg=handles.model.dflowfm.domain(id).netstruc.node.mesh2d_node_y;
zg=handles.model.dflowfm.domain(id).netstruc.node.mesh2d_node_z;
gridtype='unstructured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%zg=zeros(size(zg))-1;
%% Update model data
handles.model.dflowfm.domain(id).netstruc.node.mesh2d_node_z=zg;
% Update circumference
%handles.model.dflowfm.domain(id).circumference.z=handles.model.dflowfm.domain(id).netstruc.node.z(handles.model.dflowfm.domain(id).circumference.n);
    
% Net file
handles.model.dflowfm.domain(ad).netfile=filename;
%handles.model.dflowfm.domain(id).netstruc.edge.NetLink=handles.model.dflowfm.domain(id).netstruc.edge.NetLink';
%netStruc2nc(handles.model.dflowfm.domain(id).netfile,handles.model.dflowfm.domain(id).netstruc,'cstype',handles.screenParameters.coordinateSystem.type);
cs.name=handles.screenParameters.coordinateSystem.name;
switch lower(handles.screenParameters.coordinateSystem.type(1:3))
    case{'pro','car'}
        cs.type='projected';
    otherwise
        cs.type='geographic';
end

netstruc2netcdf(handles.model.dflowfm.domain(id).netfile,handles.model.dflowfm.domain(id).netstruc,'cs',cs);
% Plot
% TODO handles=ddb_DFlowFM_plotBathymetry(handles,'plot');
handles=ddb_DFlowFM_plotBathymetry(handles,'plot');
