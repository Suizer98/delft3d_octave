function  donar_plot_monthlyHist(donarMat,sensorname,variable,thefontsize,varargin)
%donar_plot_monthlyHist  makes box-whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = donar_plot_monthlyHist(path2donarMatFile,sensorname)
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
        error('Unrecognized input type for donarMat')
    end
    
    if nargin > 4
        histbins = varargin{1};
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
    
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
  
    thedates = [month(donarMat.(variable).data(:,4))];

    cont = 1;
    h = figure;
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'position',[414, 86, 1050, 890])

    uniquemonth = unique(thedates);
    for imonth = uniquemonth'
        the_indices = (thedates(:,1) == imonth);
        
        subplot(3,4,imonth,'parent',h);
        [n,x] = hist(donarMat.(variable).data(the_indices,5),histbins);
        bar(x,n./sum(the_indices).*100);
        
        if strcmpi(sensorname,'fb')
            legend(sensorname,'location','northeast') 
        else
            legend(sensorname,'location','northwest')
        end
        
        xlim([min(x)-5 max(x)+5]);
        a = get(gca,'xticklabels');
        a(2:2:end,:) = ' ';
        set(gca,'xticklabels',a);
        
        shading flat;          
        title([monthstr(imonth,'mmmm'),char(10),' (',num2str(sum(the_indices)),' Obs)'],'fontsize',thefontsize+2)
        
        if strcmpi(sensorname,'ctd') || strcmpi(sensorname,'scanfish')
            xlabel('Upoly0 [-]','fontsize',thefontsize)
        else
            xlabel([upper(donarMat.(variable).deltares_name(1)),strrep(donarMat.(variable).deltares_name(2:end),'_',' '),' [',donarMat.(variable).hdr.EHD{2},']'],'fontsize',thefontsize)
        end
        ylabel('Number of Observations [%]','fontsize',thefontsize)
        set(gca,'fontsize',thefontsize)
    end
    cont = cont+1;
end
    