%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18149 $
%$Date: 2022-06-13 12:50:33 +0800 (Mon, 13 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_pol_bol_grd.m 18149 2022-06-13 04:50:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_pol_bol_grd.m $
%
%

function [bol_grd,pol_name]=gdm_pol_bol_grd(fid_log,flg_loc,simdef,fpath_pol)
    
%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% CALC

fdir_mat=simdef.file.mat.dir;

[pol,pol_name]=gdm_read_pol(fpath_pol);
fpath_bol=mat_tmp_name(fdir_mat,'bol_grd','pol',pol_name);
if exist(fpath_bol,'file')==2 && ~flg_loc.overwrite
    messageOut(fid_log,sprintf('Polygon grd-boolean exists: %s',fpath_bol));
    load(fpath_bol,'bol_grd')
else
    messageOut(fid_log,sprintf('Doing inpolygon for: %s',fpath_pol));
%     if numel(pol.val)>1
    if numel(pol)>1
        error('Only one polygon per input file accepted: %s',fpath_pol);
    end
    create_mat_grd(fid_log,flg_loc,simdef)
    load(simdef.file.mat.grd,'gridInfo')
%     bol_grd=inpolygon(gridInfo.Xcen,gridInfo.Ycen,pol.val{1,1}(:,1),pol.val{1,1}(:,2)); 
    bol_grd=inpolygon(gridInfo.Xcen,gridInfo.Ycen,pol.xy(:,1),pol.xy(:,2)); 
    save_check(fpath_bol,'bol_grd');
end

end %function