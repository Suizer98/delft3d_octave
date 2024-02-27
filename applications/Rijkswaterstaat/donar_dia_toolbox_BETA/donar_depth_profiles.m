function donar_depth_profiles(donarMat,variable,base_name)
%donar_depth_profiles    

     thegrid = delwaq('open',[fileparts(mfilename('fullpath')),filesep,'private',filesep,'grid_zuno_dd.lga']);
     [thegrid.X,thegrid.Y] = convertCoordinates(thegrid.X,thegrid.Y,'CS1.code',28992,'CS2.code',4326);

    if ischar(donarMat)
        disp(['Loading: ',donarMat]);
        donarMat = importdata(donarMat);
    elseif ~isstruct(donarMat)
        error('donarMat should be a donarMat structure or a string')
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
    
    %GET MINIMUM AND MAXIMUM DATE
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
    

    % GET UNIQUE LONGITUDES
    [unique_month,~,month_index] = unique( month(donarMat.(variable).data(:,4)) );
    numMonth = length(unique_month);
    
    
    for imonth = 1:1:numMonth
        f = figure('visible','off');
        set(gcf,'PaperPositionMode','auto')
        thismonth = donarMat.(variable).data(month_index == imonth,:);
        thisyear = unique(year(thismonth(:,4)));
        
        thelineS = colormap;
        [unique_campaign,~,campaign_index] = unique(thismonth(:,6));
        numCamp = length(unique_campaign);
        
        mindate = min(thismonth(:,4));
        maxdate = max(thismonth(:,4));
        
        subplot(1,2,1)
        title([monthstr(unique_month(imonth),'mmmm'),' - ',num2str(thisyear)],'FontWeight','bold','FontSize',14)
        axis square
        hold on
        subplot(1,2,2)
        plot_map('lonlat')
        hold on    
        for icampaign = 1:1:numCamp
            temp = thismonth(campaign_index == icampaign,:);
            temp = sortrows(temp,4);
            
            laleyenda(icampaign,:) = datestr(temp(1,4),'dd-mmm-yyyy HH:MM:SS');
            thecolor = thelineS(fix((temp(1,4)-mindate)/(maxdate-mindate)*64)+1 ,:);
            subplot(1,2,1)
            plot(temp(:,5),-temp(:,3)/100,'.','color',thecolor,'markersize',6);
            
            
            xlabel('Upoly0 [-]','FontSize',12);
            ylabel('Depth [m]','FontSize',12);
            set(gca,'FontSize',12);

            thisplot(icampaign,:) = mean(temp);
            subplot(1,2,2)
            plot(temp(:,1),temp(:,2),'.','color',thecolor,'markersize',20);
        end
        
        subplot(1,2,1)
        hBar = colorbar('location','south');                %# Create the colorbar
        labels = cellstr(get(hBar,'XTickLabel'));           %# Get the current y-axis tick labels
        for ilabel = 1:1:size(labels,1)
            labels{ilabel} = datestr(str2num(labels{ilabel})/size(thelineS,1)*(maxdate-mindate) + mindate, 'dd');                   %# Change the last tick label
            set(hBar,'XTickLabel',labels,'fontsize',12);             %#   and update the tick labels
        end
        axes (hBar)
        title(gca,'Day of Cruise','fontsize',12,'fontweight','bold')
        set(hBar,'position',[0.1654    0.5981*.05    0.7100    0.0316])
        
        %clear temp thisplot laleyenda;
        fileName = [base_name,'_',monthstr(unique_month(imonth),'mmmm'),'.png'];
        print('-dpng',fileName);  
        disp([fileName,' -- SAVED']);
        close(f);
        
    end
    %%
    clear iday
end