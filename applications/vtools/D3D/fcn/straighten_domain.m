%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17102 $
%$Date: 2021-03-03 05:30:16 +0800 (Wed, 03 Mar 2021) $
%$Author: chavarri $
%$Id: straighten_domain.m 17102 2021-03-02 21:30:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/straighten_domain.m $
%
%straighten_domain(file_map,varargin)
%
%INPUT:
%   -file_map = path to the netCDF file with the curved grid [string]
%   
%OPTIONAL:
%   -WriteFile = write netCDF file with straigth grid [boolean]; default = false
%   -polygon   = cell array with paths to the files with polygon(s) to plot
%   on top of grid [cell array]; default = {} (i.e., no polygon) e.g. {'poly_1.pol','poly_2.ldb'}

function straighten_domain(file_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'InitialWaterLevel','');
addOptional(parin,'WriteFiles',false); %write output: 0=NO; 1=YES
addOptional(parin,'polygon',{}); %write output: 0=NO; 1=YES

parse(parin,varargin{:});

file.wl=parin.Results.InitialWaterLevel;
flg.write=parin.Results.WriteFiles;
flg.polygon=parin.Results.polygon;
file.map=file_map;

straight_fact=1000; %straightening factor: it multiplies all y coordinates
straight_fact_exp=1; %power factor: the y coordinate is elevated to a power
max_x_mod_rep=0.10; %distance to shift repeated branches

flg.wl=0; %write water level file: 0=NO; 1=YES
if ~isempty(file.wl)
    flg.wl=1;
    warning('It is better to use map results to interpolate. Check what I did for fractions in IRM project')
end

%% READ

% ncdisp(file.map)

nci=ncinfo(file.map);
var_names={nci.Name};

idx=find_str_in_cell(var_names,{'network1d_geom_x'});
if isnan(idx)
    old_style=1;
    str_network='network';
else
    old_style=0;
    str_network='network1d';
end

network1d_geom_x=ncread(file.map,sprintf('%s_geom_x',str_network));
network1d_geom_y=ncread(file.map,sprintf('%s_geom_y',str_network));
% network1d_branch_order=ncread(file.map,'network1d_branch_order');
% network1d_branch_id=ncread(file.map,sprintf('%s_branch_id',str_network))';
% network1d_branch_long_name=ncread(file.map,'network1d_branch_long_name')';

network1d_geom_node_count=ncread(file.map,sprintf('%s_geom_node_count',str_network));

network1d_edge_nodes=ncread(file.map,sprintf('%s_edge_nodes',str_network)); %Start and end nodes of network edges

network1d_node_id=ncread(file.map,sprintf('%s_node_id',str_network))';
% network1d_node_long_name=ncread(file.map,sprintf('%s_node_long_name',str_network))';
network1d_node_x=ncread(file.map,sprintf('%s_node_x',str_network));
network1d_node_y=ncread(file.map,sprintf('%s_node_y',str_network));

% network1d_geometry=ncread(file.map,'network1d_geometry');
 
if ~isempty(flg.polygon)
   ldb=D3D_read_ldb(flg.polygon);
end

%% MODIFY

%% graph

%in old style the count starts at 0, which is not accepted by digraph
if old_style
    network1d_edge_nodes=network1d_edge_nodes+1;
end
G=digraph(network1d_edge_nodes(1,:),network1d_edge_nodes(2,:));
figure
% plot(G)
% plot(G,'layout','force')
han_G=plot(G,'layout','layered','assignLayers','alap');
print(gcf,'graph.png','-dpng','-r600')
% han_G=plot(G,'layout','layered','assignLayers','asap');
% axis equal

%% straightening

% figure
% han_G=plot(G,'XData',node_x_G_st,'YData',node_y_G_st);
% axis equal

%% get bifurcates at same elevation

node_x_G1=han_G.XData';
node_y_G1=han_G.YData';

%find bifurcations
nn=numel(node_x_G1);
for kn=1:nn
    idx_us=find(network1d_edge_nodes(1,:)==kn);
    nds=numel(idx_us);
    if nds>1
       idx_ds=network1d_edge_nodes(2,idx_us);
       for kds=1:nds
            node_y_G1(idx_ds(kds))=node_y_G1(kn)-1;
       end
    end
