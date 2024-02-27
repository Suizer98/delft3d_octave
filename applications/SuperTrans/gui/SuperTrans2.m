function SuperTrans2(varargin)

if nargin==0
    % New GUI
    initialize;
    buildgui;
else
    switch varargin{1}
        case{'selectcoordinatereferencesystem'}
            opt2=varargin{2};
            switch opt2
                case{'a'}
                    refreshcoordinatesystem(1);
                case{'b'}
                    refreshcoordinatesystem(2);
            end
            refreshdatumtransformation;
        case{'selectprojected'}
            opt2=varargin{2};
            switch opt2
                case{'a'}
                    handles=getHandles;
                    handles.coordinatesystemnames{1}=handles.projectednames;
                    handles.coordinatesystemcodes{1}=handles.projectedcodes;
                    handles.OPT.CS1.code=handles.lastprojectedcode(1);
                    handles.OPT.CS1.type='projected';
                    handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
                    handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);
                    setHandles(handles);
                    refreshcoordinatesystem(1);
                case{'b'}
                    handles=getHandles;
                    handles.coordinatesystemnames{2}=handles.projectednames;
                    handles.coordinatesystemcodes{2}=handles.projectedcodes;
                    handles.OPT.CS2.code=handles.lastprojectedcode(2);
                    handles.OPT.CS2.type='projected';
                    handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
                    handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);
                    setHandles(handles);
                    refreshcoordinatesystem(2);
            end
            refreshdatumtransformation;
        case{'selectgeographic'}
            opt2=varargin{2};           
            switch opt2
                case{'a'}
                    handles=getHandles;
                    handles.coordinatesystemnames{1}=handles.geographicnames;
                    handles.coordinatesystemcodes{1}=handles.geographiccodes;
                    handles.OPT.CS1.code=handles.lastgeographiccode(1);
                    handles.OPT.CS1.type='geographic';
                    handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
                    handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);
                    setHandles(handles);
                    refreshcoordinatesystem(1);
                case{'b'}
                    handles=getHandles;
                    handles.coordinatesystemnames{2}=handles.geographicnames;
                    handles.coordinatesystemcodes{2}=handles.geographiccodes;
                    handles.OPT.CS2.code=handles.lastgeographiccode(2);
                    handles.OPT.CS2.type='geographic';
                    handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
                    handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);
                    setHandles(handles);
                    refreshcoordinatesystem(2);
            end
            refreshdatumtransformation;
    end
end

%%
function initialize(varargin)
% Initializes parameters
handles=getHandles;

% Load EPSG file
curdir=pwd;
if ~isempty(varargin)
    handles.EPSG=varargin{1};
else
    handles.EPSG = load('EPSG.mat');
    if exist('EPSG_ud.mat','file')
        sud=load('EPSG_ud.mat');
        fnames1=fieldnames(handles.EPSG);
        for i=1:length(fnames1)
            fnames2=fieldnames(handles.EPSG.(fnames1{i}));
            for j=1:length(fnames2)
                if ~isempty(sud.(fnames1{i}).(fnames2{j}))
                    nori=length(handles.EPSG.(fnames1{i}).(fnames2{j}));
                    nnew=length(sud.(fnames1{i}).(fnames2{j}));
                    for k=1:nnew
                        if iscell(handles.EPSG.(fnames1{i}).(fnames2{j}))
                            handles.EPSG.(fnames1{i}).(fnames2{j}){nori+k}=sud.(fnames1{i}).(fnames2{j}){k};
                        else
                            handles.EPSG.(fnames1{i}).(fnames2{j})(nori+k)=sud.(fnames1{i}).(fnames2{j})(k);
                        end
                    end
                end
            end
        end
    end
end

handles.OPT=[];

handles.FilterIndex     = 1;
handles.FilePath        = curdir;

nproj=0;
ngeo=0;

% Make cell arrays with names of projected and geographic coordinate systems
for i=1:length(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind)
    switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind{i}),
        case{'projected'}
            switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i})
                case{'epsg vertical perspective example'}
                    % This thing doesn't work
                otherwise
                    nproj=nproj+1;
                    handles.projectednames{nproj}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
                    handles.projectedcodes(nproj)=handles.EPSG.coordinate_reference_system.coord_ref_sys_code(i);
            end
        case{'geographic 2d'}
            if handles.EPSG.coordinate_reference_system.coord_ref_sys_code(i)<1000000
                ngeo=ngeo+1;
                handles.geographicnames{ngeo}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
                handles.geographiccodes(ngeo)=handles.EPSG.coordinate_reference_system.coord_ref_sys_code(i);
            end
    end
end

% Initialize default values

% Coordinate system A
handles.OPT.CS1.name='Amersfoort / RD New';
handles.OPT.CS1.type='projected';
ii=strmatch(handles.OPT.CS1.name,handles.projectednames,'exact');
handles.OPT.CS1.code=handles.projectedcodes(ii);
handles.projected(1)=1;
handles.geographic(1)=0;
handles.coordinatesystemnames{1}=handles.projectednames;
handles.coordinatesystemcodes{1}=handles.projectedcodes;

% Coordinate system B
handles.OPT.CS2.name='WGS 84';
handles.OPT.CS2.type='geographic 2D';
ii=strmatch(handles.OPT.CS2.name,handles.geographicnames,'exact');
handles.OPT.CS2.code=handles.geographiccodes(ii);
handles.projected(2)=1;
handles.geographic(2)=0;
handles.coordinatesystemnames{2}=handles.geographicnames;
handles.coordinatesystemcodes{2}=handles.geographiccodes;

