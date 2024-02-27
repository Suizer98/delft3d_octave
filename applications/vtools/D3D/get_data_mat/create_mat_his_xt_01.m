%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18332 $
%$Date: 2022-08-23 22:45:22 +0800 (Tue, 23 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_his_xt_01.m 18332 2022-08-23 14:45:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_xt_01.m $
%
%

function create_mat_his_xt_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

switch simdef.D3D.structure
    case 2
        model_type_str='dfm';
    case 3
        model_type_str='sobek3';
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef.file.his;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

%2DO make this inside actually reading the grid and ouput <no_layers>=1. Repeat in <plot>
if simdef.D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end
[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his,fdir_mat);

%% DIMENSIONS

nvar=numel(flg_loc.var);
ntr=numel(flg_loc.stations_track);

%% CONSTANT IN TIME

%% LOOP

% ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ntr*100));

for ktr=1:ntr
    flg_loc.stations=flg_loc.stations_track{ktr};
    stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef.D3D.structure);
%     ns=numel(stations);
    ksc=ksc+1;
    for kvar=1:nvar

        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef);

        %loop over stations and get data of each layer, etcetera. See RMM3D21
    %         layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
        layer=1;

        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'var',var_str,'layer',layer,'station',flg_loc.stations_track_name{ktr});

        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

        %% read data

        %2DO make a function that reworks the data if necessary
        data_raw=EHY_getmodeldata(fpath_his,stations,model_type_str,'varName',var_str,'layer',layer,'t0',time_dnum(1),'tend',time_dnum(end));

        %save_check(fpath_mat_tmp,'data_raw');

        %% calc

        data=data_raw.val; %#ok

        %% save and disp
        save_check(fpath_mat_tmp,'data');
        messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ntr*100));

        %% BEGIN DEBUG

        %END DEBUG
    end %kvar
end %kss

end %function

%% 
%% FUNCTION
%%
