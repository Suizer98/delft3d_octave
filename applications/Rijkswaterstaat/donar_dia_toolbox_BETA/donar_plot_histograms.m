function minX = donar_plot_histograms(donarMat,variable,thefontsize)
%donar_plot_histograms

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
    
    %%%%%%%%%%%%%%
    % HISTOGRAMS %
    %%%%%%%%%%%%%%
    f = figure;
    set(gcf,'position',[745   569   375   379])
    set(gcf,'PaperPositionMode','auto')
    hist(donarMat.(variable).data(:,5),100,'facecolor','k');

    elmax = max(donarMat.(variable).data(:,5));
    elmin = min(donarMat.(variable).data(:,5));
    numreg = length(donarMat.(variable).data(:,5));
    xlabel(['Bounds: [',num2str(elmin),',',num2str(elmax),']  -  Size: ',num2str(numreg)],'FontSize',thefontsize);
    title([strrep([upper(donarMat.(variable).deltares_name(1)),lower(donarMat.(variable).deltares_name(2:end))],'_',' '),' ',num2str(year(minX))],'FontWeight','bold','FontSize',thefontsize);
    set(gca,'FontSize',thefontsize);
    axis square
end