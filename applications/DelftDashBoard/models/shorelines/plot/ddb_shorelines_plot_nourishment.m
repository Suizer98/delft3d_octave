function handles = ddb_shorelines_plot_nourishment(handles, opt, varargin)

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
            h=findobj(gca,'tag','shorelines_nourishment');
            delete(h);
        end
            
        if handles.model.shorelines.nrnourishments>0
            for as=1:handles.model.shorelines.nrnourishments
                % First delete old shoreline
                try
                    delete(handles.model.shorelines.nourishments(as).handle);
                end
                handles.model.shorelines.nourishments(as).handle=[];
                xp=handles.model.shorelines.nourishments(as).x;
                yp=handles.model.shorelines.nourishments(as).y;
                
                % h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
                if as==handles.model.shorelines.activenourishment
                    %h=plot(xp,yp,'r','linewidth',2)
                    h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@modify_nourishment,'tag','shorelines_nourishment','color','k','linestyle',':','marker','o');
                else
                    h=plot(xp,yp,'k:','linewidth',1.5,'tag','shorelines_nourishment');
                end
                handles.model.shorelines.nourishments(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
        
        
    case{'delete'}
        
        % First delete old nourishment
        try
            h=findobj(gca,'tag','shorelines_nourishment');
            delete(h);
        end
        
    case{'update'}
        
        % First delete old nourishment
        try
            h=findobj(gca,'tag','shorelines_nourishment');
            delete(h);
        end
        
        if handles.model.shorelines.nrnourishments>0
            for as=1:handles.model.shorelines.nrnourishments
                handles.model.shorelines.nourishments(as).handle=[];
                xp=handles.model.shorelines.nourishments(as).x;
                yp=handles.model.shorelines.nourishments(as).y;
                
                h=plot(xp,yp,'k:','linewidth',1.5,'tag','shorelines_nourishment');
                handles.model.shorelines.nourishments(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
end

%%
function modify_nourishment(h,x,y,number)

handles=getHandles;

% Delete temporary nourishment

% delete(h);
as=handles.model.shorelines.activenourishment;
handles.model.shorelines.nourishments(as).x=x;
handles.model.shorelines.nourishments(as).y=y;
%handles.model.shorelines.nourishments(as).handle=h;

setHandles(handles);


