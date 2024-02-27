%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_map_1D_xv_diff_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_1D_xv_diff_01.m $
%
%

function plot_map_1D_xv_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

if contains(tag_fig,'all')
    tag_do='do_s_all';
else
    tag_do='do_s';
end
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

is_straigth=0;
if isfield(flg_loc,'fpath_map_curved')
    is_straigth=1;
end

do_rkm=0;
if isfield(flg_loc,'fpath_rkm')
    do_rkm=1;
end

%add if necessary
% if isfield(flg_loc,'do_s_xtv')==0
%     flg_loc.do_s_xtv=1;
% end
% 
% if isfield(flg_loc,'do_s_p')==0
%     flg_loc.do_s_p=1;
% end

if isfield(flg_loc,'do_xvallt')==0
    flg_loc.do_xvallt=0;
end

%% PATHS

nS=numel(simdef);
fdir_mat_ref=simdef_ref.file.mat.dir;
fpath_mat_ref=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
fpath_mat_time_ref=strrep(fpath_mat_ref,'.mat','_tim.mat'); 

if nS==1
    fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
    runid=sprintf('%s-%s',simdef.file.runid,simdef_ref.file.runid);
else
    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
    runid=sprintf('ref_%s',simdef_ref.file.runid);
end
mkdir_check(fdir_fig);

% fdir_mat_ref=simdef_ref.file.mat.dir;
fdir_mat=simdef(1).file.mat.dir; %assuming same grid!
% fpath_mat_ref=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time_ref=strrep(fpath_mat_ref,'.mat','_tim.mat'); %shuld be the same for reference and non-reference
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); %shuld be the same for reference and non-reference
% fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
% mkdir_check(fdir_fig);
% fpath_map_ref=simdef_ref.file.map;
% fpath_map=simdef_ref.file.map;
% runid_ref=simdef_ref.file.runid;
% runid=simdef.file.runid;

% nS=numel(simdef);
% fdir_mat=simdef(1).file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
% mkdir_check(fdir_fig); %we create it in the loop
% runid=simdef(1).file.runid;

fpath_map=gdm_fpathmap(simdef_ref,0);

%take coordinates from curved domain (in case the domain is straightened)
fpath_map_grd=fpath_map; 
if is_straigth
    fpath_map_grd=flg_loc.fpath_map_curved;
end

%% LOAD

gridInfo_ref=gdm_load_grid(fid_log,fdir_mat_ref,fpath_map_grd,'dim',1);
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map_grd,'dim',1); %we assume same grid
load(fpath_mat_time_ref,'tim'); %we are assuming the same time -> val=gdm_match_times_diff_val(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref,fdir_mat,tag,var_str,pliname)
v2struct(tim); %time_dnum, time_dtime

if flg_loc.tim_type==1
    time_dnum_v=time_dnum;
    time_dtime_v=time_dtime;
elseif flg_loc.tim_type==2
    time_dnum_v=time_mor_dnum;
    time_dtime_v=time_mor_dtime;
end

%% DIMENSION

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nbr=numel(flg_loc.branch);
nylim=size(flg_loc.ylims_diff_s,1); 

%2DO call function that computes this
if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
% in_p.unit={'qsp','qxsp','qysp'};
%             in_p.gen_struct=gen_struct;
in_p.fig_size=[0,0,14.5,12];

% fext=ext_of_fig(in_p.fig_print);

if nS>1
    in_p.leg_str=flg_loc.leg_str;
end

%% LOOP
for kbr=1:nbr %branches
    
    branch=flg_loc.branch{kbr,1};
    branch_name=flg_loc.branch_name{kbr,1};
    
    gridInfo_br_ref=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat_ref,gridInfo_ref,branch,branch_name); %we assume they all have the same grid...
    gridInfo_br=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat,gridInfo,branch,branch_name); %we assume they all have the same grid...
    nx=numel(gridInfo.offset);    
    
    if do_rkm
        in_p.s=gridInfo_br.rkm;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;
    else
        in_p.s=gridInfo_br.offset;
        in_p.xlab_str='dist';
        in_p.xlab_un=1;
    end

    kt_v=gdm_kt_v(flg_loc,nt); %time index vector
%         fpath_file=cell(nt,1); %movie

    for kvar=1:nvar %variable
        
        [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));

        %time 0
        kt=1;
            %reference
        fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
        load(fpath_mat_tmp,'data');            
        data_0_ref=data;
            %cases
        data_0=NaN(nx,nS);    
        for kS=1:nS    
            fdir_mat=simdef(kS).file.mat.dir;
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
            load(fpath_mat_tmp,'data');            
            data_0(:,kS)=data;
        end
        
        %skip if multidimentional
