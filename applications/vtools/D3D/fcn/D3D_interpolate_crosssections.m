%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18353 $
%$Date: 2022-09-08 19:39:21 +0800 (Thu, 08 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_interpolate_crosssections.m 18353 2022-09-08 11:39:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_interpolate_crosssections.m $
%
%Interpolates cross-sections at each computational node. 
%
%INPUT:
%   -path_mdu_ori: path to the mdu-file of the original (hydrodynamic) simulation; char
%   -path_sim_upd: path to the folder of the simulation to update the cross-section definitions and locations files; char

function D3D_interpolate_crosssections(path_mdu_ori,path_sim_upd)

simdef=D3D_simpath_mdu(path_mdu_ori);

path_csdef_ori=simdef.file.csdef;
path_csloc_ori=simdef.file.csloc;
path_map_ori=simdef.file.map;

if exist(path_csdef_ori,'file')==2
    [~,cs_def_ori]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',2);
else
    error('Cannot access file: %s',path_csdef_ori);
end
if exist(path_csloc_ori,'file')==2
    [~,cs_loc_ori]=S3_read_crosssectiondefinitions(path_csloc_ori,'file_type',3);
else
    error('Cannot access file: %s',path_csloc_ori);
end

if any([cs_loc_ori.shift])
    error('You have to rework this function for dealing with a shift.')
end

nelev_cs=max([cs_def_ori.numLevels]); %number of points to interpolate the new elevation 

% nc_info=ncinfo(path_map_ori);
mesh1d_node_offset=ncread(path_map_ori,'mesh1d_node_offset');
mesh1d_node_branch=ncread(path_map_ori,'mesh1d_node_branch');
mesh1d_flowelem_bl=ncread(path_map_ori,'mesh1d_flowelem_bl');
mesh1d_edge_nodes=ncread(path_map_ori,'mesh1d_edge_nodes');

[~,~,str_network1d]=D3D_is(path_map_ori);
network1d_branch_id=ncread(path_map_ori,sprintf('%s_branch_id',str_network1d))';
nb=size(network1d_branch_id,1);
network1d_branch_id_c=cell(nb,1);
for kb=1:nb
    network1d_branch_id_c{kb,1}=strtrim(network1d_branch_id(kb,:));
end

nn=numel(mesh1d_node_branch);

%copy original structure
cs_def_upd=cs_def_ori(1); 
cs_loc_upd=cs_loc_ori(1); 

%reference value
cs_def_ref=cs_def_ori(1); %save it to 

%% loop on branches

F_min=cell(nb,1);
F_max=cell(nb,1);
F_flowWidths=cell(nb,1);
F_totalWidths=cell(nb,1);
for kb=1:nb
    idx_br_loc=find_str_in_cell({cs_loc_ori.branchId},network1d_branch_id_c(kb,1));
    chain=[cs_loc_ori(idx_br_loc).chainage]';
    def_id={cs_loc_ori(idx_br_loc).definitionId};
    idx_br_def=find_str_in_cell({cs_def_ori.id},def_id);
    levels={cs_def_ori(idx_br_def).levels};
    flowWidths={cs_def_ori(idx_br_def).flowWidths};
    totalWidths={cs_def_ori(idx_br_def).totalWidths};

    %sort
    [chain,idx_s]=sort(chain);  %#ok<TRSRT> I want it column for the griddedInterpolant
    levels=levels(idx_s);
%     flowWidths=flowWidths(idx_s);
%     totalWidths=totalWidths(idx_s);

    %interpolation objects minimum elevation for all branches
    min_lev=cellfun(@(X)X(1),levels)';
    F_min{kb,1}=griddedInterpolant(chain,min_lev);

    %interpolation objects maximum elevation for all branches
    max_lev=cellfun(@(X)X(end),levels)';
    F_max{kb,1}=griddedInterpolant(chain,max_lev);

    %interpolation objects x-z-w for all branches
    ncs=numel(levels);
    chain_v=[];
    level_v=[];
    flowWidths_v=[];
    totalWidths_v=[];
    for kcs=1:ncs
        nlev=numel(levels{1,kcs});
        chain_v=cat(1,chain_v,chain(kcs).*ones(nlev,1));
        level_v=cat(1,level_v,levels{1,kcs}');
        flowWidths_v=cat(1,flowWidths_v,flowWidths{1,kcs}');    
        totalWidths_v=cat(1,totalWidths_v,totalWidths{1,kcs}');    
    end
    F_flowWidths{kb,1}=scatteredInterpolant(chain_v,level_v,flowWidths_v,'linear','nearest');
    F_totalWidths{kb,1}=scatteredInterpolant(chain_v,level_v,totalWidths_v,'linear','nearest');
end %kb

%% loop on nodes

for kn=1:nn
    
    %local names
    br_l=strtrim(network1d_branch_id(mesh1d_node_branch(kn)+1,:));
    ch_l=mesh1d_node_offset(kn);
    cs_id_l=cs_name(br_l,ch_l);
    
    [lev_i,relative_levels,flowWidths_i,totalWidths_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths);

    %definition
    cs_def_upd(kn)=cs_def_ref; %copy original
    cs_def_upd(kn).id=cs_id_l; %modify name    
    cs_def_upd(kn).flowWidths=flowWidths_i; 
    cs_def_upd(kn).totalWidths=totalWidths_i;
    cs_def_upd(kn).numLevels=nelev_cs;

    %modify levels
    %the two lines below should be the same. Using the mesh1d_bl we guarantee that it is exactly the same.
    cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; 
%     cs_def_upd(kn).levels=lev_i; 

    %location
    cs_loc_upd(kn).id=cs_id_l;
    cs_loc_upd(kn).branchId=br_l;
    cs_loc_upd(kn).chainage=ch_l;
    cs_loc_upd(kn).shift=0;
    cs_loc_upd(kn).definitionId=cs_id_l;
       
end

%% add CS at bifurcations

us_u=unique(double(mesh1d_edge_nodes(1,:))); %upstream nodes unique
us_count=hist(mesh1d_edge_nodes(1,:),us_u)'; %time a node is upstream node
bol_bif=us_count>1;
idx_bif=us_u(bol_bif);
nbif=sum(bol_bif);

for kbif=1:nbif
    us_node_v=find(mesh1d_edge_nodes(1,:)==idx_bif(kbif));
    nds=numel(us_node_v);
    for kds=1:nds
        idx_ds=mesh1d_edge_nodes(2,us_node_v(kds));
        cs_loc_ds=cs_loc_upd(idx_ds);
        cs_def_ds=cs_def_upd(idx_ds);

        ch_l=0;
        br_l=cs_loc_ds.branchId;
        [lev_i,relative_levels,flowWidths_i,totalWidths_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths);
    
        %add
        kn=kn+1;

        cs_id_l=cs_name(br_l,ch_l);

        %definition
        cs_def_upd(kn)=cs_def_ds; %copy original
        cs_def_upd(kn).id=cs_id_l; %modify name    
        cs_def_upd(kn).flowWidths=flowWidths_i; 
        cs_def_upd(kn).totalWidths=totalWidths_i;
        cs_def_upd(kn).numLevels=nelev_cs;

        %modify levels
        %the two lines below should be the same. We need to extrapolate in this case
%         cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; 
        cs_def_upd(kn).levels=lev_i; 

        %location
        cs_loc_upd(kn).id=cs_id_l;
        cs_loc_upd(kn).branchId=br_l;
        cs_loc_upd(kn).chainage=ch_l;
        cs_loc_upd(kn).shift=0;
        cs_loc_upd(kn).definitionId=cs_id_l;

    end
end %kbif

%% write

simdef.D3D.dire_sim=path_sim_upd;
simdef.csd=cs_def_upd;
simdef.csl=cs_loc_upd;

simdef=D3D_simpath(simdef);
[~,csloc_fname,csloc_ext]=fileparts(simdef.file.csloc);
[~,csdef_fname,csdef_ext]=fileparts(simdef.file.csdef);
D3D_crosssectiondefinitions(simdef,'check_existing',false,'fname',sprintf('%s%s',csdef_fname,csdef_ext));
D3D_crosssectionlocation(simdef,'check_existing',false,'fname',sprintf('%s%s',csloc_fname,csloc_ext));

end %function

%%
%% FUNCTIONS
%%

function [lev_i,relative_levels,flowWidths_i,totalWidths_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths)

idx_br=find_str_in_cell(network1d_branch_id_c,{br_l});

min_lev_i=F_min{idx_br,1}(ch_l); %interpolate minimum elevation
max_lev_i=F_max{idx_br,1}(ch_l); %interpolate maximum elevation

lev_i=linspace(min_lev_i,max_lev_i,nelev_cs)';
relative_levels=cumsum([0;diff(lev_i)]);
flowWidths_i=F_flowWidths{idx_br,1}(ch_l.*ones(nelev_cs,1),lev_i); %interpolate maximum elevation
totalWidths_i=F_totalWidths{idx_br,1}(ch_l.*ones(nelev_cs,1),lev_i); %interpolate maximum elevation

end %funtion

%%

function cs_id_l=cs_name(br_l,ch_l)

cs_id_l=sprintf('br_%s_ch_%7.7f',br_l,ch_l);

end %function