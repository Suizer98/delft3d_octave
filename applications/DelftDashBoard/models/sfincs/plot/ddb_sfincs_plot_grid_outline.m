function handles = ddb_sfincs_plot_grid_outline(handles, opt, varargin)

col=[1 0 0];
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
            delete(handles.model.sfincs.domain(id).gridoutline.handle);
        end
        
        x0=handles.model.sfincs.domain(id).input.x0;
        y0=handles.model.sfincs.domain(id).input.y0;
        dx=handles.model.sfincs.domain(id).input.dx;
        dy=handles.model.sfincs.domain(id).input.dy;
        mmax=handles.model.sfincs.domain(id).input.mmax;
        nmax=handles.model.sfincs.domain(id).input.nmax;
        dx=dx*mmax;
        dy=dy*nmax;
        rot=handles.model.sfincs.domain(id).input.rotation*pi/180;
        
        xx(1)=x0;
        yy(1)=y0;
        xx(2)=xx(1)+cos(rot)*dx;
        yy(2)=yy(1)+sin(rot)*dx;
        xx(3)=xx(2)+cos(rot+0.5*pi)*dy;
        yy(3)=yy(2)+sin(rot+0.5*pi)*dy;
        xx(4)=xx(3)+cos(rot+1.0*pi)*dx;
        yy(4)=yy(3)+sin(rot+1.0*pi)*dx;
        xx(5)=xx(1);
        yy(5)=yy(1);
        
        p=plot(xx,yy);
        set(p,'Color',col,'LineWidth',1.5,'tag','sfincsgridoutline');
        set(p,'HitTest','off');
        
        handles.model.sfincs.domain(id).gridoutline.handle=p;
        
        if vis
            set(p,'Color',col,'Visible','on');
        else
            set(p,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).gridoutline.handle);
        catch
            h=findobj(gcf,'tag','sfincsgridoutline');
            if ~isempty(h)
                delete(h);
            end            
        end
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).gridoutline.handle;
            if ~isempty(p)
                try
                    set(p,'Color',col);
                    if vis
                        set(p,'Color',col,'Visible','on');
                    else
                        set(p,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

