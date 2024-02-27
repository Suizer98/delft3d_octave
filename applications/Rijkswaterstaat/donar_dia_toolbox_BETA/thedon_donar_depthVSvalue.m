function thedon_donar_depthVSvalue
% thedon_donar_depthVSvalue
% Makes plots of presence of measurements in time. The X axis is day
% number while the Y axis is the year. A dot in the graph means that for
% that day and year there is an observation available. 
    clc; clear; close all, fclose all;

    files_of_interest = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...
    };

    warning off;
    
% -> Specify names of sensors:
    sensors = {'CTD';'FerryBox';'ScanFish'};
    
    for ifile=1:length(files_of_interest)
        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor      = sensors{1};
        elseif strfind(lower(files_of_interest{ifile}),'ferrybox')
            sensor      = sensors{2};
        elseif strfind(lower(files_of_interest{ifile}),'scanfish')
            sensor      = sensors{3};
        end
        
        disp(['Loading: ',files_of_interest{ifile}]);
        thefile = importdata(files_of_interest{ifile});
                
        temp = donar_depthVSvalue(thefile,'turbidity',20);
        
        if ifile == 1
            p = temp;
        else
            p = [p; temp];
        end
        
    end
    
    
    thefontsize = 20;
%% TEMPORAL BEHAVIOR OF THE LOG-FIT PARAMETERS
    
    % p_filtered = p(p(:,1) < 110 & p(:,3) < 10  & p(:,3) > -10 & p(:,2) < 0.2 & p(:,2) > -0.2,:);
    p_filtered = p( p(:,1) > percentile(p(:,1),5)  & ...
                 p(:,1) < percentile(p(:,1),95)  & ...
                 p(:,2) > percentile(p(:,2),5)  & ...
                 p(:,2) < percentile(p(:,2),95)& ...
                 p(:,3) > percentile(p(:,3),5) & ...
                 p(:,3) < percentile(p(:,3),95) ...
                 ,:);

                
    close all
    p_filtered = sortrows(p_filtered,6);
    
% ->  
    figure(1)
    xlim([0,366])
    title('Parameter A vs Time','fontweight','bold','fontsize',thefontsize)
    xlabel('Day','fontsize',thefontsize)
    ylabel('A','fontsize',thefontsize)
    hold on
    plot(p_filtered(:,6),p_filtered(:,1),'.b','markersize',20)
    set(gca,'fontsize',thefontsize-6)
    print('-dpng','lognormalfit_p1vsT')
    close
    
    figure(2)
    xlim([0,366])
    xlabel('Day','fontsize',thefontsize)
    ylabel('B','fontsize',thefontsize)
    hold on
    plot(p_filtered(:,6),p_filtered(:,2),'.b','markersize',20)
    title('Parameter B vs Time','fontweight','bold','fontsize',thefontsize)
    set(gca,'fontsize',thefontsize-6)
    print('-dpng','lognormalfit_p2vsT')
    close
    
    figure(3)
    xlim([0,366])
    xlabel('Day','fontsize',thefontsize)
    ylabel('C','fontsize',thefontsize)
    hold on
    plot(p_filtered(:,6),p_filtered(:,3),'.b','markersize',20)
    title('Parameter C vs Time','fontweight','bold','fontsize',thefontsize)
    set(gca,'fontsize',thefontsize-6)
    print('-dpng','lognormalfit_p3vsT')
    close

%% SPATIAL BEHAVIOR OF THE LOG-FIT PARAMETERS
    
    close all
    
    p_negative = sortrows(p_filtered(   p_filtered(:,2)<0,:   ),5);
    
%     figure
%     set(gcf,'PaperPositionMode','auto');
%     plot_map('lonlat','color',[0.5,0.5,0.5])
%     hold on
%     scatter(p_negative(:,4),p_negative(:,5),50,p_negative(:,1),'filled')
%     colorbar 
%     title('Parameter 1','fontsize',16)
%     set(gca,'fontsize',16)
%     print('-dpng','lognormalfit_p1_vs_space_negative')
    close
    
    figure
    set(gcf,'PaperPositionMode','auto');
    plot_map('lonlat','color',[0.5,0.5,0.5])
    hold on
    scatter(p_negative(:,4),p_negative(:,5),50,p_negative(:,2),'filled')
    colorbar
    title('Parameter 2','fontsize',16)
    set(gca,'fontsize',16)
    print('-dpng','lognormalfit_p2_vs_space_negative')
    close
    
%     figure
%     set(gcf,'PaperPositionMode','auto');
%     plot_map('lonlat','color',[0.5,0.5,0.5])
%     hold on
%     scatter(p_negative(:,4),p_negative(:,5),50,p_negative(:,3),'filled')
%     colorbar
%     clim([-2 4])
%     title('Parameter 3','fontsize',16)
%     set(gca,'fontsize',16)
%     print('-dpng','lognormalfit_p3_vs_space_negative')
%     close

     
    
    p_positive = sortrows(p_filtered(   p_filtered(:,2)>0,:   ),5);
    
