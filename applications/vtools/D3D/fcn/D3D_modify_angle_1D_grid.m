%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18003 $
%$Date: 2022-04-29 12:24:09 +0800 (Fri, 29 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_modify_angle_1D_grid.m 18003 2022-04-29 04:24:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_modify_angle_1D_grid.m $
%
%Change the location of a geometry node in a 1D network. Given a 
%grid, a node (either by its name or its index) and the new
%coordinates of the node (either in cartesian or polar system)
%a new grid is created with the modified geometry. 
%
%INPUT:
%   -fpath_grd_in = full path of the original network
%
%PAIR INPUT
%   Node to be modified.
%       Option 1:
%           -'node_idx' = index of the geometry-node to be modified as in variable <network1d_geom_x> and <network1d_geom_x>; double(1,1)
%       Option 2:
%           -'node_name' = id of the node to be modified as in variable <network1d_node_id>; char
%   Coordinates of the modified node
%       Option 1:
%           -'xy' = cartesian coordinates of the node; double(1,2)
%       Option 2:
%           -'phirad' = radius and angle in degrees of the polar coordinates; double(1,2)
%
%OPTIONAL (as pair input)
%   -'fpath_grd_out' = full path of the modified grid. Default is in the same folder and name plus string '_mod' added. 
%
%E.G.:
% fpath_grd_in='FlowFM_net.nc';
% node_name='Node003_Waal';
% phirad=[185,100000];
% D3D_modify_angle_1D_grid(fpath_grd_in,'node_name',node_name,'phirad',phirad)

function D3D_modify_angle_1D_grid(fpath_grd_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'xy',[]);
addOptional(parin,'phirad',[]);
addOptional(parin,'node_name',{});
addOptional(parin,'node_idx',[]);
addOptional(parin,'fpath_grd_out','');

parse(parin,varargin{:})

xy=parin.Results.xy;
phirad=parin.Results.phirad;
node_name=parin.Results.node_name;
node_idx=parin.Results.node_idx;
fpath_grd_out=parin.Results.fpath_grd_out;

%type_in_cord
type_in_cord=1;
if isempty(xy)
    type_in_cord=2;
end
if isempty(phirad) && type_in_cord==2
    error('input must be either ''xy'' or ''phirad''')
end

%type_out_cord
type_out_cord=1;
if isempty(node_idx)
    type_out_cord=2;
end
if isempty(node_name) && type_out_cord==2
    error('input must be either ''node_name'' or ''node_idx''')
end
    %make a cell array
if ischar(node_name) 
    node_name={node_name};
end

%fpath_grd_out
if isempty(fpath_grd_out)
    fpath_grd_out=strrep(fpath_grd_in,'.nc','_mod.nc');
end

%% CALC

%% read

[~,~,str_network1d,~]=D3D_is(fpath_grd_in);

network1d_geom_x=ncread(fpath_grd_in,sprintf('%s_geom_x',str_network1d));
network1d_geom_y=ncread(fpath_grd_in,sprintf('%s_geom_y',str_network1d));

network1d_node_x=ncread(fpath_grd_in,sprintf('%s_node_x',str_network1d));
network1d_node_y=ncread(fpath_grd_in,sprintf('%s_node_y',str_network1d));

%% convert to x-y
switch type_in_cord
    case 1 %x-y is given
        x=xy(1);
        y=xy(2);
    case 2 %phi-rad is given
        phi_deg=phirad(1);
        rad=phirad(2);
        phi=phi_deg*2*pi/360; %angles
        [x,y]=pol2cart(phi,rad);
end


%% convert to coordinate of the index
switch type_out_cord
    case 1 %idx is given
        idx_geom_mod=node_idx;
        
        xy_geom=[network1d_geom_x(idx_geom_mod),network1d_geom_y(idx_geom_mod)];
        [min_val,idx_node_mod]=min(sqrt(sum((xy_geom-[network1d_node_x,network1d_node_y]).^2,2)));
        if min_val>1e-8
            error('something weird is happening')
        end
    case 2 %name of node is given
        network1d_node_id=ncread(fpath_grd_in,sprintf('%s_node_id',str_network1d))';
        idx_node_mod=get_branch_idx(node_name,network1d_node_id);

        xy_node=[network1d_node_x(idx_node_mod),network1d_node_y(idx_node_mod)];
        [min_val,idx_geom_mod]=min(sqrt(sum((xy_node-[network1d_geom_x,network1d_geom_y]).^2,2)));
        if min_val>1e-8
            error('something weird is happening')
        end
%     case 3 %coordinate of node is given?
%         idx_geom_mod=4; %index of the coordinate of the point to modify
end

network1d_geom_x(idx_geom_mod)=x;
network1d_geom_y(idx_geom_mod)=y;

network1d_node_x(idx_node_mod)=x;
network1d_node_y(idx_node_mod)=y;

%% copy and write

copyfile(fpath_grd_in,fpath_grd_out)

%geometry: this is the only one that matters for changing the grid
ncwrite(fpath_grd_out,sprintf('%s_geom_x',str_network1d),network1d_geom_x);
ncwrite(fpath_grd_out,sprintf('%s_geom_y',str_network1d),network1d_geom_y);

%node
ncwrite(fpath_grd_out,sprintf('%s_node_x',str_network1d),network1d_node_x);
ncwrite(fpath_grd_out,sprintf('%s_node_y',str_network1d),network1d_node_y);

%% PLOT

% figure
% scatter(network1d_geom_x,network1d_geom_y)

end %function