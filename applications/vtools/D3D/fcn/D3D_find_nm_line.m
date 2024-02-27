%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17804 $
%$Date: 2022-03-02 16:37:25 +0800 (Wed, 02 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_find_nm_line.m 17804 2022-03-02 08:37:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_find_nm_line.m $
%

function [nodes_xy_mline,node_all]=D3D_find_nm_line(fpath_grd,node_0,node_1,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'do_debug',0)
addOptional(parin,'tol_angle',2*pi/8)
addOptional(parin,'max_nodes',5000)

parse(parin,varargin{:});

do_debug=parin.Results.do_debug;
tol_angle=parin.Results.tol_angle;
max_nodes=parin.Results.max_nodes;

%% READ

node_x=ncread(fpath_grd,'mesh2d_node_x');
node_y=ncread(fpath_grd,'mesh2d_node_y');
node_c=ncread(fpath_grd,'mesh2d_edge_nodes')';

sc=size(node_c);

%% INI

idx_c_m1=find(ismember(node_c,[node_0,node_1;node_1,node_0],'rows')); %existing
if isempty(idx_c_m1)
    error('the initial coordinates do not exist')
end

xy_0=[node_x(node_0),node_y(node_0)];
xy_1=[node_x(node_1),node_y(node_1)];
angle_aux=angle_polyline([xy_0(1),xy_1(1)],[xy_0(2),xy_1(2)],1);
angle_01=angle_aux(1);
    
xy_0=xy_1;
angle_diff=0;
node_all=[node_0;node_1];
kn=2;

if do_debug
gridInfo=EHY_getGridInfo(fpath_grd,{'grid'});
figure 
hold on
plot(gridInfo.grid(:,1),gridInfo.grid(:,2),'color','k')
scatter(node_x(node_0),node_y(node_0),10,'r','filled')
axis equal
end

%% LOOP

while angle_diff<tol_angle && kn<max_nodes
    
    %xy_0: current location
    %xy_1: possible next locations
    
    %debug
    if do_debug
        scatter(node_x(node_1),node_y(node_1),10,'r','filled')
        title(kn)
%         pause
    end
    
    [idx_c_p,~]=ind2sub(sc,find(node_c==node_1)); %next
    % node_c(idx_c_p,:) %next possible nodes

    %remove the one we come from (not needed and super expensive!)
%     idx_c_m1=find(ismember(node_c,[node_0,node_1;node_1,node_0],'rows')); % (really expensive)
%     idx_c_p(idx_c_p==idx_c_m1)=[];

    %get the ones we are not 
    edge_next=node_c(idx_c_p,:); %next possible edges
    node_next=edge_next(edge_next~=node_1);

    np=numel(node_next);
    angle_e_n=NaN(np,1);
    for kp=1:np
        xy_1=[node_x(node_next(kp)),node_y(node_next(kp))];
        angle_aux=angle_polyline([xy_0(1),xy_1(1)],[xy_0(2),xy_1(2)],1);
        angle_e_n(kp)=angle_aux(1);
    end %kp

    angle_diff_v=angle_difference(angle_01,angle_e_n);
    [angle_diff,idx_min]=min(abs(angle_diff_v));
   
    %update
    node_1=node_next(idx_min);
    angle_01=angle_e_n(idx_min);
    xy_0=[node_x(node_1),node_y(node_1)];
    
    node_all=cat(1,node_all,node_1); 

    kn=kn+1;
    fprintf('nodes %04d \n',kn)
end

nodes_xy_mline=[node_x(node_all),node_y(node_all)];
