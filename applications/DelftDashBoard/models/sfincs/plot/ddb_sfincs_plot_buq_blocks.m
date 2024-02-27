function handles = ddb_sfincs_plot_buq_blocks(handles, opt, varargin)

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
            delete(handles.model.sfincs.domain(id).buq_blocks.handle);
        end
        buq = handles.model.sfincs.domain(id).buq;
        [xg,yg]=buq_get_block_coordinates(buq);
        p = plot(xg,yg,'k');
        
        set(p,'Color',col,'LineWidth',0.2,'tag','sfincs_buq_blocks');
        set(p,'HitTest','off');
        
        handles.model.sfincs.domain(id).buq_blocks.handle=p;
        
        if vis
            set(p,'Color',col,'Visible','on');
        else
            set(p,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).buq_blocks.handle);
        catch
            h=findobj(gcf,'tag','sfincs_buq_blocks');
            if ~isempty(h)
                delete(h);
            end            
        end
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).buq_blocks.handle;
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

