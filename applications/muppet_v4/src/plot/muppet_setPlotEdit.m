function muppet_setPlotEdit(iopt)

fig=getappdata(gcf,'figure');
figh=fig.handle;

h=findobj(figh,'Tag','UIToggleToolEditFigure');

set(figh, 'windowbuttonupfcn', []);
set(figh, 'windowbuttondownfcn', []);
set(figh, 'windowbuttonmotionfcn', []);

if iopt==0
    set(h,'State','off');
    set(figh, 'windowbuttonupfcn', []);
    set(figh, 'windowbuttondownfcn', []);
    set(figh, 'windowbuttonmotionfcn', []);
    %
    ax=findobj(figh,'Tag','axis');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',[]);
    %
    ax=findobj(figh,'Tag','legend');
    set(ax,'SelectionHighlight','off');
%     set(ax,'ButtonDownFcn',{@SelectLegend});
    %
    ax=findobj(figh,'Tag','vectorlegend');
    set(ax,'SelectionHighlight','off');
%     set(ax,'ButtonDownFcn',{@SelectVectorLegend});
    %
    ax=findobj(figh,'Tag','scalebar');
    set(ax,'SelectionHighlight','off');
%     set(ax,'ButtonDownFcn',{@SelectScaleBar});
    %
    ax=findobj(figh,'Tag','northarrow');
    set(ax,'SelectionHighlight','off');
%     set(ax,'ButtonDownFcn',{@SelectNorthArrow});
    %
    ax=findobj(figh,'Tag','colorbar');
    set(ax,'SelectionHighlight','off');
    for i=1:length(ax)
        usd=get(ax(i),'UserData');
        if length(usd)==2
%             set(ax(i),'ButtonDownFcn',{@SelectColorBar,1});
        else
%             set(ax(i),'ButtonDownFcn',{@SelectColorBar,2});
        end
    end
    %
    ax=findall(figh,'Tag','annotation');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@muppet_UIEditAnnotationOptions});
    %
else
    ax=findobj(figh,'Tag','axis');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    for i=1:length(ax)
        usd=get(ax(i),'UserData');
        if strcmp(fig.subplots(usd(2)).subplot.type,'3d')
            set(ax(i),'ButtonDownFcn',[]);
        end
    end
    ax=findobj(figh,'Tag','legend');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    ax=findobj(figh,'Tag','vectorlegend');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    ax=findobj(figh,'Tag','scalebar');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    ax=findobj(figh,'Tag','northarrow');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    ax=findobj(figh,'Tag','colorbar');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    ax=findall(figh,'Tag','annotation');
    set(ax,'ButtonDownFcn',{@muppet_selectAxis});
    set(h,'State','on');
end

set(figh,'HitTest','off');
set(figh,'Selected','off');
set(figh,'SelectionHighlight','off');

set(figh,'pointer','arrow');

h(1)=findobj(figh,'ToolTipString','Zoom In');
h(2)=findobj(figh,'ToolTipString','Zoom Out');
h(3)=findobj(figh,'ToolTipString','Pan');
h(4)=findobj(figh,'ToolTipString','Rotate 3D');

set(h(1),'State','off');
set(h(2),'State','off');
set(h(3),'State','off');
set(h(4),'State','off');
