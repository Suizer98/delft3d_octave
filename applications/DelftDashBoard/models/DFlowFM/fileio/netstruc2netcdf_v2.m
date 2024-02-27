function netstruc2netcdf(ncfile,netstruc,varargin)

cs.name='WGS 84';
cs.type='geographic';
format='new';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'cs'}
                cs=varargin{ii+1};
            case{'format'}
                format=varargin{ii+1};
        end
    end
end

switch lower(cs.type(1:3))
    case{'geo'}
        xunits='degrees_east';
        yunits='degrees_north';
        xstd='longitude';
        ystd='latitude';
    otherwise
        xunits='m';
        yunits='m';
        xstd='projection_x_coordinate';
        ystd='projection_y_coordinate';        
end

nnodes=length(netstruc.node.mesh2d_node_x);
nedges=size(netstruc.edge.mesh2d_edge_nodes,2);
if isfield(netstruc,'face')
    nfaces=size(netstruc.face.mesh2d_face_nodes,2);
    nfacenodes=size(netstruc.face.mesh2d_face_nodes,1);
else
    nfaces=0;
    nfacenodes=6;
end

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

grdmapping='wgs84';

if strcmpi(format,'new')
    name_nmesh2d_edge='nmesh2d_edge';
    name_nmesh2d_node='nmesh2d_node';
    name_Two='Two';
    name_nmesh2d_face='nmesh2d_face';
    name_max_nmesh2d_face_nodes='nmesh2d_face_nodes_nodes';
    name_mesh2d_node_x='mesh2d_node_x';
    name_mesh2d_node_y='mesh2d_node_y';
    name_mesh2d_node_z='mesh2d_node_z';
    name_mesh2d_edge_nodes='mesh2d_edge_nodes';
    name_mesh2d_edge_types=mesh2d_edge_types;
    name_mesh2d_face_nodes='mesh2d_edge_faces';
else
    name_nmesh2d_edge='nNetNode';
    name_nmesh2d_node='nNetLink';
    name_Two='nNetLinkPts';
    name_nmesh2d_face='nNetElem';
    name_max_nmesh2d_face_nodes='nNetElemMaxNode';
    name_mesh2d_node_x='NetNode_x';
    name_mesh2d_node_y='NetNode_y';
    name_mesh2d_node_z='NetNode_z';
    name_mesh2d_edge_nodes='NetLink';
    name_mesh2d_edge_types='NetLinkType';
    name_mesh2d_face_nodes='NetElemNode';
end

% Dimensions
nmesh2d_edge           = netcdf.defDim(NCid,          name_nmesh2d_edge,           nedges);
nmesh2d_node           = netcdf.defDim(NCid,          name_nmesh2d_node,           nnodes);
Two                    = netcdf.defDim(NCid,          name_Two,                    2);

nmesh2d_face           = netcdf.defDim(NCid,          name_nmesh2d_face,           nfaces);
max_nmesh2d_face_nodes = netcdf.defDim(NCid,          name_max_nmesh2d_face_nodes, nfacenodes);

% Global attributes
tstr=datestr(now,'yyyy-mm-ddTHH:MM:SS');
netcdf.putAtt(NCid,globalID,'institution','Deltares');
netcdf.putAtt(NCid,globalID,'references','http://www.deltares.nl');
netcdf.putAtt(NCid,globalID,'source','Deltares');
netcdf.putAtt(NCid,globalID,'history',['Created on ' tstr]);
netcdf.putAtt(NCid,globalID,'date_created',tstr);
netcdf.putAtt(NCid,globalID,'date_modified',tstr);
netcdf.putAtt(NCid,globalID,'Conventions','CF-1.6 UGRID-1.0/Deltares-0.8');

% Variables

