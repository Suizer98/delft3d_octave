%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: NC_read_map_get_fm1d_data.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map_get_fm1d_data.m $
%
%

function out=NC_read_map_get_fm1d_data(tag_read,file_map,in,branch,offset,x_node,y_node,branch_length,branch_id)

kf=in.kf;
kt=in.kt;

%it does not matter whether it is nodes or edges
switch tag_read
    case {'mesh1d_flowelem_bl','mesh1d_flowelem_ba','mesh1d_mor_width_u','mesh1d_node_offset'} %{s}
        wl=ncread(file_map,tag_read,1,Inf);
    case {'mesh1d_sbcx','mesh1d_sbcy','mesh1d_sbcx_reconstructed','mesh1d_sbcy_reconstructed','mesh1d_sscx_reconstructed','mesh1d_sscy_reconstructed','mesh1d_sbn','mesh1d_sbt'} %{s,f,t}
        wl=ncread(file_map,tag_read,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_waterdepth','mesh1d_s1','mesh1d_umod','mesh1d_mor_bl','mesh1d_q1_main','mesh1d_q1','mesh1d_dm','mesh1d_ucmag','mesh1d_dg','mesh1d_bl_ave','mesh1d_czs','mesh1d_taus'} %mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,kt(2)]);
    case {'mesh1d_lyrfrac'} %mesh1d_nNodes,nBedLayers,nSedTot,time
        wl=ncread(file_map,tag_read,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    case {'mesh1d_thlyr'} %nBedLayers,mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_msed'} %nSedTot,nBedLayers,mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    otherwise
        error('indicate for %s variable what the size is',tag_read)
end

[wl_br,o_br,cord_br]=NC_read_map_get_data_from_branches(wl,in,branch,offset,x_node,y_node,branch_length,branch_id);

%output
out.z=wl_br;
out.XZ=cord_br(:,1);
out.YZ=cord_br(:,2);
out.SZ=o_br;

%convert to river km
if isfield(in,'path_rkm')
    rkm_br=convert2rkm(in.path_rkm,cord_br,'TolMinDist',in.rkm_TolMinDist);
    out.SZ=rkm_br;
end

end %function