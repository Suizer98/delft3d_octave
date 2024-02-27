%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_plot_raw.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_raw.m $
%

%%
%% SCRIPT
%%

% %
% %Victor Chavarrias (victor.chavarrias@deltares.nl)
% %
% %$Revision: 18282 $
% %$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
% %$Author: chavarri $
% %$Id: D3D_plot_raw.m 18282 2022-08-05 14:25:39Z chavarri $
% %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_raw.m $
% %

% %% PREAMBLE
% 
% % close all
% clear
% clc
% fclose all;
% 
% %% ADD OET
% 
% path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% % path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
% addpath(path_add_fcn)
% addOET(path_add_fcn) %1=c-drive; 2=p-drive
% 
% %% C or P
% 
% % paths_project='p:\11206813-007-kpp2021_rmm-3d'; 
% % paths_project='d:\temporal\210402_RMM3D\';
% 
% %% PATHS
% 
% fdir_sim='P:\11208075-002-ijsselmeer\06_simulations\02_runs\r030\';
% 
% %% INPUT
% 
% %his
% flg.his_sta=0; %stations
% flg.his_sal=0; %salinity
%     flg.sal_u=0; %unit: 1=psu; 2=chlorinity
% flg.his_etaw=0; %water level
% flg.his_dt=0; %time step
% flg.his_ucmaga=1; %water level
% flg.his_times=0; %his-times available
%
% %map
% flg.map_times=0;
% flg.map_ucmaga=0;
% flg.map_Patm=0;
% flg.map_etab=0;
%     flg.clim_etab=[-20,10];
% flg.map_chez=0;
% flg.map_etaw=0;
%     flg.clim_etaw=[0,4];
% flg.map_numlimdt=0;
% flg.map_sal=0; %not available yet
% flg.map_waterdepth=0;
% 
% %times from history file
% % NaN: all times available
% % t0=datenum(2035,01,10,20,00,00);
% % t0=NaN;
% tend=t0;
% 
% % stations={'KU_0020.00','KU_0021.00','FL47','MWTL_Vrouwezand','obs_WPJ_PWN'};
% % stations=[]; %all
% % stations={'obs_WPJ_PWN'};
% stations={'KU_0032.00'};
% 
% flg.fig_print=0;
% flg.fig_close=0;
% flg.fig_visible=1;

function D3D_plot_raw(fdir_sim,flg,t0,tend,stations)

%%

if isfield(flg,'fig_separate')==0
    flg.fig_separate=0;
end
if isfield(flg,'fig_print')==0
    flg.fig_print=0;
end
fig_visible=~flg.fig_print;

%% CALC

messageOut(NaN,'start preprocessing')

% ns=numel(stations);

%flags map
if any([flg.map_ucmaga,flg.map_Patm,flg.map_etab,flg.map_etaw,flg.map_numlimdt,flg.map_sal])
    flg.map=1;
else
    flg.map=0;
end

%flags his
if any([flg.his_sal,flg.his_etaw,flg.his_dt,flg.his_ucmaga,flg.his_times,flg.his_sta])
    flg.his=1;
else
    flg.his=0;
end


%%
%his times
% simdef.D3D.dire_sim=fullfile(paths.dir_computations,runid);
simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
path_his=simdef.file.his;
if isfield(simdef.file,'map')
    path_map=simdef.file.map;
end


if flg.his
    [~,~,time_dnum_his_0,time_dtime_his_0]=D3D_results_time(path_his,0,[1,1]);
    [~,~,time_dnum_his_f,time_dtime_his_f]=D3D_results_time(path_his,0,NaN);
    if isnan(t0)
        t0=time_dnum_his_0;
        tend=time_dnum_his_f;
    end
end

