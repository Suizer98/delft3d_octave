function [h,ok]=gui_newWindow(hin,varargin)

% Opens new modal GUI window, based on xml file
% Data is stored in  stored figure's user data

% Defaults
xmlfile=[];
xmldir=[];
element=[];
color=[];
hgt=500;
wdt=200;
iconfile=[];
ttl='';
tag='uifigure';
modal=1;
createcallback=[];
createinput=[];
menuitem=[];
getfcn=@gui_getUserData;
setfcn=@gui_setUserData;
resizefcn=[];
closerequestfcn=[];
rsz=1;
include_zoom=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'xmldir'}
                xmldir=varargin{ii+1};
            case{'xmlfile'}
                xmlfile=varargin{ii+1};
            case{'element'}
                element=varargin{ii+1};
            case{'menuitem'}
                menuitem=varargin{ii+1};
            case{'height'}
                hgt=varargin{ii+1};
            case{'width'}
                wdt=varargin{ii+1};
            case{'iconfile'}
                iconfile=varargin{ii+1};
            case{'tag'}
                tag=varargin{ii+1};
            case{'title'}
                ttl=varargin{ii+1};
            case{'modal'}
                modal=varargin{ii+1};
            case{'getfcn'}
                getfcn=varargin{ii+1};
            case{'setfcn'}
                setfcn=varargin{ii+1};
            case{'createcallback'}
                createcallback=varargin{ii+1};
            case{'createinput'}
                createinput=varargin{ii+1};
            case{'color'}
                color=varargin{ii+1};
            case{'resize'}
                rsz=varargin{ii+1};
            case{'resizefcn'}
                resizefcn=varargin{ii+1};
            case{'closerequestfcn'}
                closerequestfcn=varargin{ii+1};
            case{'zoom'}
                include_zoom=varargin{ii+1};
        end
    end
end

hin.ok=1;

if ~isempty(xmldir)
    % Load xml file with elements
    xml=gui_readXMLfile(xmlfile,xmldir);
    if isfield(xml,'tag')
        tag=xml.tag;
    else
        tag='uifigure';
    end
    element=xml.element;
    sz(1)=str2double(xml.width);
    sz(2)=str2double(xml.height);
    ttl=xml.title;
    if isfield(xml,'menuitem')
        menuitem=xml.menuitem;
    end
else
    sz(1)=wdt;
    sz(2)=hgt;
end

screensize=get(0,'ScreenSize');
if screensize(3)>1900
    sz=sz*1.2;
end

if ~isempty(iconfile)
    if modal
        figh=MakeNewWindow(ttl,sz,'modal','iconfile',iconfile);
    else
        figh=MakeNewWindow(ttl,sz,'iconfile',iconfile);
    end
else
    if modal
        figh=MakeNewWindow(ttl,sz,'modal');
    else
        figh=MakeNewWindow(ttl,sz);
    end
end



if ~rsz
    set(figh,'Resize','off');
end

if ~isempty(color)
  set(figh,'Color',color);
end

set(figh,'Tag',tag);

if ~isempty(resizefcn)
    set(figh,'ResizeFcn',resizefcn);
end
if ~isempty(closerequestfcn)
    set(figh,'CloseRequestFcn',closerequestfcn);
end
    
feval(setfcn,hin);

if ~isempty(menuitem)
    gui_addMenu(figh,menuitem);
end

element=gui_addElements(figh,element,'getfcn',getfcn,'setfcn',setfcn);

if ~isempty(createcallback)
    feval(createcallback,createinput);
    gui_setElements(element);
end


if include_zoom
    
    % zoom toolbar
    tbh = uitoolbar;
    
    settingsDir='d:\checkouts\OET\trunk\matlab\applications\DelftDashBoard\settings';
    
    c=load([settingsDir filesep 'icons' filesep 'icons_muppet.mat']);
    cpan=load([settingsDir filesep 'icons' filesep 'icons.mat']);
    
    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
    set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,[],[],[],[]});
    set(h,'Tag','UIToggleToolZoomIn');
    set(h,'cdata',c.ico.zoomin16);
    handles.GUIHandles.toolBar.zoomIn=h;
    %set(h,'cdata',c2.ico.zoom_in_32x32);
    
    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
    set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,[],[],[],[]});
    set(h,'Tag','UIToggleToolZoomOut');
    set(h,'cdata',c.ico.zoomout16);
    handles.GUIHandles.toolBar.zoomOut=h;
    
    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
    set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,[],[],[],[]}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',cpan.icons.pan);
    handles.GUIHandles.toolBar.pan=h;
    
    handles.GUIHandles.mapAxis=gca;
    
    handles.screenParameters.coordinateSystem.type='geographic';
    
    handles.screenParameters.xMaxRange=[-1e9 1e9];
    handles.screenParameters.yMaxRange=[-1e9 1e9];
    handles.GUIHandles.toolBar.autoRefreshBathymetry=[];
    
    setHandles(handles);
end



if nargout>0
        
    uiwait;
    
    hnew=feval(getfcn);

    ok=0;
    if isfield(hnew,'ok')
        if hnew.ok
            ok=1;
        else
            ok=0;
        end
        % Remove ok field from output structure
        hnew=rmfield(hnew,'ok');
    end
    
    if ok
        % Ok, using new user data for output
        h=hnew;
    else
        % Not ok, output is identical to input
        h=hin;
    end    
    
    % Close the figure
    try
        delete(figh);
    end
    
end

