function  [the_quantiles,the_indices] = donar_plot_depth_boxwhiskers(donarMat,sensorname,variable,numboxes,thefontsize)
%donar_plot_depth_boxwhiskers Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = donar_plot_depth_boxwhiskers(donarMatFile,sensorname,variable,number_of_boxes,fig_font_size)
%   where Qs is a structure containing the quantiles of the information per
%   sensor name and per month. 
%  
%   donarMatFile [str/struct]: Path to the donarMat file or donarMat
%                              structure containing the data of interest.
%   sensorname [str]: Name of the sensor to be used as the title of the
%                     figure.
%   variable [str]: Name of the variable to be used as the label of the y
%                   axis.
%   number_of_boxes [int]: Number of boxes in the plot.
%   fig_font_size [f]: Size of the font of the figure.
%   See also: DONAR*

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
    
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
    minZ = min(donarMat.(variable).data(:,3));
    maxZ = max(donarMat.(variable).data(:,3));
    
    the_box = (maxZ-minZ)/numboxes;
    the_depths = fix(donarMat.(variable).data(:,3)/the_box)+1;

    % close all
    h = figure;
    set(gcf,'PaperPositionMode','auto');
    
    hold on;
    uniquedepths = unique(the_depths);
    for idepth = uniquedepths'
        the_indices = find(the_depths(:,1) == idepth);
        theticks(idepth) = fix(mean(donarMat.(variable).data(the_indices,3)))/100;
        the_quantiles(idepth,:) = boxPlot(idepth, donarMat.(variable).data(the_indices,5),h);
    end
    title(strrep(sensorname,'_',' '),'FontWeight','bold','FontSize',thefontsize);
    ylabel([upper(donarMat.(variable).deltares_name(1)),strrep(donarMat.(variable).deltares_name(2:end),'_',' '),' [',donarMat.(variable).hdr.EHD{2},']'],'fontsize',thefontsize)
    xlabel('Depth [m]','fontsize',thefontsize)
    xlim([0,numboxes+1])
    tick(gca,'x',[1:2:numboxes+1],'%2.0f')
    set(gca,'XTickLabel',theticks(1:2:numboxes+1))
    set(gca,'fontsize',thefontsize-6)
end
        