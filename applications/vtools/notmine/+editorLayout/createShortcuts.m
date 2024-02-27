%Add shortcuts to matlab for loading, opening, and managing editor
%sessions. Also optionally copies needed files to userpath for opening
%sessions right when matlab is opened without changing the path.
%
%Make sure this file is on the path before running it!

disp('Make sure to place the editorLayout package on the user path (a path')
disp(' that will be available when first opening matlab, otherwise the ')
disp(' shortcuts will not work. ')
disp('You can run editorLayout.copyFilesToUserPath to do this automatically if you want.')

shortcutNames = {
    editorLayout.SessionEditor.shortcutSave;
    editorLayout.SessionEditor.shortcutOpen;
    editorLayout.SessionEditor.shortcutManageSessions};
shortcutCategoryName = editorLayout.SessionEditor.shortcutCategory;
shortcutCallbacks = {
    'editorLayout.SessionEditor.saveSession()';
    'editorLayout.SessionEditor.openSession()';
    'editorLayout.SessionEditor.manageSessions()'};

shortcutsJava = com.mathworks.mlwidgets.shortcuts.ShortcutUtils.getShortcutsByCategory(shortcutCategoryName);
if isempty(shortcutsJava)
    shortcuts = {};
else
    shortcuts = cell(shortcutsJava.size(),1);
end
for i=1:length(shortcuts)
    shortcuts{i} = char(shortcutsJava.elementAt(i-1));
end
for i=1:length(shortcutNames)
    if any(strcmp(shortcutNames{i},shortcuts))
        icon = shortcutsJava.elementAt(i-1).getIconPath;%preserve previous icon if customized. Don't do [] as this will put no icon instead of 'Standard icon'.
        editable = 'true';
        awtinvoke(com.mathworks.mlwidgets.shortcuts.ShortcutUtils,'editShortcut', shortcutNames{i}, shortcutCategoryName, shortcutNames{i}, shortcutCategoryName, shortcutCallbacks{i},icon,editable);
    else
        icon = [];% This becomes 'Standard icon'
        editable = 'true';
        awtinvoke(com.mathworks.mlwidgets.shortcuts.ShortcutUtils,'addShortcutToBottom', shortcutNames{i}, shortcutCallbacks{i}, icon, shortcutCategoryName, editable);
    end
end

disp('Shortcuts added successfully');