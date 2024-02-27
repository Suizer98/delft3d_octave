%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%variables: open D3D_list_of_variables

%% PREAMBLE

% %
% %Victor Chavarrias (victor.chavarrias@deltares.nl)
% %
% %$Revision: 18412 $
% %$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
% %$Author: chavarri $
% %$Id: D3D_gdm.m 18412 2022-10-07 14:37:21Z chavarri $
% %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
% %
% %Description
% 
% %% PREAMBLE
% 
% % dbclear all;
% clear
% clc
% fclose all;
% 
% %% PATHS
% 
% fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% 
% % fpath_project='d:\temporal\220517_improve_exner\';
% fpath_project='p:\dflowfm\projects\2022_improve_exner\';
% 
% %% ADD OET
% 
% if isunix
%     fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
% end
% addpath(fpath_add_fcn)
% addOET(fpath_add_fcn) 
% 
% %% PATHS
% 
% fpaths=paths_project(fpath_project);

%% 

%% simulation

% ks=0;
% 
% ks=ks+1;
% in_plot.fdir_sim{ks}=fullfile(fpaths.dir_runs,'r002'); 
% in_plot.str_sim{ks}='reference';
% 
% in_plot.sim_ref=1;
% in_plot.lan='en';
% in_plot.tag_serie='01';
% in_plot.path_tiles='C:\Users\chavarri\checkouts\riv\earth_tiles\';

%% display map times

% tag='disp_time_map';
% in_plot.(tag).do=1;

%% grid

% tag='fig_grid_01';
% in_plot.(tag).do=1;
% in_plot.(tag).fig_print=1;
% in_plot.(tag).fig_visible=0;
% in_plot.(tag).axis_equal=1;
% in_plot.(tag).do_plot_along_rkm=1;
% in_plot.(tag).do_rkm_disp=1;
% in_plot.(tag).fpath_rkm_plot_along=fullfile(fpaths.dir_rkm,'rkm_5km.csv');
% in_plot.(tag).fpath_rkm_disp=fullfile(fpaths.dir_rkm,'rkm.csv');
% in_plot.(tag).rkm_tol_x=5000;
% in_plot.(tag).rkm_tol_y=5000;
% in_plot.(tag).plot_tiles=1;

%% 2DH

% tag='fig_map_2DH_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_diff=1; %difference initial time
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).do_s_diff=1; %difference with reference and initial time
% in_plot.(tag).var={'T_max','T_da','T_surf'}; %open D3D_list_of_variables
% in_plot.(tag).layer=NaN; %NaN=top layer
% % in_plot.(tag).var_idx={1,1,1}; %index of a variable with several indices: {'T_max','T_da','T_surf'}.
% in_plot.(tag).tim=NaN; %all times
% in_plot.(tag).order_anl=2; %1=normal; 2=random
% in_plot.(tag).clims_type=1; %1=regular; 2=upper limit is number of days since <clims_type_var>
% % in_plot.(tag).clims_type_var=datenum(2018,07,01); %in case of <clims_type>=2
% in_plot.(tag).clims=[NaN,NaN]; 
% in_plot.(tag).clims_diff_t=[NaN,NaN]; %clim of difference with time
% in_plot.(tag).clims_diff_s=[NaN,NaN]; %clim of difference with simulation
% in_plot.(tag).do_movie=0; %
% in_plot.(tag).tim_movie=40; %movie duration [s]
% in_plot.(tag).fpath_ldb{1,1}=fullfile(fpath_project,'model','postprocessing','mkm-inner.ldb');
% in_plot.(tag).fpath_ldb{2,1}=fullfile(fpath_project,'model','postprocessing','mkm-outer.ldb');
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=1; %overwrite mat-files
% in_plot.(tag).do_vector=0; %add velocity vectors
% in_plot.(tag).do_axis_equal=0;
% in_plot.(tag).fpath_rkm_plot_along=fullfile(fpaths.dir_rkm,'rkm_5km.csv'); %file to go along specified rkm to plot
% in_plot.(tag).fpath_rkm_disp=fullfile(fpaths.dir_rkm,'rkm.csv'); %file to display rkm

