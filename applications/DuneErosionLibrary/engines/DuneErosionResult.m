classdef DuneErosionResult
    %% General properties
    properties
        iD;
    end
    
    properties
        calculationTime;
        messages;
    end
    
    properties (Abstract = true, SetAccess = 'protected')
        % profiles (time dependant?)
        xPreStorm;
        zPreStorm;
        xPostStorm;
        zPostStorm;
    end
    
    properties
        % calculation result (volumes)
        erosionVolume;
        accretionVolume;
        volumeBalance;
        cumulativeVolumes;
    end
        
    methods
        function plot(obj,varargin)
            OPT = struct(...
                'DisplayName','Dune erosion calculation result',...
                'LineStyle','-',...
                'LineWidth',2);
            
            if nargin > 1 && ishandle(varargin{1}) && strcmp(get(varargin{1},'type'),'axes')
                handle = varargin{1};
                varargin(1)=[];
            else
                handle = gca;
            end

            setproperty(OPT,varargin);
            
            holdstate = ishold(handle);
            
            hold(handle);
            for iobj = length(obj):-1:1
                plot(handle,obj(iobj).xPreStorm,obj(iobj).zPreStorm,OPT,'Color','k');
                plot(handle,obj(iobj).xPostStorm,obj(iobj).zPostStorm,OPT,'Color','r');
                patch([obj(iobj).xPreStorm; flipud(obj(iobj).xPostStorm)],...
                    [obj(iobj).zPreStorm; flipud(obj(iobj).zPostStorm)],...
                    [0 0 0.4],...
                    'HandleVisibility','off',...
                    'EdgeColor','none');
            end
            box(handle,'on');
            grid(handle,'on');
            legend(handle,'show');
            
            if holdstate
                hold(handle,'on');
            else
                hold(handle,'off');
            end
        end
    end
    
end