function [xl,yl]=zoom_to(ax,xl,yl,cstype)

xmaxrange=[-1e9 1e9];
ymaxrange=[-1e9 1e9];
border=0;

% Zoom to specific area

dx=xl(2)-xl(1);
dy=yl(2)-yl(1);

xl(1)=xl(1)-border*dx;
xl(2)=xl(2)+border*dx;
yl(1)=yl(1)-border*dy;
yl(2)=yl(2)+border*dy;

[xl,yl]=compute_axis_limits(ax,xl,yl,xmaxrange,ymaxrange,cstype);

set(ax,'XLim',xl,'YLim',yl);