%% 2DH ls

% tag='fig_map_2DH_ls_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).var={'bl'}; %<open main_plot_layout>
% in_plot.(tag).tim=NaN;
% in_plot.(tag).tim_type=2;
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random
% in_plot.(tag).tol_tim=1.1;
% in_plot.(tag).fig_size=[0,0,16,9].*2;
% in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'y500.pli');
% in_plot.(tag).ylims=[NaN,NaN;-0.2e-3,1.2e-3];
% in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).do_movie=0; %
% in_plot.(tag).ml=2.5;
% in_plot.(tag).do_marker=1;
% in_plot.(tag).markersize=5;

%% summerbed

%computes statistic values (mean, max, min, std) of a variables inside the summerbed 
%and inside a kilometre polygon. 

% tag='fig_map_summerbed_01';
% in_plot.(tag).do=1;
% in_plot.(tag).tim=NaN; %analysis time [datenum, datetime]. NaN=all, Inf=last.
% % in_plot.(tag).tim=[datenum(2014,06,01),datenum(2015,06,01),datenum(2016,06,01),datenum(2017,06,01),datenum(2018,06,01)];
% in_plot.(tag).tim_type=2; %Type of input time: 1=flow; 2=morpho. 
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).do_movie=0;
% % in_plot.(tag).statis_plot={'val_mean'}; %statistics to plot. Comment to have all. 
% in_plot.(tag).var={'mesh2d_taus'}; % ,'mesh2d_dg'} %,14,27,'mesh2d_dg'}; % ,14,27,44,'mesh2d_dg',47}; %{1,14,27,44,'mesh2d_dg','mesh2d_DXX01','mesh2d_DXX06'}; %can be cell array vector. See <open D3D_list_of_variables> for possible input flags
% in_plot.(tag).rkm={145:1:175}; %river km vectors to average the data; cell(1,nrkm)
% in_plot.(tag).rkm_name={'1km'}; %name of the river km vector (for saving); cell(1,nrkm)
%     %construct branches name
%     for kidx=1:numel(in_plot.(tag).rkm)
%         in_plot.(tag).rkm_br{kidx,1}=maas_branches(in_plot.(tag).rkm{kidx}); %branch name of each rkm point
%     end
% in_plot.(tag).xlims=[145,175]; %x limits for plotting [nxlims,2]
% in_plot.(tag).fpath_rkm=fullfile(fpaths.dir_rkm,'rkm.csv'); %river kilometer file. See format: open convert2rkm
% 
% %polygons and measurements associated to it
% 
% kp=0;
% 
% kp=kp+1;
% in_plot.(tag).sb_pol{kp,1}=fullfile(fpaths.dir_rkm,'L3R3.shp');
% in_plot.(tag).measurements{kp,1}=fullfile(fpaths.dir_data,'20220415_van_Arjan_1d_calibratie_parameters','L3R3_measured.mat'); 
%
% %time average
%
% %Computes the statistics (mean, max, min, std) for each statistic of a variable over a period of time. E.g., 
% %the std of the bed elevation between <t1> and <t2>.
%
% in_plot.(tag).overwrite_ave=1; %overwrite mat-files
% %Times taken to compute the statistics in time. [<t3>,<t4>] means e.g. that the mean is based on the results at <t3> and <t4>. 
% %For computing the mean based on all results between <t1> and <t2>, set these times in <tim> and set NaN in <tim_ave> (i.e., the time in <tim_ave> is the same as that in <tim>). 
% in_plot.(tag).tim_ave{1,1}=[datenum(2014,06,01),datenum(2015,06,01),datenum(2016,06,01),datenum(2017,06,01),datenum(2018,06,01)]; 
% in_plot.(tag).tim_ave_type=2; %1=flow; 2=morpho
% in_plot.(tag).tol_tim=30; %tolerance to match day in period with results

%% 1D map

