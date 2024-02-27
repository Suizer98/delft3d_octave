function netStruc2nc(ncfile,netStruc,varargin)

% Get basic information right
cstype='geographic';
csname='Unknown projected';
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'cstype'}
                cstype=varargin{ii+1};
            case{'csname'}
                csname=varargin{ii+1};
        end
    end
end

% Get dimensions
nnodes=length(netStruc.node.x);
nlinks=size(netStruc.edge.NetLink,2);
if isfield(netStruc,'face')
    nelems=size(netStruc.face.NetElemNode,1);
end
% if isfield(netStruc,'bndLink')
%     nbndlinks=length(netStruc.bndLink);
% end
%
NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');


% Define dimensions
nNetNodeDimId        = netcdf.defDim(NCid,          'nNetNode',           nnodes);
nNetLinkDimId        = netcdf.defDim(NCid,          'nNetLink',           nlinks);
nNetLinkPtsDimId     = netcdf.defDim(NCid,          'nNetLinkPts',        2);
% if isfield(netStruc,'bndLink')
%     nBndLinkDimId        = netcdf.defDim(NCid,          'nBndLink',           nbndlinks);
% end
if isfield(netStruc,'face')
    nNetElemDimId        = netcdf.defDim(NCid,          'nNetElem',           nelems);
    nNetElemMaxNodeDimId = netcdf.defDim(NCid,          'nNetElemMaxNode',    size(netStruc.face.NetElemNode,2));
end
% nNetElemMaxNodeDimId = netcdf.defDim(NCid,          'nNetElemMaxNode',    4);

tstr=datestr(now,'yyyy-mm-ddTHH:MM:SS');
netcdf.putAtt(NCid,globalID,'institution','Deltares');
netcdf.putAtt(NCid,globalID,'references','http://www.deltares.nl');
netcdf.putAtt(NCid,globalID,'source','Deltares');
netcdf.putAtt(NCid,globalID,'history',['Created on ' tstr]);
netcdf.putAtt(NCid,globalID,'date_created',tstr);
netcdf.putAtt(NCid,globalID,'date_modified',tstr);
netcdf.putAtt(NCid,globalID,'Conventions','UGRID-0.9');

% Variables
varid = netcdf.defVar(NCid,'Mesh2D','int',[]);
netcdf.putAtt(NCid,varid,'cf_role','mesh_topology');
netcdf.putAtt(NCid,varid,'node_coordinates','NetNode_x NetNode_y');
netcdf.putAtt(NCid,varid,'node_dimension','nNetNode');
netcdf.putAtt(NCid,varid,'edge_node_connectivity','NetLink');
netcdf.putAtt(NCid,varid,'edge_dimension','nNetLink');
netcdf.putAtt(NCid,varid,'topology_dimension',int32(1));
netcdf.endDef(NCid);

% Create coordinate system
if strcmpi(cstype,'geographic')
    
    % Always the same
    epsgcode = 4326;
    netcdf.reDef(NCid);
    grdmapping='wgs84';
    varid = netcdf.defVar(NCid,grdmapping,'int',[]);
    netcdf.putAtt(NCid,varid,'name','WGS84');
    netcdf.putAtt(NCid,varid,'epsg',int32(epsgcode));
    netcdf.putAtt(NCid,varid,'grid_mapping_name','latitude_longitude');
    netcdf.putAtt(NCid,varid,'longitude_of_prime_meridian',0);
    netcdf.putAtt(NCid,varid,'semi_major_axis',6.37814e+006);
    netcdf.putAtt(NCid,varid,'semi_minor_axis',6.35675e+006);
    netcdf.putAtt(NCid,varid,'inverse_flattening',298.257);
    netcdf.putAtt(NCid,varid,'proj4_params',' ');
    netcdf.putAtt(NCid,varid,'EPSG_code',['EPGS:', num2str(epsgcode)]);
    netcdf.putAtt(NCid,varid,'projection_name',' ');
    netcdf.putAtt(NCid,varid,'wkt',' ');
    netcdf.putAtt(NCid,varid,'comment',' ');
    netcdf.putAtt(NCid,varid,'value','value is equal to EPSG code');
    netcdf.endDef(NCid);
    
