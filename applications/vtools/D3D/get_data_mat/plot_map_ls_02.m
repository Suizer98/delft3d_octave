%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18257 $
%$Date: 2022-07-22 19:19:06 +0800 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: plot_map_ls_02.m 18257 2022-07-22 11:19:06Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_ls_02.m $
%
%

function plot_map_ls_02(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);
tag_fig='map_ls_02'; %?? change?

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);

% simdef.file.mat.map_ls_01=fullfile(fdir_mat,'map_ls_01.mat');
% simdef.file.mat.map_ls_01_tim=fullfile(fdir_mat,'map_ls_01_tim.mat');

% simdef.file.fig.map_ls_01=fullfile(fdir_fig,'map_ls_01');
    
%%

% %% BEGIN DEBUG
% 
% % load(fullfile(simdef.file.mat.dir,'map_ls_tmp_pli_01_kt_70.mat'));
% 
% %% END DEBUG

%load
% load(simdef.file.mat.map_ls_01,'data_map_ls_01');
%temporal solution for old results
tmp_tim=load(fpath_mat_time);
if isfield(tmp_tim,'tim')
    v2struct(tmp_tim.tim); %time_dnum, time_dtime
else
    v2struct(tmp_tim)
end
% load(fpath_mat_time,'time_dnum');

nclim=size(flg_loc.clims_sal,1);
npli=numel(flg_loc.pli);
nt=numel(time_dnum);

%figures
in_p=flg_loc; %attention with unexpected input
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

fext=ext_of_fig(in_p.fig_print);

%% LOOP

fpath_file=cell(nt,nclim,npli);
for kpli=1:npli
    [~,pliname,~]=fileparts(flg_loc.pli{kpli,1});
    pliname=strrep(pliname,' ','_');
    
    
    in_p.ylims=flg_loc.ylims(kpli,:); %move to input
    
    %loading all
%     in_p.data_ls=data_map_ls_01(kpli);
    for kt=1:nt
        %loading each file
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pli',pliname);
        load(fpath_mat_tmp,'data_map_ls_01');
        in_p.data_ls=data_map_ls_01;
        
        in_p.xlims=[0,data_map_ls_01.Scor(end)];
        
        for kclim=1:nclim
            fname_noext=fullfile(fdir_fig,sprintf('sal_ls_02_%s_%s_clim_%02d_pli_%s',simdef.file.runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim,pliname));
            fpath_file{kt,kclim,kpli}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
%             in_p.kt=kt;
            in_p.tim=time_dnum(kt);

%             clims=flg_loc.clims(kclim,:);
%             if all(isnan(clims)==[0,1]) %[0,NaN]
%                 error('do')
%                 in_p.clims=[clims(1),max_tot];
%             else
%                 in_p.clims=clims;
%             end
            in_p.clims_sal=flg_loc.clims_sal(kclim,:);
            in_p.clims_us=flg_loc.clims_us(kclim,:);
            in_p.clims_un=flg_loc.clims_un(kclim,:);
            in_p.clims_uz=flg_loc.clims_uz(kclim,:);
            
            fig_map_ls_02(in_p);
        end %kclim
    end %kt
end %kpli

%% movies

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=1;
end

if flg_loc.do_movie
    dt_aux=diff(time_dnum);
    dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
    rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
    for kpli=1:npli
        for kclim=1:nclim
           make_video(fpath_file(:,kclim,kpli),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
        end
    end
end

end %function
