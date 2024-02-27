function  [the_quantiles,the_indices] = donar_plot_yearlyBoxWhis(donarMatFile,sensorname,thefontsize)
%donar_plot_yearlyBoxWhis Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = donar_plot_yearlyBoxWhis(path2donarMatFile,sensorname)
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
    
    disp(['Loading: ',donarMatFile]);
    load(donarMatFile)
    
    thefields = fields(thecompend);

    the_path2file = donarMatFile(1:max(findstr(donarMatFile,'\')));
    thedir = [the_path2file,'donar_dia_TeX\figures\'];
    
    if ~exist(thedir), mkdir(thedir); end

    
    
    % Get the minimum and maximum date in the data series... it will be
    % usefull for names and titles. 
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)
        thecompend.(thefields{j}).data(:,4) = thecompend.(thefields{j}).data(:,4) + thecompend.(thefields{j}).referenceDate;
        minX = min(minX,min(thecompend.(thefields{j}).data(:,4)));
        maxX = max(maxX,max(thecompend.(thefields{j}).data(:,4)));
    end

    
    
    % Let's us get those plots done. 
    for j = 1:length(thefields)
        
        thedates = [year(thecompend.(thefields{j}).data(:,4)),month(thecompend.(thefields{j}).data(:,4))];
        uniqueyears = unique(thedates(:,1));

        h = figure('visible','off');
        hold on;
        cont = 1;
        
        the_indices.(thefields{j}) = cell(length(uniqueyears),2);
        the_quantiles.(thefields{j}) = cell(length(uniqueyears),2);
        
        for iyear = uniqueyears'
            thefig = subplot(3,ceil(length(uniqueyears)/3),cont,'parent',h);
            hold on;
            uniquemonth = unique(thedates( thedates(:,1) == iyear ,2));
            
            for imonth = uniquemonth'
                the_indices.(thefields{j}){cont,1} = iyear;
                the_indices.(thefields{j}){cont,2}{imonth} = find(thedates(:,1) == iyear & thedates(:,2) == imonth); 
                
                the_quantiles.(thefields{j}){cont,1} = iyear;
                the_quantiles.(thefields{j}){cont,2}(imonth,:) = boxPlot(imonth, thecompend.(thefields{j}).data(the_indices.(thefields{j}){cont,2}{imonth},5),thefig);
            end
            subplot(thefig)
            title(['Year ',num2str(iyear)],'fontsize',thefontsize,'fontweight','bold')
            ylabel([upper(thecompend.(thefields{j}).deltares_name(1)),strrep(thecompend.(thefields{j}).deltares_name(2:end),'_',' '),' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'fontsize',thefontsize)
            theticks = [1:2:12];
            xlim([0,13])
            tick(gca,'x',theticks,'%f')
            set(gca,'XTickLabel',monthstr(theticks,'mmm'))
            set(gca,'fontsize',thefontsize)

            cont = cont+1;

        end

        fileName = [sensorname,'_themap','_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        close;
    end
end