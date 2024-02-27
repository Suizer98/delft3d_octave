function donar_plot_campaign_maps(donarMat,variable,thedir,thefontsize,themarkersize)
%donar_plot_campaign_maps

    if ischar(donarMat)
        disp(['Loading: ',donarMat]);
        donarMat = importdata(donarMat);
    elseif ~isstruct(donarMat)
        error('Unrecognized input type for donarMat')
    end
    
    
    % Get the fields... those are the substances
    allfields = fields(donarMat);
    
    if isempty(allfields(strcmpi(allfields,variable)))
        disp('Parameter not found in file.')
        return;
    end
    disp(['Looking for values of ',variable]);
    
    % Create a TeX file where the figures are going to be produced
    mkdir(thedir);

    minX = now;
    maxX = datenum('01-Jan-1800');

    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
    minX = min(minX,min(donarMat.(variable).data(:,4)));
    maxX = max(maxX,max(donarMat.(variable).data(:,4)));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Observations per year map %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    f = figure;
    set(gcf,'PaperPositionMode','auto');
    plot_map('lonlat','color',[0.5,0.5,0.5]);   
    hold on;
    
    plot_xyColor(donarMat.(variable).data( donarMat.(variable).data(:,3) < 500 ,1),donarMat.(variable).data( donarMat.(variable).data(:,3) < 500 ,2),donarMat.(variable).data( donarMat.(variable).data(:,3) < 500 ,5),themarkersize);

    title([upper(donarMat.(variable).deltares_name(1)),lower(strrep(donarMat.(variable).deltares_name(2:end),'_',' '))], ...
        'FontWeight','bold', ...
        'FontSize'  ,thefontsize);

    h2 = colorbar('south','fontsize',thefontsize);

    initpos = get(h2,'Position');
    set(h2, ...
               'Position',[initpos(1)+0.05, ...
                           initpos(2) - 0.01, ...
                           initpos(3)*0.7, ...
                           initpos(4)*0.2], ...
               'FontSize',thefontsize);

    set(gca,'FontSize',thefontsize);
end