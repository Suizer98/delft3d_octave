function element=gui_addElements(figh,element,varargin)

getFcn=[];
setFcn=[];
parenthandle=figh;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'getfcn','getfunction'}
                getFcn=varargin{i+1};
            case{'setfcn','setfunction'}
                setFcn=varargin{i+1};
            case{'parent'}
                parenthandle=varargin{i+1};
        end
    end
end

bgc=get(figh,'Color');

for i=1:length(element)
        
    try
        
        element(i).element.handle=[];
        element(i).element.texthandle=[];
        pos=element(i).element.position;
                               
        switch lower(element(i).element.style)
            
            %% Standard element
            
            case{'edit'}
                
                % Edit box

                element(i).element.handle=uicontrol(figh,'Style','edit','String','','Position',pos,'BackgroundColor',[1 1 1]);

                if ~isempty(element(i).element.type)
                    tp=element(i).element.type;
                else
                    tp=element(i).element.variable.type;
                end
                
                switch tp
                    case{'char','string'}
                        horal='left';
                    case{'int','integer'}
                        horal='right';
                    case{'real'}
                        horal='right';
                    case{'datetime','time','date'}
                        horal='right';
                end
                
                set(element(i).element.handle,'HorizontalAlignment',horal);
                if element(i).element.nrlines>1
                    set(element(i).element.handle,'Max',element(i).element.nrlines);
                end
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Parent',parenthandle,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end
                
            case{'panel'}
                
                % Panel
                
                str='';
                if ~isempty(element(i).element.text)
                    if ischar(element(i).element.text)
                        str=element(i).element.text;
                    end
                end
                
                element(i).element.handle=uipanel('Title',str,'Units','pixels','Position',pos,'BackgroundColor',bgc);
                set(element(i).element.handle,'BorderType',element(i).element.bordertype);
                
            case{'radiobutton'}
                
                % Radio button

                if ~isstruct(element(i).element.text)
                    str=element(i).element.text;
                    element(i).element.handle=uicontrol(figh,'Style','radio','String',str,'Position',[pos(1) pos(2) 20 20],'BackgroundColor',bgc);
                    % Length of string is known
                    ext=get(element(i).element.handle,'Extent');
                    set(element(i).element.handle,'Position',[pos(1) pos(2) ext(3)+20 20]);
                else
                    element(i).element.handle=uicontrol(figh,'Style','radio','String',' ','Position',[pos(1) pos(2) pos(3) 20],'BackgroundColor',bgc);
                end
                
            case{'checkbox'}
                
                % Check box
                
                if ~isstruct(element(i).element.text)
                    str=element(i).element.text;
                    element(i).element.handle=uicontrol(figh,'Style','check','String',str,'Position',[pos(1) pos(2) 20 20],'BackgroundColor',bgc);
                    % Length of string is known
                    ext=get(element(i).element.handle,'Extent');
                    set(element(i).element.handle,'Position',[pos(1) pos(2) ext(3)+20 20]);
                else
                    element(i).element.handle=uicontrol(figh,'Style','check','String',' ','Position',[pos(1) pos(2) pos(3) 20],'BackgroundColor',bgc);
                end
                
            case{'pushbutton'}
                
                % Push button
                
                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String',element(i).element.text,'Position',pos);
                
                if isfield(element(i).element,'fontweight')
                    set(element(i).element.handle,'fontweight',element(i).element.fontweight);
                end

                if isfield(element(i).element,'fontsize')
                    set(element(i).element.handle,'fontsize',element(i).element.fontsize);
                end

            case{'pushok'}

                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String','OK','Position',pos);

            case{'pushcancel'}

                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String','Cancel','Position',pos);

            case{'selectfont'}

                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String','Font','Position',pos);

            case{'axis'}

                hp=[];
                if ~isempty(element(i).element.parent)
                    hp=findobj(figh,'tag',element(i).element.parent);
                end
                if ~isempty(hp)
                    posp=get(hp,'Position');
                    h=axes('Parent',hp);
                else                
                    posp=[0 0 0 0];
                    h=axes;
                end
                set(h,'Units','pixels');
                posn=pos;
                posn(1)=pos(1)-posp(1);
                posn(2)=pos(2)-posp(2);
                set(h,'Position',posn);
                element(i).element.handle=h;

            case{'togglebutton'}
                
                % Toggle button

                element(i).element.handle=uicontrol(figh,'Style','togglebutton','String',element(i).element.text,'Position',pos);
                
            case{'listbox'}

                % List box
                
                element(i).element.handle=uicontrol(figh,'Style','listbox','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                if ~isempty(element(i).element.max)
                    set(element(i).element.handle,'Max',element(i).element.max);
                end
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end

            case{'selectcolor'}
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String','','Position',pos,'BackgroundColor',[1 1 1]);
                str=colorlist('getlist');
                if isfield(element(i).element,'includenone')
                    if element(i).element.includenone
                        str{end+1}='none';
                    end
                end
                if isfield(element(i).element,'includeauto')
                    if element(i).element.includeauto
                        str{end+1}='automatic';
                    end
                end
                set(element(i).element.handle,'String',str);
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end

            case{'selectlinestyle'}
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                texts={'-','--','-.',':','none'};

                set(element(i).element.handle,'String',texts);
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end
                
            case{'selectmarker'}
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                texts={'point','circle','x-mark','plus','star','square','diamond','triangle (down)', ...
                    'triangle (up)','triangle (left)','triangle (right)','pentagram','hexagram','none'};

                set(element(i).element.handle,'String',texts);
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end

            case{'selectheadstyle'}
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                texts={'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2','cback3' ...
                    'fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'};
                
                set(element(i).element.handle,'String',texts);
                
                % Set text
                if ~isempty(element(i).element.text)
                    str=[element(i).element.text ' '];
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end
                
                
            case{'selectmarkersize'}
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                for ii=1:100
                    texts{ii}=num2str(ii);
                end
                set(element(i).element.handle,'String',texts);
                
                % Set text
                if ~isempty(element(i).element.text)
                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end
                
            case{'popupmenu'}

                % Pop-up menu
                
                element(i).element.handle=uicontrol(figh,'Style','popupmenu','String',{'a','b'},'Position',pos,'BackgroundColor',[1 1 1]);
                
                % Set text
                if ~isempty(element(i).element.text)

                    if ~isstruct(element(i).element.text)
                        str=element(i).element.text;
                    else
                        str=' ';
                    end
                    switch element(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    
                    % Text
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,element(i).element.textposition);
                end
                
            case{'text'}
                
                % Text
                
                if ~isstruct(element(i).element.text)
                    str=element(i).element.text;
                else
                    str=' ';
                end
                
                element(i).element.handle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc,'HorizontalAlignment','left');
                                    
                ext=get(element(i).element.handle,'Extent');
                ext(3)=ext(3)+2;
                
                ps1=pos(1);
                if strcmpi(element(i).element.horal,'right')
                    ps1=pos(1)-ext(3);
                end
                
                if element(i).element.position(4)<26
                     set(element(i).element.handle,'Position',[ps1 pos(2) ext(3) 15]);
                end
                
            case{'pushselectfile','pushsavefile'}
                
                % Push select file
                
                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String',element(i).element.text,'Position',pos);
                
                if element(i).element.showfilename
                    % Text
                    str='File : ';
                    element(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(element(i).element.texthandle,pos,'right');
                end

            case{'selectcoordinatesystem'}

                elpos=pos;
                elpos(2)=elpos(2)+20;
                elpos(3)=max(elpos(3),100);
                elpos(4)=20;
                element(i).element.handle=uicontrol(figh,'Style','pushbutton','String','Coordinate System','Position',elpos);

                elpos=pos;
                elpos(3)=90;
                elpos(4)=20;
                element(i).element.prjhandle=uicontrol(figh,'Style','radiobutton','String','Projected','Position',elpos,'Enable','off','BackgroundColor',bgc);

                elpos=pos;
                elpos(1)=elpos(1)+90;
                elpos(3)=100;
                elpos(4)=20;
                element(i).element.geohandle=uicontrol(figh,'Style','radiobutton','String','Geographic','Position',elpos,'Enable','off','BackgroundColor',bgc);
                
                % Set text
                elpos=pos;
                elpos(2)=elpos(2)+20;
                elpos(3)=max(elpos(3),100);
                elpos(4)=20;
                txtpos=elpos;
                txtpos(1)=txtpos(1)+txtpos(3)+10;
                txtpos(2)=txtpos(2)+3;
                txtpos(3)=200;
                txtpos(4)=15;
                str='CS text';
                element(i).element.texthandle=uicontrol(figh,'Parent',parenthandle,'Style','text','String',str, ...
                    'Position',txtpos,'BackgroundColor',bgc,'HorizontalAlignment','left');
                
                
                
            case{'tabpanel'}
                
                panelname=element(i).element.tag;
                for j=1:length(element(i).element.tab)
                    strings{j}=element(i).element.tab(j).tab.tabstring;
                    tabnames{j}=element(i).element.tab(j).tab.tabstring;
                    callbacks{j}=[];
                    if ~isempty(element(i).element.tab(j).tab.callback)
                        callbacks{j}=element(i).element.tab(j).tab.callback;
                        inputArguments{j}=[];
                    else
                        % No callback given, use defaultTabCallback which
                        % tries to execute callback of active tab of
                        % tabpanel within current tab
                        callbacks{j}=@defaultTabCallback;
                        inputArguments{j}={'tag',panelname,'tabnr',j};
                    end
                end
                
                if ~isfield(element(i).element,'activetabnr')
                    % Tab panel is drawn for the first time
                    element(i).element.activetabnr=1;
                end
                
                % Create tab panel
                tabhandle=tabpanel('create','figure',figh,'tag',panelname,'position',pos,'strings',strings, ...
                    'callbacks',callbacks,'tabnames',tabnames,'activetabnr',element(i).element.activetabnr, ...
                    'inputarguments',inputArguments,'parent',parenthandle,'element',element(i).element);
                % Element structure has been updated with handles
                element(i).element=getappdata(tabhandle,'element');
                element(i).element.handle=tabhandle;
                
                for j=1:length(element(i).element.tab)
                    if element(i).element.tab(j).tab.enable==0
                        tabpanel('disabletab','handle',element(i).element.handle,'tabname',element(i).element.tab(j).tab.tabstring);
                    end
                end

            case{'table'}
                
                tag=element(i).element.tag;
                nrrows=element(i).element.nrrows;
                inclb=element(i).element.includebuttons;
                incln=element(i).element.includenumbers;
                
                cltp=[];
                width=[];
                enable=[];
                format=[];
                txt=[];
                callbacks=[];
                
                % Properties
                for j=1:length(element(i).element.column)
                    cltp{j}=element(i).element.column(j).column.style;
                    width(j)=element(i).element.column(j).column.width;
                    for k=1:nrrows
                        enable(k,j)=element(i).element.column(j).column.enable;
                    end
                    format{j}=element(i).element.column(j).column.format;
                    txt{j}=element(i).element.column(j).column.text;
                    callbacks{j}=[];
                    popuptext{j}={' '};
                end
                
                % Data?
                data=[];
                for j=1:length(element(i).element.column)
                    for k=1:element(i).element.nrrows
                        switch lower(cltp{j})
                            case{'editreal'}
                                data{k,j}=0;
                            case{'editstring'}
                                data{k,j}=' ';
                            case{'popupmenu'}
                                data{k,j}=1;
                            case{'checkbox'}
                                data{k,j}=1;
                            case{'pushbutton'}
                                data{k,j}=[];
                            case{'text'}
                                data{k,j}=' ';                                
                                
                        end
                    end
                end
                element(i).element.handle=gui_table(gcf,'create','tag',tag,'data',data,'position',pos,'nrrows',nrrows,'columntypes',cltp,'width',width,'callbacks',callbacks, ...
                    'includebuttons',inclb,'includenumbers',incln,'format',format,'enable',enable,'columntext',txt,'popuptext',popuptext);
        end
    catch
        disp(['Something went wrong with generating element ' element(i).element.tag]);
        a=lasterror;
        disp(a.message);
        for ia=1:length(a.stack)
            disp(a.stack(ia));
        end
    end

    %% Set some stuff needed for each type of element

    % Parent
    if ~isempty(element(i).element.parent)
        % Use parent defined in xml file (needed for element inside panels)
        ph=findobj(gcf,'Tag',element(i).element.parent);
    else
        % Default parent
        ph=parenthandle;
    end
    if ~isempty(ph)
        set(element(i).element.handle,'Parent',ph);
        element(i).element.parenthandle=ph;
        if isfield(element(i).element,'texthandle')
            set(element(i).element.texthandle,'Parent',ph);
        end
    end
    
    % Tooltip string
    if ~isempty(element(i).element.tooltipstring)
        set(element(i).element.handle,'ToolTipString',element(i).element.tooltipstring);
    end

    % Enable
    if element(i).element.enable==0
        set(element(i).element.handle,'Enable','off');
        if isfield(element(i).element,'texthandle')
            set(element(i).element.texthandle,'Enable','off');
        end
    end
    
    %drawnow;
%    try
        set(element(i).element.handle,'Tag',element(i).element.tag);
%    catch
%        shite=1
%element(i).element.handle
%    end
%    try
    setappdata(element(i).element.handle,'getFcn',getFcn);
%    catch
%        shite=2;
%    end
    setappdata(element(i).element.handle,'setFcn',setFcn);
    setappdata(element(i).element.handle,'element',element(i).element);

end

setappdata(parenthandle,'elements',element);
setappdata(parenthandle,'getFcn',getFcn);
setappdata(parenthandle,'setFcn',setFcn);

gui_setElements(element);

% Now set callbacks for each element
for i=1:length(element)

    try
        
        switch lower(element(i).element.style)
            
            %% Standard element
            
            case{'edit'}
                set(element(i).element.handle,'Callback',{@edit_Callback,getFcn,setFcn,element,i});
                
            case{'checkbox'}
                set(element(i).element.handle,'Callback',{@checkbox_Callback,getFcn,setFcn,element,i});
                
            case{'radiobutton'}
                set(element(i).element.handle,'Callback',{@radiobutton_Callback,getFcn,setFcn,element,i});
                
            case{'pushbutton'}
                set(element(i).element.handle,'Callback',{@pushbutton_Callback,element,i});

             case{'pushok'}
                set(element(i).element.handle,'Callback',{@pushOK_Callback,element,i});

            case{'pushcancel'}
                set(element(i).element.handle,'Callback',{@pushCancel_Callback,element,i});

            case{'selectfont'}
                set(element(i).element.handle,'Callback',{@pushSelectFont_Callback,element,i});

            case{'selectcolor'}
                set(element(i).element.handle,'Callback',{@selectColor_Callback,element,i});

            case{'selectmarker'}
                set(element(i).element.handle,'Callback',{@selectMarker_Callback,element,i});

            case{'selectmarkersize'}
                set(element(i).element.handle,'Callback',{@selectMarkerSize_Callback,element,i});

            case{'selectlinestyle'}
                set(element(i).element.handle,'Callback',{@selectLineStyle_Callback,element,i});

            case{'selectheadstyle'}
                set(element(i).element.handle,'Callback',{@selectHeadStyle_Callback,element,i});
                
            case{'togglebutton'}
                set(element(i).element.handle,'Callback',{@togglebutton_Callback,getFcn,setFcn,element,i});
                
            case{'table'}
                % Get handles from table
                usd=get(element(i).element.handle,'UserData');
                tbh=usd.handles;
                for j=1:length(element(i).element.column)
                    for k=1:element(i).element.nrrows
                        callback={@table_Callback,getFcn,setFcn,element,i,j};
                        setappdata(tbh(k,j),'callback',callback);
                    end
                end
                
            case{'listbox'}
                set(element(i).element.handle,'Callback',{@listbox_Callback,getFcn,setFcn,element,i});

            case{'popupmenu'}
                set(element(i).element.handle,'Callback',{@popupmenu_Callback,getFcn,setFcn,element,i});

            case{'pushselectfile'}
                set(element(i).element.handle,'Callback',{@pushSelectFile_Callback,getFcn,setFcn,element,i});

            case{'pushsavefile'}
                set(element(i).element.handle,'Callback',{@pushSaveFile_Callback,getFcn,setFcn,element,i});

            case{'selectcoordinatesystem'}
                set(element(i).element.handle,'Callback',{@pushSelectCoordinateSystem_Callback,element,i});

        end
        
    catch
        disp(['Something went wrong with setting callbacks element ' num2str(i)]);
        a=lasterror;
        disp(a.message);
        for ia=1:length(a.stack)
            disp(a.stack(ia));
        end
    end
    
end

%%
function edit_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

v=get(hObject,'String');

tp=el.type;

for ii=1:10
    try
        switch tp
            case{'string'}
            case{'datetime'}
                v=datenum(v,'yyyy mm dd HH MM SS');
            case{'date'}
                v=datenum(v,'yyyy mm dd');
            case{'time'}
                v=datenum(v,'HH MM SS');
            otherwise
                v=str2double(v);
        end
        break;
    catch
        % Try again, not sure why this fails sometimes
        pause(0.1);
    end
end

gui_setValue(el,el.variable,v);

finishCallback(element,i);

%%
function checkbox_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

v=get(hObject,'Value');

gui_setValue(el,el.variable,v); 

finishCallback(element,i);

%%
function radiobutton_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

ion=get(hObject,'Value');

if ~ion
    % Button was turned
    set(hObject,'Value',1);
else
    
    v=el.value;
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end
    switch lower(tp)
        case{'real','integer'}
            v=str2double(v);
    end
                        
    gui_setValue(el,el.variable,v); 
    
    finishCallback(element,i);
    
end

%%
function togglebutton_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

ion=get(hObject,'Value');

gui_setValue(el,el.variable,ion); 

finishCallback(element,i);

%%
function listbox_Callback(hObject,eventdata,getFcn,setFcn,element,i)

str=get(hObject,'String');
% Check if listbox is not empty
if ~isempty(str{1})
    
    el=element(i).element;
    
    if isfield(el,'variable')
        
        ii=get(hObject,'Value');
        
        if ~isempty(el.type)
            tp=lower(el.type);
        else
            tp=lower(el.variable.type);
        end
        
        switch tp
            case{'string'}
                if ~isempty(el.listvalue)
                    % Values must be cell array of strings
                    if isstruct(el.listvalue)
                        if isfield(el.listvalue(1).listvalue,'variable')
                            values=gui_getValue(el,el.listvalue(1).listvalue.variable);
                        else
                            for jj=1:length(el.listvalue)
                                values{jj}=el.listvalue(jj).listvalue;
                            end
                        end
                    else
                        values{1}=el.listvalue;
                    end
                else
                    values=str;
                end
                if length(ii)>1
                    % multiple points selected
                    gui_setValue(el,el.variable,values{ii});
                    if ~isempty(el.multivariable)
                        for j=1:length(ii)
                            v{j}=values{ii};
                        end
                        gui_setValue(el,el.multivariable,v);
                    end
                else
                    gui_setValue(el,el.variable,values{ii});
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values{ii});
                    end
                end
            otherwise
                % Integer
                if ~isempty(el.listvalue)
                    % Values must be cell array of strings
                    if isstruct(el.listvalue)
                        if isfield(el.listvalue(1).listvalue,'variable')
                            values=gui_getValue(el,el.listvalue(1).listvalue.variable);
                        else
                            for jj=1:length(el.listvalue)
                                values(jj)=str2double(el.listvalue(j).listvalue);
                            end
                        end
                    else
                        values=str2double(el.listvalue);
                    end
                else
                    values=1:length(str);
                end
                if length(ii)>1
                    % multi
                    gui_setValue(el,el.variable,values(ii(1)));
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values(ii));
                    end
                else
                    gui_setValue(el,el.variable,values(ii));
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values(ii));
                    end
                end
        end
        
        finishCallback(element,i);
    end
    
