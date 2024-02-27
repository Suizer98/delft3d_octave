function handles = ddb_shorelines_plot_channel(handles, opt, varargin)

col=[0.35 0.35 0.35];
vis=1;
id=ad;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}

        try
            h=findobj(gca,'tag','shorelines_channel');
            delete(h);
        end
                
        if handles.model.shorelines.nrchannels>0
            for as=1:handles.model.shorelines.nrchannels
                handles.model.shorelines.channels(as).handle=[];
                xp=handles.model.shorelines.channels(as).x;
                yp=handles.model.shorelines.channels(as).y;
                
                % h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
                if as==handles.model.shorelines.activechannel
                    %h=plot(xp,yp,'r','linewidth',2)
                    h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@modify_channel,'tag','shorelines_channel','color','b','linestyle','--','marker','o');
                else
                    h=plot(xp,yp,'b--','linewidth',1.5,'tag','shorelines_channel');
                end
                handles.model.shorelines.channels(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
        
        
    case{'delete'}
        
        % First delete old channel
        try
            h=findobj(gca,'tag','shorelines_channel');
            delete(h);
        end
        
    case{'update'}
        
        try
            h=findobj(gca,'tag','shorelines_channel');
            delete(h);
        end
        
        if handles.model.shorelines.nrchannels>0
%             for as=1:handles.model.shorelines.nrchannels
%                 handles.model.shorelines.channels(as).handle=[];
                xp=handles.model.shorelines.domain.xr_mc;
                yp=handles.model.shorelines.domain.yr_mc;
                
                h=plot(xp,yp,'b--','linewidth',1.5,'tag','shorelines_channel');
                handles.model.shorelines.channels.handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
%             end
        end
end

%%
function modify_channel(h,x,y,number)

handles=getHandles;

% Delete temporary channel

% delete(h);
as=handles.model.shorelines.activechannel;
handles.model.shorelines.channels(as).x=x;
handles.model.shorelines.channels(as).y=y;
%handles.model.shorelines.channels(as).handle=h;

setHandles(handles);


