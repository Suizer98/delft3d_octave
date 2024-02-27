function ddb_plotsfincs(option,varargin)

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.

handles=getHandles;

vis=1;
act=0;
id=ad;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'deactivate'}
                dact=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

if id==0
    id1=1;
    id2=length(handles.model.sfincs.domain);
else
    id1=id;
    id2=id;
end

for id=id1:id2
    
    switch option
        
        case{'plot'}
            
            col='r';
            handles=ddb_sfincs_plot_grid_outline(handles,option,'domain',id,'color',col,'visible',1);
            handles=ddb_sfincs_plot_grid(handles,option,'domain',id,'color',[0.8 0.8 0.8],'visible',1);
            handles=ddb_sfincs_plot_flow_boundary_points(handles,option,'domain',id,'visible',1);
            handles=ddb_sfincs_plot_wave_boundary_points(handles,option,'domain',id,'visible',1);
            handles=ddb_sfincs_plot_mask(handles,option,'domain',id,'visible',1);
            handles=ddb_sfincs_plot_coastline_points(handles,option,'domain',id,'visible',1);
            if ~isempty(handles.model.sfincs.domain(id).buq)
                handles=ddb_sfincs_plot_buq_blocks(handles,option,'domain',id,'visible',1);
            end
            
        case{'delete'}
            
            handles=ddb_sfincs_plot_grid_outline(handles,option,'domain',id);
            handles=ddb_sfincs_plot_grid(handles,option,'domain',id);
            handles=ddb_sfincs_plot_flow_boundary_points(handles,option,'domain',id);
            handles=ddb_sfincs_plot_wave_boundary_points(handles,option,'domain',id);
            handles=ddb_sfincs_plot_mask(handles,option,'domain',id);
            handles=ddb_sfincs_plot_coastline_points(handles,option,'domain',id);
            if ~isempty(handles.model.sfincs.domain(id).buq)
                handles=ddb_sfincs_plot_buq_blocks(handles,option,'domain',id);
            end

            try
                delete(handles.model.sfincs.boundaryspline.handle);                
            end
            h=findobj(gcf,'Tag','sfincsboundaryspline');
            if ~isempty(h)
                delete(h)
            end
            try
                delete(handles.model.sfincs.coastspline.handle);                
            end
            h=findobj(gcf,'Tag','sfincscoastspline');
            if ~isempty(h)
                delete(h)
            end
            try
                delete(handles.model.sfincs.depthcontour.handle);
            end
            h=findobj(gcf,'Tag','datadepthcontour');
            if ~isempty(h)
                delete(h)
            end
            handles.model.sfincs.boundaryspline.handle=[];
            handles.model.sfincs.depthcontour.handle=[];
            
        case{'update'}
            
%             if act
%                 col=[1 1 0];
%             else
%                 col=[0.8 0.8 0.8];
%             end
%             handles=ddb_sfincs_plot_grid_outline(handles,option,'domain',id,'visible',vis,'color',col);

            col=[0.8 0.8 0.8];
            handles=ddb_sfincs_plot_grid_outline(handles,option,'domain',id,'visible',vis,'color',col);
            
            if act && vis
                ivis=1;
            else
                ivis=0;
            end
            
            handles=ddb_sfincs_plot_flow_boundary_points(handles,option,'domain',id,'visible',ivis);
            handles=ddb_sfincs_plot_wave_boundary_points(handles,option,'domain',id,'visible',ivis);
            
            % Boundary spline
            try
                h=handles.model.sfincs.boundaryspline.handle;
                if ~isempty(h)
                    set(h,'visible','off');
                end
            end

            % Coastline spline
            try
                h=handles.model.sfincs.coastspline.handle;
                if ~isempty(h)
                    set(h,'visible','off');
                end
            end
            
            % Depth contour
            try
                h=handles.model.sfincs.depthcontour.handle;
                if ~isempty(h)
                    set(h,'visible','off');
                end
            end

            if act
                ivis=1;
            else
                ivis=0;
            end
            ivis=1;
            handles=ddb_sfincs_plot_mask(handles,option,'domain',id,'visible',ivis);
            handles=ddb_sfincs_plot_coastline_points(handles,option,'domain',id,'visible',ivis);            

%             if act && vis
%                 ivis=1;
%             else
%                 ivis=0;
%             end
            if ~isempty(handles.model.sfincs.domain(id).buq)
                handles=ddb_sfincs_plot_buq_blocks(handles,option,'domain',id,'visible',1);
            end
            
            
    end
    
end

setHandles(handles);
