function theDon(varargin)
%theDon steering module for donar_* toolbox
%
%See also: rijkswaterstaat

OPT.diadir = 'p:\1204561-noordzee\data\svnchkout\donar_dia\';

%% Make time plots and histograms.
if false
    
    clc; clear; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');
        
    load([thedonarfiles{1}(1:end-4),'_the_compend','.mat'])


        warning off;
        
        for i = 1%:length(thedonarfiles)
            
            if strfind(lower(thedonarfiles{i}),'ctd')
                sensor_name = 'CTD'; 
            elseif strfind(lower(thedonarfiles{i}),'ferry')
                sensor_name = 'Ferrybox';
            elseif strfind(lower(thedonarfiles{i}),'meetvis')
                sensor_name = 'Meetvis';
            end
            
            donar_plot_histograms([thedonarfiles{i}(1:end-4),'_the_compend.mat'],sensor_name);
        end 
        
end



%% Make time plots and histograms %%
if false
    
    clc; clear; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');
        
    load([thedonarfiles{1}(1:end-4),'_the_compend','.mat'])


        warning off;
        
        for i = 1%:length(thedonarfiles)
            
            if strfind(lower(thedonarfiles{i}),'ctd')
                sensor_name = 'CTD'; 
            elseif strfind(lower(thedonarfiles{i}),'ferry')
                sensor_name = 'Ferrybox';
            elseif strfind(lower(thedonarfiles{i}),'meetvis')
                sensor_name = 'Meetvis';
            end
            
            donar_plot_histograms([thedonarfiles{i}(1:end-4),'_the_compend.mat'],sensor_name);
        end 
        
end
%% Make map
if false
    
    clc; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');        
    for i = 1:length(thedonarfiles)

        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
        end

        donar_plot_map([thedonarfiles{i}(1:end-4),'_the_compend','.mat'],sensor_name,20,15);
    end
end

%% Make scatter plots Depth vs Observation %%
if false
    
    clc; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');        
    for i = 1:length(thedonarfiles)

        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 
            donar_plot_scatVarXdepth([thedonarfiles{i}(1:end-4),'_the_compend','.mat'],sensor_name,15,15);
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
            donar_plot_scatVarXdepth([thedonarfiles{i}(1:end-4),'_the_compend','.mat'],sensor_name,15,15);
        end

        
    end
end

%% Box and Whisker diagram for all observations %%
if false
    
    clc; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');        
    for i = 1:length(thedonarfiles)

        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
        end

        donar_plot_boxwhiskers([thedonarfiles{i}(1:end-4),'_the_compend','.mat'],sensor_name,20);
    end
end

%% Histogram monthly per year %%

if false
    clc; close all, fclose all;
    thedonarfiles = dirrec(OPT.diadir,'.dia');
    thefontsize = 8;
        
        for i = 1:length(thedonarfiles)
            
            if i == 1, main_fields = fields(thecompend); end
            
            if strfind(lower(thedonarfiles{i}),'ctd')
                sensor_name = 'CTD'; 
            elseif strfind(lower(thedonarfiles{i}),'ferry')
                sensor_name = 'Ferrybox';
            elseif strfind(lower(thedonarfiles{i}),'meetvis')
                sensor_name = 'Meetvis';
            end
            
            donar_plot_monthlyHist([thedonarfiles{1}(1:end-4),'_the_compend','.mat'],sensor_name,thefontsize)
        end
end

%% Some extra analysis: LOCATIONS %%
if false

    % 1. Lets start by checking tha amount of data by year and month

    clc; clear; close all;
    
    thedonarfiles = dirrec(OPT.diadir,'.dia');
    thegrid = delwaq('open','grid_zuno_dd.lga');
    [thegrid.X,thegrid.Y] = convertCoordinates(thegrid.X,thegrid.Y,'CS1.code',28992,'CS2.code',4326);
    
    fileID = fopen([OPT.diadir,filesep,'\donar_dia_TeX\theTeX_Locations.tex'],'w');
    