%             fn_data=fieldnames(data_0(1));
%             if size(data_0(1).(fn_data{1}),2)>1
%                 messageOut(fid_log,sprintf('Skipping variable with multiple dimensions: %s',var_str_save));
%                 continue
%             end

        ktc=0;
        data_T=NaN(nx,nS,nt);
        data_T_ref=NaN(nx,1,nt);
        for kt=kt_v %time
            ktc=ktc+1;

            %% load
            
            %reference
            fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
            load(fpath_mat_tmp,'data');
            data_T_ref(:,1,kt)=data;
            
            %cases
            for kS=1:nS
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
                load(fpath_mat_tmp,'data');
                data_T(:,kS,kt)=data;
            end
            
            in_p.tim=time_dnum_v(kt);
            in_p.lab_str=var_str_save;
            in_p.xlims=flg_loc.xlims;

            for kdiff=1:ndiff

                %measurements                        
                in_p.plot_mea=false;
                if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
                    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                    data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                    if isstruct(data_mea) %there is data
                        in_p.plot_mea=true;
                        in_p.s_mea=data_mea.x;
                        if kdiff==1
                            in_p.val_mea=data_mea.y;
                        elseif kdiff==2
                            tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
                            data_mea_0=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                            in_p.val_mea=data_mea.y-data_mea_0.y;
                            %we are assuming <s_mea> is the same
                        end
                    end
                end
                
                for kylim=1:nylim
                    
                    
                    %2DO adapt this function
%                     [in_p,str_dir]=gdm_data_diff(in_p,flg_loc,kdiff,kylim,data,data_ref,'clims_diff_s','clims_diff_st',var_str);
%                     in_p.is_diff=1; %it is difference between simulations!

                    if kdiff==1
                        in_p.ylims=flg_loc.ylims_diff_s(kylim,:);
                        val_diff=NaN(nx,nS);
                        for kS=1:nS
                            val_diff(:,kS)=D3D_diff_val(data_T(:,kS,kt),data_T_ref(:,1,kt),gridInfo_br,gridInfo_br_ref);
                        end
                        in_p.val=val_diff;
                        in_p.is_diff=0;
                        str_dir='val';
                        val_diff0=D3D_diff_val(data_0(:,1),data_0_ref,gridInfo_br,gridInfo_br_ref); %same initial condition
                        in_p.val0=data_0(:,1);
                        in_p.val0=val_diff0;
                    elseif kdiff==2
                        in_p.ylims=flg_loc.ylims_diff_st(kylim,:);
                        val_diff=NaN(nx,nS);
                        for kS=1:nS
                            val_diff(:,kS)=D3D_diff_val(data_T(:,kS,kt)-data_0(:,kS),data_T_ref(:,1,kt)-data_0_ref,gridInfo_br,gridInfo_br_ref);
                        end
                        in_p.val=val_diff;
                        in_p.is_diff=1;
                        str_dir='diff';
                        val_diff0=D3D_diff_val(data_0(:,1)-data_0(:,1),data_0_ref-data_0_ref,gridInfo_br,gridInfo_br_ref); %just make 0
                        in_p.val0=val_diff0;
                    end

                    fdir_fig_loc=fullfile(fdir_fig,branch_name,var_str_save,str_dir);
                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                    fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_save,branch_name,str_dir,kylim);
    %                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                    in_p.fname=fname_noext;

                    fig_1D_01(in_p);
                end %kylim
            end %kref
            messageOut(fid_log,sprintf('Done plotting figure %s time %4.2f %% variable %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));


            %BEGIN DEBUG

            %END DEBUG

            %% movie

%                 if isfield(flg_loc,'do_movie')==0
%                     flg_loc.do_movie=1;
%                 end
% 
%                 if flg_loc.do_movie
%                     dt_aux=diff(time_dnum);
%                     dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
%                     rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
%                     make_video(fpath_file,'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
%                 end


        end %kt
        
        %% all times in same figure xtv
        
        if flg_loc.do_xtv && nt>1
            for kS=1:nS
                fdir_fig_s=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                
                [x_m,y_m]=meshgrid(in_p.s,time_dtime_v);
                in_p.x_m=x_m;
                in_p.y_m=y_m;
                in_p.clab_str=var_str_save;
                in_p.ylab_str='';
                in_p.tit_str=branch_name;
                for kdiff=1:ndiff
                    switch kdiff
                        case 1
                            in_p.val=squeeze(data_T(:,kS,:)-data_T_ref)';
                            in_p.is_diff=0;
                            str_dir='val';
                        case 2
                            in_p.val=squeeze((data_T(:,kS,:)-data_T_ref)-(data_0(:,kS,:)-data_0_ref))';
                            in_p.is_diff=1;
                            str_dir='diff';
                    end
                    fdir_fig_loc=fullfile(fdir_fig_s,branch_name,var_str_save,str_dir);
                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                    fname_noext=fig_name_all(fdir_fig_loc,tag,runid,var_str_save,branch_name,str_dir);

                    in_p.fname=fname_noext;
                    fig_surf(in_p)
                end %kdiff
            end
        end %do_xtv
        
        %% all times in same figure xvt
        
        if flg_loc.do_xvallt && nS==1 && nt>1
            error('not finished')
                
            fig_1D_01(in_p);
        end
        
    end %kvar    
end %kbr

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,branch_name,str_dir,kylim)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_kylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,branch_name,str_dir,kylim));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function

function fpath_fig=fig_name_all(fdir_fig,tag,runid,var_str,branch_name,str_dir)
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_allt_%s_%s_%s',tag,runid,var_str,branch_name,str_dir));

end %function
