%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_map_1D.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_1D.m $
%
%

function create_mat_map_1D(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

is_straigth=0;
if isfield(flg_loc,'fpath_map_curved')
    is_straigth=1;
end

% if isfield(flg_loc,'write_shp')==0
%     flg_loc.write_shp=0;
% end
% if flg_loc.write_shp==1
%     messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
% end

% %add velocity vector to variables if needed
% if isfield(flg_loc,'do_vector')==0
%     flg_loc.do_vector=zeros(1,numel(flg_loc.var));
% end
% 
% if isfield(flg_loc,'var_idx')==0
%     flg_loc.var_idx=cell(1,numel(flg_loc.var));
% end
% var_idx=flg_loc.var_idx;
% 
% if isfield(flg_loc,'tol')==0
%     flg_loc.tol=1.5e-7;
% end
% tol=flg_loc.tol;

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%take coordinates from curved domain (in case the domain is straightened)
fpath_map_grd=fpath_map; 
if is_straigth
    fpath_map_grd=flg_loc.fpath_map_curved;
end

%% SHP

% if flg_loc.write_shp
%     fpath_poly=fullfile(fdir_mat,'grd_polygons.mat');
%     if exist(fpath_poly,'file')==2
%         load(fpath_poly,'polygons')
%     else        
%         polygons=D3D_grid_polygons(fpath_map);
%         save_check(fpath_poly,'polygons');
%     end
% end

%% DIMENSIONS

nvar=numel(flg_loc.var);
nbr=numel(flg_loc.branch);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRIDS

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map_grd,'dim',1);

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kbr=1:nbr %branches
    
    branch=flg_loc.branch{kbr,1};
    branch_name=flg_loc.branch_name{kbr,1};

    gridInfo_br=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat,gridInfo,branch,branch_name);
    
for kt=kt_v
    ktc=ktc+1;
    for kvar=1:nvar %variable
        
            
        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef);
        
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'branch',branch_name);
%         fpath_shp_tmp=strrep(fpath_mat_tmp,'.mat','.shp');

        do_read=1;
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
            do_read=0;
        end
%         do_shp=0;
%         if flg_loc.write_shp && (exist(fpath_shp_tmp,'file')~=2 || do_read==1)
%             do_shp=1;
%         end

        %% read data
        if do_read
            data_var=gdm_read_data_map_simdef(fdir_mat,simdef,varname,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'idx_branch',gridInfo_br.idx);    
            data=squeeze(data_var.val); %#ok
            save_check(fpath_mat_tmp,'data'); 
        end                
                
        %% shp
%         if do_shp
%             if ~do_read
%                 load(fpath_mat_tmp,'data')
%             end
%             messageOut(fid_log,sprintf('Starting to write shp: %s',fpath_shp_tmp));
%             shapewrite(fpath_shp_tmp,'polygon',polygons,reshape(data,[],1));
% %             messageOut(fid_log,sprintf('Finished to write shp: %s',fpath_shp_tmp)); %next message is sufficient
%         end
        
        %% velocity
%         if flg_loc.do_vector(kvar)
%             gdm_read_data_map_simdef(fdir_mat,simdef,'uv','tim',time_dnum(kt),'sim_idx',sim_idx(kt),'var_idx',var_idx{kvar},'do_load',0);         
%         end
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
        
    end %var
end %kt
end %br

%% SAVE

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%
