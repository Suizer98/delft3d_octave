function handles = ddb_sfincs_plot_flow_boundary_points(handles, opt, varargin)

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
        
        % First delete old grid
        try
            delete(handles.model.sfincs.domain(id).flowboundarypoints.handle);
        end
        
        xp=handles.model.sfincs.domain(ad).flowboundarypoints.x;
        yp=handles.model.sfincs.domain(ad).flowboundarypoints.y;
        p=plot(xp,yp,'o');
        set(p,'MarkerEdgeColor','m','MarkerFaceColor','m');
        set(p,'tag','sfincsflowboundarypoints');
        handles.model.sfincs.domain(ad).flowboundarypoints.handle=p;
        
        if vis
            set(p,'Visible','on');
        else
            set(p,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).flowboundarypoints.handle);
        catch
            p=findobj(gcf,'tag','sfincsflowboundarypoints');
            if ~isempty(p)
                delete(p);
            end
        end
        handles.model.sfincs.domain(id).flowboundarypoints.handle=[];
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).flowboundarypoints.handle;
            if ~isempty(p)
                try
                    if vis
                        set(p,'Visible','on');
                    else
                        set(p,'Visible','off');
                    end
                end
            end
        end
end

