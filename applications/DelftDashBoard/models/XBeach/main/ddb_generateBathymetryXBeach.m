function handles=ddb_generateBathymetryXBeach(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if ~isempty(handles.GUIHandles.XBeachInput(id).xfile)

    dpori=handles.GUIHandles.XBeachInput(id).Depth;
    dmax=max(max(dpori));

    if isnan(dmax)
        opt='overwrite';
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                opt='combine';
            case 'Yes',
                opt='overwrite';
        end
    end
    
    wb = waitbox('Generating bathymetry ...');

    AttName=get(handles.EditAttributeName,'String');
    
    % Generate bathymetry

    xx=handles.GUIData.x;
    yy=handles.GUIData.y;
    zz=handles.GUIData.z;
    
    dpsopt='DP';

    x=handles.GUIHandles.XBeachInput(id).GridXZ;
    y=handles.GUIHandles.XBeachInput(id).GridYZ;

    x(isnan(x))=0;
    y(isnan(y))=0;
    
    z=interp2(xx,yy,zz,x,y);
    
    switch opt
        case{'overwrite'}
            handles.GUIHandles.XBeachInput(id).Depth=z;
        case{'combine'}
            handles.GUIHandles.XBeachInput(id).Depth(isnan(handles.GUIHandles.XBeachInput(id).Depth))=z(isnan(handles.GUIHandles.XBeachInput(id).Depth));
    end

    handles.GUIHandles.XBeachInput(id).DepthZ=GetDepthZ(z,dpsopt);

    wldep_mvo('write',[AttName '.dep'],z);

    handles.GUIHandles.XBeachInput(id).depfile=[AttName '.dep'];

    setHandles(handles);
    
    try
        close(wb);
    end

    ddb_plotXBeachBathymetry(handles,'plot',id);

else
    ddb_giveWarning('Warning','First generate or load a grid');
end