end %kn

%% solve points with same coordinates

node_x_G=node_x_G1;
node_y_G=node_y_G1;

cords_aux=[node_x_G,node_y_G];
nco=size(cords_aux,1);
idx_nodes_v=1:1:nco;
[~,idx_u,~]=unique(cords_aux,'rows');
idx_repcord=setdiff(idx_nodes_v,idx_u); %indices of nodes with repeated coordinates
nrepcord=numel(idx_repcord);
node_y_G_m=node_y_G;
for krepcord=1:nrepcord
    %prevent from moving up the nodes with the same coordinate as the
    %repeated one that are destination from that point
    idx_repcord_ds=network1d_edge_nodes(2,network1d_edge_nodes(1,:)==idx_repcord(krepcord));
    idx_l=node_y_G_m'>=node_y_G_m(idx_repcord(krepcord)) & idx_nodes_v~=idx_repcord(krepcord) & idx_nodes_v~=idx_repcord_ds;
    node_y_G_m(idx_l)=node_y_G_m(idx_l)+1;

    idx_l=node_y_G_m'<=node_y_G_m(idx_repcord(krepcord)) & idx_nodes_v~=idx_repcord(krepcord);
    node_y_G_m(idx_l)=node_y_G_m(idx_l)-1;
end
node_y_G=node_y_G_m;

%check uniqueness
cords_aux=[node_x_G,node_y_G];
[~,idx_u,~]=unique(cords_aux,'rows');
ncu=numel(idx_u);
if nco~=ncu
    error('There are points with repeated coordinates')
end

%% modify coordinates

ng=numel(network1d_geom_x); %number of geometry nodes
nb=size(network1d_edge_nodes,2); %number of branches 

network1d_geom_node_count_cs=cumsum(network1d_geom_node_count); %cumulative sum without order

network1d_geom_x_stra=NaN(ng,1);
network1d_geom_y_stra=NaN(ng,1);

idx_g_i=NaN(nb,1);
idx_g_f=NaN(nb,1);

for kb=1:nb
    %initial coordinates of branch in the straightened domain
    x_i=node_x_G(network1d_edge_nodes(1,kb)); 
    y_i=node_y_G(network1d_edge_nodes(1,kb)); 
    
    %final coordinates of branch in the straightened domain
    x_f=node_x_G(network1d_edge_nodes(2,kb)); 
    y_f=node_y_G(network1d_edge_nodes(2,kb)); 
    
    %interpolation
    geom_x=linspace(x_i,x_f,network1d_geom_node_count(kb));
    geom_y=linspace(y_i,y_f,network1d_geom_node_count(kb));
    
    %indices to save coordinates
    idx_g_i(kb)=network1d_geom_node_count_cs(kb)-network1d_geom_node_count(kb)+1;
    idx_g_f(kb)=network1d_geom_node_count_cs(kb);
    
    %save coordinates
    network1d_geom_x_stra(idx_g_i(kb):idx_g_f(kb))=geom_x;
    network1d_geom_y_stra(idx_g_i(kb):idx_g_f(kb))=geom_y;
    
end %kb

%% straighten
%straightening in y because of the graph type we use

network1d_geom_x_stra=network1d_geom_x_stra;
% network1d_geom_y_stra=network1d_geom_y_stra*straight_fact;
network1d_geom_y_stra=(network1d_geom_y_stra.^straight_fact_exp)*straight_fact;

network1d_node_x_stra=node_x_G;
% network1d_node_y_stra=node_y_G*straight_fact;
network1d_node_y_stra=(node_y_G.^straight_fact_exp)*straight_fact;

%%

% figure
% scatter(network1d_geom_x_stra,network1d_geom_y_stra)

%% get rid of repetitions
%this occurs when two branches connect the same nodes