end

%%
function selectColor_Callback(hObject,eventdata,element,i)

str=get(hObject,'String');
% Check if listbox is not empty
if ~isempty(str{1})
    
    el=element(i).element;
    
    if isfield(el,'variable')        
        ii=get(hObject,'Value');        
        gui_setValue(el,el.variable,str{ii});        
        finishCallback(element,i);
    end
    
end

%%
function selectMarker_Callback(hObject,eventdata,element,i)

values={'.','o','x','+','*','s','d','v','^','<','>','p','h','none'};

el=element(i).element;
    
if isfield(el,'variable')
    ii=get(hObject,'Value');
    gui_setValue(el,el.variable,values{ii});
    finishCallback(element,i);
end

%%
function selectHeadStyle_Callback(hObject,eventdata,element,i)

values={'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2','cback3' ...
    'fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'};

el=element(i).element;

if isfield(el,'variable')
    ii=get(hObject,'Value');
    gui_setValue(el,el.variable,values{ii});
    finishCallback(element,i);
end

%%
function selectLineStyle_Callback(hObject,eventdata,element,i)

values={'-','--','-.',':','none'};

el=element(i).element;
    
if isfield(el,'variable')
    ii=get(hObject,'Value');
    gui_setValue(el,el.variable,values{ii});
    finishCallback(element,i);
