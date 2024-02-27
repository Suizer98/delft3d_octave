%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: create_grid_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_grid_01.m $
%
%

function create_grid_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'write_shp')==0
    flg_loc.write_shp=0;
end
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_grd_mat=fullfile(fdir_mat,'grd.mat');

%% get map from grid

if exist(fpath_grd_mat,'file')
    return
end

if isfield(simdef.file,'map')==0 %there is no map file
    fpath_map=fullfile(fdir_mat,'grid_map.nc');
    D3D_grd2map(simdef.file.grd,'fpath_map',fpath_map);
    simdef.file.map=fpath_map;
end
fpath_map=gdm_fpathmap(simdef,0);

%% SHP

if flg_loc.write_shp
    fpath_poly=fullfile(fdir_mat,'grd_polygons.mat');
    if exist(fpath_poly,'file')==2
        load(fpath_poly,'polygons')
    else        
        polygons=D3D_grid_polygons(fpath_map);
        save_check(fpath_poly,'polygons');
    end
end

%% GRID

gdm_load_grid(fid_log,fdir_mat,fpath_map,'do_load',0);
% gdm_load_grid_simdef(fid_log,simdef,'do_load',0); %don't call, because we have to pass the grd-file

%% shp
if flg_loc.write_shp
    error('do')
%     EHY_convert(fpath_grd
end


%% SAVE

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

        %% JOIN

        %if creating files in parallel, another instance may have already created it.
        %
        %Not a good idea because of the overwriting flag. Maybe best to join it several times.
        %
        % if exist(fpath_mat,'file')==2
        %     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
        %     return
        % end

        % data=struct();

        %% first time for allocating

%         kt=1;
%         fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%         tmp=load(fpath_mat_tmp,'data');
% 
%         %constant
% 
%         %time varying
%         nF=size(tmp.data.q_mag,2);
% 
%         q_mag=NaN(nt,nF);
%         q_x=NaN(nt,nF);
%         q_y=NaN(nt,nF);
% 
%         %% loop 
% 
%         for kt=1:nt
%             fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%             tmp=load(fpath_mat_tmp,'data');
% 
%             q_mag(kt,:)=tmp.data.q_mag;
%             q_x(kt,:)=tmp.data.q_x;
%             q_y(kt,:)=tmp.data.q_y;
% 
%         end
% 
%         data=v2struct(q_mag,q_x,q_y); %#ok
%         save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
