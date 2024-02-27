function grid_props = D3D_grd_properties(path_grd);
% D3D_grd_properties - compute edge centres, edge neighbours, orthogonality and smoothness

if nc_isvar(path_grd,'wgs84')
    error('Spherical grids not supported') 
end 

edge_nodes=ncread(path_grd,'mesh2d_edge_nodes'); %{'Start and end nodes of mesh edges'}
edge_type=ncread(path_grd,'mesh2d_edge_type');
node_x=ncread(path_grd,'mesh2d_node_x');
node_y=ncread(path_grd,'mesh2d_node_y');
edge_x=ncread(path_grd,'mesh2d_edge_x');
edge_y=ncread(path_grd,'mesh2d_edge_y');
face_x=ncread(path_grd,'mesh2d_face_x');
face_y=ncread(path_grd,'mesh2d_face_y');
%net_elem_node=double(ncread(path_grd,'NetElemNode')); %which cell corners connect each cell max=2585
edge_faces=double(ncread(path_grd,'mesh2d_edge_faces')); %which
%net_elem_link(abs(net_elem_link)>1e5)=NaN;
NetLinkContour_x=ncread(path_grd,'mesh2d_face_x_bnd'); %{'list of x-contour points of momentum control volume surrounding each net/flow link'}
NetLinkContour_y=ncread(path_grd,'mesh2d_face_y_bnd');
% The orthogonality is defined as the cosine of the angle ? between a flowlink and a netlink.
% The smoothness of a mesh is defined as the ratio of the areas of two adjacent cells
%%
p0=[node_x(edge_nodes(1,:)),node_y(edge_nodes(1,:))];
pf=[node_x(edge_nodes(2,:)),node_y(edge_nodes(2,:))];
%plot(node_x(edge_nodes(:,1:end)),node_y(edge_nodes(:,1:end)),'k-')
%hold on; 
%%
internal_edges = find(edge_type==1);
for e = internal_edges(:).'; 
    jj = edge_faces(:,e);
    if length(find(jj>0)) == 2;
        A.x1 = face_x(jj(1));
        A.x2 = face_x(jj(2));
        A.y1 = face_y(jj(1));
        A.y2 = face_y(jj(2));
        B.x1 = node_x(edge_nodes(1,e));
        B.x2 = node_x(edge_nodes(2,e));
        B.y1 = node_y(edge_nodes(1,e));
        B.y2 = node_y(edge_nodes(2,e));
        %hold on;
        %plot(face_x(jj),face_y(jj),'r-',node_x(edge_nodes(:,e)),node_y(edge_nodes(:,e)),'r-')
        %C = dflowfm.intersect_lines(A, B);
        v=[A.x2-A.x1;A.y2-A.y1;];
        u=[B.x2-B.x1;B.y2-B.y1;];
        det   = ( (A.x2-A.x1).*(B.y2-B.y1) - (A.y2-A.y1).*(B.x2-B.x1) );
        C.alpha = ( (B.x1-A.x1).*(B.y2-B.y1) - (B.y1-A.y1).*(B.x2-B.x1) ) ./ det;
        C.beta  = ( (B.x1-A.x1).*(A.y2-A.y1) - (B.y1-A.y1).*(A.x2-A.x1) ) ./ det;
        C.x  = A.x1 + C.alpha.*(A.x2-A.x1);
        C.y  = A.y1 + C.alpha.*(A.y2-A.y1);
        orthogonality(e) = dot(u,v)/(norm(u)*norm(v));
        if (C.alpha<(1/11) | C.alpha>(10/11));
            smoothness(e) = 10;
        else
            smoothness(e) = max(C.alpha/(1-C.alpha),(1-C.alpha)/C.alpha);  % maximized at 10; 
        end
        edge_mid_x(e) = C.x;
        edge_mid_y(e) = C.y;
        xp = [A.x1,A.x2,B.x1,B.x2]; 
        yp = [A.y1,A.y2,B.y1,B.y2];
        k = convhull(xp,yp);
        face_nodes_x(1:4,e) = xp(k(1:4));
        face_nodes_y(1:4,e) = yp(k(1:4));
    else
        orthogonality(e) = NaN;
        smoothness(e) = NaN;
        edge_mid_x(e) = NaN;
        edge_mid_y(e) = NaN;
        face_nodes_x(1:4,e) = NaN*[1:4];
        face_nodes_y(1:4,e) = NaN*[1:4];
    end
end
grid_props=v2struct(edge_mid_x,edge_mid_y,orthogonality,smoothness,edge_faces,edge_nodes,face_x,face_y,node_x,node_y,internal_edges,face_nodes_x,face_nodes_y);
end
