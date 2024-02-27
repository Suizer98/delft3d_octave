function donar_plot_scatVarXdepth(donarMat,sensorname,variable,thefontsize)
%donar_plot_scatVarXdepth Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = donar_plot_scatVarXdepth(path2donarMatFile,sensorname)
%   where Qs is a structure containing the quantiles of the information per
%   sensor name and per month. 
%  
%   Arguments:
%   <X> x coordenates of the grid to be checked 
%   <Y> y coordenates of the grid to be checked 
%   <coord> the type of coordenates
%   See also: INPOLYGON, REDUCE2MASK

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 14.08.2012
%      Author: I. Garcia Triana
% -------------------------------------------------------------------------


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
    
    % Get the minimum and maximum date in the data series... it will be
    % usefull for names and titles. 
        
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
    minX = min(donarMat.(variable).data(:,4));
    maxX = max(donarMat.(variable).data(:,4));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % All Observations Maps %
    %%%%%%%%%%%%%%%%%%%%%%%%%            
    f = figure;
    set(gcf,'PaperPositionMode','auto');
    thelineS = colormap;        

    plot_scatterhist(donarMat.(variable).data(:,5),-donarMat.(variable).data(:,3),60,'cBins',15);

    xlabel([upper(donarMat.(variable).deltares_name(1)),strrep(donarMat.(variable).deltares_name(2:end),'_',' '),' [',donarMat.(variable).hdr.EHD{2},']'],'fontsize',thefontsize)

    %  The ylabel
    if strcmpi(donarMat.(variable).dimensions{3,2},'centimeters'),             ylabel('Depth [cm]','fontsize',thefontsize)
    elseif strcmpi(donarMat.(variable).dimensions{3,2},'meters'),              ylabel('Depth [m]', 'fontsize',thefontsize)
    end

    title([sensorname,': ',upper(donarMat.(variable).deltares_name(1)),strrep(donarMat.(variable).deltares_name(2:end),'_',' '),' vs Depth (',num2str(year(minX)),' - ',num2str(year(maxX)),')'],'FontWeight','bold','FontSize',thefontsize);

    set(gca,'FontSize',thefontsize-4);
end