% -->    
    size_quad = 1; % "size_quad = 4" the quadrant will be a fourth of a degree
    
    for i = 1:1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        load([thedonarfiles{i}(1:end-4),'_the_compend','.mat']);    
        thefields = fields(thecompend);
        
        thestr = ['\section{',strrep(['File: ',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end)],'_',' '),'}'];
        fprintf(fileID,'%s\n',thestr);

        for j = 1:1:length(thefields)

            %GET MINIMUM AND MAXIMUM DATE
            mindate = min(thecompend.(thefields{j}).data(:,4));
            maxdate = max(thecompend.(thefields{j}).data(:,4));
            
            % GET UNIQUE LONGITUDES
            [unique_lon,~,lon_index] = unique(fix(thecompend.(thefields{j}).data(:,1)*size_quad)/size_quad);
            numLon = length(unique_lon);
            for ilon = 1:1:numLon
            
                % GET UNIQUE LATITUDES (for this set of unique logitudes)
                table = thecompend.(thefields{j}).data(lon_index==ilon,:);
                [unique_lat,~,lat_index] = unique(fix(table(:,2)*size_quad)/size_quad);
                for ilat = 1:1:length(unique_lat)
                    
                    thisquadrant = table(lat_index == ilat,:);
                    
                    %f = figure('visible','off');
                    f = figure;
                    thelineS = colormap;
                    [unique_campaign,~,campaign_index] = unique(thisquadrant(:,6));
                    numCamp = length(unique_campaign);
                    
                    for icampaign = 1:1:numCamp
                        
                        temp = thisquadrant(campaign_index == icampaign,:);
                        temp = sortrows(temp,4);
                        
                        laleyenda(icampaign,:) = datestr(temp(1,4),'dd-mmm-yyyy HH:MM:SS');
                        
                        subplot(2,2,1:2);
                        hold on
                        
                        if i == 2
                            plot(month(temp(:,4)),temp(:,5),'.','color',thelineS(fix((temp(1,4)-mindate)/(maxdate-mindate)*64)+1 ,:),'markersize',4); 
                            xlim([1 12]); 
                            tick('x',[1:12],'%02.0f')
                            title(['Depth distribution of "',thefields{j},'" measurements per cruise'],'FontWeight','bold','FontSize',6)
                            xlabel('Month of the Year','FontSize',6);
                            ylabel([thefields{j}, ' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'FontSize',6);
                            set(gca,'FontSize',6);
                        else
                            plot(temp(:,5),temp(:,3),'.','color',thelineS(fix((temp(1,4)-mindate)/(maxdate-mindate)*64)+1 ,:),'markersize',4);
                            title(['Depth distribution of "',thefields{j},'" measurements per cruise'],'FontWeight','bold','FontSize',6)
                            xlabel([thefields{j}, ' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'FontSize',6);
                            ylabel('Depth [cm]','FontSize',6);
                            set(gca,'FontSize',6);
                        end
                        thisplot(icampaign,:) = mean(temp(  temp(:,3) == min(temp(:,3))  ,:  ),1);
                    end
                    
                    %[thisplot(:,1),thisplot(:,2)] = convertCoordinates(thisplot(:,1),thisplot(:,2),'CS1.code',4326,'CS2.code',28992);
                    subplot(2,2,1:2)
                    if numCamp <20
                        hLeg = legend(laleyenda,'Location','EastOutside');
                        v = get(hLeg,'title');
                        set(v,'string','Date of Cruise','fontsize',6,'fontweight','bold');
                    else
                        hBar = colorbar;                           %# Create the colorbar
                        labels = cellstr(get(hBar,'YTickLabel'));           %# Get the current y-axis tick labels
                        for ilabel = 1:1:size(labels,1)
                            labels{ilabel} = datestr(str2num(labels{ilabel})/size(thelineS,1)*(maxdate-mindate) + mindate, 'mmm yyyy');                   %# Change the last tick label
                            set(hBar,'YTickLabel',labels,'fontsize',6);             %#   and update the tick labels
                        end
                        axes (hBar)
                        title(gca,'Date of Cruise','fontsize',6,'fontweight','bold')
                        error
                    end
                    
                    subplot(2,2,3)
                    figure
                    hold on
                    plot(thegrid.X,thegrid.Y,'color',[0.8,0.8,0.8])
                    plot(thegrid.X',thegrid.Y','color',[0.8,0.8,0.8])
                    scatter(thisplot(:,1),thisplot(:,2),10,thisplot(:,5),'filled');
                    xlabel('Longitude','FontSize',6);
                    ylabel('Latitude','FontSize',6);
                    xlim([fix(min(thisplot(:,1))*size_quad)/size_quad,fix(min(thisplot(:,1))*size_quad)/size_quad + 1/size_quad]);
                    ylim([fix(min(thisplot(:,2))*size_quad)/size_quad,fix(min(thisplot(:,2))*size_quad)/size_quad + 1/size_quad]);
                    title(['Location of "',thefields{j},'" campaigns in the quadrant'],'FontWeight','bold','FontSize',6);
                    axis square
                    set(gca,'FontSize',6);
                    h1 = colorbar('south','fontsize',6);

                    subplot(2,2,4)
                    plot_map('lonlat');
                    hold on;
                    scatter(thisplot(:,1),thisplot(:,2),10,thisplot(:,5),'filled');
                    xlabel('Longitude','FontSize',6);
                    ylabel('Latitude','FontSize',6);
                    title(['General Location of "',thefields{j},'" campaigns'],'FontWeight','bold','FontSize',6)
                    set(gca,'FontSize',6);
                    h2 = colorbar('south','fontsize',6);
                    
                    initpos = get(h2,'Position');
                    set(h2, ...
                               'Position',[initpos(1)+0.07, ...
                                           initpos(2)*0.9, ...
                                           initpos(3)*0.7, ...
                                           initpos(4)*0.2], ...
                               'FontSize',6);
                   
                   initpos = get(h1,'Position');
                   set(h1, ...
                       'Position',[initpos(1)+0.07, ...
                                   initpos(2)*0.9, ...
                                   initpos(3)*0.7, ...
                                   initpos(4)*0.2], ...
                       'FontSize',6);
       
                    clear temp thisplot laleyenda;
                    fileName = [OPT.diadir,filesep,'\figures\locations\',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end-4),'_',thefields{j},'_quadrant_',num2str(ilon*100+ilat,'%04.0f'),'.png'];
                    print('-dpng',fileName);                disp([fileName,' -- SAVED']);
                    thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1\textwidth]{',fileName,'} \end{figure}'];
                    %close(f);
                end
            end
            clear iday
        end
    end
    
    fclose(fileID);
end
%% Some extra analysis: Means and variances %%
if false

    % 1. Lets start by checking tha amount of data by year and month

    clc; clear; close all;
    
    thedonarfiles = dirrec(OPT.diadir,'.dia');
    thegrid = delwaq('open','grid_zuno_dd.lga');
    [thegrid.X,thegrid.Y] = convertCoordinates(thegrid.X,thegrid.Y,'CS1.code',28992,'CS2.code',4326);
    
    fileID = fopen([OPT.diadir,filesep,'\donar_dia_TeX\theTeX_stats.tex'],'w');
    
% -->    
    size_quad = 1; % "size_quad = 4" the quadrant will be a fourth of a degree

    for i = 1:1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        load([thedonarfiles{i}(1:end-4),'_the_compend','.mat']);    
        thefields = fields(thecompend);
        
        thestr = ['\section{',strrep(['File: ',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end)],'_',' '),'}'];
        fprintf(fileID,'%s\n',thestr);
        
        for j = 6%1:1:length(thefields)
            thefields{j}
            %GET MINIMUM AND MAXIMUM DATE
            mindate = min(thecompend.(thefields{j}).data(:,4));
            maxdate = max(thecompend.(thefields{j}).data(:,4));
            
            % GET UNIQUE DEPTHS
            [unique_depths,~,depths_index] = unique(fix(thecompend.(thefields{j}).data(:,3)/10)*10);
            numDepths = length(unique_depths);
            for idepth = 1:1:numDepths
            
                % GET UNIQUE LATITUDES (for this set of unique logitudes)
                table = thecompend.(thefields{j}).data(depths_index==idepth,:);
                
                [unique_month,~,month_index] = unique(month(table(:,4)));
                numMonths = length(unique_month);
                for imonth = 1:1:numMonths
                    thisquadrant = table(month_index == imonth,:);
                    if size(thisquadrant > 1)
                        theMonthlyStat(imonth,:) = [unique_depths(idepth) unique_month(imonth) mean(thisquadrant(:,5)) std(thisquadrant(:,5))];
                    else
                        theMonthlyStat(imonth,:) = [unique_depths(idepth) unique_month(imonth) thisquadrant(:,5) 0];
                    end
                end
            end
            
            f = figure;
            scatter(theMonthlyStat(:,2),theMonthlyStat(:,1),30,theMonthlyStat(:,3),'s','filled');
            xlim([1 12])
            xlabel('Month')
            tick('x',[1:12],'%02.0f')
            ylabel('Depth []')
            hBar = colorbar;                           %# Create the colorbar
            axes (hBar)
            title(gca,'Mean Value','fontsize',6,'fontweight','bold')
            fileName = [OPT.diadir,filesep,'\figures\stats\',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end-4),'_',thefields{j},'_stats','.png'];
            print('-dpng',fileName);                disp([fileName,' -- SAVED']);

        end
    end
    
    fclose(fileID);
end

%% Spatial analysis with respect to the model grid: COVERTURES %%
if true
    clc; close all, fclose all;
    
    clear
    
    thedonarfiles = dirrec(OPT.diadir,'.dia');
    thefontsize = 8;
    thegrid = delwaq('open','grid_zuno_dd.lga');
    
    for i = 3%:length(thedonarfiles)
        
        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
        end
        
        disp(['Loading: ',thedonarfiles{i}]);
        load([thedonarfiles{i}(1:end-4),'_the_compend','.mat']);
        
        the_path2file = thedonarfiles{i}(1:max(findstr(thedonarfiles{i},'\')));
        thedir = [the_path2file,'donar_dia_TeX\figures\'];
        if ~exist(thedir), mkdir(thedir); end
        fileID = fopen([the_path2file,'donar_dia_TeX\theTeX_General.tex'],'W');
    
        thefields = fields(thecompend);
        
        for j = 6%1:length(thefields)
            
            %Get the segment numbers
            the_day = fix(thecompend.(thefields{j}).data(:,4)) - fix(min(thecompend.(thefields{j}).data(:,4)))+1;

            [the_segnr,x,y] = delwaq_xy2segnr(thegrid,thecompend.(thefields{j}).data(:,1),thecompend.(thefields{j}).data(:,2),'ll');
            
            
            thecompend.(thefields{j}).data(   isnan(thecompend.(thefields{j}).data(:,end  )),:   )
            plot_map('lonlat');
            hold on;
            plot(thecompend.(thefields{j}).data(   isnan(the_segnr),1   ),thecompend.(thefields{j}).data(   isnan(the_segnr),2   ),'.r')
            

            [unique_days,~,days_index] = unique(the_day);
            numdays = length(unique_days);
            cont = 1;
            for iday = 1:1:numdays
                [unique_segnrs,~,segnrs_index] = unique(the_segnr( days_index == iday ));
                for iseg = unique_segnrs
                    daySegObs{cont} = [ thecompend.(thefields{j}).data( the_segnr == iseg,5 )]
                    cont = cont + 1;
                end
            end
                        thecompend.(thefields{j}).data(   isnan(thecompend.(thefields{j}).data(:,end  )),:   ) = [];
            
            
            S = sparse( thecompend.(thefields{j}).data(:,end-1), ...
                        thecompend.(thefields{j}).data(:,end  ), ...
                        thecompend.(thefields{j}).data(:,5)   );
        end
    end
end

%% Spatial analysis with respect to the model grid: COVERTURES
if false
    close all, clc, clear
    
    thegrid = delwaq('open','grid_zuno_dd.lga');
    
    thedonarfiles = dirrec(OPT.diadir,'.dia');
    warning off;
    
    fileID = fopen([OPT.diadir,filesep,'\donar_dia_TeX\theTeX_covertures.tex'],'w');
    
    for i = 1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        load([thedonarfiles{i}(1:end-4),'_the_compend','.mat']);
        
        thefields = fields(thecompend);
        
        for j = 6%1:length(thefields)
            
            % Get the unique coordinates where measurements have taken
            % place.
                
                [unique_coords,~,coords_index] = unique(thecompend.(thefields{j}).data(:,1:2),'rows');
                
                [unique_xy(:,1),unique_xy(:,2)] =  convertCoordinates(unique_coords(:,1),unique_coords(:,2),'CS1.code',4326,'CS2.code',28992);
                
                [neighbors,distances] = knearestneighbors(cen_coords,unique_xy,1);
                
                unique_neighbors = unique(neighbors);
                [freq_centers,centers] = hist(neighbors,unique_neighbors);
                save([OPT.diadir,filesep,'\figures\covertures\',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end-4),'_workspace']);
                
                f = figure('visible','off')
                hold on
                plot(thegrid.X(2:end,2:end),thegrid.Y(2:end,2:end),'color',[0.8,0.8,0.8]);
                plot(thegrid.X(2:end,2:end)',thegrid.Y(2:end,2:end)','color',[0.8,0.8,0.8]);

                
                scatter(cen_coords(centers,1),cen_coords(centers,2),30,freq_centers,'s','filled');
                xlim([min(cen_coords(centers,1))-10000,max(cen_coords(centers,1))+10000])
                ylim([min(cen_coords(centers,2))-10000,max(cen_coords(centers,2))+10000])
                colorbar
                set(gca,'FontSize',6);
                xlabel([num2str(size(unique_neighbors,1)),' gridcells with at least one observation'],'FontSize',8)
                title(['Number of observations of "',lower(strrep(thefields{j},'_',' ')) ,'" per gridcell'],'FontWeight','bold','FontSize',8);
                
                fileName = [OPT.diadir,filesep,'\figures\covertures\',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end-4),'_',thefields{j},'_coverture','.png'];
                print('-dpng',fileName);                disp([fileName,' -- SAVED']);
                thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1\textwidth]{',fileName,'} \end{figure}'];
                
                close(f);
                clear unique_coords unique_xy coords_index neighbors distances
        end
    end
end