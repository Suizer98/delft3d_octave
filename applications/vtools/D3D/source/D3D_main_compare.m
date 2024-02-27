%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(oetsettings)
   
%% PREAMBLE

clear
clc

%% INPUT

    %% simulations paths
%path to the folder containing the runs
path_runs_1='C:\Users\chavarri\temporal\200721_salzach\';

%path to each folder containing .mdu or .md1d files
ks=0;

% kf=kf+1; 
% dire_sim_v{kf}=fullfile(path_runs_1,'\r_002\dflowfm'); 
% desc_sim_v{kf}='curved';

% ks=ks+1; 
% dire_sim_v{ks}='C:\Users\chavarri\temporal\201009_rt_hkv\r002\dflowfm'; 
% desc_sim_v{ks}='dt = 300 s';

ks=ks+1; 
dire_sim_v{ks}='C:\Users\chavarri\temporal\201009_rt_hkv\r003\dflowfm'; 
desc_sim_v{ks}='dt = 120 s';

% ks=ks+1; 
% dire_sim_v{ks}='C:\Users\chavarri\temporal\201009_rt_hkv\r004\dflowfm'; 
% desc_sim_v{ks}='dt = 60 s';

ks=ks+1; 
dire_sim_v{ks}='C:\Users\chavarri\temporal\201009_rt_hkv\r005\dflowfm'; 
desc_sim_v{ks}='ISLope, MaximumWaterDepth';

    %% branches
    
% kb=0;

% kb=kb+1;
% branch_v{kb,1}={'01_SAZ','02_SAZ','03_SAZ','04_SAZ','05_SAZ','06_SAZ','07_SAZ','08_SAZ','09_SAZ','10_SAZ','11_SAZ','12_SAZ','13_SAZ_A','13_SAZ_B_A','13_SAZ_B_B_A','13_SAZ_B_B_B_A','13_SAZ_B_B_B_B','14_SAZ','15_SAZ','16_SAZ_A','16_SAZ_B'};
% br_name{kb,1}='c1';

kb=0;

% kb=kb+1;
% branch_v{kb,1}={'29_A','29_B_A','29_B_B','29_B_C','29_B_D','52_A','52_B','31_A_A','31_A_B','31_A_C','31_B','51_A','BovenLobith','Bovenrijn'};
% br_name{kb,1}='Rhein - Boven-Rijn';
% 
% kb=kb+1;
% branch_v{kb,1}={'Waal1','Waal2','Waal3','Waal4','Waal5','Waal6'};
% br_name{kb,1}='Waal';
% 
% kb=kb+1;
% branch_v{kb,1}={'PanKan1','PanKan2'};
% br_name{kb,1}='Pannerdensch Kanaal';

kb=kb+1;
branch_v{kb,1}={'Nederrijn1','Nederrijn2','Nederrijn3','Nederrijn4','Nederrijn5','Nederrijn6','Lek1','Lek2','Lek4','Lek5','Lek6','Lek7','Lek8'};
br_name{kb,1}='Nederrijn - Lek';

% kb=kb+1;
% branch_v{kb,1}={'IJssel01','IJssel02','IJssel03','IJssel04','IJssel05','IJssel06','IJssel07','IJssel08','IJssel09','IJssel10','IJssel11','IJssel12','Keteldiep'};
% br_name{kb,1}='IJssel';
% 
% kb=kb+1;
% branch_v{kb,1}={'Kattendiep1','Kattendiep2'};
% br_name{kb,1}='Kattendiep';

    %% time
time_data=0; %0=all times (one time call); 1=several times (several time calls); 
kt_v=[NaN]; %times to plot. If NaN, takes the last one. 
time_cmp=1; %if plotting until last result available: 1=take the same result time (largest) for all simulations (if mapinterval is the same); 2=take last one for each simulation

    %% variable to plot
