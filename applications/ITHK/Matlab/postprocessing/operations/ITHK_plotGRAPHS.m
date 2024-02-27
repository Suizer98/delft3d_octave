function ITHK_plotGRAPHS(sens)


global S

%% INPUT PARAMETERS
ind_
%groyne
%nourishment
%revetment
ind_eco1     =  S.PP(sens).GEmapping.eco(1).benthos;
ind_eco2     =  S.PP(sens).GEmapping.eco(2).benthos;
ind_juvfish  =  S.PP(sens).GEmapping.foreshore.juvenilefish;
ind_costs1   =  S.PP(sens).GEmapping.costs.direct1;
ind_costs2   =  S.PP(sens).GEmapping.costs.direct2;
ind_costs3   =  S.PP(sens).GEmapping.costs.direct3;
ind_dunecl   =  S.PP(sens).GEmapping.dunes.duneclasses;
ind_dunehr   =  S.PP(sens).GEmapping.dunes.habitatrichness;
ind_recrb    =  S.PP(sens).GEmapping.recreation.beachwidth;
ind_recrd    =  S.PP(sens).GEmapping.recreation.dunearea;
ind_drwat    =  S.PP(sens).GEmapping.drinkwater.dunearea;
ind_grwat    =  S.PP(sens).GEmapping.residential.groundwater;



coastline
duneposition
























%% DETERMINE PARAMETERS
section = [86:300];      % coast between Scheveningen & IJmuiden
section1 = [130:230];    % coast between Scheveningen & IJmuiden
section2 = [139:190];    % coast between Scheveningen & IJmuiden
dz_crit = [0,10,20,40];  % dz_crit = 1;
for ii=1:nrruns     
    S = load([modeldir3 SCdirs(ii).name filesep SCdirs(ii).name '.mat']);
    S.userinput.name                = SCdirs(ii).name;
    z = S.UB(1).results.PRNdata.z(section,:)-S.UB(1).data_ref.PRNdata.z(section,1:S.userinput.duration+1);
    cellwidth = S.PP.settings.s0(section(2):section(end)+1)-S.PP.settings.s0(section);
    cellwidth1 = S.PP.settings.s0(section1(2):section1(end)+1)-S.PP.settings.s0(section1);
    % sum impacts for all coastal sections
    for jj=1:S.userinput.duration+1
        S.output.dz_crit                  = dz_crit;
        for kk=1:length(dz_crit)
            impactids                     = find(z(:,jj)>dz_crit(kk));
            S.output.impactarea{kk}(jj)   = sum(z(impactids,jj).*cellwidth(impactids));
            S.output.impactlength{kk}(jj) = sum(cellwidth(impactids));
        end
        for kk=1:length(S.PP.eco)
            S.output.eco(kk).P(jj)        = sum(S.PP.eco(kk).P(jj,section2))/length(section2);
        end
        for kk=1:3
            idunes = find(S.PP.dunes.duneclass(section1,jj)==kk);
            idunesref = find(S.PP.dunes.duneclassref(section1,jj)==kk);
            S.output.dunes.duneclass{kk}(jj)     = sum(cellwidth1(idunes))/sum(cellwidth1);
            S.output.dunes.duneclassref{kk}(jj)  = sum(cellwidth1(idunesref))/sum(cellwidth1);
        end
    end
    save([S.settings.outputdir S.userinput.name,'2.mat'],'-struct','S');
end

%% RE-ARRANGE DATA OF SEPERATE UNIBEST DATA FILES (S) IN ONE STRUCTURE (T)
T = struct;
for ii=1:length(volume)
    name = ['katwijk_' strrep(num2str(volume(ii)/10^6),'.','') 'Mm3_95yr_new'];
    %name = 'katwijk_2Mm3_95yr_cont';
    S = load([modeldir3 name filesep name '2.mat']);
    T(ii).volume        = volume(ii);
    T(ii).name          = name;

    for kk=1:length(S.output.impactarea)
    T(ii).dz_crit           = S.output.dz_crit;
    T(ii).impactarea{kk}    = S.output.impactarea{kk};
    T(ii).impactlength{kk}  = S.output.impactlength{kk};
    end
    for kk=1:length(S.output.eco)
        T(ii).eco(kk)   = S.output.eco(kk);
    end
    for kk=1:length(S.output.dunes.duneclass)
        T(ii).duneclass{kk}    = S.output.dunes.duneclass{kk};
    end
end

%% PLOT IMPACT LENGTH
colors = {'k','r','b','g','m','c','y'};legtxt={};
for kk=[1,3] %1:length(dz_crit)
    figure('Position',[100 100 900 600]);
    for ii=1:length(volume)
        hp(ii) = plot(T(ii).impactlength{kk},'color',colors{ii});hold on;
        legtxt{ii} = ['V = ',num2str(volume(ii)/1e6),' 10^6 m3'];
    end
    hleg = legend(hp,legtxt,'Location','NorthWest');
    xlabel('time [years]');
    ylabel('impact length [m]');
    if kk==1
        title(['total impacted length of nourishment']);
        print('-dpng','-r150','Fig1A_impactlength_total.png');
    elseif kk==3
        title(['impact length of nourishment with minimum width of y_m_i_n = ',num2str(dz_crit(kk)),'m)']);
        print('-dpng','-r150','Fig1B_impactlength_minwidthcriterion.png');
    end
