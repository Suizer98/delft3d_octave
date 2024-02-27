function handles=muppet_getCoordinateSystems(handles)

global EPSG
global COORDINATESYSTEMS

%%

fname=[handles.settingsdir 'data' filesep 'epsg' filesep 'epsg.mat'];

handles.EPSG=load(fname);

nproj=0;
ngeo=0;

for i=1:length(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind)
    switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind{i}),
        case{'projected'}
            switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i})
                case{'epsg vertical perspective example'}
                    % This thing doesn't work
                otherwise
                    nproj=nproj+1;
                    handles.coordinateData.coordSysCart{nproj}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
            end
        case{'geographic 2d'}
            if handles.EPSG.coordinate_reference_system.coord_ref_sys_code(i)<1000000
                ngeo=ngeo+1;
                handles.coordinateData.coordSysGeo{ngeo}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
            end
    end
end

EPSG=handles.EPSG;
COORDINATESYSTEMS=handles.coordinateData;