end

%%
function selectMarkerSize_Callback(hObject,eventdata,element,i)

el=element(i).element;
    
if isfield(el,'variable')
    ii=get(hObject,'Value');
    gui_setValue(el,el.variable,ii);
    finishCallback(element,i);
end

%%
function popupmenu_Callback(hObject,eventdata,getFcn,setFcn,element,i)

str=get(hObject,'String');
% Check if menu is not empty
if ~isempty(str{1})
       
    el=element(i).element;
    
    ii=get(hObject,'Value');
    
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end

    switch tp
        case{'string'}
            if ~isempty(el.listvalue)
                % Values must be cell array of strings
                if isstruct(el.listvalue)
                    if isfield(el.listvalue(1).listvalue,'variable')
                        values=gui_getValue(el,el.listvalue(1).listvalue.variable);
                    else
                        for jj=1:length(el.listvalue)
                            values{jj}=el.listvalue(jj).listvalue;
                        end
                    end
                else
                    values{1}=el.listvalue;
                end
            else
                values=str;
            end
            gui_setValue(el,el.variable,values{ii});
        otherwise
            if ~isempty(el.listvalue)
                if isstruct(el.listvalue)
                    if isfield(el.listvalue(1).listvalue,'variable')
                        values=gui_getValue(el,el.listvalue(1).listvalue.variable);
                    else
                        for jj=1:length(el.listvalue)
                            values(jj)=str2double(el.listvalue(jj).listvalue);
                        end
                    end
                else
                    values{1}=str2double(el.listvalue);
                end
            else
                values=1:length(str);
            end
            gui_setValue(el,el.variable,values(ii));
    end
        
    finishCallback(element,i);

