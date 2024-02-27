function thedon_donar_compare_with_meris
%thedon_donar_compare_with_meris compare DONAR dia data and MERIS
clc, %clear;

    addpath('\utilities\')
    
if false
    the_meris_files = dirrec('p:\1204561-mos3\data\RemoteSensing\MERIS2WAQ\MERIS2WAQ_V03\','.map')';
    the_meris_files(~cellfun('isempty',strfind(the_meris_files,'bin'))) = []; % Remove some undesired files
    
    the_donar_files = { ...
        
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2009_the_compend.mat'; ...
    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2009_the_compend.mat'; ...   doesn't have information aboutturbidity
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2005_the_compend.mat'; ...  
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2008_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2009_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2010_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2011_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2012_the_compend.mat' ...
        };
        

    the_grid_file = 'd:\Dropbox\Deltares\Matlab\donar_dia_toolbox_BETA\utilities\grid_zuno_dd.lga'; 

    donar_compare_with_meris(the_donar_files,the_meris_files,the_grid_file,'turbidity')
end  
%%    
    clear
    close all
    
    compare_donar_meris_files = {...
                        'donar_meris_Ferrybox_2005_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2006_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2007_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2008_turbidity.mat'; ...

                        'donar_meris_CTD_2003_turbidity.mat'; ...
                        'donar_meris_CTD_2004_turbidity.mat'; ...
                        'donar_meris_CTD_2005_turbidity.mat'; ...
                        'donar_meris_CTD_2006_turbidity.mat'; ...
                        'donar_meris_CTD_2007_turbidity.mat'; ...

                        'donar_meris_Meetvis_2003_turbidity.mat'; ...
                        'donar_meris_Meetvis_2004_turbidity.mat'; ...
                        'donar_meris_Meetvis_2005_turbidity.mat'; ...
                        'donar_meris_Meetvis_2006_turbidity.mat'; ...
                        'donar_meris_Meetvis_2007_turbidity.mat'; ...
                        'donar_meris_Meetvis_2008_turbidity.mat'} 
    
    sensors = {'CTD';'FerryBox';'ScanFish'};
    cont_ctd       = 1;
    cont_scanfish  = 1;
    cont_ferrybox  = 1;
    
    for ifile=1:length(compare_donar_meris_files)
        
        disp(['Loading: ',compare_donar_meris_files{ifile}]);
        thefile = importdata(compare_donar_meris_files{ifile});
        
        if strfind(lower( compare_donar_meris_files{ifile}),'ctd'),           

            sensor = sensors{1};
            if cont_ctd == 1,       ctd = thefile;
            else                    ctd = [ctd; thefile];
            end    
            cont_ctd = cont_ctd + 1;
            
        elseif strfind(lower( compare_donar_meris_files{ifile}),'ferrybox'),  
            
            sensor = sensors{2};
            if cont_ferrybox == 1,  ferrybox = thefile;
            else                    ferrybox= [ferrybox; thefile];
            end    
            cont_ferrybox = cont_ferrybox + 1;
            
        elseif strfind(lower( compare_donar_meris_files{ifile}),'meetvis'),  
            
            
            sensor = sensors{3};
            if cont_scanfish == 1,  scanfish = thefile;
            else                    scanfish = [scanfish; thefile];
            end    
            cont_scanfish = cont_scanfish + 1;
            
        end
    end
    
    scanfish(:,3) = -log(scanfish(:,3)/100);
    ctd(:,3)      = -log(ctd(:,3)/100);
    
    scanfish( scanfish(:,3) < -2  ,:) = [];
    
    % ScanFish y CTD
    figure
    plot(scanfish(:,3),scanfish(:,4),'.g',log(ctd(:,3)/100),ctd(:,4),'.r')
    xlim([-1.5 0.1])
    legend('ScanFish','CTD'); 
    axis square;
    ylabel('MERIS','fontsize',16);
    xlabel('log(0.01*Upoly0)','fontsize',16)
    set(gca,'fontsize',16)
    
    % Only FerryBox
    figure
    plot(ferrybox(:,3),ferrybox(:,4),'.b')
    legend('Ferrybox'); 
    axis square;
    ylabel('MERIS','fontsize',16);
    set(gca,'fontsize',16)
    
%%    
%     figure
%     set(gcf,'position',[3 225 1637 473])
%     set(gcf,'PaperPositionMode','auto')
    
    close all
    
    % CTD
    h1 = figure
    set(gcf,'position',[852         0         575         551])
    set(gcf,'PaperPositionMode','auto')
    plot(ctd(:,3),ctd(:,4),'.r','markersize',20)
    
    thefit  = polyfit(ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,3),ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,4),1)
    hold on
    xlim(xlim)
    corrcoef(ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,3),ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,4))
    plot([min(xlim);max(xlim)],[thefit(1)*min(xlim)+thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    
    legend('Observations',['meris = ',num2str(thefit(1)),'*CTD',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('CTD: -log(0.01*Upoly0)','fontsize',16);
    axis square;
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\comparison_with_meris\ctd_vs_meris'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h1,filename,'fig');
    
    % Scanfish
    h2 = figure
    set(gcf,'position',[852         0         575         551])   
    set(gcf,'PaperPositionMode','auto')
    plot(scanfish(:,3),scanfish(:,4),'.g','markersize',20)
    
    thefit  = polyfit(scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3),scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4),1)
    hold on
    xlim(xlim)
    corrcoef(scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3),scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4))
    plot([min(xlim);max(xlim)],[thefit(1)*min(xlim)+thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    
    legend('Observations',['meris = ',num2str(thefit(1)),'*SF',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('ScanFish: -log(0.01*Upoly0)','fontsize',16);
    axis square;
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\comparison_with_meris\scanfish_vs_meris'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h2,filename,'fig');
    
    %% Scanfish
    
    h5 = figure
    set(gcf,'position',[852         0         575         551])   
    set(gcf,'PaperPositionMode','auto')
    plot(scanfish( scanfish(:,3)< 8 ,3),scanfish( scanfish(:,3)< 8 ,4),'.g','markersize',20)
    
    scanfish = scanfish(scanfish(:,3) < 8,:);
    % scanfish(:,3)< 8
    
    [ scanfish(~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3), ...
      scanfish(~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4)]
    thefit  = polyfit( ...
                   scanfish( ~isnan(scanfish( scanfish(:,3)< 8 ,3)) & ~isnan(scanfish( scanfish(:,3)< 8 ,4)) ,3), ...
                   scanfish( ~isnan(scanfish( scanfish(:,3)< 8 ,3)) & ~isnan(scanfish( scanfish(:,3)< 8 ,4)) ,4), ...
                   1)
    hold on
    xlim(xlim)
    corrcoef(scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3),scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4))
    plot([min(xlim);max(xlim)],[thefit(1)*min(xlim)+thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    
    legend('Observations',['meris = ',num2str(thefit(1)),'*SF',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('ScanFish: -log(0.01*Upoly0)','fontsize',16);
    axis square;
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\comparison_with_meris\clipped_scanfish_vs_meris'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h5,filename,'fig');
    
    %% Ferrybox
    h3 = figure
    set(gcf,'position',[852         0         575         551])
    set(gcf,'PaperPositionMode','auto')
    plot(ferrybox(:,3),ferrybox(:,4),'.b','markersize',20)
    
    thefit  = polyfit(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,3),ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,4),1)
    corrcoef(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,3),ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,4))
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*FB',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('FerryBox','fontsize',16);
    xlim(ylim)
    axis square;
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\comparison_with_meris\ferry_vs_meris'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h3,filename,'fig');
    
    %Ferrybox Zoom in
    h4 = figure
    set(gcf,'position',[852         0         575         551])
    set(gcf,'PaperPositionMode','auto')
    plot(ferrybox(ferrybox(:,3)<3,3),ferrybox(ferrybox(:,3)<3,4),'.b','markersize',20)
    thefit  = polyfit(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<3 ,3), ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<3 ,4),1)
    corrcoef(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<3 ,3), ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<3 ,4) )
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*FB',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('FerryBox','fontsize',16);
    axis square;
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\comparison_with_meris\clipped_ferry_vs_meris'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h4 ,filename,'fig');