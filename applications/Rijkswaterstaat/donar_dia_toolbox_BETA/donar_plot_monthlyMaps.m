function minX = donar_plot_monthlyMaps(donarMat,variable,thefontsize)
%donar_plot_monthlyMaps

    if ischar(donarMat)
        disp(['Loading: ',donarMat]);
        donarMat = importdata(donarMat);
    elseif ~isstruct(donarMat)
        error('Unrecognized input type for donarMat')
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
                
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;

    minX = min(donarMat.(variable).data(:,4));
    maxX = max(donarMat.(variable).data(:,4));
       
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Observations per year map %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numCruises = max(donarMat.(variable).data(:,6));
    [unique_month,~,month_index] = unique(month(donarMat.(variable).data(:,4)));
    nummonths = length(unique_month);
    f = figure;
    
    thelineS = colormap;
    for imonth = 1:1:nummonths

        % Lets focus on that data alone
        table_month = donarMat.(variable).data(month_index==imonth,:);

        subplot(3,4,unique_month(imonth));
        plot_map('lonlat','color',[0.5,0.5,0.5]);   
        hold on;

        [unique_campaign,~,campaign_index] = unique(table_month(:,6));
        plot_xyColor(table_month(:,1),table_month(:,2),table_month(:,5),8);
        
        %upper(donarMat.(variable).deltares_name(1)),lower(strrep(donarMat.
        %(variable).deltares_name(2:end),'_',' ')),' '
        
        if imonth == 1 
            title([num2str(year(maxX)),': ',monthstr(unique_month(imonth),'mmm')],'FontWeight','bold','FontSize',thefontsize);
        else
            title(monthstr(unique_month(imonth),'mmm'),'FontWeight','bold','FontSize',thefontsize);
        end
        h2 = colorbar('south','fontsize',thefontsize);

        initpos = get(h2,'Position');
        set(gca,'FontSize',thefontsize);
        set(h2, ...
                   'Position',[initpos(1)+0.05, ...
                               initpos(2) - 0.01, ...
                               initpos(3)*0.7, ...
                               initpos(4)*0.2], 'fontsize',8);

        
    end

    
end