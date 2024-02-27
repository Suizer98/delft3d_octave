function data=table(fig,hobj,action,varargin)
%TABLE No description

position=[0 0];
nrrows=0;
columntypes='';
width=[];
data=0;
enab=[];
popuptext='';
pushtext='';
callbacks=[];
fmt=[];
includebuttons=0;
includenumbers=0;

for i=1:nargin-3
    if ischar(varargin{i})
        switch(lower(varargin{i})),
            case{'position'}
                position=varargin{i+1};
            case{'nrrows'}
                nrrows=varargin{i+1};
            case{'columntypes'}
                columntypes=varargin{i+1};
            case{'width'}
                width=varargin{i+1};
            case{'data'}
                data=varargin{i+1};
            case{'popuptext'}
                popuptext=varargin{i+1};
            case{'pushtext'}
                pushtext=varargin{i+1};
            case{'enable'}
                enab=varargin{i+1};
            case{'format'}
                fmt=varargin{i+1};
            case{'callbacks'}
                callbacks=varargin{i+1};
            case{'includebuttons'}
                includebuttons=1;
            case{'includenumbers'}
                includenumbers=1;
        end
    end
end            

nrcolumns=length(columntypes);

if isempty(enab)
    enab=zeros(nrrows,nrcolumns)+1;
end
if isempty(callbacks)
    for i=1:nrcolumns;
        callbacks{i}=[];
    end
end
if isempty(fmt)
    for i=1:nrcolumns;
        fmt{i}=[];
    end
end

switch lower(action),
    case{'create'}
      CreateTable(hobj,position,nrcolumns,nrrows,columntypes,width,data,popuptext,pushtext,enab,callbacks,fmt,includebuttons,includenumbers);
    case{'delete'}
      DeleteTable(hobj);
    case{'change'}
      ChangeTable(hobj,data,varargin);
    case{'find'}
        data=FindTable(hobj);
    case{'getdata'}
        tb=FindTable(hobj);
        if ~isempty(tb)
            usd=get(tb,'UserData');
            data=usd.Data;
        else
            data=[];
        end
end

%%
function CreateTable(hobj,position,nrcolumns,nrrows,columntypes,width,data,popuptext,pushtext,enab,callbacks,fmt,includebuttons,includenumbers)

if isempty(width)
    for j=1:nrcolumns
        switch(columntypes{j}),
            case{'editreal','editstring','edittime','popupmenu'}
                width(j)=80;
            case{'checkbox'}
                width(j)=20;
        end
    end
end
if includenumbers
    posy=position(2)+nrrows*20-20;
    for i=1:nrrows
        h=uicontrol(gcf,'Style','text','String',num2str(i),'Position',[position(1) posy-4 20 20],'HorizontalAlignment','right');
        cl=get(gcf,'Color');
        set(h,'BackgroundColor',cl);
        posy=posy-20;
        usd.NumberHandles(i)=h;
        set(h,'UserData',hobj,'Tag','UIControl');
    end
    posx0=position(1)+25;
else
    posx0=position(1);
end

