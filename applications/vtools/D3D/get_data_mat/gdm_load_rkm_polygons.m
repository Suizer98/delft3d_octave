%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18395 $
%$Date: 2022-09-29 12:32:50 +0800 (Thu, 29 Sep 2022) $
%$Author: chavarri $
%$Id: gdm_load_rkm_polygons.m 18395 2022-09-29 04:32:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_rkm_polygons.m $
%
%

function data=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name)

%%

fpath_rkm_pol=mat_tmp_name(fdir_mat,tag,'pol',rkm_name);
if exist(fpath_rkm_pol,'file')==2 %&& ~flg_loc.overwrite 
    load(fpath_rkm_pol,'data')
    return
end

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

rkm_edg=cen2cor(rkm_cen)';
rkm_dx=diff(rkm_edg);
%     rkm_edg_br=maas_branches(rkm_edg); %cannot call this function here
rkm_edg_br=cat(1,rkm_cen_br,rkm_cen_br{end}); %this is not good enough. It may be that an edge point falls in a different branch name

rkm_edg_xy=convert2rkm(fpath_rkm,rkm_edg,rkm_edg_br);
rkm_cen_xy=convert2rkm(fpath_rkm,rkm_cen,rkm_cen_br);
[rkm_edg_xy_L,rkm_edg_xy_R]=perpendicular_polyline(rkm_edg_xy,2,1000); %lines 1000 m to the right and left of the centre. Make the step an input.
npol=numel(rkm_cen);
bol_pol_loc=cell(npol,1);
for kpol=1:npol
    pol_loc=[[rkm_edg_xy_L(kpol:kpol+1,1);flipud(rkm_edg_xy_R(kpol:kpol+1,1));rkm_edg_xy_L(kpol,1)],[rkm_edg_xy_L(kpol:kpol+1,2);flipud(rkm_edg_xy_R(kpol:kpol+1,2));rkm_edg_xy_L(kpol,2)]];

    bol_pol_loc{kpol,1}=inpolygon(gridInfo.Xcen,gridInfo.Ycen,pol_loc(:,1),pol_loc(:,2));
%             %% BEGIN DEBUG
%             figure; hold on; plot(pol_loc(:,1),pol_loc(:,2),'-*')
%             % END DEBUG
end
data=v2struct(bol_pol_loc,rkm_cen,rkm_edg,rkm_cen_br,rkm_edg_br,rkm_edg_xy,rkm_cen_xy,rkm_edg_xy_L,rkm_edg_xy_R,rkm_dx); %#ok
save_check(fpath_rkm_pol,'data');

