function netstruc=ddb_DFlowFM_read_netstruc(fname)

try
    netstruc=dflowfm.readNet_new(fname);
catch    
    netstruc=dflowfm.readNetOld(fname);

    netstruc.edge.mesh2d_edge_nodes=netstruc.edge.NetLink;
    netstruc.edge=rmfield(netstruc.edge,'NetLink');

    netstruc.node.mesh2d_node_x=netstruc.node.x;
    netstruc.node.mesh2d_node_y=netstruc.node.y;
    netstruc.node.mesh2d_node_z=netstruc.node.z;
    netstruc.node=rmfield(netstruc.node,'x');
    netstruc.node=rmfield(netstruc.node,'y');
    netstruc.node=rmfield(netstruc.node,'z');

    if isfield(netstruc,'face')
        netstruc.face.mesh2d_face_nodes=netstruc.face.NetElemNode';
        netstruc.face=rmfield(netstruc.face,'NetElemNode');
    end
    
end

netstruc.node.mesh2d_node_z(netstruc.node.mesh2d_node_z==-999)=NaN;