varid = netcdf.defVar(NCid,'mesh2d','int',[]);
netcdf.putAtt(NCid,varid,'cf_role','mesh_topology');
netcdf.putAtt(NCid,varid,'topology_dimension',int32(2));
netcdf.putAtt(NCid,varid,'node_coordinates','mesh2d_node_x mesh2d_node_y');
netcdf.putAtt(NCid,varid,'node_dimension','nmesh2d_node');
netcdf.putAtt(NCid,varid,'max_face_nodes_dimension','max_nmesh2d_face_nodes');
netcdf.putAtt(NCid,varid,'edge_node_connectivity','mesh2d_edge_nodes');
netcdf.putAtt(NCid,varid,'edge_dimension','nmesh2d_edge');
netcdf.putAtt(NCid,varid,'edge_coordinates','mesh2d_edge_x mesh2d_edge_y');
netcdf.putAtt(NCid,varid,'face_node_connectivity','mesh2d_face_nodes');
netcdf.putAtt(NCid,varid,'face_dimension','nmesh2d_face');
netcdf.putAtt(NCid,varid,'edge_face_connectivity','mesh2d_edge_faces');
netcdf.putAtt(NCid,varid,'face_coordinates','mesh2d_face_x mesh2d_face_y');
netcdf.endDef(NCid);

%% Nodes

% Node x
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,name_mesh2d_node_x,'double',nmesh2d_node);
netcdf.putAtt(NCid,varid,'units',xunits);
netcdf.putAtt(NCid,varid,'standard_name',xstd);
netcdf.putAtt(NCid,varid,'long_name','x-coordinate of net nodes');
netcdf.putAtt(NCid,varid,'mesh','mesh2d');
netcdf.putAtt(NCid,varid,'location','node');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netstruc.node.mesh2d_node_x);

% Node y
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,name_mesh2d_node_y,'double',nmesh2d_node);
netcdf.putAtt(NCid,varid,'units',yunits);
netcdf.putAtt(NCid,varid,'standard_name',ystd);
netcdf.putAtt(NCid,varid,'long_name','y-coordinate of net nodes');
netcdf.putAtt(NCid,varid,'mesh','mesh2d');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netstruc.node.mesh2d_node_y);

% Node z
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,name_mesh2d_node_z,'double',nmesh2d_node);
netcdf.putAtt(NCid,varid,'mesh','mesh2d');
netcdf.putAtt(NCid,varid,'location','node');
netcdf.putAtt(NCid,varid,'coordinates','mesh2d_node_x mesh2d_node_y');
netcdf.putAtt(NCid,varid,'units','m');
netcdf.putAtt(NCid,varid,'positive','up');
netcdf.putAtt(NCid,varid,'standard_name','altitude');
netcdf.putAtt(NCid,varid,'long_name','z-coordinate of mesh nodes');
netcdf.putAtt(NCid,varid,'_FillValue',-999);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netstruc.node.mesh2d_node_z);


%% Edges

netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,name_mesh2d_edge_nodes,'int',[Two nmesh2d_edge]);
netcdf.putAtt(NCid,varid,'cf_role','edge_node_connectivity');
netcdf.putAtt(NCid,varid,'mesh','mesh2d');
netcdf.putAtt(NCid,varid,'location','edge');
netcdf.putAtt(NCid,varid,'long_name','Mapping from every edge to the two nodes that it connects');
netcdf.putAtt(NCid,varid,'start_index',1.0);
netcdf.putAtt(NCid,varid,'_FillValue',int32(-999));
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_nodes);

if isfield(netstruc.edge,'mesh2d_edge_types')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,name_mesh2d_edge_types,'int',nmesh2d_edge);
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','edge');
    netcdf.putAtt(NCid,varid,'coordinates','mesh2d_edge_x mesh2d_edge_y');
    netcdf.putAtt(NCid,varid,'cell_methods','nmesh2d: mean');
    netcdf.putAtt(NCid,varid,'long_name','edge type (relation between edge and flow geometry)');
    netcdf.putAtt(NCid,varid,'start_index',1.0);
    netcdf.putAtt(NCid,varid,'_FillValue',int32(-999));
    netcdf.putAtt(NCid,varid,'flag_values','0, 1, 2, 3');
    netcdf.putAtt(NCid,varid,'flag_meanings','internal_closed internal boundary boundary_closed');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_types);
end