end

%%
function pushSelectFile_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

if isfield(el.selectiontext,'selectiontext')
    selectiontext=gui_getValue(el,el.selectiontext.selectiontext.variable);
else
    selectiontext=el.selectiontext;
end

% if isfield(el.extension,'extension')
%     extension=gui_getValue(el,el.extension.extension.variable);
% else
%     extension=el.extension;
% end

if isfield(el,'filter')
    % Filter structure
    for ii=1:length(el.filter)
        extension{ii,1}=el.filter(ii).filter.extension;
        if isfield(el.filter(ii).filter,'text')
            extension{ii,2}=el.filter(ii).filter.text;
        else
            extension{ii,2}=el.filter(ii).filter.extension;
        end
    end    
else    
    if isstruct(el.extension)
        for ii=1:length(el.extension)
            if isfield(el.extension(ii).extension,'variable')
                extension{ii,1}=gui_getValue(el,el.extension(ii).extension.variable);
                extension{ii,2}=extension{ii,1};
            else
                extension{ii,1}=el.extension(ii).extension;
                extension{ii,2}=el.extension(ii).extension;
            end
        end
    else
        if isfield(el.extension,'variable')
            extension=gui_getValue(el,el.extension.variable);
        else
            extension=el.extension;
        end
    end    
end