% which_v_v=[1,2,12,28];
which_v_v=[1];
%   1=etab
%   2=h
%   3=dm Fak
%   4=dm fIk
%   5=fIk
%   6=I
%   7=elliptic
%	8=Fak
%   9=detrended etab based on etab_0
%   10=depth averaged velocity
%   11=velocity
%   12=water level
%   13=face indices
%   14=active layer thickness
%   15=bed shear stress
%   16=specific water discharge
%   17=cumulative bed elevation
%   18=water discharge 
%   19=bed load transport in streamwise direction (at nodes)
%   20=velocity at the main channel
%   21=discharge at main channel
%   22=cumulative nourished volume of sediment
%   23=suspended transport in streamwise direction
%   24=cumulative bed load transport
%   25=total sediment mass (summation of all substrate layers)
%   26=dg Fak
%   27=total sediment thickness (summation of all substrate layers)
%   28=main channel averaged bed level
%   29=sediment transport magnitude at edges m^2/s
%   30=sediment transport magnitude at edges m^3/s
%   31=morphodynamic width [m]
%   32=Chezy 
%   33=cell area [m^2]

    %% conversion to river kilometers
in_read.path_rkm="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rkm_rijntakken_rhein.csv";
in_read.rkm_curved="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rijn-flow-model_map_curved.nc";
in_read.rkm_TolMinDist=300; %tolerance for accepting an rkm point

%% PRE-CALC

    %% not input
simdef.flg.which_p=3; %plot type 

    %% size
    
nb=numel(branch_v);
ns=numel(dire_sim_v);
nv=numel(which_v_v);

    %% max number time steps
    
%preallocate
aux_max_nTt=NaN(ns,1);

for ks=1:ns

in_read.kt=0;
simdef.D3D.dire_sim=dire_sim_v{ks};
simdef=D3D_comp(simdef);
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);

aux_max_nTt(ks)=out_read.nTt;

end

max_nTt=min(aux_max_nTt);
fprintf('number of map results = %d \n',max_nTt)

%% CALC

    %% simulations
    
%time
switch time_data
    case 0
        switch time_cmp
            case 1
                in_read.kt=[1,max_nTt];
            case 2
                kt_v_m=[ones(ns,1),aux_max_nTt];
        end
        nt=1;
    case 1
        switch time_cmp
            case 1
                kt_v(isnan(kt_v))=max_nTt;
            case 2
                kt_v_m=NaN(ns,numel(kt_v));
                for ks=1:ns
                    kt_v_m(ks,:)=kt_v;
                    kt_v_m(ks,isnan(kt_v))=aux_max_nTt(ks);
                end 
        end
        nt=size(kt_v,2);
%     case 2
%         if isnan(kt_v)
%             in_read.kt=[max_nTt,1];
%         else
%             in_read.kt=[kt_v,1];
%         end
%         nt=1;
end
   
%preallocate
z=cell(ns,nb,nt,nv);
SZ=cell(ns,nb,nt,nv);
time_r=cell(ns,nb,nt,nv);
zlab=cell(nv);
refdate=cell(ns,1);

for kb=1:nb
    for ks=1:ns
        for kt=1:nt
            for kv=1:nv
                %adapt input
                switch time_data
                    case 0
                        switch time_cmp
                            case 1
%                                 in_read.kt=[kt_v(kt),1];
                            case 2
                                in_read.kt=kt_v_m(ks,:);
                        end
                    case 1
                        switch time_cmp
                            case 1
                                in_read.kt=[kt_v(kt),1];
                            case 2
                                in_read.kt=[kt_v_m(ks,kt),1];
                        end
                end
                in_read.branch=branch_v{kb,1};        
                simdef.D3D.dire_sim=dire_sim_v{ks};
                simdef.flg.which_v=which_v_v(kv); 

                %call
                simdef=D3D_comp(simdef);
                simdef=D3D_simpath(simdef);
                out_read=D3D_read(simdef,in_read);
                mdf=dflowfm_io_mdu('read',simdef.file.mdf);
                

                %save
                z{ks,kb,kt,kv}=out_read.z;
                SZ{ks,kb,kt,kv}=out_read.SZ;
                time_r{ks,kb,kt,kv}=out_read.time_r;
                zlab{kv}=out_read.zlabel;
                refdate{ks,1}=mdf.time.RefDate;

                %disp
                fprintf('branch %4.2f %% simulation %4.2f %% time %4.2f %% variable %4.2f %% \n',kb/nb*100,ks/ns*100,kt/nt*100,kv/nv*100);
            end
        end
    end
end %kb

%% ERROR

% between runs for all times
z_err=cell(nb,ns-1,nt);

for kb=1:nb
    for ks=2:ns
        for kt=1:nt
    %assuming same s vector!    