[~,idx_u_aux,~]=unique(network1d_edge_nodes','rows','first');
idx_diff_aux=setdiff((1:size(network1d_edge_nodes,2))',idx_u_aux,'rows');

nbr=numel(idx_diff_aux); %number of repetitions

%loop on repetitions
for kbr=1:nbr
    
    duplicate_edges=network1d_edge_nodes(:,idx_diff_aux(kbr));
    branches_repeated=find(ismember(network1d_edge_nodes',duplicate_edges','rows'));
    nb=numel(branches_repeated); %number of branches connecting the same nodes

    %loop on branches (all but the first)
    for kb=2:nb
        
        %geometry coordinates (at this moment the same for all branches)
        x_br1=network1d_geom_x_stra(idx_g_i(branches_repeated(kb)):idx_g_f(branches_repeated(kb)));
        y_br1=network1d_geom_y_stra(idx_g_i(branches_repeated(kb)):idx_g_f(branches_repeated(kb)));

        dist=compute_distance_along_line([x_br1,y_br1]);
        xadd=max_x_mod_rep*(kb-1)/(dist(end)/2).*dist;
        xadd(dist>dist(end)/2)=-max_x_mod_rep*(kb-1)/(dist(end)/2).*(dist(dist>dist(end)/2)-dist(end)/2)+max_x_mod_rep*(kb-1);

        x_mod=x_br1+xadd;
        y_mod=y_br1;
        
        network1d_geom_x_stra(idx_g_i(branches_repeated(kb)):idx_g_f(branches_repeated(kb)))=x_mod;
        network1d_geom_y_stra(idx_g_i(branches_repeated(kb)):idx_g_f(branches_repeated(kb)))=y_mod;
    end
    
end %nbr

%%

% figure
% scatter(network1d_geom_x_stra,network1d_geom_y_stra)
% axis equal

%% INITIAL WATER LEVEL

if flg.wl
    
%read file
fid=fopen(file.wl,'r');
fstr='%f %f %f';
wl_in_raw=textscan(fid,fstr,'headerlines',0,'delimiter',' ');
fclose(fid);

%map initial water level
wl_i_x=wl_in_raw{1,1};
wl_i_y=wl_in_raw{1,2};
wl_i_v=wl_in_raw{1,3};

nwlp=numel(wl_in_raw{1,1});

wl_o_x=NaN(nwlp,1);
wl_o_y=NaN(nwlp,1);

for kp=1:nwlp
    
    %search geometry point closest to point in xyz
    dist_wl=sqrt((network1d_geom_x-wl_i_x(kp)).^2+(network1d_geom_y-wl_i_y(kp)).^2);
    
    %search in which branch
    [~,idx_cl]=min(abs(dist_wl));
%     idx_int=idx_cl(idx_um);
    a1=network1d_geom_node_count_cs-idx_cl;
    a1(a1<0)=Inf;
    [~,idx_br]=min(a1);
    
    %compute chainage
    br_geom_x=network1d_geom_x(1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br):network1d_geom_node_count_cs(idx_br));
    br_geom_y=network1d_geom_y(1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br):network1d_geom_node_count_cs(idx_br));
    
    npb=numel(br_geom_x);
    br_chain=NaN(npb,1);
    br_chain(1)=0;
    for kpb=2:npb
        br_chain(kpb)=br_chain(kpb-1)+sqrt((br_geom_x(kpb)-br_geom_x(kpb-1))^2+(br_geom_y(kpb)-br_geom_y(kpb-1))^2);
    end %kpb
    
    %
    idx_br_l=idx_cl-(1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br))+1;
    idx_frac=br_chain(idx_br_l)/br_chain(end);
    
    br_geom_x_stra=network1d_geom_x_stra(1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br):network1d_geom_node_count_cs(idx_br));
    br_geom_y_stra=network1d_geom_y_stra(1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br):network1d_geom_node_count_cs(idx_br));
    
    npb=numel(br_geom_x);
    br_chain_stra=NaN(npb,1);
    br_chain_stra(1)=0;
    for kpb=2:npb
        br_chain_stra(kpb)=br_chain_stra(kpb-1)+sqrt((br_geom_x_stra(kpb)-br_geom_x_stra(kpb-1))^2+(br_geom_y_stra(kpb)-br_geom_y_stra(kpb-1))^2);
    end %kpb
    
    br_chain_stra_frac=br_chain_stra./br_chain_stra(end);
    
    [~,idx_pas]=min(abs(idx_frac-br_chain_stra_frac));
    
    idx_gl=idx_pas+1+network1d_geom_node_count_cs(idx_br)-network1d_geom_node_count(idx_br)-1;
    
    wl_o_x(kp)=network1d_geom_x_stra(idx_gl);
    wl_o_y(kp)=network1d_geom_y_stra(idx_gl);
    