if isempty(extension)
    extension='*.*';
end

[filename, pathname, filterindex] = uigetfile(extension,selectiontext);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    gui_setValue(el,el.variable,v); 
    
    if el.showfilename
        set(el.texthandle,'enable','on','String',['File : ' v]);
        pos=get(el.texthandle,'Position');
        ext=get(el.texthandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.texthandle,'Position',pos);
    end
    
    element(i).element.option2=filterindex;
    
    finishCallback(element,i);

end

%%
function pushSaveFile_Callback(hObject,eventdata,getFcn,setFcn,element,i)

el=element(i).element;

fnameori=gui_getValue(el,el.variable);

if isfield(el.selectiontext,'variable')
    selectiontext=gui_getValue(el,el.selectiontext.variable);
else
    selectiontext=el.selectiontext;
end


if isfield(el,'filter')
    %
    % Filter structure
    %
    % First extensions
    %
    if isfield(el.filter(1).filter.extension,'extension')
        % Extensions given as variable
        ext=gui_getValue(el,el.filter(1).filter.extension.extension.variable);        
        if ~iscell(ext)
            % Make it a cell-array
            ext0=ext;
            ext=[];
            ext{1}=ext0;
        end
        for ii=1:length(ext)
            extension{ii,1}=ext{ii};
            extension{ii,2}=extension{ii,1};
        end
    else
        for ii=1:length(el.filter)
            extension{ii,1}=el.filter(ii).filter.extension;
            extension{ii,2}=extension{ii,1};
        end
    end
    %
    % Now the text
    %
    if isfield(el.filter(1).filter,'text')
        if isfield(el.filter(1).filter.text,'text')
            % Texts given as variable
            txt=gui_getValue(el,el.filter(1).filter.text.text.variable);
            if ~iscell(txt)
                % Make it a cell-array
                txt0=txt;
                txt=[];
                txt{1}=txt0;
            end
            for ii=1:length(txt)
                extension{ii,2}=txt{ii};
            end
        else
            for ii=1:length(el.filter)
                extension{ii,2}=el.filter(ii).filter.text;
            end
        end
    end    