if isfield(netstruc.edge,'mesh2d_edge_x')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'mesh2d_edge_x','double',nmesh2d_edge);
    netcdf.putAtt(NCid,varid,'units',xunits);
    netcdf.putAtt(NCid,varid,'standard_name',xstd);
    netcdf.putAtt(NCid,varid,'long_name','characteristic x-coordinate of the mesh edge (e.g. midpoint)');
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','edge');
    netcdf.putAtt(NCid,varid,'bounds','mesh2d_edge_x_bnd');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_x);
end

if isfield(netstruc.edge,'mesh2d_edge_y')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'mesh2d_edge_y','double',nmesh2d_edge);
    netcdf.putAtt(NCid,varid,'units',yunits);
    netcdf.putAtt(NCid,varid,'standard_name',ystd);
    netcdf.putAtt(NCid,varid,'long_name','characteristic y-coordinate of the mesh edge (e.g. midpoint)');
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','edge');
    netcdf.putAtt(NCid,varid,'bounds','mesh2d_edge_y_bnd');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_y);
end

if isfield(netstruc.edge,'mesh2d_edge_x_bnd')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'mesh2d_edge_x_bnd','double',[Two nmesh2d_edge]);
    netcdf.putAtt(NCid,varid,'units',xunits);
    netcdf.putAtt(NCid,varid,'standard_name',xstd);
    netcdf.putAtt(NCid,varid,'long_name','x-coordinate bounds of 2D mesh edge (i.e. end point coordinates)');
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','edge');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_x_bnd);
end

if isfield(netstruc.edge,'mesh2d_edge_y_bnd')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'mesh2d_edge_y_bnd','double',[Two nmesh2d_edge]);
    netcdf.putAtt(NCid,varid,'units',yunits);
    netcdf.putAtt(NCid,varid,'standard_name',ystd);
    netcdf.putAtt(NCid,varid,'long_name','y-coordinate bounds of 2D mesh edge (i.e. end point coordinates)');
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','edge');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_x_bnd);
end

if isfield(netstruc.edge,'mesh2d_edge_faces')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'name_mesh2d_edge_faces','int',[Two nmesh2d_edge]);
    netcdf.putAtt(NCid,varid,'cf_role','edge_face_connectivity');
    netcdf.putAtt(NCid,varid,'long_name','Mapping from every edge to the two faces that it separates');
    netcdf.putAtt(NCid,varid,'start_index',1.0);
    netcdf.putAtt(NCid,varid,'_FillValue',int32(-999));
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.edge.mesh2d_edge_faces);
end

%% Faces

