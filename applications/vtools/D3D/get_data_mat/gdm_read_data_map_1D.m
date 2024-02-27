%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_1D.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_1D.m $
%
%

function z=gdm_read_data_map_1D(fpath_map,varname,idx_branch,idx_tim)

kt=[idx_tim,1]; %[start, counter];

%it does not matter whether it is nodes or edges
switch varname
    case {'mesh1d_flowelem_bl','mesh1d_flowelem_ba','mesh1d_mor_width_u','mesh1d_node_offset'} %{s}
        wl=ncread(fpath_map,varname,1,Inf);
    case {'mesh1d_sbcx','mesh1d_sbcy','mesh1d_sbcx_reconstructed','mesh1d_sbcy_reconstructed','mesh1d_sscx_reconstructed','mesh1d_sscy_reconstructed','mesh1d_sbn','mesh1d_sbt'} %{s,f,t}
        wl=ncread(fpath_map,varname,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_waterdepth','mesh1d_s1','mesh1d_umod','mesh1d_mor_bl','mesh1d_q1_main','mesh1d_q1','mesh1d_dm','mesh1d_ucmag','mesh1d_dg','mesh1d_bl_ave','mesh1d_czs','mesh1d_taus'} %mesh1d_nNodes,time
        wl=ncread(fpath_map,varname,[1,kt(1)],[Inf,kt(2)]);
    case {'mesh1d_lyrfrac'} %mesh1d_nNodes,nBedLayers,nSedTot,time
        wl=ncread(fpath_map,varname,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    case {'mesh1d_thlyr'} %nBedLayers,mesh1d_nNodes,time
        wl=ncread(fpath_map,varname,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_msed'} %nSedTot,nBedLayers,mesh1d_nNodes,time
        wl=ncread(fpath_map,varname,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    otherwise
        error('indicate for %s variable what the size is',varname)
end

nb=max(idx_branch);
% np=sum(idx_branch~=0);
% z=NaN(np,1);
z=[];
for kb=1:nb
    z=cat(1,z,wl(idx_branch==kb)); %we could preallocate...
end

end %function