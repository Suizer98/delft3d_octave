function kngr_clearWindowsMotionFcn

global session

set(gcf,'WindowButtonMotionFcn','')  
set(gcf,'WindowButtonUpFcn','')  

if ~strcmp(get(gco,'type'),'line')
    kngr_deselectVertices;
    try
        id = find(ismember(vertcat(session.vertices{:,3}),gco));
        set(session.vertices{id,3},'FaceColor',[0 1 0]);
    end
end