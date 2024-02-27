function kngr_moveObject

global session handles;
switch get(gcf,'selectiontype')
    case 'normal' % left mouse button click
        id = [];
        if strcmp(get(gco,'type'),'line')
            id = ismember(session.edgeHandles,gco); 
            [i,j,s] = find(id);
            id = [i j];
            set(findobj('tag','frmtxt'),'string',session.vertices{i,1},'BackgroundColor',[0 1 0]);
            set(findobj('tag','totxt'),'string',session.vertices{j,1},'BackgroundColor',[0 1 0]);
            set(findobj('Tag','type'), 'value', session.edges(i,j)+1);
            
            % edge movement will clear the interpretation text boxes
            set(findobj('Tag','txtin'), 'string', '');
            set(findobj('Tag','txtout'), 'string', '');
            set(findobj('Tag','txtDic'), 'string', '');
        elseif strcmp(get(gco,'type'),'patch')
            try
                kngr_interpretGraph
            end
            id = find(ismember(vertcat(session.vertices{:,3}),gco));
        end

        if ~isempty(id)
            handles = [];
            for i = 1: length(id)
                try
                    vinfr = session.vertices{id(i),7};
                catch
                    vinfr = [];
                end
                handles = [handles; vertcat(session.vertices{id(i),3}, session.vertices{vinfr,3})];
            end
            if ~strcmp(get(gco,'type'),'line')
                id = find(ismember(vertcat(session.vertices{:,3}),gco));
                set(findobj('tag','frmtxt'),'string',session.vertices{id,1},'BackgroundColor',[0 1 0]);
                set(findobj('tag','totxt'),'BackgroundColor',[1 1 1]);
            end
            kngr_setWindowButtonDownFcn(1);
            kngr_moveVertex;
        end
    case 'alt' % right mousebutton click
        try
            id = find(ismember(vertcat(session.vertices{:,3}),gco));
            kngr_deselectVertices;
            set(session.vertices{id,3},'FaceColor',[1 0 0]);
            set(findobj('tag','frmtxt'),'BackgroundColor',[1 1 1]);
            set(findobj('tag','totxt'),'string',session.vertices{id,1},'BackgroundColor',[1 0 0]);
            try
                kngr_interpretGraph
            end
        end
    case 'extend'

    case 'open'

end