%     figure
%     set(gcf,'PaperPositionMode','auto');
%     plot_map('lonlat','color',[0.5,0.5,0.5])
%     hold on
%     scatter(p_positive(:,4),p_positive(:,5),50,p_positive(:,1),'filled')
%     colorbar 
%     title('Parameter 1','fontsize',16)
%     set(gca,'fontsize',16)
%     print('-dpng','lognormalfit_p1VSspace_positive')
%     close
    
    figure
    set(gcf,'PaperPositionMode','auto');
    plot_map('lonlat','color',[0.5,0.5,0.5])
    hold on
    scatter(p_positive(:,4),p_positive(:,5),50,p_positive(:,2),'filled')
    colorbar
    title('Parameter 2','fontsize',16)
    set(gca,'fontsize',16)
    print('-dpng','lognormalfit_p2VSspace_positive')
    close
    
%     figure
%     set(gcf,'PaperPositionMode','auto');
%     plot_map('lonlat','color',[0.5,0.5,0.5])
%     hold on
%     scatter(p_positive(:,4),p_positive(:,5),50,p_positive(:,3),'filled')
%     colorbar
%     clim([-2 4])
%     title('Parameter 3','fontsize',16)
%     set(gca,'fontsize',16)
%     print('-dpng','lognormalfit_p3VSspace_positive')
%     close
    
%% EXAMPLES OF PROFILES WITH NEGATIVE SHAPE PARAMETER
    close all
    clc
    
    p_negative = sortrows(p_filtered(   p_filtered(:,2)<0,:   ),5);
    num_p = 7;
    
    figure
    set(gcf,'PaperPositionMode','auto');
    themap = colormap;
    posw = ([560   528   907   420]);
    set(gcf,'position',posw)
  % ->     
    subplot(1,2,1)
    set(gcf,'PaperPositionMode','auto');
    plot_map('lonlat')
    hold on
    plot(p_negative(:,4),p_negative(:,5),'.b')
    set(gca,'fontsize',thefontsize-6)
    
  % ->
    subplot(1,2,2)
    set(gcf,'PaperPositionMode','auto');
    ylabel('Depth','fontsize',thefontsize)
    xlabel('Upoly0 [-]','fontsize',thefontsize)
    hold on
    axis square
    maxZ = length(p_negative);
    set(gca,'fontsize',thefontsize-6)
    
    for ip = 1:fix(maxZ/num_p):maxZ
        thecolor = fix((ip - 1)/(maxZ - 1)*63+1);
        
        subplot(1,2,1)
        plot(p_negative(ip,4),p_negative(ip,5),'o','color',themap(thecolor,:),'linewidth',2)
        
                
        subplot(1,2,2)
        plot(p_negative(ip,1)*exp(p_negative(ip,2)*(log([0:0.5:30])-p_negative(ip,3)).^2),-[0:0.5:30],'.','color',themap(thecolor,:)) 
    end
   
   print('-dpng','lognormalfit_examples_negative')
   close
   
%% EXAMPLES OF PROFILES WITH POSITIVE SHAPE PARAMETER
    close all
    clc
    
    p_positive = sortrows(p_filtered(   p_filtered(:,2)>0,:   ),5);
    num_p = 7;
    
    figure
    set(gcf,'PaperPositionMode','auto');
    themap = colormap;
    posw = ([560   528   907   420]);
    set(gcf,'position',posw)
    
  % ->
    subplot(1,2,1)
    plot_map('lonlat','color',[0.5,0.5,0.5])
    hold on
    plot(p_positive(:,4),p_positive(:,5),'.b')
    set(gca,'fontsize',thefontsize-6)
    
  % -> 
    subplot(1,2,2)
    ylabel('Depth','fontsize',thefontsize)
    xlabel('Upoly0 [-]','fontsize',thefontsize)
    hold on
    maxZ = length(p_positive);
    axis square
    legend(num2str(p_positive(1:fix(maxZ/num_p):maxZ,2)))
    set(gca,'fontsize',thefontsize-6)
    
    for ip = 1:fix(maxZ/num_p):maxZ
        thecolor = fix((ip - 1)/(maxZ - 1)*63+1);
        
        subplot(1,2,1)
        plot(p_positive(ip,4),p_positive(ip,5),'o','color',themap(thecolor,:),'linewidth',2)
    
        subplot(1,2,2)
        plot(p_positive(ip,1)*exp(p_positive(ip,2)*(log([0:0.5:30])-p_positive(ip,3)).^2),-[0:0.5:30],'.','color',themap(thecolor,:)) 
    end
   print('-dpng','lognormalfit_examples_positive')
   close