%two closest geometry points
%
%     [~,idx_cl]=mink(abs(dist_wl),2);
%     cords_cl=[network1d_geom_x(idx_cl),network1d_geom_y(idx_cl)];
%     [~,idx_um]=unique(cords_cl,'rows');
%     if numel(idx_um)==1
%         [~,idx_cl]=mink(abs(dist_wl),3);
%         cords_cl=[network1d_geom_x(idx_cl),network1d_geom_y(idx_cl)];
%         [~,idx_um]=unique(cords_cl,'rows');
%     end
%     idx_int=idx_cl(idx_um);
%     
%     wl_o_x(kp)=interp1(network1d_geom_x(idx_int),network1d_geom_x_stra(idx_int),wl_i_x(kp),'linear','extrap');
%     wl_o_y(kp)=interp1(network1d_geom_y(idx_int),network1d_geom_y_stra(idx_int),wl_i_y(kp),'linear','extrap');

%closest geometry point
%
%     [~,idx_cl]=min(abs(dist_wl));
%     wl_o_x(kp)=network1d_geom_x_stra(idx_cl);
%     wl_o_y(kp)=network1d_geom_y_stra(idx_cl);
end %nwlp

%%
figure
hold on
scatter(br_geom_x,br_geom_y,10,'xr')
% scatter(wl_i_x,wl_i_y,10,wl_i_v,'filled')
% text(wl_i_x,wl_i_y,num2str(wl_i_v))
axis equal
%%
figure
hold on
scatter(network1d_geom_x,network1d_geom_y,10,'xr')
scatter(wl_i_x,wl_i_y,10,wl_i_v,'filled')
text(wl_i_x,wl_i_y,num2str(wl_i_v))
axis equal
%%
figure
hold on
scatter(network1d_geom_x_stra,network1d_geom_y_stra,10,'xr')
scatter(wl_o_x,wl_o_y,10,wl_i_v,'filled')
text(wl_o_x,wl_o_y,num2str(wl_i_v))
axis equal

end

%% WRITE
    
if flg.write
 
    %% NC
%copy nc
[nc_folder,nc_fname,nc_ext]=fileparts(file.map);
file_nc_straight=fullfile(nc_folder,strcat(nc_fname,'_straight',nc_ext));
copyfile(file.map,file_nc_straight)

ncwrite_class(file_nc_straight,sprintf('%s_geom_x',str_network),network1d_geom_x,network1d_geom_x_stra);
ncwrite_class(file_nc_straight,sprintf('%s_geom_y',str_network),network1d_geom_y,network1d_geom_y_stra);

ncwrite_class(file_nc_straight,sprintf('%s_node_x',str_network),network1d_node_x,network1d_node_x_stra);
ncwrite_class(file_nc_straight,sprintf('%s_node_y',str_network),network1d_node_y,network1d_node_y_stra);

fprintf('Straigth grid is written here: %s \n',file_nc_straight)

    %% water level
    
if flg.wl
    
%file out
[wl_in_folder,wl_in_fname,wl_in_ext]=fileparts(file.wl);
fname_wl_out=fullfile(wl_in_folder,strcat(wl_in_fname,'_straight',wl_in_ext));
fid_out=fopen(fname_wl_out,'w');

fstr_o='%f %f %f \r\n';
for kp=1:nwlp
    fprintf(fid_out,fstr_o,wl_o_x(kp),wl_o_y(kp),wl_i_v(kp));
end

fclose(fid_out); 

end %flg.wl

    %% curvature
% curvature_waal.dist=dist_c;
% curvature_waal.k=k_s;
% curvature_waal.dist=sC0;
% curvature_waal.k=iR0;
% save('curvature_waal.mat','curvature_waal')


end %flg.write

%% PLOT

nn=numel(network1d_node_x);
pos_c=1:1:ng;

%branch midpoint


%% curved, color as position in vector

