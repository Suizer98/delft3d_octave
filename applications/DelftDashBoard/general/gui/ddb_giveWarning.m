function ddb_giveWarning(varargin)


if strcmpi(varargin{1},'error')
    err=lasterror;
    disp(err);
    for j=1:length(err.stack)
        disp(err.stack(j));
    end
end

show_fig=1;
txt=varargin{2};
sz=[260 272];
if length(varargin)>2
    if strcmpi(varargin{3},'nofig')
        ntxt=length(txt);
        sz(1)=260;
        htext=20*round(ntxt/30);
        sz(2)=61+htext+20;        
        show_fig=0;
    end
end

h=getHandles;
%fig = MakeNewWindow('Warning',[260 272],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);
fig = MakeNewWindow('Warning',sz,[h.settingsDir filesep 'icons' filesep 'deltares.gif']);
cl=get(gcf,'Color');


if show_fig
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
else
    tx=uicontrol(fig,'style','text','string',txt,'position',[20 61 221 htext],'horizontalalignment','center','backgroundcolor',cl);
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
