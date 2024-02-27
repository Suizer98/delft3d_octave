function muppet_giveWarning(varargin)

h=getHandles;

imgpath=[h.settingsdir 'icons' filesep];
fig = MakeNewWindow('Warning',[260 272],'modal',[imgpath 'deltares.gif']);
cl=get(gcf,'Color');
txt=varargin{2};
ax=axes;
set(ax,'units','pixels');
set(ax,'position',[20 121 221 131]);
tx=uicontrol(fig,'style','text','string',txt,'position',[20 61 221 41],'horizontalalignment','center','backgroundcolor',cl);
if ~isempty(h)
    filename=[imgpath 'statlerwaldorf.jpg'];
    c = imread(filename,'jpeg');
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
