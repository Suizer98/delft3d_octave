
% set_resolution
% set resolution to whatever is in the text box and update axes data and
% plots accordingly
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================
ButtonName = questdlg('Do this for all images?','Same resolution?', ...
    'Yes','No,', 'Yes');

if strcmp(ButtonName,'Yes')
    
    for ii=1:length(sample)
        
        if ~isempty(sample(ii).dist) && sample(ii).resolution==1
            orig_scale{ii}=sample(ii).dist(:,1);
        elseif ~isempty(sample(ii).dist) && sample(ii).resolution~=1
            orig_scale{ii}=sample(ii).dist(:,1).*1/sample(ii).resolution;
        end
        
        sample(ii).resolution=str2double(get(findobj('tag','res'),'String'));
        
        
        if sample(ii).resolution~=1
            % if there is a distribution but resolution is not 1
            % we need to replot ax2 (plot), replot ax3 (auto image)
            
            if ~isempty(sample(ii).dist)
                sample(ii).dist(:,1)=orig_scale{ii}.*sample(ii).resolution; %sample(ii).dist(:,1)
                [sample(ii).percentiles,sample(ii).geom_moments,...
                    sample(ii).arith_moments]=gsdparams(sample(ii).dist(:,2),sample(ii).dist(:,1));
                
                sample(ii).geom_moments(2) = 1000*2^-sample(ii).geom_moments(2);
                
                axes(ax2)
                cla(ax2)
                bar(sample(ii).dist(:,1),sample(ii).dist(:,2))
                xlabel('Size (mm)')
                ylabel('Density')
                axis tight
                set(gca,'ydir','normal')
                text(.7,.92,['Mean = ',num2str(sample(ii).arith_moments(1),3)],'units','normalized')
                text(.7,.85,['Sorting = ',num2str(sample(ii).arith_moments(2),3)],'units','normalized')
                text(.7,.78,['Skewness = ',num2str(sample(ii).arith_moments(3),3)],'units','normalized')
                text(.7,.70,['D_{10} = ',num2str(sample(ii).percentiles(2),3)],'units','normalized')
                text(.7,.62,['D_{50} = ',num2str(sample(ii).percentiles(5),3)],'units','normalized')
                text(.7,.54,['D_{90} = ',num2str(sample(ii).percentiles(8),3)],'units','normalized')
            end
            

        else %if sample(ii).resolution==1
            
            % if there is a distribution and resolution is 1
            % we need to replot ax2 (plot), replot ax3 (auto image)
            
            if ~isempty(sample(ii).dist)
                sample(ii).dist(:,1)= orig_scale{ii};
                [sample(ii).percentiles,sample(ii).geom_moments,...
                    sample(ii).arith_moments]=gsdparams(sample(ii).dist(:,2),sample(ii).dist(:,1));
                
                sample(ii).geom_moments(2) = 1000*2^-sample(ii).geom_moments(2);
                
                axes(ax2)
                cla(ax2)
                bar(sample(ii).dist(:,1),sample(ii).dist(:,2))
                xlabel('Size (Pixels)')
                ylabel('Density')
                axis tight
                set(gca,'ydir','normal')
                text(.7,.92,['Mean = ',num2str(sample(ii).arith_moments(1),3)],'units','normalized')
                text(.7,.85,['Sorting = ',num2str(sample(ii).arith_moments(2),3)],'units','normalized')
                text(.7,.78,['Skewness = ',num2str(sample(ii).arith_moments(3),3)],'units','normalized')
                text(.7,.70,['D_{10} = ',num2str(sample(ii).percentiles(2),3)],'units','normalized')
                text(.7,.62,['D_{50} = ',num2str(sample(ii).percentiles(5),3)],'units','normalized')
                text(.7,.54,['D_{90} = ',num2str(sample(ii).percentiles(8),3)],'units','normalized')
            end % empty
            
            
        end % res ==1
        
    end % ii
    
    if sample(ix).resolution~=1
        % turn labels to 'mm' rather than 'pixels'
        set(get(ax,'xlabel'),'string','mm')
        set(get(ax,'ylabel'),'string','mm')
        
        % first set axes ticks to be increments of 500
        set(ax,'ytick',(500:500:size(sample(ix).data,1)))
        set(ax,'xtick',(500:500:size(sample(ix).data,2)))
        % scale current x and y labels
        set(ax,'xticklabels',num2str(get(ax,'xtick')'.*sample(ix).resolution))
        set(ax,'yticklabels',num2str(get(ax,'ytick')'.*sample(ix).resolution))
        
        % turn labels to 'mm' rather than 'pixels'
        set(get(ax3,'xlabel'),'string','mm')
        set(get(ax3,'ylabel'),'string','mm')
        
        % scale current x and y labels
        set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample(ix).resolution))
        set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample(ix).resolution))
        
    else
        % turn labels to 'Pixels' rather than 'mm'
        set(get(ax,'xlabel'),'string','Pixels')
        set(get(ax,'ylabel'),'string','Pixels')
        
        % first set axes ticks to be increments of 500
        set(ax,'ytick',(500:500:size(sample(ix).data,1)))
        set(ax,'xtick',(500:500:size(sample(ix).data,2)))
        % scale current x and y labels
        set(ax,'xticklabels',num2str(get(ax,'xtick')'.*sample(ix).resolution))
        set(ax,'yticklabels',num2str(get(ax,'ytick')'.*sample(ix).resolution))
        
        % turn labels
        set(get(ax3,'xlabel'),'string','pixels')
        set(get(ax3,'ylabel'),'string','pixels')
        
        % scale current x and y labels
        set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample(ix).resolution))
        set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample(ix).resolution))
    end
    
    
