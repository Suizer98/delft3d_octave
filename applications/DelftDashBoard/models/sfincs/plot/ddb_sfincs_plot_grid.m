function handles = ddb_sfincs_plot_grid(handles, opt, varargin)

col=[0.8 0.8 0.8];
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

vis=vis*handles.model.sfincs.menuview.grid;

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        try
            delete(handles.model.sfincs.domain(id).grid.handle);
        end
                
%        p=plot(handles.model.sfincs.domain(id).xg,handles.model.sfincs.domain(id).yg)
        p=mesh2d(handles.model.sfincs.domain(id).xg,handles.model.sfincs.domain(id).yg);
%         p(1)=plot(handles.model.sfincs.domain(id).xg,handles.model.sfincs.domain(id).yg);
%         p(2)=plot(handles.model.sfincs.domain(id).xg',handles.model.sfincs.domain(id).yg');
        
        set(p,'Color',col,'LineWidth',0.2,'tag','sfincsgrid');
        set(p,'HitTest','off');
        
        handles.model.sfincs.domain(id).grid.handle=p;
        
        if vis
            set(p,'Color',col,'Visible','on');
        else
            set(p,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).grid.handle);
        catch
            h=findobj(gcf,'tag','sfincsgrid');
            if ~isempty(h)
                delete(h);
            end            
        end
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).grid.handle;
            if ~isempty(p)
                try
%                     set(p,'Color',col);
                    if vis
                        set(p,'Color',col,'Visible','on');
                    else
                        set(p,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

