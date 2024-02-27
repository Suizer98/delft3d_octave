%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_his_obs_01.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_obs_01.m $
%
%

function create_mat_his_obs_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

% if isfield(flg_loc,'write_shp')==0
%     flg_loc.write_shp=0;
% end

where_obs=1; %default is from <ObsFile> in mdu
if isfield(flg_loc,'fpath_obs_plot')==1
    where_obs=2;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));

%% DIMENSIONS


%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% OBSERVATION STATIONS

switch where_obs
    case 1
        obs=D3D_io_input('read',simdef.file.obsfile,'version',2);
        do_all=num2cell(ones(numel(obs),1));
        [obs.do_plot]=do_all{:};
        [obs.do_label]=do_all{:};
    case 2
        obs_num=readmatrix(flg_loc.fpath_obs_plot,'FileType','text','delimiter',',');
        obs_nam=readcell(flg_loc.fpath_obs_plot,'FileType','text','delimiter',',');
        
        obs=struct('name',obs_nam(:,3),'xy',num2cell(obs_num(:,1:2),2),'do_plot',num2cell(obs_num(:,4)),'do_label',num2cell(obs_num(:,5)));
end

%clean names
nobs=numel(obs);
for kobs=1:nobs
    obs(kobs).name=strtrim(deblank(strrep(obs(kobs).name,'''','')));
end

%% CROSS SECTIONS

crs=struct('name',{''},'xy',{[]});
nobsf=numel(simdef.file.crsfile);
for kobsf=1:nobsf
    crs_loc=D3D_io_input('read',simdef.file.crsfile{1,kobsf});
    crs=[crs,crs_loc];
end
%remove first
crs(1)=[];
%clean names
ncrs=numel(crs);
for kcrs=1:ncrs
    crs(kcrs).name=strtrim(deblank(strrep(crs(kcrs).name,'''','')));
end

%% SAVE

data.obs=obs;
data.crs=crs;

save_check(fpath_mat,'data'); %#ok

end %function

%% 
%% FUNCTION
%%
