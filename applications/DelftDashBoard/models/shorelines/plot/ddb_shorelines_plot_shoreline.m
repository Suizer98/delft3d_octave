function handles = ddb_shorelines_plot_shoreline(handles, opt, varargin)

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
            h=findobj(gca,'tag','shorelines_shoreline');
            delete(h);
        end
        
        if handles.model.shorelines.nrshorelines>0
            for as=1:handles.model.shorelines.nrshorelines
                % First delete old shoreline
                try
                    delete(handles.model.shorelines.shorelines(as).handle);
                end
                handles.model.shorelines.shorelines(as).handle=[];
                xp=handles.model.shorelines.shorelines(as).x;
                yp=handles.model.shorelines.shorelines(as).y;
                
                % h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
                if as==handles.model.shorelines.activeshoreline
                    h=plot(xp,yp,'r',xp(1),yp(1),'o','linewidth',1.5,'tag','shorelines_shoreline');
                    %h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@modify_shoreline,'tag','shorelines_shoreline','color','k','marker','o');
                else
                    h=plot(xp,yp,'k','linewidth',1.5,'tag','shorelines_shoreline');
                end
                handles.model.shorelines.shorelines(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
        
        
    case{'delete'}
        
        try
            h=findobj(gca,'tag','shorelines_shoreline')
            delete(h);
        end
        
    case{'update'}
 
        try
            h=findobj(gca,'tag','shorelines_shoreline');
            delete(h);
        end

        if handles.model.shorelines.nrshorelines>0
            for as=1:handles.model.shorelines.nrshorelines
                handles.model.shorelines.shorelines(as).handle=[];
                xp=handles.model.shorelines.shorelines(as).x;
                yp=handles.model.shorelines.shorelines(as).y;
                
                h=plot(xp,yp,'k','linewidth',1.5,'tag','shorelines_shoreline');
                handles.model.shorelines.shorelines(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
end

%%
function modify_shoreline(h,x,y,number)

handles=getHandles;

% Delete temporary shoreline

% delete(h);
as=handles.model.shorelines.activeshoreline;
handles.model.shorelines.shorelines(as).x=x;
handles.model.shorelines.shorelines(as).y=y;
%handles.model.shorelines.shorelines(as).handle=h;

setHandles(handles);


