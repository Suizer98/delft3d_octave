function lh = kngr_plotLabel(lh, x, y, txtLabel, fontSize)

if nargin == 4
    fontSize = 6;
end

if isempty(lh)
    lh = text(x,y,txtLabel);
else
    set(lh,'Position',[x y]);
end

set(lh,'HorizontalAlignment','center');
set(lh,'fontSize',fontSize,'FontWeight','bold','Color',[0 0 0]);
set(lh,'buttondownfcn','kngr_moveObject');