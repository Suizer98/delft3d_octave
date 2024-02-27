%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: pp_sb_var_cum_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/pp_sb_var_cum_01.m $
%
%Postprocessing of summerbed analysis data. Computation of
%cumulative values.

function pp_sb_var_cum_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;
tag_loc=strcat(tag,'_cum');

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

% if isfield(flg_loc,'do_val_B_mor')==0
%     flg_loc.do_val_B_mor=zeros(size(flg_loc.var));
% end

if isfield(flg_loc,'do_cum')==0
    flg_loc.do_cum=zeros(size(flg_loc.var));
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

%         rkm_cen=flg_loc.rkm{krkmv}';
        pol_name=flg_loc.rkm_name{krkmv};

        for kvar=1:nvar %variable
            
            if flg_loc.do_cum(kvar)==0; continue; end
            
            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);

            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag_loc,'pol',pol_name,'var',var_str_save,'sb',sb_pol); 

            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
            
            %preallocate
            kt=kt_v(1);
            fpath_mat_load=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_read,'sb',sb_pol);
            data_raw=load(fpath_mat_load,'data');            
            nx=numel(data_raw.data.val_mean);
            val=NaN(nx,nt);
            val(:,kt)=data_raw.data.val_mean;
            
            kt_v(1)=[]; %we have already done it
            
            ktc=0;
            for kt=kt_v %time
                
                ktc=ktc+1;

                fpath_mat_load=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_read,'sb',sb_pol);
                data_raw=load(fpath_mat_load,'data');
                val(:,kt)=data_raw.data.val_mean;
                
            %% BEGIN DEBUG
%             figure
%             hold on
% %             plot(rkm_cen,val)
%             plot(rkm_cen,val_mean)
            %END DEBUG

            end %kt
            
            %% cum
            tim_p=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum);
            diff_tim=diff(tim_p);
            val_tim=val(:,1:end-1).*reshape(diff_tim,1,[]);
            val_mean=cumsum([zeros(nx,1),val_tim],2);
            
            %% data
            data=v2struct(val_mean); %#ok

            %% save and disp
            save_check(fpath_mat_tmp,'data');
            messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));
        end %kvar
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
