function fh = kngr_plotFrame(fh, x, y, w, h)

XData = [x x+w x+w x];
YData = [y y y+h y+h];
ZData = ones(size(XData))*-.1;

if isempty(fh)
    %     fh = rectangle('Position',[x, y, w, h]);
    fh = patch(XData, YData, ZData);
    set(fh,'FaceColor','none');
else
    %     set(fh,'Position',[x, y, w, h]);
    set(fh,'XData',XData,'YData',YData,'ZData',ZData);
    set(fh,'FaceColor','none');
end

set(fh,'buttondownfcn','kngr_moveObject');
