function SetPlotEdit(iopt)

mpt=findobj('Name','Muppet');
handles=guidata(mpt);
ifig=get(gcf,'UserData');

handles.Figure(ifig).Zoom='none';
guidata(mpt,handles);

h=findall(gcf,'Tag','UIToggleToolEditFigure');

set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

if iopt==0
    set(h,'State','off');
    set(gcf, 'windowbuttonupfcn', []);
    set(gcf, 'windowbuttondownfcn', []);
    set(gcf, 'windowbuttonmotionfcn', []);
    %
    ax=findobj(gcf,'Tag','axis');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',[]);
    %
    ax=findobj(gcf,'Tag','legend');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@SelectLegend});
    %
    ax=findobj(gcf,'Tag','vectorlegend');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@SelectVectorLegend});
    %
    ax=findobj(gcf,'Tag','scalebar');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@SelectScaleBar});
    %
    ax=findobj(gcf,'Tag','northarrow');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@SelectNorthArrow});
    %
    ax=findobj(gcf,'Tag','colorbar');
    set(ax,'SelectionHighlight','off');
    for i=1:length(ax)
        usd=get(ax(i),'UserData');
        if length(usd)==2
            set(ax(i),'ButtonDownFcn',{@SelectColorBar,1});
        else
            set(ax(i),'ButtonDownFcn',{@SelectColorBar,2});
        end
    end
    %
    ax=findall(gcf,'Tag','textbox');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
    ax=findall(gcf,'Tag','rectangle');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
    ax=findall(gcf,'Tag','ellipse');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
    ax=findall(gcf,'Tag','line');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
    ax=findall(gcf,'Tag','arrow');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
    ax=findall(gcf,'Tag','doublearrow');
    set(ax,'SelectionHighlight','off');
    set(ax,'ButtonDownFcn',{@UIEditAnnotationOptions});
    %
else
    ax=findobj(gcf,'Tag','axis');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    for i=1:length(ax)
        usd=get(ax(i),'UserData');
        if strcmp(handles.Figure(usd(1)).Axis(usd(2)).PlotType,'3d')
            set(ax(i),'ButtonDownFcn',[]);
        end
    end
    ax=findobj(gcf,'Tag','legend');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findobj(gcf,'Tag','vectorlegend');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findobj(gcf,'Tag','scalebar');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findobj(gcf,'Tag','northarrow');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findobj(gcf,'Tag','colorbar');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','textbox');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','rectangle');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','ellipse');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','line');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','arrow');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    ax=findall(gcf,'Tag','doublearrow');
    set(ax,'ButtonDownFcn',{@SelectAxis});
    set(h,'State','on');
end

set(gcf,'HitTest','off');
set(gcf,'Selected','off');
set(gcf,'SelectionHighlight','off');

set(gcf,'pointer','arrow');

h(1)=findall(gcf,'ToolTipString','Zoom In');
h(2)=findall(gcf,'ToolTipString','Zoom Out');
h(3)=findall(gcf,'ToolTipString','Pan');
h(4)=findall(gcf,'ToolTipString','Rotate 3D');

set(h(1),'State','off');
set(h(2),'State','off');
set(h(3),'State','off');
set(h(4),'State','off');
