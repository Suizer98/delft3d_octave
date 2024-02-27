%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18042 $
%$Date: 2022-05-11 21:00:54 +0800 (Wed, 11 May 2022) $
%$Author: chavarri $
%$Id: gdm_read_summerbed.m 18042 2022-05-11 13:00:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_summerbed.m $
%
%Reads summerbed polygons in a shp-file and finds the points of a grid that are
%inside the polygon. 
%
%INPUT:


function sb_def=gdm_read_summerbed(fid_log,fdir_mat,fpath_sb_pol,fpath_map)

messageOut(NaN,'Start reading summer bed polygon')

%% PATHS

fpath_sb_mat=fpath_rkm_sb_bol(fdir_mat,fpath_sb_pol);

%%

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

if exist(fpath_sb_mat,'file')==2
    messageOut(fid_log,sprintf('Loading mat-file with summerbed inpolygon: %s',fpath_sb_mat));
    load(fpath_sb_mat,'sb_def');
    return
end

messageOut(fid_log,sprintf('Mat-file does not exist. Creating.'));

sb_raw=shp2struct(fpath_sb_pol);
sb=polcell2nan(sb_raw.xy.XY);
% sb=[];
% np=numel(sb_raw.xy.XY);
% for kp=1:np
%     sb=cat(1,sb,sb_raw.xy.XY{kp,1}(:,1:2));
% %     sb=cat(1,sb,[NaN,NaN]); %this separates different polygons
% end
is_nan_1=isnan(sb(:,1));
sb(is_nan_1,:)=[];
messageOut(fid_log,'Start finding boundary summer bed.')
idx_b=boundary(sb(:,1),sb(:,2),0.8); %shrink value found by trial and error
sb=sb(idx_b,:);
messageOut(fid_log,'Start finding inpolygon summer bed.')
bol_sb=inpolygon(gridInfo.Xcen,gridInfo.Ycen,sb(:,1),sb(:,2));

%% SAVE

sb_def.bol_sb=bol_sb;
sb_def.sb=sb;

save_check(fpath_sb_mat,'sb_def'); 

end %function 

%% 
%% FUNCTIONS
%%

function fpath_sb_mat=fpath_rkm_sb_bol(fdir_mat,fpath_pol)

[~,fname_pol,~]=fileparts(fpath_pol);
fpath_sb_mat=fullfile(fdir_mat,sprintf('%s.mat',fname_pol));

end %function