else    
    if isstruct(el.extension)
        for ii=1:length(el.extension)
            if isfield(el.extension(ii).extension,'variable')
                extension{ii,1}=gui_getValue(el,el.extension(ii).extension.variable);
                extension{ii,2}=extension{ii,1};
            else
                extension{ii,1}=el.extension(ii).extension;
                extension{ii,2}=el.extension(ii).extension;
            end
        end
    else
        if isfield(el.extension,'variable')
            extension=gui_getValue(el,el.extension.variable);
        else
            extension=el.extension;
        end
    end    
end

% if isstruct(el.extension)
%     for ii=1:length(el.extension)
%         extension{ii,1}=el.extension(ii).extension;
%         extension{ii,2}=el.extension(ii).extension;
%     end
% else
%     if isfield(el.extension,'variable')
%         extension=gui_getValue(el,el.extension.variable);
%     else
%         extension=el.extension;
%     end
% end

[filename, pathname, filterindex] = uiputfile(extension,selectiontext,fnameori);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    gui_setValue(el,el.variable,v); 
    
    if el.showfilename
        set(el.texthandle,'enable','on','String',['File : ' v]);
        pos=get(el.texthandle,'Position');
        ext=get(el.texthandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.texthandle,'Position',pos);
    end
        
    element(i).element.option2=filterindex;
    
    finishCallback(element,i);