%map times
if flg.map_times
    [time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(path_map,0,[1,Inf]);
    nt=numel(time_dtime);
    for kt=1:nt
        fprintf('%s \n',datestr(time_dtime(kt),'yyyy-mm-dd HH:MM:SS'))
    end
end

dir_figs=fullfile(simdef.D3D.dire_sim,'figures','checks');
mkdir_check(dir_figs);

%% checks without loading data

%% times
if flg.his_times
    fprintf('his-results: \n');
    fprintf('%s \n',datestr(time_dtime_his_0,'yyyy-mm-dd HH:MM:SS'))
    fprintf('%s \n',datestr(time_dtime_his_f,'yyyy-mm-dd HH:MM:SS'))
end

%% stations

if flg.his_sta
    obs=D3D_observation_stations(path_his);
    nobs=numel(obs.name);
    for kobs=1:nobs
        fprintf('%s \n',obs.name{kobs});
    end
end

%% ret

if flg.his_times || flg.his_sta
    return
end

%% LOAD

messageOut(NaN,'start loading')

%% map
if flg.map
   
    %% grid
map_info=ncinfo(path_map);
    
Data_face_x   = EHY_getMapModelData(path_map,'varName','mesh2d_face_x','mergePartitions',1);
Data_face_y   = EHY_getMapModelData(path_map,'varName','mesh2d_face_y','mergePartitions',1);

gridInfo = EHY_getGridInfo(path_map,{'face_nodes_xy'},'mergePartitions',1);
% gridInfo = EHY_getGridInfo(path_map,{'edge_nodes_xy'},'mergePartitions',0);

% Data_diu      = EHY_getMapModelData(path_map,'varName','mesh2d_diu','t0',t0,'tend',tend,'mergePartitions',1); %merge partitions and map plot do not work because the data is at cell edges

    %% vars
if flg.map_ucmaga
    try
Data_ucmaga=EHY_getMapModelData(path_map,'varName','mesh2d_ucmaga','t0',t0,'tend',tend,'mergePartitions',1);
    catch
Data_ucmaga=EHY_getMapModelData(path_map,'varName','mesh2d_ucmag','t0',t0,'tend',tend,'mergePartitions',1);
    end
[max_ucmaga_val,max_ucmaga_idx]=max(Data_ucmaga.val);
max_ucmaga_x=Data_face_x.val(max_ucmaga_idx);
max_ucmaga_y=Data_face_y.val(max_ucmaga_idx);
end
if flg.map_Patm
Data_Patm=EHY_getMapModelData(path_map,'varName','mesh2d_Patm','t0',t0,'tend',tend,'mergePartitions',1);
end
if flg.map_etab
Data_bl=EHY_getMapModelData(path_map,'varName','mesh2d_flowelem_bl','mergePartitions',1);
end
if flg.map_chez
Data_chez=EHY_getMapModelData(path_map,'varName','mesh2d_czs','t0',t0,'tend',tend,'mergePartitions',1);
end
if flg.map_etaw
Data_waterlevel=EHY_getMapModelData(path_map,'varName','wl','t0',t0,'tend',tend,'mergePartitions',1);
end
% Data_uv   = EHY_getMapModelData(path_map,'varName','uv','t0',t0,'tend',tend,'mergePartitions',1);
if flg.map_numlimdt
Data_Numlimdt=EHY_getMapModelData(path_map,'varName','mesh2d_Numlimdt','t0',t0,'tend',tend,'mergePartitions',1);
end
if flg.map_waterdepth
Data_waterdepth = EHY_getMapModelData(path_map,'varName','mesh2d_waterdepth','t0',t0,'tend',tend,'mergePartitions',1);
end
% Data_dtcell = EHY_getMapModelData(path_map,'varName','mesh2d_dtcell','t0',t0,'tend',tend,'mergePartitions',1);
% Data_ucmag = EHY_getMapModelData(path_map,'varName','mesh2d_ucmag','t0',t0,'tend',tend,'mergePartitions',1);
% Data_layer_z = EHY_getMapModelData(path_map,'varName','mesh2d_layer_z','t0',t0,'tend',tend,'mergePartitions',1);


%% max Numlimdt

if flg.map_numlimdt
[max_Numlimdt_val,max_Numlimdt_idx]=max(Data_Numlimdt.val);

max_Numlimdt_x=Data_face_x.val(max_Numlimdt_idx);
max_Numlimdt_y=Data_face_y.val(max_Numlimdt_idx);
end
% 
% %% max waterdepth
% 
% [max_waterdepth_val,max_waterdepth_idx]=max(Data_waterdepth.val);
% 
% max_waterdepth_x=Data_face_x.val(max_waterdepth_idx);
% max_waterdepth_y=Data_face_y.val(max_waterdepth_idx);

%% min dt of all layers

% Data_dtcell_minlay=min(Data_dtcell.val,[],3,'omitnan');

end %map

%% HIS
    
%% sal
if flg.his_sal
    
messageOut(NaN,'loading salinity')
his_sal=EHY_getmodeldata(path_his,stations,'dfm','varName','sal','layer','0','t0',t0,'tend',tend);
messageOut(NaN,'loading cell center')
his_zcen=EHY_getmodeldata(path_his,stations,'dfm','varName','Zcen_cen','layer','0','t0',t0,'tend',tend); %interfaces are wrong! don't use them!
messageOut(NaN,'loading cell interface')
his_zint=EHY_getmodeldata(path_his,stations,'dfm','varName','Zcen_int','layer','0','t0',t0,'tend',tend); %interfaces are wrong! don't use them!
 
[nt,ns,nl]=size(his_sal.val);

% nl=size(his_zcen.val,3);
% nt=size(his_zcen.val,1);
% his_zint.val=NaN(nt,1,nl+1);
% for kt=1:nt
%     his_zint.val(kt,1,:)=cen2cor(his_zcen.val(kt,1,:))';
% end

end %sal

%% etaw

if flg.his_etaw
messageOut(NaN,'loading water level')
his_wl=EHY_getmodeldata(path_his,stations,'dfm','varName','wl','t0',t0,'tend',tend);
end

%% dt

if flg.his_dt
messageOut(NaN,'loading time step')
his_dt=EHY_getmodeldata(path_his,stations,'dfm','varName','timestep','t0',t0,'tend',tend);
end

%% dt

if flg.his_ucmaga
messageOut(NaN,'loading velocity magnitude')
his_ucmaga=EHY_getmodeldata(path_his,stations,'dfm','varName','velocity_magnitude','t0',t0,'tend',tend);
end

%%
%% PLOT
%%

%% map
if flg.map
    
    %% bed level
if flg.map_etab
    zData=Data_bl.val(:,:);

    figure
    EHY_plotMapModelData(gridInfo,zData)
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='bed level [m]';
    
    if ~isnan(flg.clim_etab(1))
        clim(flg.clim_etab)
    end
    
    if flg.fig_print
        path_fig_name=fullfile(dir_figs,sprintf('etab_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
        fname_fig=sprintf('%s.png',path_fig_name);
        print(gcf,fname_fig,'-dpng','-r300')   
    end
end

    %% chezy
if flg.map_chez
    zData=Data_chez.val(:,:);

    figure
    EHY_plotMapModelData(gridInfo,zData)
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='Chezy [m/s^{1/2}]';
    
    path_fig_name=fullfile(dir_figs,sprintf('chezy_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
    fname_fig=sprintf('%s.png',path_fig_name);
    print(gcf,fname_fig,'-dpng','-r300')    
end

    %% water depth

if flg.map_waterdepth
    zData=Data_waterdepth.val(:,:);

    figure
    EHY_plotMapModelData(gridInfo,zData)
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='flow depth [m]';
    
    path_fig_name=fullfile(dir_figs,sprintf('h_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
    fname_fig=sprintf('%s.png',path_fig_name);
    print(gcf,fname_fig,'-dpng','-r300')    
end

    %% water level
    
if flg.map_etaw
    zData=Data_waterlevel.val(:,:);

    figure
    EHY_plotMapModelData(gridInfo,zData)
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='water level [m+NAP]';
    
    if ~isnan(flg.clim_etaw(1))
        clim(flg.clim_etaw)
    end
    
    if flg.fig_print
        path_fig_name=fullfile(dir_figs,sprintf('etaw_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
        fname_fig=sprintf('%s.png',path_fig_name);
        print(gcf,fname_fig,'-dpng','-r300')    
    end
end

    %% lim dt

if flg.map_numlimdt
    zData=Data_Numlimdt.val(1,:);

    figure
    hold on
    EHY_plotMapModelData(gridInfo,zData)
    scatter(max_Numlimdt_x,max_Numlimdt_y,50,'rx')
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='number of times limits time step [-]';
    
    path_fig_name=fullfile(dir_figs,sprintf('numlimdt_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
%     savefig(gcf,sprintf('%s.fig',path_fig_name))
    fname_fig=sprintf('%s.png',path_fig_name);
    print(gcf,fname_fig,'-dpng','-r300')  
end 

    %% velocity magnitude
if flg.map_ucmaga
    zData=Data_ucmaga.val(1,:);

    figure
    hold on
    EHY_plotMapModelData(gridInfo,zData)
    scatter(max_ucmaga_x,max_ucmaga_y,10,'rx')
    text(max_ucmaga_x,max_ucmaga_y,sprintf('%f m/s',max_ucmaga_val),'color','red')
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='velocity magnitude [m/s]';
%     clim([0,2])

    if flg.fig_print
        path_fig_name=fullfile(dir_figs,sprintf('ucmaga_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
    %     savefig(gcf,sprintf('%s.fig',path_fig_name))
        fname_fig=sprintf('%s.png',path_fig_name);
        print(gcf,fname_fig,'-dpng','-r300')    
    end
end

    %% diffusivity
%     kl=1;
%     kt=1;
%     zData=Data_diu.val(1,:,kl);
% 
%     figure
%     hold on
%     EHY_plotMapModelData(gridInfo,zData)
%     scatter(max_ucmaga_x,max_ucmaga_y,10,'rx')
%     axis equal
%     han.cbar=colorbar;
%     han.cbar.Label.String=sprintf('diffusivity at layer %d [m^2/s]',kl);
%     clim([0,0.1])
    
    %% dtcell
    
%     zData=Data_dtcell_minlay;
% 
%     figure
%     EHY_plotMapModelData(gridInfo,zData)
%     axis equal
%     han.cbar=colorbar;
%     han.cbar.Label.String='time step [s]';
    
%     path_fig_name=fullfile(dir_figs,sprintf('dtcell_%s',datestr(t0,'yyyy-mm-dd-HHMM')));
%     savefig(gcf,sprintf('%s.fig',path_fig_name))

    %% Patm
if flg.map_Patm
    zData=Data_Patm.val(1,:);

    figure
    hold on
    EHY_plotMapModelData(gridInfo,zData)
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='atmospheric pressure [Pa]';
end

end %map

%%
%% HIS
%%


%% sal

if flg.his_sal
    
%% time step
% 
% val=ncread(path_his,'timestep');
% figure
% hold on
% plot(val)

%%

for ks=1:ns
%     ks=2; %station
    val_stat=his_sal.val(:,ks,:);
    zint_stat=his_zint.val(:,ks,:);
    zcen_stat=his_zcen.val(:,ks,:);
%     wl_val_stat=his_wl.val(:,ks,:);
    
    % check interfaces

%     time_mat_zcen=repmat(his_sal.times,1,size(his_sal.val,3));
%     time_mat_zint=repmat(his_sal.times,1,size(his_sal.val,3)+1);
%     figure 
%     hold on
%     plot(his_wl.times,wl_val_stat,'-k','linewidth',2)
%     scatter(time_mat_zcen(:),zcen_stat(:),10,val_stat(:),'filled')
%     scatter(time_mat_zint(:),zint_stat(:),10,'*k')
    
    % salinity patch
    
    time_cor=cen2cor(his_sal.times);
    z_int_mat=reshape(zint_stat,nt,nl+1)';
    sal_mat=reshape(val_stat,nt,nl)';

    in.XCOR=time_cor;
    in.sub=z_int_mat;
    in.cvar=sal_mat;
    [faces,vertices,col]=rework4patch(in);
    
    switch flg.sal_u
        case 1
            col_p=col; %psu
            str_sal='salinity [psu]';
        case 2
            col_p=sal2cl(1,col);
            str_sal='chlorinity [mg/l]';
    end
    
    figure
    patch('faces',faces,'vertices',vertices,'FaceVertexCData',col,'edgecolor','k','FaceColor','flat');
%     patch('faces',faces,'vertices',vertices,'FaceVertexCData',col_p,'edgecolor','none','FaceColor','flat');
    han.cbar=colorbar;
    han.cbar.Label.String=str_sal;
    title(strrep(stations{ks},'_','\_'))
    fname_fig=sprintf('%s_sal.png',stations{ks});
    ylabel('elevation [m]')
    path_fig=fullfile(dir_figs,fname_fig);
    datetick('x') 

    print(gcf,path_fig,'-dpng','-r300')    
    
end %ks

end %sal

%% his etaw

if flg.his_etaw
   
    plot_his(flg,his_wl,dir_figs); 
if flg.fig_separate
    plot_his_sep(flg,his_wl,dir_figs); 
else
    plot_his_together(flg,his_wl,dir_figs);     
end

end %his_etaw

%% dt

if flg.his_dt
   tim_datet=datetime(his_dt.times,'convertFrom','datenum');
   figure('visible',fig_visible)
   hold on
   plot(tim_datet,his_dt.val);
    ylabel('water level [m+NAP]')

    fname_fig='his_dt.png';
    path_fig=fullfile(dir_figs,fname_fig);
    if flg.fig_print
        print(gcf,path_fig,'-dpng','-r300')    
        close(gcf)
    end
end

%% ucmaga

if flg.his_ucmaga
    plot_his_sep(flg,his_ucmaga,dir_figs)
end

end %function

%% 
%% FUNCTIONS
%%

%%

function plot_his_sep(flg,his_wl,dir_figs)
    
fig_visible=~flg.fig_print;
if isfield(flg,'fig_visible')==1
    fig_visible=flg.fig_visible;
end

fig_close=~flg.fig_print;
if isfield(flg,'fig_close')==1
    fig_close=flg.fig_close;
end

tim_datet=datetime(his_wl.times,'convertFrom','datenum');
stations=his_wl.requestedStations;
ns=numel(stations);

han.phe=[];
for ks=1:ns
    figure('visible',fig_visible)
    hold on
    han.phe(ks)=plot(tim_datet,his_wl.val(:,ks,:),'color','k');
    ylabel(labels4all(his_wl.OPT.varName,1,'en'))
    fname_fig=sprintf('%s_%s.png',stations{ks},his_wl.OPT.varName);
    title(strrep(stations{ks},'_','\_'))
    path_fig=fullfile(dir_figs,fname_fig);
    if flg.fig_print
        print(gcf,path_fig,'-dpng','-r300')  
        if fig_close
            close(gcf)
        end
    end
end %ks  
    
end %plot_his_sep

%%

function plot_his_together(flg,his_wl,dir_figs)

fig_visible=~flg.fig_print;
if isfield(flg,'fig_visible')==1
    fig_visible=flg.fig_visible;
end

fig_close=~flg.fig_print;
if isfield(flg,'fig_close')==1
    fig_close=flg.fig_close;
end

tim_datet=datetime(his_wl.times,'convertFrom','datenum');
stations=his_wl.requestedStations;
ns=numel(stations);

if ns<=9
    cmap=brewermap(ns,'set1');
else
    cmap=jet(ns);
end

figure('visible',fig_visible)
hold on
han.phe=[];
for ks=1:ns
    han.phe(ks)=plot(tim_datet,his_wl.val(:,ks,:),'color',cmap(ks,:));
end %ks
legend(han.phe,strrep(stations,'_','\_'),'location','eastoutside');
% legend(han.phe,strrep(stations,'_','\_'),'location','eastoutside','fontsize',3);
ylabel(labels4all(his_wl.OPT.varName,1,'en'))

fname_fig=sprintf('%s_etaw.png','obs');
path_fig=fullfile(dir_figs,fname_fig);
if flg.fig_print
    print(gcf,path_fig,'-dpng','-r300')   
    if fig_close
        close(gcf)
    end
end
    
end %function

%%

function plot_his(flg,his_wl,dir_figs)

if isfield(flg,'fig_separate')==0
    flg.fig_separate=0;
end

if flg.fig_separate
    plot_his_sep(flg,his_wl,dir_figs); 
else
    plot_his_together(flg,his_wl,dir_figs);     
end

end %function