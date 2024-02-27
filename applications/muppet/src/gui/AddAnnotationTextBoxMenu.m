function AddAnnotationTextBoxMenu(h)

cmenu = uicontextmenu; %('Label', 'Edit Annotation');
% Define the context menu items
editmenu = uimenu(cmenu, 'Label', 'Edit Annotation','CallBack','EditAnnotationOptions');

% Set UIcontextmenu
set(h, 'UIContextMenu', cmenu);
ch=get(h,'Children');
set(ch,'UIContextMenu', cmenu);
