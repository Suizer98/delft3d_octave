function AddAxesMenu(h)

cmenu = uicontextmenu; %('Label', 'Edit Annotation');
% Define the context menu items
editmenu = uimenu(cmenu, 'Label', 'Edit Axes','CallBack','EditAnnotationOptions');

% Set UIcontextmenu
set(h, 'UIContextMenu', cmenu);
ch=allchild(h);
set(ch,'UIContextMenu', cmenu);
%set(ch,'ButtonDownFcn','EditAnnotationOptions');
