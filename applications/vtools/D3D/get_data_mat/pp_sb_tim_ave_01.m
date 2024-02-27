%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18406 $
%$Date: 2022-10-06 11:31:35 +0800 (Thu, 06 Oct 2022) $
%$Author: chavarri $
%$Id: pp_sb_tim_ave_01.m 18406 2022-10-06 03:31:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/pp_sb_tim_ave_01.m $
%
%

function pp_sb_tim_ave_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;
tag_w=sprintf('%s_tim_ave',tag);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag_w); if ret; return; end

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

if isfield(flg_loc,'overwrite_ave')==0
    flg_loc.overwrite_ave=flg_loc.overwrite;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_loc=fullfile(fdir_mat,sprintf('%s.mat',tag_w));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef.file.fig.dir,tag);
% mkdir_check(fdir_fig); %we create it in the loop
% runid=simdef.file.runid;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat_loc,'overwrite_ave'); if ret; return; end

%% LOAD

% create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSION

% nt=size(time_dnum,1);
ntp=numel(flg_loc.tim_ave);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        
        ktc=0;
        for ktp=1:ntp %time period
            tim_p=flg_loc.tim_ave{ktp};           
            if isnan(tim_p) 
                tim_p=time_dnum;
                flg_loc.tim_ave_type=1; %if we want all times, it does not matter which type of time we request. We match flow time. 
            end
            
            tim_p_diff=diff(cen2cor(tim_p));
            tim_p_tot=sum(tim_p_diff);
            
            nt=numel(tim_p);
            for kvar=1:nvar %variable
                [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
                
                %allocate
                kt=1;
                tim_p_loc=tim_p(kt);
                if flg_loc.tim_ave_type==2
                    idx_m=absmintol(time_mor_dnum,tim_p_loc,'tol',tol_tim,'dnum',1);
                    tim_p_loc=time_dnum(idx_m); %flow time associated to the objective morpho time
                end
            
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',tim_p_loc,'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                load(fpath_mat_tmp,'data');
                
                fn_data=fieldnames(data);
                nfn=numel(fn_data);
                
                kfn=1;
                statis=fn_data{kfn};
                npoints=numel(data.(statis));
                
                for kfn=1:nfn
                    statis=fn_data{kfn};
                    val_p.(statis)=NaN(npoints,nt);
                end
                
                %add first values
                for kfn=1:nfn
                    statis=fn_data{kfn};
                    val_p.(statis)(:,kt)=data.(statis);
                end
                
                %loop on time
                for kt=2:nt %time

                    tim_p_loc=tim_p(kt);
                    if flg_loc.tim_ave_type==2
                        idx_m=absmintol(time_mor_dnum,tim_p_loc,'tol',tol_tim,'dnum',1);
                        tim_p_loc=time_dnum(idx_m); %flow time associated to the objective morpho time
                    end
                
                    ktc=ktc+1;

                    [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));

                    %load
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',tim_p_loc,'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                    load(fpath_mat_tmp,'data');
                    
                    %fill matrix with values for all times
                    for kfn=1:nfn
                        statis=fn_data{kfn};
                        val_p.(statis)(:,kt)=data.(statis);
                    end %kfn
                end %kt
                
                %compute statistics in time
                for kfn=1:nfn
                    
                    statis=fn_data{kfn};

                    %The name is not unique enough. There can be two periods with the same begin and end. 
                    fpath_mat_tmp_w=mat_tmp_name(fdir_mat,tag_w,'tim',tim_p(1),'tim2',tim_p(end),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'stat',statis);

                    if exist(fpath_mat_tmp_w,'file')==2 && ~flg_loc.overwrite_ave ; continue; end

                    val_mean=sum(val_p.(statis).*tim_p_diff,2)./tim_p_tot;
%                     val_std=std(val_p.(statis),0,2);
                    val_std=sqrt(var(val_p.(statis),tim_p_diff,2));
                    val_max=max(val_p.(statis),[],2);
                    val_min=min(val_p.(statis),[],2);

                    %data
                    data=v2struct(val_mean,val_std,val_max,val_min); %#ok

                    %save
                    save_check(fpath_mat_tmp_w,'data');
                    
                    %cumulative in time mean
%                     if strcmp(statis,'val_mean')
%                         a=1;
%                     end
                    
                end %kfn
                
                %disp
                messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% variable %4.2f %%',tag_w,ksb/nsb*100,krkmv/nrkmv*100,kvar/nvar*100));
            end %kvar
        end %ktp
    end %nrkmv
end %ksb

%% SAVE

%only dummy for preventing passing through the function if not overwriting
data=NaN;
save(fpath_mat_loc,'data')


end %function



%% 
%% FUNCTION
%%