%    z_err{ks,kb,kt,kv}=z{ks,kt}-z{ks,kt}; 

    %interpolating
%     z_int=interp1(SZ{ks,kt,kb},z{ks,kt,kb},SZ{1,kt,kb});
%     z_err{kb,ks-1,kt}=z_int-z{1,kt,kb};
    
        end
    end
end %kb

%%
%% PLOT
%%

%%
%% time_data=0
%%

if time_data==0
    
%% 1 simulation, 1 branch, 1 variable, all times (time_data=0)

kb=1;
kt=1;
for kv=1:nv
    for ks=1:ns
        nt=size(z{ks,kb,kt,kv},2);
        cmap=brewermap(nt,'RdYlGn');
        refdate_str=num2str(refdate{ks,1});
        time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb});
        figure 
        hold on
        for kt0=1:nt
            plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv}(:,kt0),'color',cmap(kt0,:))
        end

        han.cbar=colorbar;
        han.cbar.Label.String='time';
        clim([min(time_r{ks,kb}),max(time_r{ks,kb})]);
        aux_tick=linspace(min(time_r{ks,kb}),max(time_r{ks,kb}),10);
        han.cbar.YTick=aux_tick;
        han.cbar.YTickLabel=datestr(datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(aux_tick),'dd/mm/yyyy');
        colormap(cmap);

        title(sprintf('%s %s',br_name{kb,1},desc_sim_v{ks}))
        ylabel(zlab{kv})
        xlabel('streamwise coordinate [m]')

%         print(gcf,sprintf('xvallt_ks_%s_kb_%s_kt_%02d_kv_%02d.png',desc_sim_v{ks},br_name{kb,1},kt,which_v_v(kv)),'-dpng','-r300')
%         close(gcf)
    end
end

%% x-t

kt=1;
kv=1;
kv_m=1;

z_p=cell(ns,nb);
z_p_mea=cell(1,nb);

cmap=brewermap(100,'Reds');

for kv=1:nv
    for kb=1:nb
        for ks=1:ns

            refdate_str=num2str(refdate{ks,1});
            time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb});
    %         time_d=time_r{ks,kb};
            [s_m,t_m]=meshgrid(SZ{ks,kb},time_d);

    %         SZ_p{ks,kb}=s_m;
    %         time_p{ks,kb}=t_m;

            z_p{ks,kb}=z{ks,kb,kt,kv};
            str_var=zlab{kv};

    %         z_p{ks,kb}=z{ks,kb,kt,kv}-repmat(z{ks,kb,kt,kv}(:,1),1,size(z{ks,kb,kt,kv},2)); %with respect to initial 
    %         str_var=sprintf('change in %s',zlab{kv});

    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}-z{ks,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv_m}-z{ks,kb,1,kv_m}; %initial condition of simulations is measured

            figure
            hold on

            surf(s_m,t_m,z_p{ks,kb}','edgecolor','none')

            title(sprintf('%s %s',br_name{kb,1},desc_sim_v{ks}))
            xlabel('streamwise coordinate [m]')
            ylabel('time')

            han.cbar=colorbar;
            han.cbar.Label.String=str_var;
            colormap(cmap);

%             print(gcf,sprintf('xt_ks_%s_kb_%s_kt_%02d_kv_%02d.png',desc_sim_v{ks},br_name{kb,1},kt,which_v_v(kv)),'-dpng','-r300')
%             close(gcf)
        end
    end
end

%%
%% time_data=1
%%

else
  
%% 1 simulation, all branches branch, 1 variable, 1 time

ks=1;
kv=1;
kt=1;

% nt=size(z{ks,kb,kt,kv},2);
nt=size(z,3);
% cmap=brewermap(nt,'RdYlGn');
cmap=brewermap(nt,'set1');
for kb=1:nb
figure 
hold on
for kt=1:nt
    plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv},'color',cmap(kt,:))
end
% han.cbar=colorbar;
% han.cbar.Label.String='time [s]';
% clim([min(time_r{ks,kb,kt,kv}),max(time_r{ks,kb,kt,kv})]);
% colormap(cmap);
title(br_name{kb,1})
ylabel(zlab{kv})
xlabel('streamwise coordinate [m]')
end

end %time_data