posy=position(2)+nrrows*20-20;
for i=1:nrrows
    posx=posx0;
    for j=1:nrcolumns
        switch(columntypes{j}),
            case{'editreal'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
                set(h,'CallBack',{@EditReal_CallBack,i,j,callbacks{j}},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'editstring'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
                set(h,'CallBack',{@EditString_CallBack,i,j,callbacks{j}},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'edittime'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
                set(h,'CallBack',{@EditTime_CallBack,i,j,callbacks{j}},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'popupmenu'}
                for ii=1:size(popuptext,1)
                    str{ii}=popuptext{ii,j};
                end
                h=uicontrol(gcf,'Style','popupmenu','Position',[posx posy width(j) 20],'BackgroundColor',[1 1 1]);
                set(h,'Value',1);
                set(h,'String',str);
                set(h,'CallBack',{@PopupMenu_CallBack,i,j,callbacks{j}},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'pushbutton'}
                h=uicontrol(gcf,'Style','pushbutton','Position',[posx posy width(j) 20],'BackgroundColor',[1 1 1]);
                set(h,'CallBack',{@PushButton_CallBack,i,j},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'checkbox'}
                h=uicontrol(gcf,'Style','checkbox','String','','Position',[posx+3 posy width(j) 20]);
                set(h,'CallBack',{@CheckBox_CallBack,i,j,callbacks{j}},'Tag','UIControl','Enable','on');
                set(h,'UserData',hobj);
            case{'text'}
                h=uicontrol(gcf,'Style','text','String','','Position',[posx+3 posy-4 width(j) 20]);
                set(h,'Tag','UIControl');
                set(h,'UserData',hobj);
        end
        if enab(i,j)==0
            set(h,'Enable','off');
        end
        posx=posx+width(j);
        usd.Handles(i,j)=h;
    end
    posy=posy-20;
end

h = uicontrol(gcf,'Style','slider', 'Position', [posx+3 position(2) 20 nrrows*20]);
set(h,'UserData',hobj,'Tag','UIControl');
set(h,'CallBack',{@VerticalSlider_CallBack});
usd.VerticalSlider=h;
if includebuttons
    h = uicontrol(gcf,'Style','pushbutton','String','Copy Row',  'Position',[posx+30 position(2)+nrrows*20-20 80 20]);
    set(h,'CallBack',{@PushCopyRow_CallBack},'UserData',hobj,'Tag','UIControl');
    h = uicontrol(gcf,'Style','pushbutton','String','Delete Row','Position',[posx+30 position(2)+nrrows*20-45 80 20]);
    set(h,'CallBack',{@PushDeleteRow_CallBack},'UserData',hobj,'Tag','UIControl');
end
usd.Data=data;
usd.NrRows=nrrows;
usd.NrColumns=nrcolumns;
usd.ColumnTypes=columntypes;
usd.ActiveRow=1;
usd.ActiveColumn=1;
usd.FirstRow=1;
usd.FirstColumn=1;
usd.Format=fmt;
h=uipanel('Units','pixels','Position',[0 0 1 1],'Tag','UIControl','Visible','off');
set(h,'UserData',usd);
setappdata(h,'Table',hobj);
RefreshVerticalSlider(hobj);
RefreshTable(hobj);

%%
function DeleteTable(tag)
tb=FindTable(tag);
if ~isempty(tb)
    delete(tb);
end
h=findall(gcf,'UserData',tag);
if ~isempty(h)
    delete(h);
end

%%
function ChangeTable(tag,data,varargin)

tb=FindTable(tag);
usd=get(tb,'UserData');
usd.Data=data;
if usd.ActiveRow>size(data,1)
    usd.ActiveRow=1;
end
%usd.ActiveColumn=1;
set(tb,'UserData',usd);
RefreshVerticalSlider(tag);

RefreshTable(tag,varargin);

%%
function VerticalSlider_CallBack(hObject,eventdata)

tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
if size(usd.Data,1)<=usd.NrRows
    ip=0;
else
    ii=round(get(usd.VerticalSlider,'Value'));
    imin=get(usd.VerticalSlider,'Min');
    imax=get(usd.VerticalSlider,'Max');
    ip=(imax-ii);
end
usd.FirstRow=ip+1;
val=get(hObject,'Value');
tag=get(hObject,'UserData');
set(hObject,'Value',round(val));
set(tb,'UserData',usd);
RefreshTable(tag);

%%
function EditTime_CallBack(hObject,eventdata,i,j,callback)
tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
ip=usd.FirstRow-1;
usd.Data{i+ip,j}=D3DTimeString(get(hObject,'String'));
usd.ActiveRow=i;
usd.ActiveColumn=j;
set(tb,'UserData',usd);
if ~isempty(callback)
    feval(callback);
end

%%
function EditReal_CallBack(hObject,eventdata,i,j,callback)
tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
ip=usd.FirstRow-1;
usd.Data{i+ip,j}=str2num(get(hObject,'String'));
usd.ActiveRow=i;
usd.ActiveColumn=j;
set(tb,'UserData',usd);
if ~isempty(callback)
    feval(callback);
end

%%
function EditString_CallBack(hObject,eventdata,i,j,callback)
tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
ip=usd.FirstRow-1;
usd.Data{i+ip,j}=get(hObject,'String');
set(tb,'UserData',usd);
if ~isempty(callback)
    feval(callback);
end

%%
function PopupMenu_CallBack(hObject,eventdata,i,j,callback)
tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
ip=usd.FirstRow-1;
ii=get(hObject,'Value');
txt=get(hObject,'String');
usd.ActiveRow=i;
usd.ActiveColumn=j;
usd.Data{i+ip,j}=txt{ii}; 
set(tb,'UserData',usd);
if ~isempty(callback)
    feval(callback);
end

%%
function CheckBox_CallBack(hObject,eventdata,i,j,callback)
tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
ip=usd.FirstRow-1;
ii=get(hObject,'Value');
usd.Data{i+ip,j}=ii; 
usd.ActiveRow=i;
usd.ActiveColumn=j;
set(tb,'UserData',usd);
if ~isempty(callback)
    feval(callback);
end

%%
function PushCopyRow_CallBack(hObject,eventdata)

tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
data=usd.Data;
nrrows=usd.NrRows;
nrcolumns=usd.NrColumns;
vslider=usd.VerticalSlider;
columntypes=usd.ColumnTypes;
handles=usd.Handles;
iac=usd.ActiveRow;
nr=size(usd.Data,1);
ip=usd.FirstRow-1;
iac=iac+ip;
for j=1:nrcolumns
    if iac<nr
        for i=nr+1:-1:iac+2
            data{i,j}=data{i-1,j};
        end
    end
    data{iac+1,j}=data{iac,j};
end
usd.Data=data;
set(tb,'UserData',usd);
RefreshVerticalSlider(tag);
RefreshTable(tag);

%%
function PushDeleteRow_CallBack(hObject,eventdata)

tag=get(hObject,'UserData');
tb=FindTable(tag);
usd=get(tb,'UserData');
data=usd.Data;
nrrows=usd.NrRows;
nrcolumns=usd.NrColumns;
vslider=usd.VerticalSlider;
columntypes=usd.ColumnTypes;
handles=usd.Handles;
iac=usd.ActiveRow;
nr=size(usd.Data,1);
ip=usd.FirstRow-1;
iac=iac+ip;
if nr>2
    for j=1:nrcolumns
        if iac<nr
            for i=iac:nr-1
                data{i,j}=data{i+1,j};
            end
        end
        for i=1:nr-1
            data0{i,j}=data{i,j};
        end
    end
    usd.Data=data0;
    set(tb,'UserData',usd);
    RefreshVerticalSlider(tag);
    RefreshTable(tag);
end

%%
function RefreshTable(tag,varargin)

varg=[];
a=varargin;
if ~isempty(a)
    b=varargin{1};
    varg=b{1};
end

enab=[];

for i=1:length(varg)
    if ischar(varg{i})
        switch(lower(varg{i})),
%             case{'position'}
%                 position=varargin{i+1};
%             case{'nrrows'}
%                 nrrows=varargin{i+1};
%             case{'columntypes'}
%                 columntypes=varargin{i+1};
%             case{'width'}
%                 width=varargin{i+1};
%             case{'data'}
%                 data=varargin{i+1};
%             case{'popuptext'}
%                 popuptext=varargin{i+1};
%             case{'pushtext'}
%                 pushtext=varargin{i+1};
            case{'enable'}
                enab=varg{i+1};
%             case{'format'}
%                 fmt=varargin{i+1};
%             case{'callbacks'}
%                 callbacks=varargin{i+1};
%             case{'includebuttons'}
%                 includebuttons=1;
%             case{'includenumbers'}
%                 includenumbers=1;
        end
    end
end            

tb=FindTable(tag);
usd=get(tb,'UserData');
data=usd.Data;
nrrows=usd.NrRows;
nrcolumns=usd.NrColumns;

if isempty(enab)
    enab=zeros(nrrows,nrcolumns)+1;
end

vslider=usd.VerticalSlider;
columntypes=usd.ColumnTypes;
handles=usd.Handles;
fmt=usd.Format;
nr=size(data,1);
if nr<=nrrows
    set(vslider,'Visible','off');
else
    set(vslider,'Visible','on');
end
ip=usd.FirstRow-1;
if isfield(usd,'NumberHandles')
    numberhandles=usd.NumberHandles;
    for i=1:min(nr,nrrows)
        set(numberhandles(i),'String',num2str(i+ip));
        set(numberhandles(i),'Visible','on');
    end
    for i=nr+1:nrrows
        set(numberhandles(i),'Visible','off');
    end
end

for j=1:nrcolumns
    for i=1:min(nr,nrrows)
        k=min(i+ip,size(data,1));
        switch(columntypes{j}),
            case{'editreal'}
                if ~isempty(fmt{j})
                    set(handles(i,j),'String',num2str(data{k,j},fmt{j}),'Visible','on');
                else
                    set(handles(i,j),'String',num2str(data{k,j}),'Visible','on');
                end
            case{'editstring'}
                set(handles(i,j),'String',data{k,j},'Visible','on');
            case{'edittime'}
                set(handles(i,j),'String',D3DTimeString(data{k,j}),'Visible','on');
            case{'popupmenu'}
                txt=get(handles(i,j),'String');
                ii=strmatch(data{k,j},txt,'exact');
                set(handles(i,j),'Value',ii,'Visible','on');
            case{'checkbox'}
                set(handles(i,j),'Value',data{k,j},'Visible','on');
            case{'pushbutton'}
                set(handles(i,j),'String',data{k,j},'Visible','on');
            case{'text'}
                set(handles(i,j),'String',data{k,j},'Visible','on');
        end
        if enab(i,j)
            set(handles(i,j),'Enable','on');
        else
            set(handles(i,j),'Enable','off');
        end
    end
    for i=nr+1:nrrows
        set(handles(i,j),'Visible','off');
    end
end

%%
function RefreshVerticalSlider(tag)

tb=FindTable(tag);
usd=get(tb,'UserData');
data=usd.Data;
nrrows=usd.NrRows;
vslider=usd.VerticalSlider;
nr=size(data,1);
if nr<=nrrows
    set(vslider,'Min',0);
    set(vslider,'Max',max(nr,1));
    set(vslider,'SliderStep',[1 nrrows]);
    set(vslider,'Value',0);
    set(vslider,'Visible','off');
else
    set(vslider,'Visible','on');
    set(vslider,'Min',0);
    set(vslider,'Max',nr-nrrows);
    set(vslider,'Value',nr-nrrows);
    ii=nr-nrrows;
    set(vslider,'SliderStep',[1/ii nrrows/(nr-nrrows)]);
end

%%
function ClickTextBox(imagefig, varargins,i,j)
hobj=get(gcf,'CurrentObject');
if strcmp(get(hobj,'Tag'),'UIControl') && strcmp(get(gcf,'SelectionType'),'normal')
    tag=get(hobj,'UserData');
    tb=FindTable(tag);
    usd=get(tb,'UserData');
    uicontrol(hobj);
    set(hobj,'Enable','on');
    if isfield(usd,'ActiveUITool')
        pos=get(usd.ActiveUITool,'Position');
        str=get(usd.ActiveUITool,'String');
        horal=get(usd.ActiveUITool,'HorizontalAlignment');
        set(usd.ActiveUITool,'Enable','inactive');
        str=get(usd.ActiveUITool,'String');
%         delete(usd.ActiveUITool);
%         i0=usd.ActiveRow;
%         j0=usd.ActiveColumn;
%         usd.ActiveUITool=uicontrol(gcf,'Style','edit','String',str,'Position',pos,'HorizontalAlignment',horal,'BackgroundColor',[1 1 1]);
%         set(usd.ActiveUITool,'Tag','UIControl','Enable','inactive','UserData',tag);
%         usd.Handles(i0,j0)=usd.ActiveUITool;
%         switch(columntypes{j0}),
%             case{'editreal'}
%                 set(usd.ActiveUITool,'CallBack',{@EditReal_CallBack,i0,j0});
%             case{'editstring'}
%                 set(usd.ActiveUITool,'CallBack',{@EditString_CallBack,i0,j0});
%             case{'edittime'}
%                 set(usd.ActiveUITool,'CallBack',{@EditTime_CallBack,i0,j0});
%         end
%         set(usd.ActiveUITool,'ButtonDownFcn',{@ClickTextBox,i0,j0});
    end
    usd.ActiveUITool=hobj;
    usd.ActiveRow=i;
    usd.ActiveColumn=j;
    set(tb,'UserData',usd);
end

%%
function tb=FindTable(tag)
h=findobj('type','uipanel');
tb=[];
for i=1:length(h)
    if isappdata(h(i),'Table')
        t=getappdata(h(i),'Table');
        if strcmp(t,tag)
            tb=h(i);
        end
    end
end

