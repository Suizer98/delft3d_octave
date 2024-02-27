function kngr_moveVertex

global session firstclick posold handles;

pos    = get(gca,'CurrentPoint');

XVerschuiving = firstclick(1,1)-pos(1,1);
YVerschuiving = firstclick(1,2)-pos(1,2);

kngr_deselectVertices;

for ii = 1:length(handles)
    id = find(ismember(vertcat(session.vertices{:,3}),handles(ii)));
    session.vertices{id,2} = [posold(ii).XData - XVerschuiving posold(ii).YData - YVerschuiving];
    set(session.vertices{id,3},'FaceColor',[0 1 0]);
end

kngr_plotGraph(gcf);

