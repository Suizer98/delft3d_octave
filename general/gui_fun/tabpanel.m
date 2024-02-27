function tabpanel(fig,panel,fcn,varargin)
%TABPANEL No description

clr=get(gcf,'Color');

switch fcn,
    case{'create'}
        CreateTabPanel(fig,panel,clr,varargin{:});
    case{'change'}
        CreateTabPanel(fig,panel,clr,varargin{:});
    case{'select'}
        Select(fig,panel,clr,varargin{:});
    case{'delete'}
        DeleteTabPanel(fig,panel);
    case{'resize'}
        ResizeTabPanel(fig,panel,varargin{:});
end

%%
function CreateTabPanel(fig,panel,clr,varargin)
h=findall(gcf,'Tag',panel);
if length(h)>0
    Panel=get(h,'UserData');
    delete(Panel.Tabs);
    delete(Panel.BlankText);
    NewTabPanel=Panel.Handle;
else
    NewTabPanel=[];
end
pos=varargin{1};
strings=varargin{2};
callbacks=varargin{3};
if nargin>6
    width=varargin{4};
else
    width=zeros(length(strings))+80;
end
pos0=pos(1)+3;
for i=1:length(strings)
    sz=width(i);
    posi=[pos0 pos(2)+pos(4)-1 sz 20];
    pos0=pos0+sz;
    Tabs(i) = uicontrol(fig,'Style','pushbutton','String',strings{i},'Position',posi,'Tag',strings{i},'BackgroundColor',0.9*clr);
    set(Tabs(i),'CallBack',{@SelectTab});
    usd.Nr=i;
    usd.Panel=panel;
    usd.Fig=fig;
    usd.CallBack=callbacks{i};
    set(Tabs(i),'UserData',usd);
end
if length(NewTabPanel)==0
    NewTabPanel = uipanel('Title','','Units','pixels','Position',pos,'BorderType','beveledout','BackgroundColor',clr,'Tag',panel);
end

pos0=pos(1)+4;
for i=1:length(strings)
    sz=width(i);
    posi=[pos0 pos(2)+pos(4)-1 sz-3 3];
    pos0=pos0+sz;
    BlankText(i) = uicontrol(fig,'Style','text','String','','Position',posi);
    set(BlankText(i),'BackgroundColor',0.9*clr);
end
set(Tabs(1),'BackgroundColor',clr);
set(Tabs(1),'FontWeight','bold');
posi=[pos(1)+4 pos(2)+pos(4)-5 sz-3 7];
set(BlankText(1),'BackgroundColor',clr,'Position',posi);
Panel.Nr=length(strings);
Panel.Strings=strings;
Panel.Tabs=Tabs;
Panel.BlankText=BlankText;
Panel.Handle=NewTabPanel;
Panel.Position=pos;
Panel.Width=width;
set(NewTabPanel,'UserData',Panel);

%%
function SelectTab(hObject,eventdata)
clr=get(gcf,'Color');
Tabs=get(hObject,'UserData');
h=findall(gcf,'Tag',Tabs.Panel);
Panel=get(h,'UserData');
pos=Panel.Position;
iac=Tabs.Nr;
set(Panel.Tabs,'BackgroundColor',0.9*clr);
set(Panel.Tabs,'FontWeight','normal');
pos0(1)=pos(1)+4;
for i=1:Panel.Nr
    sz=Panel.Width(i);
    posi=[pos0(i) pos(2)+pos(4)-1 sz-3 3];
    pos0(i+1)=pos0(i)+sz;
    set(Panel.BlankText(i),'Position',posi,'BackgroundColor',0.9*clr);
end
set(hObject,'BackgroundColor',clr);
set(hObject,'FontWeight','bold');
set(hObject,'SelectionHighlight','off');
set(hObject,'Value',0);
posi=[pos0(iac) pos(2)+pos(4)-5 Panel.Width(iac)-3 7];
set(Panel.BlankText(iac),'BackgroundColor',clr,'Position',posi);
feval(Tabs.CallBack);

%%
function Select(fig,panel,clr,tabname)
tab=findall(gcf,'Tag',tabname);
Tabs=get(tab,'UserData');
h=findall(gcf,'Tag',Tabs.Panel);
Panel=get(h,'UserData');
pos=Panel.Position;
iac=Tabs.Nr;
set(Panel.Tabs,'BackgroundColor',0.9*clr);
set(Panel.Tabs,'FontWeight','normal');
pos0(1)=pos(1)+4;
for i=1:Panel.Nr
    sz=Panel.Width(i);
    posi=[pos0(i) pos(2)+pos(4)-1 sz-3 3];
    pos0(i+1)=pos0(i)+sz;
    set(Panel.BlankText(i),'Position',posi,'BackgroundColor',0.9*clr);
end
set(tab,'BackgroundColor',clr);
set(tab,'FontWeight','bold');
set(tab,'SelectionHighlight','off');
set(tab,'Value',0);
posi=[pos0(iac) pos(2)+pos(4)-5 Panel.Width(iac)-3 7];
set(Panel.BlankText(iac),'BackgroundColor',clr,'Position',posi);
feval(Tabs.CallBack);

%%
function DeleteTabPanel(fig,panel)
h=findall(gcf,'Tag',panel);
if length(h)>0
    Panel=get(h,'UserData');
    delete(Panel.Tabs);
    delete(Panel.BlankText);
    delete(Panel.Handle);
end


%%
function ResizeTabPanel(fig,panel,varargin)
pos=varargin{1};
h=findall(gcf,'Tag',panel);
Panel=get(h,'UserData');
set(h,'Position',pos);
pos0=pos(1)+3;
for i=1:Panel.Nr
    pos00=get(Panel.Tabs(i),'Position');
    sz=pos00(3);
    posi=[pos0 pos(2)+pos(4)-1 sz 20];
    set(Panel.Tabs(i),'Position',posi);
    col=get(Panel.BlankText(i),'BackgroundColor');
    if col==[0.8314 0.8157 0.7843]
%         posi=[pos0(iac) pos(2)+pos(4)-5 Panel.Width(iac)-3 7];
%         set(Panel.BlankText(iac),'BackgroundColor',[0.8314 0.8157 0.7843],'Position',posi);
        set(Panel.BlankText(i),'Position',[pos0+1 pos(2)+pos(4)-5 sz-3 7]);
    else
        set(Panel.BlankText(i),'Position',[pos0+1 pos(2)+pos(4)-1 sz-3 3]);
    end
    pos0=pos0+sz;
end
Panel.Position=pos;
set(h,'UserData',Panel);
