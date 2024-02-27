%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_1D_tim_ave_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_1D_tim_ave_01.m $
%
%

function plot_1D_tim_ave_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

tag_w=sprintf('%s_tim_ave',tag);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig); %we create it in the loop
runid=simdef.file.runid;

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

%% FIG FLAGS

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
% in_p.unit={'qsp','qxsp','qysp'};
%             in_p.gen_struct=gen_struct;
in_p.fig_size=[0,0,14.5,12];

fext=ext_of_fig(in_p.fig_print);

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;
        
%         ktc=0;
        for ktp=1:ntp %time period
            tim_p=flg_loc.tim_ave{ktp};   
            tim_p_str=tim_p;
            if isnan(tim_p) 
                tim_p=time_dnum;
                tim_p_str=tim_p;
                if flg_loc.tim_ave_type==2
                    tim_p_str=time_mor_dnum;
                end
            end
                    
            tim_str=sprintf('%s-%s',datestr(tim_p_str(1),'yyyymmddHHMMSS'),datestr(tim_p_str(end),'yyyymmddHHMMSS'));
            
%             nt=numel(tim_p);
            for kvar=1:nvar %variable
                [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
                    
                %ATTENTION! very weak point. 
                %We loop over the fieldnames (i.e., statistics) of a file containing the statistics of a variable. 
                %E.g., we compute the std of a mean. Not all are computed in the postprocessing, so we cannot load
                %the file without 'statis' and loop over it. 
                statis='val_mean';
                fpath_mat_tmp_w=mat_tmp_name(fdir_mat,tag_w,'tim',tim_p(1),'tim2',tim_p(end),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'stat',statis);
                load(fpath_mat_tmp_w,'data')
                
                fn_data=fieldnames(data);
                nfn=numel(fn_data);

                in_p.tim=[tim_p_str(1),tim_p_str(end)];
                in_p.lab_str=var_str_save;
                in_p.xlims=flg_loc.xlims;

                %loop statistics
                for kfn=1:nfn
                    statis=fn_data{kfn};

                    fpath_mat_tmp_w=mat_tmp_name(fdir_mat,tag_w,'tim',tim_p(1),'tim2',tim_p(end),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'stat',statis);
                    if exist(fpath_mat_tmp_w,'file')~=2
                        messageOut(fid_log,sprintf('Statistics %s for variable %s unavailable',statis,var_str_save))
                        continue
                    end
                    load(fpath_mat_tmp_w,'data')
                    
                    fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,tim_str,var_str_save,statis);
                    mkdir_check(fdir_fig_loc);
                    
                    for kfn2=1:nfn
                        statis2=fn_data{kfn2};
                        
                        if strcmp(statis2,'val_std')
                            in_p.is_std=1;
                        else
                            in_p.is_std=0;
                        end
                        in_p.val=data.(statis2);

                        fname_noext=fig_name(fdir_fig_loc,tag,runid,tim_p(1),tim_p(end),var_str_save,statis,statis2,sb_pol);
    %                     fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                        in_p.fname=fname_noext;

                        fig_1D_01(in_p);
                        messageOut(fid_log,sprintf('Done plotting figure %s rkm poly %4.2f %% time %4.2f %% variable %4.2f %% statistic %4.2f %% statistic %4.2f %%',tag,krkmv/nrkmv*100,ktp/ntp*100,kvar/nvar*100,kfn/nfn*100,kfn2/nfn*100));
                    end
                end %kfn
            end %kvar
        end %ktp
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,time_dnum2,var_str,fn,fn2,sb_pol)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%s_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),datestr(time_dnum2,'yyyymmddHHMM'),var_str,fn,fn2,sb_pol));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function