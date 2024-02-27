%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: pp_sb_var_01.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/pp_sb_var_01.m $
%
%Postprocessing of summerbed analysis data for each time.

function pp_sb_var_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_val_B_mor')==0
    flg_loc.do_val_B_mor=zeros(size(flg_loc.var));
end
if isfield(flg_loc,'do_val_B')==0
    flg_loc.do_val_B=zeros(size(flg_loc.var));
end
if any(flg_loc.do_val_B_mor & flg_loc.do_val_B)
    error('either full width or morphodynamic width')
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% MEASUREMENTS
        
%% OVERWRITE

% ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat,'overwrite_tim'); if ret; return; end

%% LOAD TIME

[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% CONSTANT IN TIME


%% DIMENSION

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);

%% LOOP

ktc=0;
krkmv=0;
kvar=0;
ksb=0;
messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);
    
    for krkmv=1:nrkmv %rkm polygons

        rkm_cen=flg_loc.rkm{krkmv}';
        pol_name=flg_loc.rkm_name{krkmv};

        ktc=0;
        for kt=kt_v %time
            ktc=ktc+1;
                 
            for kvar=1:nvar %variable
                [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
                
                if flg_loc.do_val_B_mor(kvar)
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',sprintf('%s_B_mor',var_str_save),'sb',sb_pol);
                elseif flg_loc.do_val_B(kvar)
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',sprintf('%s_B',var_str_save),'sb',sb_pol);
                else
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol); %the variable to save is different than the raw variable name we read
                end
                
                if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

                fpath_mat_load=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_read,'sb',sb_pol);
                data_raw=load(fpath_mat_load,'data');
                val=data_raw.data.val_mean;

                switch var_id
                    case 'detab_ds'
                        dx=diff(rkm_cen*1000);
                        detab_dx=NaN(size(val));
                        detab_dx(2:end-1)=(val(3:end)-val(1:end-2))./(dx(1:end-1)+dx(2:end));
                        
                        val_mean=detab_dx; 
                    otherwise
                        if flg_loc.do_val_B_mor(kvar) %multiply value by morphodynamic width
                            fpath_mat_load=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var','ba_mor','sb',sb_pol);
                            data_ba_mor=load(fpath_mat_load,'data');
                            val_mean=val.*data_ba_mor.data.val_sum_length;
                        elseif flg_loc.do_val_B(kvar) %multiply value per width
                            fpath_mat_load=gdm_map_summerbed_mat_name('ba',fdir_mat,tag,pol_name,time_dnum(kt),sb_pol);
                            data_ba=load(fpath_mat_load,'data');
                            val_mean=val.*data_ba.data.val_sum_length;
                        else
                            continue
                        end
                end
                
                %% data
                data=v2struct(val_mean); %#ok

                %% save and disp
                save_check(fpath_mat_tmp,'data');
                messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

            %% BEGIN DEBUG
%             figure
%             hold on
% %             plot(rkm_cen,val)
%             plot(rkm_cen,val_mean)
            %END DEBUG

            end %kvar
        end %kt    
    end %nrkmv
end %ksb

%% SAVE

%only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%
