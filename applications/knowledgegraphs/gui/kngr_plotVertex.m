function vh = kngr_plotVertex(vh, x, y, vertexSize)

if nargin == 3
    vertexSize = 5;
end

XData = [x - .5*vertexSize, x + .5*vertexSize, x + .5*vertexSize, x - .5*vertexSize];
YData = [y - .5*vertexSize, y - .5*vertexSize, y + .5*vertexSize, y + .5*vertexSize];

if isempty(vh)
    vh = patch(XData, YData, ones(size(XData))*0,'b');
else
    set(vh,'XData',XData,'YData',YData);
end

set(vh,'buttondownfcn','kngr_moveObject');