end

%% PLOT IMPACT ON POPULATION
colors = {'k','r','b','g','m','c','y'};
for kk=1:length(T(ii).eco)
    figure('Position',[40 20 600 800]);legtxt={};
    for ii=1:length(volume)
        P          = T(ii).eco(kk).P;
        legtxt     = S.PP.eco(kk).name;
        subplot(4,2,ii);
        hbar = bar(P(1:20),1);
        set(hbar(1),'FaceColor',colors{kk+1});
        set(hbar(1),'LineStyle','none');
        if ii==length(volume)
            hleg = legend(hbar,legtxt);
            set(hleg,'Position',[0.57 0.11 0.3 0.15],'FontSize',12,'FontWeight','bold');
        end
        xlabel('time [years]');
        ylabel(strvcat('population','[% relative to initial]'));
        ht = title(['volume = ',num2str(volume(ii)/1e6),' 10^6 m3']);
        set(ht,'FontSize',9,'FontWeight','bold');    
    end
    if kk==1
        print('-dpng','-r150',['Fig2A_population_',S.PP.eco(kk).name,' (r=',num2str(S.PP.eco(kk).r),').png']);    
    elseif kk==2
        print('-dpng','-r150',['Fig2B_population_',S.PP.eco(kk).name,' (r=',num2str(S.PP.eco(kk).r),').png']);    
    end
end
% combined figure
colors = {'k','r','b','g','m','c','y'};
figure('Position',[40 20 600 800]);legtxt={};
for ii=1:length(volume)
    P=[];
    for kk=1:length(T(ii).eco)
        P(:,kk)          = T(ii).eco(kk).P;
    end
    legtxt     = {S.PP.eco(1).name,S.PP.eco(2).name};
    subplot(4,2,ii);
    hbar = bar(P(1:20,:),1.2);
    set(hbar(1),'FaceColor',colors{2});
    set(hbar(2),'FaceColor',colors{3});
    set(hbar(1),'LineStyle','none');
    set(hbar(2),'LineStyle','none');
    if ii==length(volume)
        hleg = legend(hbar,legtxt);
        set(hleg,'Position',[0.57 0.11 0.3 0.15],'FontSize',12,'FontWeight','bold');
    end
    xlim([0,20]);
    ylim([0,105]);
    xlabel('time [years]');
    ylabel(strvcat('population','[% relative to initial]'));
    ht = title(['volume = ',num2str(volume(ii)/1e6),' 10^6 m3']);
    set(ht,'FontSize',9,'FontWeight','bold');    
end
print('-dpng','-r150',['Fig2C_population_(',S.PP.eco(1).name,' & ',S.PP.eco(2).name,').png']);    

%% PLOT DUNES TYPES IN TIME (SEPERATELY FOR EACH RUN)
figure('Position',[40 20 600 800]);legtxt={};
for ii=1:length(volume)
    subplot(4,2,ii);
    Y = [T(ii).duneclass{1}',T(ii).duneclass{2}',T(ii).duneclass{3}'];
    harea = area(Y);
    set(harea(1),'FaceColor',[1 0 0]);
    set(harea(2),'FaceColor',[1  1 0]);
    set(harea(3),'FaceColor',[0  1 0]);

    if ii==length(volume)
    legtxt{1} = strvcat('class 1 : erosive','(also erosion of nourishment)');
    legtxt{2} = strvcat('class 2 : balance and','slight new dune formation','(also wide beach to normal)');
    legtxt{3} = strvcat('class 3 : new dune',' formation on wide beach','(also stable wide beach)');
    hleg = legend(harea,legtxt);
    set(hleg,'Position',[0.57 0.095 0.375 0.18],'FontSize',8,'FontWeight','bold');
    end
    xlabel('time [years]');
    ylabel(strvcat('relative importance','per dune class [%]'));
    ht = title(['volume = ',num2str(volume(ii)/1e6),' 10^6 m3']);
    set(ht,'FontSize',9,'FontWeight','bold');
end
print('-dpng','-r150',['Fig3_dunetypes.png']);    

%% PLOT IMPACT AREA
colors = {'k','r','b','g','m','c','y'};legtxt={};
for kk=[1,3];%2:length(dz_crit)
    figure('Position',[100 100 900 600]);
    for ii=1:length(volume)
        hp(ii) = plot(T(ii).impactarea{kk},'color',colors{ii});hold on;
        legtxt{ii} = ['V = ',num2str(volume(ii)/1e6),' 10^6 m3'];
    end
    hleg = legend(hp,legtxt,'Location','NorthWest');
    xlabel('time [years]');
    ylabel('impact area [m^2]');
%    title(['impact area for criterion of y_m_i_n = ',num2str(dz_crit(kk)),'m']);
    if kk==1
        title(['total impacted area of nourishment']);
        print('-dpng','-r150','Fig4A_impactarea_total.png');
    elseif kk==3
        title(['impact area of nourishment with minimum width of y_m_i_n = ',num2str(dz_crit(kk)),'m)']);
        print('-dpng','-r150','Fig4B_impactarea_minwidthcriterion.png');
    end
end