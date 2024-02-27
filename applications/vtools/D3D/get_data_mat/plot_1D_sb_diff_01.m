%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_1D_sb_diff_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_1D_sb_diff_01.m $
%
%

function plot_1D_sb_diff_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE


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

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol_diff);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
% in_p.unit={'qsp','qxsp','qysp'};
%             in_p.gen_struct=gen_struct;
in_p.fig_size=[0,0,14.5,12];
in_p.is_diff=1;

fext=ext_of_fig(in_p.fig_print);

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{flg_loc.sb_pol_diff{ksb}(1)};
    [~,sb_pol_1,~]=fileparts(fpath_sb_pol);
    fpath_sb_pol=flg_loc.sb_pol{flg_loc.sb_pol_diff{ksb}(2)};
    [~,sb_pol_2,~]=fileparts(fpath_sb_pol);
    sb_pol_diff=sprintf('%s-%s',sb_pol_1,sb_pol_2);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;

        ktc=0;
        kt_v=gdm_kt_v(flg_loc,nt); %time index vector
        fpath_file=cell(nt,1);
        for kt=kt_v %time
            ktc=ktc+1;
            for kvar=1:nvar %variable
                varname=flg_loc.var{kvar};
                var_str=D3D_var_num2str(varname);

                %load
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol_1);
                data_1=load(fpath_mat_tmp,'data');
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol_2);
                data_2=load(fpath_mat_tmp,'data');

                fn_data=fieldnames(data_1.data);
                nfn=numel(fn_data);

                in_p.tim=time_dnum(kt);
                in_p.lab_str=var_str;
                in_p.xlims=flg_loc.xlims;

                for kfn=1:nfn
                    statis=fn_data{kfn};

                    fdir_fig_loc=fullfile(fdir_fig,sb_pol_diff,pol_name,var_str,statis);
                    mkdir_check(fdir_fig_loc);

                    in_p.val=data_1.data.(statis)-data_2.data.(statis);
                    fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str,statis,sb_pol_diff);
                    fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                    in_p.fname=fname_noext;

                    fig_1D_01(in_p);
                    messageOut(fid_log,sprintf('Done plotting figure %s rkm poly %4.2f %% time %4.2f %% variable %4.2f %% statistic %4.2f %%',tag,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100,kfn/nfn*100));
                end

                %BEGIN DEBUG

                %END DEBUG

                %% movie

                if isfield(flg_loc,'do_movie')==0
                    flg_loc.do_movie=1;
                end

                if flg_loc.do_movie
                    dt_aux=diff(time_dnum);
                    dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
                    rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
                    make_video(fpath_file,'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
                end


            end %kvar
        end %kt    
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,fn,sb_pol)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,fn,sb_pol));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function