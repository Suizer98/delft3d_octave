function kngr_setWindowButtonDownFcn(type)
clear global firstclick posold;
global session firstclick posold handles;

firstclick = get(gca,'CurrentPoint');

set(gcf,'WindowButtonUpFcn','kngr_clearWindowsMotionFcn');

switch type
    case 1 % move vertex
        for ii = 1: length(handles)
            id = find(ismember(vertcat(session.vertices{:,3}),handles(ii)));

            posold(ii).XData = session.vertices{id,2}(1,1);
            posold(ii).YData = session.vertices{id,2}(1,2);
        end
        
        set(gcf,'WindowButtonMotionFcn','kngr_moveVertex')
end
