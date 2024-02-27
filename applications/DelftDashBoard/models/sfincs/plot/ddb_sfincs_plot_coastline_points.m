function handles = ddb_sfincs_plot_coastline_points(handles, opt, varargin)

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
            delete(handles.model.sfincs.domain(id).coastline.handle);
        end
        handles.model.sfincs.domain(id).coastline.handle=[];
        try
            delete(handles.model.sfincs.domain(id).coastline.active_point_handle);
        end
        handles.model.sfincs.domain(id).coastline.active_point_handle=[];
        
        if handles.model.sfincs.domain(ad).coastline.length>0
            
            xp=handles.model.sfincs.domain(ad).coastline.x;
            yp=handles.model.sfincs.domain(ad).coastline.y;
            p=plot(xp,yp,'o');
            set(p,'MarkerEdgeColor','k','MarkerFaceColor','k');
            set(p,'tag','sfincscoastlinepoints');
            handles.model.sfincs.domain(ad).coastline.handle=p;
            
            ip=handles.model.sfincs.domain(ad).coastline.active_point;
            xp=handles.model.sfincs.domain(ad).coastline.x(ip);
            yp=handles.model.sfincs.domain(ad).coastline.y(ip);
            p2a=plot(xp,yp,'o');
            set(p2a,'MarkerEdgeColor','r','MarkerFaceColor','r');
            set(p2a,'tag','sfincsactivecoastlinepoint');
            l=1000;
            phi=0.5*pi-handles.model.sfincs.domain(ad).coastline.orientation(ip)*pi/180;
            x(1)=xp+l*cos(phi);
            x(2)=xp;
            y(1)=yp+l*sin(phi);
            y(2)=yp;
            p2b=plot(x,y,'r');
            set(p2b,'tag','sfincsactivecoastlinepoint');
            p2=hggroup;
            set(p2a,'Parent',p2);
            set(p2b,'Parent',p2);
            
            handles.model.sfincs.domain(ad).coastline.active_point_handle=p2;
            
            if vis
                set(p,'Visible','on');
                set(p2,'Visible','on');
            else
                set(p,'Visible','off');
                set(p2,'Visible','off');
            end
            
        end
        
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).coastline.handle);
        catch
            p=findobj(gcf,'tag','sfincscoastlinepoints');
            if ~isempty(p)
                delete(p);
            end
        end
        try
            delete(handles.model.sfincs.domain(id).coastline.active_point_handle);
        catch
            p=findobj(gcf,'tag','sfincsactivecoastlinepoint');
            if ~isempty(p)
                delete(p);
            end
        end
        handles.model.sfincs.domain(id).coastline.handle=[];
        handles.model.sfincs.domain(id).coastline.active_point_handle=[];
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).coastline.handle;
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
        try
            p=handles.model.sfincs.domain(id).coastline.active_point_handle;
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