else % no just this one
    
    if ~isempty(sample(ix).dist) && sample(ix).resolution==1
        orig_scale{ix}=sample(ix).dist(:,1);
    elseif ~isempty(sample(ix).dist) && sample(ix).resolution~=1
        orig_scale{ix}=sample(ix).dist(:,1).*1/sample(ix).resolution;
    end
    
    sample(ix).resolution=str2double(get(findobj('tag','res'),'String'));
    
    
    if sample(ix).resolution~=1
        % if there is a distribution but resolution is not 1
        % we need to replot ax2 (plot), replot ax3 (auto image)
        
        if ~isempty(sample(ix).dist)
            sample(ix).dist(:,1)=orig_scale{ix}.*sample(ix).resolution; %sample(ix).dist(:,1)
            [sample(ix).percentiles,sample(ix).geom_moments,...
                sample(ix).arith_moments]=gsdparams(sample(ix).dist(:,2),sample(ix).dist(:,1));
            
            sample(ix).geom_moments(2) = 1000*2^-sample(ix).geom_moments(2);
            
            axes(ax2)
            cla(ax2)
            bar(sample(ix).dist(:,1),sample(ix).dist(:,2))
            xlabel('Size (mm)')
            ylabel('Density')
            axis tight
            set(gca,'ydir','normal')
            text(.7,.92,['Mean = ',num2str(sample(ix).arith_moments(1),3)],'units','normalized')
            text(.7,.85,['Sorting = ',num2str(sample(ix).arith_moments(2),3)],'units','normalized')
            text(.7,.78,['Skewness = ',num2str(sample(ix).arith_moments(3),3)],'units','normalized')
            text(.7,.70,['D_{10} = ',num2str(sample(ix).percentiles(2),3)],'units','normalized')
            text(.7,.62,['D_{50} = ',num2str(sample(ix).percentiles(5),3)],'units','normalized')
            text(.7,.54,['D_{90} = ',num2str(sample(ix).percentiles(8),3)],'units','normalized')
        end
        
        % turn labels to 'mm' rather than 'pixels'
        set(get(ax,'xlabel'),'string','mm')
        set(get(ax,'ylabel'),'string','mm')
        
        % first set axes ticks to be increments of 500
        set(ax,'ytick',(500:500:size(sample(ix).data,1)))
        set(ax,'xtick',(500:500:size(sample(ix).data,2)))
        % scale current x and y labels
        set(ax,'xticklabels',num2str(get(ax,'xtick')'.*sample(ix).resolution))
        set(ax,'yticklabels',num2str(get(ax,'ytick')'.*sample(ix).resolution))
        
        % turn labels to 'mm' rather than 'pixels'
        set(get(ax3,'xlabel'),'string','mm')
        set(get(ax3,'ylabel'),'string','mm')
        
        % scale current x and y labels
        set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample(ix).resolution))
        set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample(ix).resolution))
        
        
    else %if sample(ix).resolution==1
        
        % if there is a distribution and resolution is 1
        % we need to replot ax2 (plot), replot ax3 (auto image)
        
        if ~isempty(sample(ix).dist)
            sample(ix).dist(:,1)= orig_scale{ix};
            [sample(ix).percentiles,sample(ix).geom_moments,...
                sample(ix).arith_moments]=gsdparams(sample(ix).dist(:,2),sample(ix).dist(:,1));
            
            sample(ix).geom_moments(2) = 1000*2^-sample(ix).geom_moments(2);
            
            axes(ax2)
            cla(ax2)
            bar(sample(ix).dist(:,1),sample(ix).dist(:,2))
            xlabel('Size (Pixels)')
            ylabel('Density')
            axis tight
            set(gca,'ydir','normal')
            text(.7,.92,['Mean = ',num2str(sample(ix).arith_moments(1),3)],'units','normalized')
            text(.7,.85,['Sorting = ',num2str(sample(ix).arith_moments(2),3)],'units','normalized')
            text(.7,.78,['Skewness = ',num2str(sample(ix).arith_moments(3),3)],'units','normalized')
            text(.7,.70,['D_{10} = ',num2str(sample(ix).percentiles(2),3)],'units','normalized')
            text(.7,.62,['D_{50} = ',num2str(sample(ix).percentiles(5),3)],'units','normalized')
            text(.7,.54,['D_{90} = ',num2str(sample(ix).percentiles(8),3)],'units','normalized')
        end
        
        % turn labels to 'Pixels' rather than 'mm'
        set(get(ax,'xlabel'),'string','Pixels')
        set(get(ax,'ylabel'),'string','Pixels')
        
        % first set axes ticks to be increments of 500
        set(ax,'ytick',(500:500:size(sample(ix).data,1)))
        set(ax,'xtick',(500:500:size(sample(ix).data,2)))
        % scale current x and y labels
        set(ax,'xticklabels',num2str(get(ax,'xtick')'.*sample(ix).resolution))
        set(ax,'yticklabels',num2str(get(ax,'ytick')'.*sample(ix).resolution))
        
        % turn labels
        set(get(ax3,'xlabel'),'string','pixels')
        set(get(ax3,'ylabel'),'string','pixels')
        
        % scale current x and y labels
        set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample(ix).resolution))
        set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample(ix).resolution))
        
        
    end 
    
end

% finally make ax the current axes, and submit sample to userdata
axes(ax)
set(findobj('tag','current_image'),'userdata',sample);