end

%%
function table_Callback(getFcn,setFcn,element,i,icol)

el=element(i).element;

data=gui_table(el.handle,'getdata');

% Now set the data
for j=1:length(el.column)

    v=[];
    
    for k=1:size(data,1)
        switch lower(el.column(j).column.style)
            case{'editreal'}
                v(k)=data{k,j};
            case{'edittime'}
                v(k)=data{k,j};
            case{'editstring'}
                v{k}=data{k,j};
            case{'popupmenu'}
                if isnumeric(data{k,j})
                    v(k)=data{k,j};
                else
                    v{k}=data{k,j};
                end
            case{'checkbox'}
                v(k)=data{k,j};
        end
    end
    
    gui_setValue(el,el.column(j).column.variable,v);

end

finishCallback(element,i,'column',icol);

%%
function pushbutton_Callback(hObject,eventdata,element,i)

finishCallback(element,i);

%%
function pushOK_Callback(hObject,eventdata,element,i)

el=element(i).element;
getFcn=getappdata(el.handle,'getFcn');
setFcn=getappdata(el.handle,'setFcn');
s=feval(getFcn);

if ~isempty(el.callback)
    if ~isempty(el.option1)
        ok=feval(el.callback,{s,el.option1});
    else    
        ok=feval(el.callback,s);
    end    
    if ~ok
        return
    end
