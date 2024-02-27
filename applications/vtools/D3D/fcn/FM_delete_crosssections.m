%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: FM_delete_crosssections.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/FM_delete_crosssections.m $
%
%Deletes cross-sections from an FM1D simulation that are too far from a
%computational node.

function [csloc_in,cs]=FM_delete_crosssections(path_net,path_csloc,varargin)

%% INPUT

tol=1e-3; %tolerance for accepting cross-section at node

%% READ

%read net
node_offset=ncread(path_net,'mesh1d_node_offset');
node_branch=ncread(path_net,'mesh1d_node_branch');
branch_id=ncread(path_net,'network1d_branch_id')';

%read csloc
[csloc_in,cs]=S3_read_crosssectiondefinitions(path_csloc,'file_type',3);

%% loop on network1s 
nn=numel(node_offset);
cs_get=struct('id','a','branchId','a','chainage',NaN,'shift',NaN,'definitionId','a'); %this is a shitty way to preallocate
min_dist=NaN(nn,1);
for kn=1:nn
    br_loc=deblank(branch_id(node_branch(kn),:));
    chain_loc=node_offset(kn);
    
    br_loc_idx=strcmp({cs.branchId},br_loc);
    cs_loc=cs(br_loc_idx);
    chain_br=[cs_loc.chainage];
    
    [chain_min,chain_min_idx]=min(abs(chain_br-chain_loc));
    
    cs_get(kn)=cs_loc(chain_min_idx);
    min_dist(kn)=chain_min;
    if chain_min>tol
        cs_get(kn).chainage=chain_loc;
    end

end %nn

%% add first and last if not there

nb=size(branch_id,1);
kn=nn;
for kb=1:nb
    br_loc=deblank(branch_id(kb,:));
    
    br_loc_idx=strcmp({cs.branchId},br_loc);
    cs_loc=cs(br_loc_idx);
    chain_br=[cs_loc.chainage];
    
    %first
    [~,chain_min_idx]=min(chain_br);
    idx_first=strcmp({cs_get.id},cs_loc(chain_min_idx).id);
    if ~any(idx_first)
       cs_get(kn+1)=cs_loc(chain_min_idx);
       kn=kn+1;
    end

    %last
    [~,chain_min_idx]=max(chain_br);
    idx_first=strcmp({cs_get.id},cs_loc(chain_min_idx).id);
    if ~any(idx_first)
       cs_get(kn+1)=cs_loc(chain_min_idx);
       kn=kn+1;
    end
end

%% write cross-section locations

npw=numel(cs_get);
cs_write=cell(1,1);
kl=1;
cs_write{kl,1}='[General]                             ';kl=kl+1;
cs_write{kl,1}='    fileVersion           = 1.01      ';kl=kl+1;
cs_write{kl,1}='    fileType              = crossLoc  ';kl=kl+1;  
cs_write{kl,1}='';kl=kl+1;

for kcs=1:npw
cs_write{kl,1}='[CrossSection]                            ';kl=kl+1;
cs_write{kl,1}=sprintf('    id                    = #%s#  ',cs_get(kcs).id);kl=kl+1;
cs_write{kl,1}=sprintf('    branchId              = #%s#  ',cs_get(kcs).branchId);kl=kl+1;
cs_write{kl,1}=sprintf('    chainage              = %5.3f ',cs_get(kcs).chainage);kl=kl+1;              
cs_write{kl,1}=sprintf('    shift                 = %5.3f ',cs_get(kcs).shift);kl=kl+1;              
cs_write{kl,1}=sprintf('    definitionId          = #%s#  ',cs_get(kcs).definitionId);kl=kl+1;
cs_write{kl,1}='';kl=kl+1;
end

%write
writetxt('CrossSectionLocations_mod.ini',cs_write,'check_existing',false);

%% PLOT

nxp=1:1:nn;

figure
hold on
plot(nxp,min_dist)
scatter(nxp(min_dist>tol),min_dist(min_dist>tol))

