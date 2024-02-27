function donar_plot_locations
%donar_plot_locations Some extra analysis on LOCATIONS

    % 1. Lets start by checking tha amount of data by year and month

    clc; clear; close all;
    
    thedonarfiles = dirrec('p:\1204561-noordzee\data\svnchkout\donar_dia\','.dia');
    thegrid = delwaq('open','grid_zuno_dd.lga');
    [thegrid.X,thegrid.Y] = convertCoordinates(thegrid.X,thegrid.Y,'CS1.code',28992,'CS2.code',4326);
    
    fileID = fopen('p:\1204561-noordzee\data\svnchkout\donar_dia\donar_dia_TeX\theTeX_Locations.tex','w');
    
% -->    
    size_quad = 1; % "size_quad = 4" the quadrant will be a fourth of a degree
    
    for i = 2
        
        disp(['Loading: ',thedonarfiles{i}]);
        load([thedonarfiles{i}(1:end-4),'_the_compend','.mat']);    
        thefields = fields(thecompend);
        
        thestr = ['\section{',strrep(['File: ',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end)],'_',' '),'}'];
        fprintf(fileID,'%s\n',thestr);
%%
        for j = 6%1:1:length(thefields)

            %GET MINIMUM AND MAXIMUM DATE
            mindate = min(thecompend.(thefields{j}).data(:,4));
            maxdate = max(thecompend.(thefields{j}).data(:,4));
            
            
            [unique_year,~,year_index] = unique(thecompend.(thefields{j}).data(:,8));
            numYears = length(unique_year);
            for iyear = 1:1:numYears

                table_year = thecompend.(thefields{j}).data(year_index==iyear,:);

                %f = figure('visible','off');
                f = figure;
                thelineS = colormap;
            
                [unique_week,~,week_index] = unique(table_year(:,10));
                numWeek = length(unique_week);
            
                subplot(2,2,1:2);
                hold on
                for iweek = 1:1:numWeek
                    
                    table_year_week = table_year(week_index == iweek,:);
                    table_year_week = sortrows(table_year_week,4);
                
                    plot(table_year_week(:,10),table_year_week(:,5),'.','color','k','markersize',8); 
                    xlim([1 52]); 
                    tick('x',[1:4:52],'%0.0f')
                    
                    xlabel('Month of the Year','FontSize',6);
                    ylabel([thefields{j}, ' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'FontSize',6);
                    set(gca,'FontSize',6);

                    thisplot(iyear,:) = mean(table_year_week,1);
                end
                title(['Distribution of "',thefields{j},'" measurements per week in ',num2str(unique_year(iyear))],'FontWeight','bold','FontSize',6)
                                                                            %[thisplot(:,1),thisplot(:,2)] = convertCoordinates(thisplot(:,1),thisplot(:,2),'CS1.code',4326,'CS2.code',28992);
                
                subplot(2,2,3)
                hold on
                plot(thegrid.X,thegrid.Y,'color',[0.8,0.8,0.8])
                plot(thegrid.X',thegrid.Y','color',[0.8,0.8,0.8])
                
                for iweek = 1:1:numWeek
                    
                    table_year_week = table_year(week_index == iweek,:);
                    table_year_week = sortrows(table_year_week,4);
                    
                    plot(table_year_week(:,1),table_year_week(:,2),'.','color',thelineS(fix((iweek-1)/numWeek*64)+1,:));
                    xlabel('Longitude','FontSize',6);
                    ylabel('Latitude','FontSize',6);
%                     xlim([fix(min(thisplot(:,1))*size_quad)/size_quad,fix(min(thisplot(:,1))*size_quad)/size_quad + 1/size_quad]);
%                     ylim([fix(min(thisplot(:,2))*size_quad)/size_quad,fix(min(thisplot(:,2))*size_quad)/size_quad + 1/size_quad]);
                    title(['Location of "',thefields{j},'" campaigns in the quadrant'],'FontWeight','bold','FontSize',6);
                    axis square
                    set(gca,'FontSize',6);
                end
                
                
                subplot(2,2,4)
                hold on
                plot(thegrid.X,thegrid.Y,'color',[0.8,0.8,0.8])
                plot(thegrid.X',thegrid.Y','color',[0.8,0.8,0.8])
                
                for iweek = 1:1:numWeek
                    
                    table_year_week = table_year(week_index == iweek,:);
                    table_year_week = sortrows(table_year_week,4);
                    
                    plot(table_year_week(:,1),table_year_week(:,2),'.','color', ...
                        thelineS(fix(( mean(table_year_week(:,5)) - 0)/250*64)+1,:));
                    
                    xlabel('Longitude','FontSize',6);
                    ylabel('Latitude','FontSize',6);
%                     xlim([fix(min(thisplot(:,1))*size_quad)/size_quad,fix(min(thisplot(:,1))*size_quad)/size_quad + 1/size_quad]);
%                     ylim([fix(min(thisplot(:,2))*size_quad)/size_quad,fix(min(thisplot(:,2))*size_quad)/size_quad + 1/size_quad]);
                    title(['Location of "',thefields{j},'" campaigns in the quadrant'],'FontWeight','bold','FontSize',6);
                    axis square
                    set(gca,'FontSize',6);
                end
                h2 = colorbar('south','fontsize',6);

                initpos = get(h2,'Position');
                set(h2, ...
                           'Position',[initpos(1)+0.07, ...
                                       initpos(2)*0.9, ...
                                       initpos(3)*0.7, ...
                                       initpos(4)*0.2], ...
                           'FontSize',6);

               
                clear temp thisplot laleyenda;
                fileName = ['p:\1204561-noordzee\data\svnchkout\donar_dia\figures\locations\',thedonarfiles{i}(1+max(findstr(thedonarfiles{i},'\')):end-4),'_',thefields{j},'_', num2str(unique_year(iyear)),'prueba.png'];
                print('-dpng',fileName);                disp([fileName,' -- SAVED']);
                thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1\textwidth]{',fileName,'} \end{figure}'];
                close(f);
            end
        end
        clear iday
    end
    
    fclose(fileID);