% for ks=1:ns
% for kb=1:nb
% in_p.SZ_p=SZ_p{ks,kb};
% in_p.time_p=time_p{ks,kb};
% in_p.z_p=z_p{ks,kb};
% % in_p.SZ_mea=SZ_mea(:,kb);
% % in_p.z_p_mea=z_p_mea(:,kb);
% in_p.zlab=zlab{kv};    
% in_p.kv=kv;
% in_p.kb=kb;
% in_p.ks=ks;
% in_p.absrel=1; %1=absolute; 2=relative
% in_p.plot_mea=0; %plot measured
% in_p.leg=desc_sim_v;
% in_p.fig_print=0;
% in_p.tit=br_name{kb};
% in_p.tag='regxt';
% 
% fig_xt(in_p)

%%
% kv=2;
% kt=2;
% kb=1;
% 
% nf=size(z{ks,kb,kt,kv},2);
% lsty={'-','--'};
% cmap=brewermap(nf,'set1');
% figure
% hold on
% for ks=1:ns
% % plot(SZ{ks,kb},z{ks,kb,kt,kv}-z{ks,kb,1,kv})
% for kf=1:nf
% han.p(ks)=plot(SZ{ks,kb},z{ks,kb,kt,kv}(:,kf),'linestyle',lsty{ks},'color',cmap(kf,:));
% end
% end
% title(sprintf('time = %f s',time_r{ks,kb,kt,kv}))
% legend(han.p,desc_sim_v)
% xlabel('x-coordinate [m]')
% ylabel('sediment transport rate [m^2/s]')
% print(gcf,'sedtrans.png','-dpng','-r600')

%% all simulations

% kv=1;
% kt=1;
% kb=1;
% 
% nf=size(z{ks,kb,kt,kv},2);
% % lsty={'-','--'};
% % cmap=brewermap(nf,'set1');
% figure
% hold on
% for ks=1:ns
% plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv})
% end
% title(sprintf('time = %f s',time_r{ks,kb,kt,kv}))
% legend(desc_sim_v)
% xlabel('x-coordinate [m]')
% ylabel(zlab{kv})
% print(gcf,'p.png','-dpng','-r600')


%% difference with reference simulation

% kv=1;
% kt=1;
% kb=1;
% ks_ref=1;
% idx_ks=1:1:ns;
% idx_ks(idx_ks==ks_ref)=[];
% 
% nf=size(z{ks,kb,kt,kv},2);
% lsty={'-','--'};
% cmap=brewermap(nf,'set1');
% figure
% hold on
% for ks=idx_ks
% plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv}-z{ks_ref,kb,kt,kv})
% end
% title(sprintf('time = %f s',time_r{ks,kb,kt,kv}))
% % legend(desc_sim_v)
% xlabel('x-coordinate [m]')
% ylabel(sprintf('%s difference',zlab{kv}))
% print(gcf,'diff.png','-dpng','-r600')