handles.lastprojectedcode(1)=handles.OPT.CS1.code;
handles.lastgeographiccode(1)=handles.OPT.CS2.code;
handles.lastprojectedcode(2)=handles.OPT.CS1.code;
handles.lastgeographiccode(2)=handles.OPT.CS2.code;

handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);

setHandles(handles);

refreshcoordinatesystem(1);
refreshcoordinatesystem(2);

%%
function buildgui
% Builds GUI

handles=getHandles;

xmldir='d:\checkouts\OpenEarthTools\trunk\matlab\applications\SuperTrans\';
xmlfile='supertrans.xml';
gui_newWindow(handles,'xmldir',xmldir,'xmlfile',xmlfile,'modal',0,'getfcn',@getHandles,'setfcn',@setHandles);

setHandles(handles);

%%
%%
function refreshcoordinatesystem(ii)

handles=getHandles;

handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.code',handles.OPT.CS1.code,'CS1.type',handles.OPT.CS1.type,'CS2.code',handles.OPT.CS2.code,'CS2.type',handles.OPT.CS2.type);
handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);

OPT=handles.OPT;

if ii==1
    CS=OPT.CS1;
    proj_conv=OPT.proj_conv1;
else
    CS=OPT.CS2;
    proj_conv=OPT.proj_conv2;
end

handles.coordinateoperationstring{ii}='';
for k=1:7
    handles.conversionparametertext{ii,k}='';
    handles.conversionparameterstring{ii,k}='';
    handles.conversionparameterunit{ii,k}='';
end

handles.nrconversionparameters(ii)=0;

if strcmpi(CS.type,'projected')

    handles.lastprojectedcode(ii)=CS.code;
    handles.projected(ii)=1;
    handles.geographic(ii)=0;

%     % Projection
%     handles.coordinateoperationstring{ii}=['Operation : ' proj_conv.method.name];

    n=length(proj_conv.param.codes);
    handles.nrconversionparameters(ii)=n;
    
    pars=[];
    
    switch proj_conv.method.code
        case{9801} % Lambert Conic Conformal (1SP)
            pars{1}='Latitude of natural origin';
            pars{2}='Longitude of natural origin';
            pars{3}='False easting';
            pars{4}='False northing';
            pars{5}='Scale factor at natural origin';
        case{9802,9803}
            pars{1}='Longitude of false origin';
            pars{2}='Easting at false origin';
            pars{3}='Latitude of false origin';
            pars{4}='Northing at false origin';
            pars{5}='Latitude of 1st standard parallel';
            pars{6}='Latitude of 2nd standard parallel';
        case{9807,9808,9809}
            pars{1}='Longitude of natural origin';
            pars{2}='Latitude of natural origin';
            pars{3}='False easting';
            pars{4}='False northing';
            pars{5}='Scale factor at natural origin';
        case{9812}
            pars{1}='False easting';
            pars{2}='False northing';
            pars{3}='Longitude of projection centre';
            pars{4}='Latitude of projection centre';
            pars{5}='Azimuth of initial line';
            pars{6}='Angle from Rectified to Skew Grid';
            pars{7}='Scale factor on initial line';
        case{9815}
            pars{1}='Easting at projection centre';
            pars{2}='Northing at projection centre';
            pars{3}='Longitude of projection centre';
            pars{4}='Latitude of projection centre';
            pars{5}='Azimuth of initial line';
            pars{6}='Angle from Rectified to Skew Grid';
            pars{7}='Scale factor on initial line';           
        case{9818}
            pars{1}='Longitude of natural origin';
            pars{2}='Latitude of natural origin';
            pars{3}='False easting';
            pars{4}='False northing';
        otherwise
            for j=1:length(proj_conv.param.codes)
                pars{j} = proj_conv.param.name{j};
            end
    end

    for k=1:n
        % Find matching parameter
        jj=strmatch(lower(pars{k}),lower(proj_conv.param.name),'exact');
        % Set parameter text
        handles.conversionparametertext{ii,k}=pars{k};
        % Unit
        unit=ConvertUnitString(proj_conv.param.UoM.name{jj});
        handles.conversionparameterunit{ii,k}=unit;
        % Value
        val=proj_conv.param.value(jj);
        % Set text in edit box
        if ~strcmpi(unit,'deg')
            handles.conversionparameterstring{ii,k}=num2str(val,'%0.9g');
        else
            dms=d2dms(val);
            if dms.sc<1e-8
                dms.sc=0;
            end
            degstr=[num2str(dms.dg) ' ' num2str(dms.mn) ''' ' num2str(dms.sc) '"'];
            handles.conversionparameterstring{ii,k}=degstr;
        end
    end

    % Check if conversion method is available
    switch proj_conv.method.code
        case{9801,9802,9803,9807,9808,9809,9812,9815}
            handles.conversionok=1;
        otherwise
            % Conversion method not available
            handles.conversionok=0;
            handles.coordinateoperationstring{ii}=['Operation : ' proj_conv.method.name ' - NOT YET AVAILABLE !'];
    end
else
    handles.lastgeographiccode(ii)=CS.code;
    handles.projected(ii)=0;
    handles.geographic(ii)=1;
    handles.OPT.proj_conv1.method.name='';
end

setHandles(handles);

%%
function refreshdatumtransformation

