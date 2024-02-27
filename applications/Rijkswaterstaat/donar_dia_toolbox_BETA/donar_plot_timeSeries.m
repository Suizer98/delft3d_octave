function minX = donar_plot_timeSeries(donarMat,variable,thefontsize)
%donar_plot_timeSeries

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
       
    f = figure;
    set(gcf,'position',[398   680   722   268])
    set(gcf,'PaperPositionMode','auto')
    
    disp(variable);
    plot(donarMat.(variable).data(:,4),donarMat.(variable).data(:,5),'.b','markersize',10);
    
    
    xlim([datenum(['1-Jan-',num2str(year(minX))]),datenum(['31-Dec-',num2str(year(minX))])]);
    
    datetick(gca,'x','mmm','keeplimits','keepticks');
    
    title([strrep([upper(donarMat.(variable).deltares_name(1)),lower(donarMat.(variable).deltares_name(2:end))],'_',' '),' ',num2str(year(minX))],'FontWeight','bold','FontSize',thefontsize);
    set(gca,'FontSize',thefontsize);    
    
end