%%
% 
% if flg.plot_xt
% for ks=1:ns
% for kb=1:nb
% in_p.SZ_p=SZ_p{ks,kb};
% in_p.time_p=time_p{ks,kb};
% in_p.z_p=z_p{ks,kb};
% % in_p.SZ_mea=SZ_mea(:,kb);
% % in_p.z_p_mea=z_p_mea(:,kb);
% in_p.zlab=zlab{kv};    
% in_p.kv=kv;
% in_p.kb=kb;
% in_p.ks=ks;
% in_p.absrel=1; %1=absolute; 2=relative
% in_p.plot_mea=0; %plot measured
% in_p.leg=desc_sim_v;
% in_p.fig_print=0;
% in_p.tit=br_name{kb};
% in_p.tag='regxt';
% 
% fig_xt(in_p)
% 
% end
% end
% end
% 
% %%
% 
% % in_p.SZ_p=SZ_p{ks,kb};
% % in_p.time_p=time_p{ks,kb};
% % in_p.z_p=z_p{ks,kb};
% % % in_p.SZ_mea=SZ_mea(:,kb);
% % % in_p.z_p_mea=z_p_mea(:,kb);
% % in_p.zlab=zlab{kv};    
% % in_p.kv=kv;
% % in_p.kb=kb;
% % in_p.ks=ks;
% % in_p.absrel=1; %1=absolute; 2=relative
% % in_p.plot_mea=0; %plot measured
% % in_p.leg=desc_sim_v;
% % in_p.fig_print=0;
% % in_p.tit=br_name{kb};
% % in_p.tag='regxt';
% 
% %%
% 
% in_p2.kb=1;
% in_p2.kx=NaN; %NaN is last
% in_p2.idx_p=1:1:ns;
% in_p2.tag='br';
% in_p2.time_p=time_p;
% in_p2.z_p=z_p;
% in_p2.tit=br_name{in_p2.kb};
% in_p2.leg=desc_sim_v;
% 
% fig_tv(in_p2)
% 
% %%
% in_p2.kb=2;
% in_p2.kx=1; %NaN is last
% in_p2.idx_p=1:1:ns;
% in_p2.tag='wa';
% in_p2.time_p=time_p;
% in_p2.z_p=z_p;
% in_p2.tit=br_name{in_p2.kb};
% in_p2.leg=desc_sim_v;
% 
% fig_tv(in_p2)
% 
% %%
% in_p2.kb=3;
% in_p2.kx=1; %NaN is last
% in_p2.idx_p=1:1:ns;
% in_p2.tag='pk';
% in_p2.time_p=time_p;
% in_p2.z_p=z_p;
% in_p2.tit=br_name{in_p2.kb};
% in_p2.leg=desc_sim_v;
% 
% fig_tv(in_p2)
% 
% %%
% 
% % kt=nt;
% % kv=3;
% % kv_m=1;
% % 
% % z_p=cell(ns,nb);
% % z_p_mea=cell(1,nb);
% % 
% % for kb=1:nb
% %     for ks=1:ns
% %         z_p{ks,kb}=z{ks,kb,kt,kv};
% %         z_p_mea{1,kb}=z{ks,kb,1,kv}; %initial condition of simulations is measured
% % 
% % %         z_p_mea{1,kb}=z_mea{1,kb,1,kv_m}-z{ks,kb,1,kv_m}; %initial condition of simulations is measured
% %         
% % %         z_p{ks,kb}=z{ks,kb,kt,kv};
% % %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}; %initial condition of simulations is measured
% %     end
% % end
% % 
% % for kb=1:nb
% % in_p.SZ_p=SZ(:,kb,kt,kv);
% % in_p.z_p=z_p(:,kb);
% % in_p.SZ_mea=SZ(:,kb,kt,kv);
% % in_p.z_p_mea=z_p_mea(:,kb);
% % in_p.zlab=zlab{kv};    
% % in_p.kv=kv;
% % in_p.kb=kb;
% % in_p.absrel=1; %1=absolute; 2=relative
% % in_p.plot_mea=1; %plot measured
% % in_p.leg=desc_sim_v;
% % in_p.fig_print=1;
% % in_p.tit=br_name{kb};
% % 
% % fig_long_rel(in_p)
% % 
% % end
% 
% %%
% 
% % kb=1;
% % figure
% % hold on
% % plot(z_mea{1,kb,1,kv})
% % plot(z{ks,kb,1,kv})
% % %%
% % 
% % kt=nt;
% % 
% % sty={'-b','*r'};
% % cmap=brewermap(ns,'set1');
% % for kb=1:nb
% %     
% % han.fig=figure;
% % set(han.fig,'paperunits','centimeters','paperposition',[0,0,14.5,13])
% % % 
% % 
% % hold on
% % for ks=1:ns
% %     han.p0(ks)=plot(SZ{ks,kb,kt},zeros(size(SZ{ks,kb,kt})),'linestyle','-','color','k');
% % % han.p(ks)=plot(SZ{ks,kb},z{ks,kb},'linestyle','-','color',cmap(ks,:));
% % han.p(ks)=plot(SZ{ks,kb,kt},z{ks,kb,kt}-z{ks,kb,1},'linestyle','-','color',cmap(ks,:));
% % 
% % end
% % 
% % % 
% % legend(han.p,desc_sim_v,'location','eastoutside')
% % xlabel('streamwise position [m]')
% % % ylabel(out_read.zlabel)
% % ylabel({'change in',zlab{kv}})
% % title(br_name{kb,1})
% % print(han.fig,sprintf('d_etab_%d.png',kb),'-dpng','-r300')
% % end

%%

