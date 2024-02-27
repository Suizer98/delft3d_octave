function handles=ddb_zoomTo(handles,xl,yl,border)
% Zoom to specific area
dx=xl(2)-xl(1);
dy=yl(2)-yl(1);

xl(1)=xl(1)-border*dx;
xl(2)=xl(2)+border*dx;
yl(1)=yl(1)-border*dy;
yl(2)=yl(2)+border*dy;

[xl,yl]=CompXYLim(xl,yl,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);

set(handles.GUIHandles.mapAxis,'XLim',xl,'YLim',yl);
handles.screenParameters.xLim=xl;
handles.screenParameters.yLim=yl;