% tag='fig_map_1D';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=0; %regular plot
% in_plot.(tag).do_xtv=1; %
% in_plot.(tag).do_diff=1; %regular plot
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).var={'h'}; %<open main_plot_layout>
% in_plot.(tag).branch{1,1}={'Channel_1D_1'}; %<open main_plot_layout>
% in_plot.(tag).branch_name{1,1}='c1';
% in_plot.(tag).tim=NaN;
% in_plot.(tag).tim_type=1;
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random
% in_plot.(tag).xlims=[NaN,NaN];
% in_plot.(tag).ylims=[NaN,NaN];
% % in_plot.(tag).ylims=[NaN,NaN;-0.2e-3,1.2e-3];
% % in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=1; %overwrite mat-files
% in_plot.(tag).do_movie=0; %
% % in_plot.(tag).ml=2.5;
% in_plot.(tag).plot_markers=1;

%%

function D3D_gdm(in_plot)

%% DEFAULT

in_plot=create_mat_default_flags(in_plot);
fid_log=NaN;

if ~isfield(in_plot,'fdir_sim')
    error('Specify the simulations to analyse <fdir_sim>')
end
ns=numel(in_plot.fdir_sim);

%% CREATE MAT-FILES

messageOut(fid_log,'------------------------------')
messageOut(fid_log,'---Creating mat-files---------')
messageOut(fid_log,'------------------------------')

for ks=1:ns

    %% paths
    simdef=gdm_paths_single_run(fid_log,in_plot,ks);
    
    %% call
    create_mat_single_run(fid_log,in_plot,simdef);
    
end %ks

%% PLOT INDIVIDUAL RUNS

messageOut(fid_log,'------------------------------')
messageOut(fid_log,'---Plotting individual runs---')
messageOut(fid_log,'------------------------------')

for ks=1:ns
    
    %% paths
    simdef=gdm_paths_single_run(fid_log,in_plot,ks);
    
    %% call
    plot_individual_runs(fid_log,in_plot,simdef);
    
end %ks

%% PLOT DIFFERENCES WITH REFERENCE

if isfield(in_plot,'sim_ref') && ~isnan(in_plot.sim_ref) && ns>1

    %% reference paths
    ks_ref=in_plot.sim_ref;
    simdef_ref=gdm_paths_single_run(fid_log,in_plot,ks_ref,'disp',0);

    %% PLOT DIFFERENCES BETWEEN RUNS

    messageOut(fid_log,'---------------------------------------------------')
    messageOut(fid_log,'---Plotting differences between runs---------------')
    messageOut(fid_log,'---------------------------------------------------')

    for ks=1:ns

        if ks==ks_ref; continue; end

        %% paths
        simdef=gdm_paths_single_run(fid_log,in_plot,ks);

        %% call
        plot_differences_between_runs(fid_log,in_plot,simdef_ref,simdef)

    end %ks

    %% PLOT DIFFERENCES BETWEEN RUNS IN ONE FIGURE

    messageOut(fid_log,'-----------------------------------------------------')
    messageOut(fid_log,'---Plotting differences between runs in one figure---')
    messageOut(fid_log,'-----------------------------------------------------')

    %% paths no ref
    ksc=0;
    for ks=1:ns
        if ks==ks_ref; continue; end
        ksc=ksc+1;
        [simdef_no_ref(ksc),leg_str_no_ref{ksc}]=gdm_paths_single_run(fid_log,in_plot,ks,'disp',0);
    end
    
    %% call
    plot_differences_between_runs_one_figure(fid_log,in_plot,simdef_ref,simdef_no_ref,leg_str_no_ref)

end %reference run 

%% PLOT ALL RUNS IN ONE FIGURE

if ns>1
    
    messageOut(fid_log,'-------------------------------------')
    messageOut(fid_log,'---Plotting all runs in one figure---')
    messageOut(fid_log,'-------------------------------------')

    %% paths all
    for ks=1:ns
        [simdef_all(ks),leg_str_all{ks}]=gdm_paths_single_run(fid_log,in_plot,ks,'disp',0);
    end

    %% call
    plot_all_runs_one_figure(fid_log,in_plot,simdef_all,leg_str_all)

end %ns>1

end %function