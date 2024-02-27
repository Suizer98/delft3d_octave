function  [the_quantiles,the_indices] = donar_plot_boxwhiskers(donarMat,variable,sensorname,thefontsize)
%donar_plot_boxwhiskers Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = donar_plot_boxwhiskers(path2donarMatFile,sensorname)
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
    

    if ischar(donarMat),         donarMat = importdata(donarMat{ifile});
    elseif ~isstruct(donarMat),  error('First argument shoulc be either the path to a donarmat file or a donar mat structure.')
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
    
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)

        donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;

        minX = min(minX,min(donarMat.(variable).data(:,4)));
        maxX = max(maxX,max(donarMat.(variable).data(:,4)));
    end
    
    thedates = [month(donarMat.(variable).data(:,4))];

    h = figure;
    set(gcf,'PaperPositionMode','auto');

    hold on;
    uniquemonth = unique(thedates);
    for imonth = uniquemonth'
        the_indices = find(thedates(:,1) == imonth);
        the_quantiles(imonth,:) = boxPlot(imonth, donarMat.(variable).data(the_indices,5),h);
    end
    title([strrep(sensorname,'_',' '),': ',num2str(year(minX)),' - ',num2str(year(maxX))],'FontWeight','bold','FontSize',thefontsize);
    ylabel([upper(donarMat.(variable).deltares_name(1)),strrep(donarMat.(variable).deltares_name(2:end),'_',' '),' [',donarMat.(variable).hdr.EHD{2},']'],'fontsize',thefontsize)
    theticks = [1:2:12];
    xlim([0,13])
    tick(gca,'x',theticks,'%f')
    set(gca,'XTickLabel',monthstr(theticks,'mmm'))
    set(gca,'fontsize',thefontsize)
    
end
        