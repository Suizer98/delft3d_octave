% Makes plots of presence of measurements in time. The X axis is day
% number while the Y axis is the year. A dot in the graph means that for
% that day and year there is an observation available. 
   
    clc; clear; close all, fclose all;

    files_of_interest = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2005_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2006_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2007_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2008_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_withFlag.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_withFlag.mat'; ...
    };

    warning off;
    
% -> Specify names of sensors:
    sensors = {'CTD';'FerryBox';'ScanFish'};
    sensor_fields = {'Air_radiance','Conductivity','Fluorescence','Oxygen','Ph','Sea_Water_Salinity','Turbidity','Water_radiance'};
    numfields = length(sensor_fields);
    
    cont = 1;
    for ifile = 1:1:length(files_of_interest)
        
        donarMat = importdata(files_of_interest{ifile});
        thefields = fields(donarMat);
        
        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor_name      = sensors{1};
        elseif strfind(lower(files_of_interest{ifile}),'ferrybox')
            sensor_name      = sensors{2};
        elseif strfind(lower(files_of_interest{ifile}),'scanfish')
            sensor_name      = sensors{3};
        end
            
        for ifield = 1:length(thefields)
            
            unique_year = unique(year(donarMat.(thefields{ifield}).data(:,4)+donarMat.(thefields{ifield}).referenceDate));
            if length(unique_year) > 1,                 error('More than one year in the file');            end
            
            
        % -> Use this line if you want to plot FLAGGED values !!!!
%             unique_days      = unique(yearday(donarMat.(thefields{ifield}).data(      donarMat.(thefields{ifield}).data(:,7)~=0 ,4    ) + donarMat.(thefields{ifield}).referenceDate));
%             unique_campaigns = unique(        donarMat.(thefields{ifield}).data(      donarMat.(thefields{ifield}).data(:,7)~=0 ,6    )                                              );
%             num_observations = length(find(donarMat.(thefields{ifield}).data(:,7)~=0));
%             [theflagcount,theflag]   = count(donarMat.(thefields{ifield}).data(    find(donarMat.(thefields{ifield}).data(:,7)~=0), 7));
            
        % -> Use this line if you want to plot measurements !!!!
            unique_days      = unique(yearday(donarMat.(thefields{ifield}).data(      donarMat.(thefields{ifield}).data(:,7)==0 ,4     ) + donarMat.(thefields{ifield}).referenceDate));
            unique_campaigns = unique(        donarMat.(thefields{ifield}).data(      donarMat.(thefields{ifield}).data(:,7)==0 ,6     )                                              );
            num_observations = length(find(donarMat.(thefields{ifield}).data(:,7)==0));
            
            theinfo{cont,1} = sensor_name;
            theinfo{cont,2} = thefields{ifield};
            theinfo{cont,3} = unique_year;
            theinfo{cont,4} = length(unique_campaigns);                                % Number of (flagged) Campaigns
            theinfo{cont,5} = length(unique_days);                                     % Number of (flagged) Days
            theinfo{cont,6} = num_observations;                                        % Number of (flagged) observations per variable per year
            theinfo{cont,7} = unique_days;                                             % The (flagged) days        
        % -> Uncomment this lines if you want to work !!!!
%             theinfo{cont,8} = [theflag,theflagcount];
            
            disp(['Sensor: ',sensor_name,' parameter: ',thefields{ifield},' year: ',num2str(unique_year),' observed days: ',num2str(length(unique_days))]);
            cont=cont+1;
            
        end
    end

%%        
    
    numcolors = length(colormap);
    close all
    for isensor=1:3
        x_sensor      = strcmpi(theinfo(:,1),sensors{isensor});
        h = figure%('visible','off');
        hold all;
        
        cont = 1;
        thecolor = 'gbrkmcbr';
        for ifield = 1:1:8
            
            x_parameter   = strcmpi(theinfo(:,2),sensor_fields{ifield});
            x             = theinfo(x_sensor & x_parameter,3);
            y             = theinfo(x_sensor & x_parameter,7);
        
            if ~isempty(x)
                
                for iyear = 1:length(y)
                    the_plot_cell{iyear,1} = y{iyear};
                    the_plot_cell{iyear,2} = (x{iyear}+cont/10)*ones(length(y{iyear}),1);
                end
                theplot = cell2mat(the_plot_cell);
                
         % -> Use this line if you want to plot FLAGGED values !!!!
                %plot(theplot(:,1),theplot(:,2),'.r','markersize',8);
         % -> Use this line if you want to plot measurements !!!!
                plot(theplot(:,1),theplot(:,2),['.',thecolor(ifield)],'markersize',20);
         % -> Use this line if you want to plot measurements !!!!
        
                clear theplot the_plot_cell iyear
                if cont == 1
                    the_legend = strrep([sensor_fields{ifield}],'_',' ');
                else
                    the_legend = [the_legend;strrep(sensor_fields(ifield),'_',' ')];
                end
                hold all;
                cont =  cont+1;
            end
        end
        
        ylim([min([theinfo{:,3}])-1,max([theinfo{:,3}])+1])

         
        posSw = [246         232        1320         564];
        set(gcf,'PaperPositionMode','auto')
        set(gcf,'Position',posSw)
        title(['Sensor: ',sensors{isensor}],'fontweight','bold')
        
        theylims = ylim();
        
        %set(gca,'ytick',[theylims(1)+0.5:0.5:theylims(2)-0.5],'yticklabel',num2str(fix([theylims(1)+0.5:0.5:theylims(2)])','%0.0f'))
        legend(the_legend,'Location','eastoutside')
        clear the_legend
        xlim([0 367])
        tick('x',0:14:367,'%0.0f') 
        xlabel('Day')
        ylabel('Year')
        
        theylims = ylim();
        tick('x',0:14:367,'%0.0f') 
        set(gca, ...
            'XMinorGrid','on', ...
            'YMinorGrid','on', ...
            'MinorGridLineStyle',':', ... 
            'box','on', ...
            'fontsize',12)
        
        filename = [pwd,filesep,'flags_obsdayVSyear_',sensors{isensor}];
        disp(['saving : ',filename]);
        print('-depsc2',filename);
        print('-dpng',filename);
        saveas(h,filename,'fig');
        
        %close(h);
        
    end