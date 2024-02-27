%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17473 $
%$Date: 2021-09-01 22:26:00 +0800 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: D3D_flow_link_length.m 17473 2021-09-01 14:26:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_flow_link_length.m $
%
%Compute link length

function link_L=D3D_flow_link_length(fpath_map)

%% READ

edge_faces=ncread(fpath_map,'mesh2d_edge_faces'); %for each link, which faces does it connect
edge_type=ncread(fpath_map,'mesh2d_edge_type');
face_x=ncread(fpath_map,'mesh2d_face_x');
face_y=ncread(fpath_map,'mesh2d_face_y');

%% CALC

edge_face_nor=edge_faces(:,edge_type==1);

link_x=face_x(edge_face_nor);
link_y=face_y(edge_face_nor);
link_L=sqrt(diff(link_x,1,1).^2+diff(link_y,1,1).^2);

%% PLOT

% node_x=ncread(fpath_map,'mesh2d_node_x');
% node_y=ncread(fpath_map,'mesh2d_node_y');
% figure
% hold on
% plot(link_x,link_y,'-k')
% scatter(link_x(:),link_y(:),10,'r')
% scatter(node_x(:),node_y(:),10,'b')

end %function