function kngr_moveEdge

global session firstclick posold handles;

pos = get(gca,'CurrentPoint');

XVerschuiving = firstclick(1,1)-pos(1,1);
YVerschuiving = firstclick(1,2)-pos(1,2);

id = find(ismember(vertcat(session.vertices{:,3}),handles));

session.vertices{posold.edgecomponent1,2}(1,1) = posold.XData1 - XVerschuiving;
session.vertices{posold.edgecomponent1,2}(1,2) = posold.YData1 - YVerschuiving;
session.vertices{posold.edgecomponent2,2}(1,1) = posold.XData2 - XVerschuiving;
session.vertices{posold.edgecomponent2,2}(1,2) = posold.YData2 - YVerschuiving;

deselectVertices

set(session.vertices{posold.edgecomponent1,3},'FaceColor',[0 1 0]);
set(session.vertices{posold.edgecomponent2,3},'FaceColor',[0 1 0]);

kngr_plotGraph(gcf);