end

s.ok=1;
feval(setFcn,s);
uiresume;

%%
function pushCancel_Callback(hObject,eventdata,element,i)

el=element(i).element;
getFcn=getappdata(el.handle,'getFcn');
setFcn=getappdata(el.handle,'setFcn');
s=feval(getFcn);
s.ok=0;
feval(setFcn,s);
uiresume;

%%
function pushSelectFont_Callback(hObject,eventdata,element,i)

el=element(i).element;
fontori=gui_getValue(el,el.variable);
if isfield(el,'horizontalalignment')
    horal=el.horizontalalignment;
else
    horal=0;
end
if isfield(el,'verticalalignment')
    veral=el.verticalalignment;
else
    veral=0;
end
if ~isempty(fontori)
    fontnew=gui_selectFont('font',fontori,'horizontalalignment',horal,'verticalalignment',veral);
else
    fontnew=gui_selectFont('horizontalalignment',horal,'verticalalignment',veral);
end
gui_setValue(el,el.variable,fontnew);
finishCallback(element,i);

%%
function pushSelectCoordinateSystem_Callback(hObject,eventdata,element,i)

el=element(i).element;
csori=gui_getValue(el,el.variable);
[cs,ok]=gui_selectCoordinateSystem('default',csori.name,'defaulttype',csori.type,'type','both');
if ok
    gui_setValue(el,el.variable,cs);
    finishCallback(element,i);
end

%%
function finishCallback(element,i,varargin)

icol=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'column'}
                icol=varargin{ii+1};
        end
    end
end

if ~isempty(icol)
    % Table element
    if ~isempty(element(i).element.column(icol).column.callback)
        % Column callback overrules table callback
        feval(element(i).element.column(icol).column.callback,element(i).element.column(icol).column.option1,element(i).element.column(icol).column.option2);
    elseif ~isempty(element(i).element.callback)
        feval(element(i).element.callback,element(i).element.option1,element(i).element.option2);
    end
else    
    % All element are updated and the callback is executed
    if ~isempty(element(i).element.callback)
        % Execute callback
        feval(element(i).element.callback,element(i).element.option1,element(i).element.option2);
    end
end

gui_setElements(element);
