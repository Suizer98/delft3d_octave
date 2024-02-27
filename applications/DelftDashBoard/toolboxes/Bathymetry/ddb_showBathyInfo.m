function ddb_showBathyInfo(handles,iac)

fig = MakeNewWindow('Warning',[260 272],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);
cl=get(gcf,'Color');
ax=axes;
set(ax,'units','pixels');
set(ax,'position',[20 121 221 131]);
tx=uicontrol(fig,'style','text','string',txt,'position',[20 61 221 41],'horizontalalignment','center','backgroundcolor',cl);
if ~isempty(h)
    StatName=[h.settingsDir filesep 'icons' filesep 'god2.jpg'];
    c = imread(StatName,'jpeg');
    image(c);
    tick(gca,'x','none');tick(gca,'y','none');
else
    set(gca,'Visible','off');
end
okbut=uicontrol(gcf,'style','pushbutton','position',[100 21 71 31],'String','OK');
set(okbut,'Callback',@pushOK);
uiwait;
try
    close(fig);
end

%%
function pushOK(hObject, eventdata)
uiresume;
