%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200828
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(oetsettings)
%add paths to RIV tools:
%   https://repos.deltares.nl/repos/RIVmodels/rivtools/trunk/matlab
%   run(rivsettings)

%% PREAMBLE

clear
clc

%% INPUT

% path_grd='../data/net.nc';
path_grd='c:\Users\chavarri\checkouts\riv\matlab\scripts\vtools\D3D\data\net.nc';

%% CALC

% clc; ncdisp(path_grd);

mesh2d_node_x=ncread(path_grd,'mesh2d_node_x');
mesh2d_node_y=ncread(path_grd,'mesh2d_node_y');

mesh2d_face_nodes=ncread(path_grd,'mesh2d_face_nodes');
mesh2d_face_x=ncread(path_grd,'mesh2d_face_x');
mesh2d_face_y=ncread(path_grd,'mesh2d_face_y');

mesh2d_face_x_bnd=ncread(path_grd,'mesh2d_face_x_bnd');
mesh2d_face_y_bnd=ncread(path_grd,'mesh2d_face_y_bnd');
% mesh2d_edge_faces=ncread(path_grd,'mesh2d_edge_faces');

nface=size(mesh2d_face_nodes,2);

mean_mesh2d_face_x_bnd=mean(mesh2d_face_x_bnd,1);
mean_mesh2d_face_y_bnd=mean(mesh2d_face_y_bnd,1);

%% PLOT

figure
hold on
han.node=scatter(mesh2d_node_x,mesh2d_node_y,10,'k','*');
han.face=scatter(mesh2d_face_x,mesh2d_face_y,10,'r','o');
% han.face=scatter(mean_mesh2d_face_x_bnd,mean_mesh2d_face_y_bnd,10,'g','x');
han.face_line=plot(mesh2d_face_x_bnd,mesh2d_face_y_bnd,'k');
legend([han.node,han.face,han.face_line(1)],{'mesh2d\_node\_(x,y) (cell corner)','mesh2d\_face\_(x,y) (cell center)','face (cell edge)'})
axis equal

