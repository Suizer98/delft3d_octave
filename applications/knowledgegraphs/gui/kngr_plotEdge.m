function eh = kngr_plotEdge(eh, x, y, type, edgeWeight)

if nargin == 3
    edgeWeight = .2;
end

if isempty(eh)
    eh = line(x,y,[-.1 -.1]);
    set(eh,'LineWidth',edgeWeight,'Color',type.color);
else
    set(eh,'XData',x,'YData',y);
    set(eh,'LineWidth',edgeWeight,'Color',type.color);
end

set(eh,'buttondownfcn','kngr_moveObject');