else
    
    % Get EPGS code
    handles=getHandles;
    if isempty(handles)
        handles.EPSG=load('EPSG');
        setHandles(handles);
    end
    [x1,y1, logs]=convertCoordinates(0,0,handles.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.name',csname,'CS2.type','xy');
    epsgcode     = logs.CS2.code;
    
    % Rest
    netcdf.reDef(NCid);
    grdmapping='projected_coordinate_system';
    varid = netcdf.defVar(NCid,grdmapping,'int',[]);
    netcdf.putAtt(NCid,varid,'name',csname);
    netcdf.putAtt(NCid,varid,'epsg',int32(epsgcode));
    netcdf.putAtt(NCid,varid,'grid_mapping_name','Unknown projected');
    netcdf.putAtt(NCid,varid,'longitude_of_prime_meridian',0);
    netcdf.putAtt(NCid,varid,'semi_major_axis',num2str(logs.CS2.ellips.semi_major_axis, '%10.5e\n'))
    netcdf.putAtt(NCid,varid,'semi_minor_axis',num2str(logs.CS2.ellips.semi_minor_axis, '%10.5e\n'))
    netcdf.putAtt(NCid,varid,'inverse_flattening',num2str(logs.CS2.ellips.inv_flattening))
    netcdf.putAtt(NCid,varid,'proj4_params',' ');
    netcdf.putAtt(NCid,varid,'EPSG_code',['EPGS:', num2str(epsgcode)]);
    netcdf.putAtt(NCid,varid,'projection_name',' ');
    netcdf.putAtt(NCid,varid,'wkt',' ');
    netcdf.putAtt(NCid,varid,'comment',' ');
    netcdf.putAtt(NCid,varid,'value','value is equal to EPSG code');
    netcdf.endDef(NCid);
end
netcdf.putVar(NCid,varid,epsgcode);

% Node x
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_x','double',nNetNodeDimId);
if strcmpi(cstype,'geographic')
    netcdf.putAtt(NCid,varid,'units','degrees_east');
    netcdf.putAtt(NCid,varid,'standard_name','longitude');
    netcdf.putAtt(NCid,varid,'long_name','longitude');
    netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
else
    netcdf.putAtt(NCid,varid,'units','m');
    netcdf.putAtt(NCid,varid,'standard_name','projection_x_coordinate');
    netcdf.putAtt(NCid,varid,'long_name','x-coordinate of net nodes');
    netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
end
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.node.x);

% Node y
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_y','double',nNetNodeDimId);
if strcmpi(cstype,'geographic')
    netcdf.putAtt(NCid,varid,'units','degrees_north');
    netcdf.putAtt(NCid,varid,'standard_name','latitude');
    netcdf.putAtt(NCid,varid,'long_name','latitude');
    netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
else
    netcdf.putAtt(NCid,varid,'units','m');
    netcdf.putAtt(NCid,varid,'standard_name','projection_y_coordinate');
    netcdf.putAtt(NCid,varid,'long_name','y-coordinate of net nodes');
    netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
end
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.node.y);
netStruc.nodeLon=netStruc.node.x;
netStruc.nodeLat=netStruc.node.y;


% % Node lon
% netcdf.reDef(NCid);
% varid = netcdf.defVar(NCid,'NetNode_lon','double',nNetNodeDimId);
% netcdf.putAtt(NCid,varid,'units','degrees_east');
% netcdf.putAtt(NCid,varid,'standard_name','longitude');
% netcdf.putAtt(NCid,varid,'long_name','longitude');
% netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
% netcdf.endDef(NCid);
% netcdf.putVar(NCid,varid,netStruc.nodeLon);
%
% % Node lat
% netcdf.reDef(NCid);
% varid = netcdf.defVar(NCid,'NetNode_lat','double',nNetNodeDimId);
% netcdf.putAtt(NCid,varid,'units','degrees_north');
% netcdf.putAtt(NCid,varid,'standard_name','latitude');
% netcdf.putAtt(NCid,varid,'long_name','latitude');
% netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
% netcdf.endDef(NCid);
% netcdf.putVar(NCid,varid,netStruc.nodeLat);

% Node depth
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_z','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','m');
netcdf.putAtt(NCid,varid,'positive','up');
netcdf.putAtt(NCid,varid,'standard_name','sea_floor_depth');
netcdf.putAtt(NCid,varid,'long_name','Bottom level at net nodes (flow element''s corners)');
netcdf.putAtt(NCid,varid,'coordinates','NetNode_x NetNode_y');
netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.node.z);

% Net link
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetLink','int',[nNetLinkPtsDimId nNetLinkDimId]);
netcdf.putAtt(NCid,varid,'standard_name','netlink');
netcdf.putAtt(NCid,varid,'long_name','link between two netnodes');
netcdf.endDef(NCid);
%netcdf.putVar(NCid,varid,netStruc.edge.NetLink');
netcdf.putVar(NCid,varid,netStruc.edge.NetLink);

% Net link type
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetLinkType','int',nNetLinkDimId);
netcdf.putAtt(NCid,varid,'long_name','type of netlink');
netcdf.putAtt(NCid,varid,'valid_range',int32([0 2]));
netcdf.putAtt(NCid,varid,'flag_values',int32([0 1 2]));
netcdf.putAtt(NCid,varid,'flag_meanings','closed_link_between_2D_nodes link_between_1D_nodes link_between_2D_nodes');
netcdf.endDef(NCid);
linktype=zeros(nlinks,1)+2;
netcdf.putVar(NCid,varid,linktype);

if isfield(netStruc,'face')
    % Net elem node
    netcdf.reDef(NCid);
    varid = netcdf.defVar(NCid,'NetElemNode','int',[nNetElemMaxNodeDimId nNetElemDimId]);
    netcdf.putAtt(NCid,varid,'long_name','Mapping from net cell to net nodes.');
    netcdf.endDef(NCid);
    netcdf.putVar(NCid,varid,netStruc.face.NetElemNode');
end

% if isfield(netStruc,'bndLink')
%     % Bnd Link
%     netcdf.reDef(NCid);
%     varid = netcdf.defVar(NCid,'BndLink','int',nBndLinkDimId);
%     netcdf.putAtt(NCid,varid,'long_name','Netlinks that compose the net boundary.');
%     netcdf.endDef(NCid);
%     netcdf.putVar(NCid,varid,netStruc.bndLink);
% end

% Close file
netcdf.close(NCid)