figure
hold on
scatter(network1d_geom_x,network1d_geom_y,10,pos_c,'filled')
scatter(network1d_node_x,network1d_node_y,50,'xr')
for kn=1:nn
%     text(network1d_node_x(kn),network1d_node_y(kn),network1d_node_long_name(kn,:),'Rotation',45)
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x(kn),network1d_node_y(kn),str_p,'Rotation',45,'Fontsize',10)    
    
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='matrix index';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
axis equal
print(gcf,'curved.png','-dpng','-r600')

%% straight, color as position in vector

figure
hold on
scatter(network1d_geom_x_stra,network1d_geom_y_stra,10,pos_c,'filled')
scatter(network1d_node_x_stra,network1d_node_y_stra,50,'xr')
for kn=1:nn
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x_stra(kn),network1d_node_y_stra(kn),str_p,'Rotation',45,'Fontsize',10)    
end
if ~isempty(flg.polygon)
%    plot(ldb.cord(:,1),ldb.cord(:,2),'*-b')
    patch(ldb.cord(:,1),ldb.cord(:,2),'r','facealpha',0.5)
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='matrix index';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
print(gcf,'straight.png','-dpng','-r600')

%% axis equal

figure
hold on
scatter(network1d_geom_x_stra,network1d_geom_y_stra,10,pos_c,'filled')
scatter(network1d_node_x_stra,network1d_node_y_stra,50,'xr')
for kn=1:nn
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x_stra(kn),network1d_node_y_stra(kn),str_p,'Rotation',45,'Fontsize',10)    
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='matrix index';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
axis equal
print(gcf,'straight_ae.png','-dpng','-r600')

%% water level
if flg.wl

%%
figure
hold on
scatter(wl_i_x,wl_i_y,10,wl_i_v,'filled')
scatter(network1d_node_x,network1d_node_y,50,'xr')
for kn=1:nn
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x(kn),network1d_node_y(kn),str_p,'Rotation',45,'Fontsize',5)    
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='water level [m]';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
axis equal
print(gcf,'wl_curved.png','-dpng','-r600')

%%
figure
hold on
scatter(wl_o_x,wl_o_y,10,wl_i_v,'filled')
scatter(network1d_node_x_stra,network1d_node_y_stra,50,'xr')
for kn=1:nn
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x_stra(kn),network1d_node_y_stra(kn),str_p,'Rotation',45,'Fontsize',5)    
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='water level [m]';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
% axis equal
print(gcf,'wl_straight.png','-dpng','-r600')

%%
figure
hold on
scatter(wl_o_x,wl_o_y,10,wl_i_v,'filled')
scatter(network1d_node_x_stra,network1d_node_y_stra,50,'xr')
for kn=1:nn
    str_p=strrep(network1d_node_id(kn,:),'_',' ');
    text(network1d_node_x_stra(kn),network1d_node_y_stra(kn),str_p,'Rotation',45,'Fontsize',1)    
end
han.cbar=colorbar;
han.cbar.Location='Northoutside';
han.cbar.Label.String='water level [m]';
xlabel('x coordinate [m]')
ylabel('y coordinate [m]')
axis equal
print(gcf,'wl_straight_ae.png','-dpng','-r600')

end

%%
%%
%%

% axis equal

% %% curved, curvature
% 
% figure
% hold on
% % scatter(x_c,y_c,10,1./k,'filled')
% scatter(x_c,y_c,10,1./k_s,'filled')
% scatter(network1d_node_x,network1d_node_y,50,'xr')
% for kn=1:nn
% %     text(network1d_node_x(kn),network1d_node_y(kn),num2str(kn))
%     text(network1d_node_x(kn),network1d_node_y(kn),network1d_node_long_name(kn,:),'Rotation',45)
%     
% end
% colorbar
% clim([0,7000])
% axis equal
% 
% %% radius curvature check
% 
% figure 
% hold on
% plot(dist_c,1./k,'r')
% plot(dist_c,1./k_s,'b')
% plot(sC0, iR0,'g')
% ylim([0,7000])
% 
% %% curvature check
% 
% figure 
% hold on
% plot(dist_c,k,'r')
% plot(dist_c,k_s,'b')
% plot(sC0, abs(iR0),'g')
% % ylim([0,7000])