if isfield(netstruc,'face')
    
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,name_mesh2d_face_nodes,'int',[max_nmesh2d_face_nodes nmesh2d_face]);
    netcdf.putAtt(NCid,varid,'cf_role','face_node_connectivity');
    netcdf.putAtt(NCid,varid,'mesh','mesh2d');
    netcdf.putAtt(NCid,varid,'location','face');
    netcdf.putAtt(NCid,varid,'long_name','Mapping from every face to its corner nodes (counterclockwise)');
    netcdf.putAtt(NCid,varid,'start_index',1.0);
    netcdf.putAtt(NCid,varid,'_FillValue',int32(-999));
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netstruc.face.mesh2d_face_nodes);
    
    if isfield(netstruc.face,'mesh2d_face_x')
        netcdf.reDef(NCid);
        varid = netcdf.defVar(NCid,'mesh2d_face_x','double',nmesh2d_face);
        netcdf.putAtt(NCid,varid,'units',xunits);
        netcdf.putAtt(NCid,varid,'standard_name',xstd);
        netcdf.putAtt(NCid,varid,'long_name','Characteristic x-coordinate of mesh face');
        netcdf.putAtt(NCid,varid,'mesh','mesh2d');
        netcdf.putAtt(NCid,varid,'location','face');
        netcdf.putAtt(NCid,varid,'bounds','mesh2d_face_x_bnd');
        netcdf.endDef(NCid);
        netcdf.putVar(NCid,varid,netstruc.face.mesh2d_face_x);
    end
    
    if isfield(netstruc.face,'mesh2d_face_y')
        netcdf.reDef(NCid);
        varid = netcdf.defVar(NCid,'mesh2d_face_y','double',nmesh2d_face);
        netcdf.putAtt(NCid,varid,'units',yunits);
        netcdf.putAtt(NCid,varid,'standard_name',ystd);
        netcdf.putAtt(NCid,varid,'long_name','Characteristic y-coordinate of mesh face');
        netcdf.putAtt(NCid,varid,'mesh','mesh2d');
        netcdf.putAtt(NCid,varid,'location','face');
        netcdf.putAtt(NCid,varid,'bounds','mesh2d_face_y_bnd');
        netcdf.endDef(NCid);
        netcdf.putVar(NCid,varid,netstruc.face.mesh2d_face_y);
    end
    
    if isfield(netstruc.face,'mesh2d_face_x_bnd')
        netcdf.reDef(NCid);
        varid = netcdf.defVar(NCid,'mesh2d_face_x_bnd','double',[max_nmesh2d_face_nodes nmesh2d_face]);
        netcdf.putAtt(NCid,varid,'units',xunits);
        netcdf.putAtt(NCid,varid,'standard_name',xstd);
        netcdf.putAtt(NCid,varid,'long_name','x-coordinate bounds of 2D mesh face (i.e. corner coordinates)');
        netcdf.putAtt(NCid,varid,'mesh','mesh2d');
        netcdf.putAtt(NCid,varid,'location','face');
        netcdf.putAtt(NCid,varid,'_FillValue',-999.0);
        netcdf.endDef(NCid);
        netcdf.putVar(NCid,varid,netstruc.face.mesh2d_face_x_bnd);
    end
    
    if isfield(netstruc.face,'mesh2d_face_y_bnd')
        netcdf.reDef(NCid);
        varid = netcdf.defVar(NCid,'mesh2d_face_y_bnd','double',[max_nmesh2d_face_nodes nmesh2d_face]);
        netcdf.putAtt(NCid,varid,'units',yunits);
        netcdf.putAtt(NCid,varid,'standard_name',ystd);
        netcdf.putAtt(NCid,varid,'long_name','y-coordinate bounds of 2D mesh face (i.e. corner coordinates)');
        netcdf.putAtt(NCid,varid,'mesh','mesh2d');
        netcdf.putAtt(NCid,varid,'location','face');
        netcdf.putAtt(NCid,varid,'_FillValue',-999.0);
        netcdf.endDef(NCid);
        netcdf.putVar(NCid,varid,netstruc.face.mesh2d_face_y_bnd);
    end
    
end

%% Horizontal coordinate system

if strcmpi(cs.type(1:3),'geo')
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'wgs84','int',[]);
    netcdf.putAtt(NCid,varid,'name','WGS84');
    netcdf.putAtt(NCid,varid,'epsg',int32(4326));
    netcdf.putAtt(NCid,varid,'grid_mapping_name','latitude_longitude');
    netcdf.putAtt(NCid,varid,'longitude_of_prime_meridian',0);
    netcdf.putAtt(NCid,varid,'semi_major_axis',6378137.0);
    netcdf.putAtt(NCid,varid,'semi_minor_axis',6356752.314245);
    netcdf.putAtt(NCid,varid,'inverse_flattening',298.257223563);
    netcdf.putAtt(NCid,varid,'proj4_params',' ');
    netcdf.putAtt(NCid,varid,'EPSG_code','EPGS:4326');
    netcdf.putAtt(NCid,varid,'projection_name',' ');
    netcdf.putAtt(NCid,varid,'wkt',' ');
    netcdf.putAtt(NCid,varid,'comment',' ');
    netcdf.putAtt(NCid,varid,'value','value is equal to EPSG code');
    netcdf.endDef(NCid);
else
    EPSG=readEPSGData;
    cs.code=[];
    cs = ConvertCoordinatesFindCoordRefSys(cs,EPSG);
    proj_conv = ConvertCoordinatesFindConversionParams(cs,EPSG);
    proj_conv
end

% Close file
netcdf.close(NCid)
