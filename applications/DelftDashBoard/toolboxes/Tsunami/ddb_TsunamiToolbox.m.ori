function ddb_TsunamiToolbox

handles=getHandles;

ddb_plotTsunami(handles,'activate');

handles.Toolbox(tb).Input.ToleranceLength=0.1;

h=findall(gca,'Tag','Plates');
if isempty(h)
    load([handles.SettingsDir 'geo\plates.mat']);
    platesz=zeros(size(platesx))+50;
    h=plot3(platesx,platesy,platesz);
    set(h,'Color',[1.0 0.5 0.00]);
    set(h,'Tag','Plates');
    set(h,'LineWidth',1.5);
    set(h,'HitTest','off');
end

uipanel('Title','Tsunami','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

uipanel('Title','Earthquake Parameters','Units','pixels','Position',[30 30 345 135],'Tag','UIControl');

handles.EditMagnitude    = uicontrol(gcf,'Style','edit','String','','Position',[145 115  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditDepthFromTop = uicontrol(gcf,'Style','edit','String','','Position',[145  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditLat          = uicontrol(gcf,'Style','edit','String','','Position',[255 115  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditLon          = uicontrol(gcf,'Style','edit','String','','Position',[315 115  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextMagnitude    = uicontrol(gcf,'Style','text','String','Magnitude (Mw)',     'Position',[40  112 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextDepthFromTop = uicontrol(gcf,'Style','text','String','Depth from Top (km)','Position',[40   87 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextEpicentre    = uicontrol(gcf,'Style','text','String','Epicentre',          'Position',[200 112 50 20],'HorizontalAlignment','center','Tag','UIControl');
handles.TextLat          = uicontrol(gcf,'Style','text','String','Lat (deg)',          'Position',[255 137  50 12],'HorizontalAlignment','right','Tag','UIControl');
handles.TextLon          = uicontrol(gcf,'Style','text','String','Lon (deg)',          'Position',[315 137  50 12],'HorizontalAlignment','right','Tag','UIControl');

handles.CheckFaultRelated  = uicontrol(gcf,'Style','checkbox','String','Fault Related to Epicentre', 'Position',[210  90 160 20],'Tag','UIControl');

handles.EditTotalFaultLength = uicontrol(gcf,'Style','edit','String','','Position', [145   65  50 20],'HorizontalAlignment','right','BackgroundColor',[0.8 0.8 0.8],'Enable','off','Tag','UIControl');
handles.EditFaultWidth       = uicontrol(gcf,'Style','edit','String','','Position', [145   40  50 20],'HorizontalAlignment','right','BackgroundColor',[0.8 0.8 0.8],'Enable','off','Tag','UIControl');
handles.EditSegment          = uicontrol(gcf,'Style','edit','String','','Position', [315   65  50 20],'HorizontalAlignment','right','BackgroundColor',[0.8 0.8 0.8],'Enable','off','Tag','UIControl');
handles.EditDislocation      = uicontrol(gcf,'Style','edit','String','','Position', [315   40  50 20],'HorizontalAlignment','right','BackgroundColor',[0.8 0.8 0.8],'Enable','off','Tag','UIControl');

handles.TextTotalFaultLength = uicontrol(gcf,'Style','text','String','Tot. Fault Length (km)','Position',[35  62 105 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextFaultWidth       = uicontrol(gcf,'Style','text','String','Fault Width (km)',      'Position',[35  37 105 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextSegment          = uicontrol(gcf,'Style','text','String','User Fault Length (km)','Position',[200 62 110 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextDip              = uicontrol(gcf,'Style','text','String','Dip / Dislocation (km)','Position',[210 37 100 20],'HorizontalAlignment','right','Tag','UIControl');

uipanel('Title','Detailed Fault Area Data','Units','pixels','Position',[385 30 465 135],'Tag','UIControl');

handles.TextFaultLength = uicontrol(gcf,'Style','text','String','Fault Length (km)','Position',[405 119  70 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextStrike      = uicontrol(gcf,'Style','text','String','Strike Degrees',   'Position',[475 119  50 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextDip         = uicontrol(gcf,'Style','text','String','Dip Degrees',      'Position',[535 119  50 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextSlipRake    = uicontrol(gcf,'Style','text','String','Slip/Rake Degrees','Position',[595 119  50 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextFocalDepth  = uicontrol(gcf,'Style','text','String','Focal Depth (km)', 'Position',[645 119  70 30],'HorizontalAlignment','center','Tag','UIControl');

handles.PushDrawSegments    = uicontrol(gcf,'Style','pushbutton','String','Draw Segments','Position',   [740 100 100 20],'Tag','UIControl');
handles.PushClickEpicentre  = uicontrol(gcf,'Style','pushbutton','String','Click Epicentre','Position', [740  75 100 20],'Tag','UIControl');

handles.PushComputeTsunami  = uicontrol(gcf,'Style','pushbutton','String','Compute Initial Tsunami','Position',[860 30 140 20],'Enable','off','Tag','UIControl');

handles.PushOpen   = uicontrol(gcf,'Style','pushbutton','String','Open','Position',      [860 135 60 20],'Tag','UIControl');
handles.PushImport = uicontrol(gcf,'Style','pushbutton','String','Import ...','Position',[930 135 60 20],'Enable','off','Tag','UIControl');
handles.PushSave   = uicontrol(gcf,'Style','pushbutton','String','Save','Position',      [860 110 60 20],'Enable','on','Tag','UIControl');

set(handles.EditMagnitude,   'CallBack',{@EditMagnitude_CallBack});
set(handles.EditDepthFromTop,'CallBack',{@EditDepthFromTop_CallBack});
set(handles.CheckFaultRelated,'CallBack',{@CheckFaultRelated_CallBack});
set(handles.EditLat,     'CallBack',{@EditLatitude_CallBack});
set(handles.EditLon,     'CallBack',{@EditLongitude_CallBack});

set(handles.PushDrawSegments,  'CallBack',{@PushDrawSegments_CallBack});
set(handles.PushClickEpicentre,'CallBack',{@PushClickEpicentre_CallBack});
set(handles.PushComputeTsunami,'CallBack',{@PushComputeTsunami_CallBack});

set(handles.PushSave,'CallBack',{@PushSaveFile_CallBack});
set(handles.PushOpen,'CallBack',{@PushOpenFile_CallBack});

handles=RefreshAll(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function EditMagnitude_CallBack(hObject,eventdata)

handles=getHandles;
handles.Toolbox(tb).Input.Magnitude=str2num(get(hObject,'String'));
handles=RefreshAll(handles);
setHandles(handles);

%%
function CheckFaultRelated_CallBack(hObject,eventdata)

handles=getHandles;
ii=get(hObject,'Value');
if ii==1
    handles.Toolbox(tb).Input.RelatedToEpicentre=1;
else
    handles.Toolbox(tb).Input.RelatedToEpicentre=0;
end
handles=RefreshAll(handles);
setHandles(handles);

%%
function EditDepthFromTop_CallBack(hObject,eventdata)

handles=getHandles;
handles.Toolbox(tb).Input.DepthFromTop=str2num(get(hObject,'String'));
handles=RefreshAll(handles);
setHandles(handles);

%%
function EditLatitude_CallBack(hObject,eventdata)

handles=getHandles;
handles.Toolbox(tb).Input.Latitude=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditLongitude_CallBack(hObject,eventdata)

handles=getHandles;
handles.Toolbox(tb).Input.Longitude=str2num(get(hObject,'String'));
setHandles(handles);

%%
function PushDrawSegments_CallBack(hObject,eventdata)

handles=getHandles;
ddb_zoomOff;
h=findall(gcf,'Tag','TsunamiSegments');
set(h,'HitTest','off');
if handles.Toolbox(tb).Input.RelatedToEpicentre
    [x,y]=DrawPolyline('g',1.5,'o','r','max',2);
else
    [x,y]=DrawPolyline('g',1.5,'o','r');
end    
if ~isempty(h)
    delete(h);
end
h=findall(gcf,'Tag','FaultArea');
if ~isempty(h)
    delete(h);
end
if ~isempty(x)
    handles.Toolbox(tb).Input.NrSegments=length(x)-1;
    handles.Toolbox(tb).Input.FaultX=x;
    handles.Toolbox(tb).Input.FaultY=y;
    for i=2:handles.Toolbox(tb).Input.NrSegments
        handles.Toolbox(tb).Input.Dip(i)=handles.Toolbox(tb).Input.Dip(1);
        handles.Toolbox(tb).Input.SlipRake(i)=handles.Toolbox(tb).Input.SlipRake(1);
    end
end
DrawTsunamiSegments(handles)
handles=RefreshAll(handles);
setHandles(handles);

%%
function PushClickEpicentre_CallBack(hObject,eventdata)
ddb_zoomOff;
ClickPoint('xy','Callback',@SelectEpicentre,'single');

%%
function PushComputeTsunami_CallBack(hObject,eventdata)

handles=getHandles;
if ~isempty(handles.Model(md).Input(ad).GrdFile) && ~isempty(handles.Model(md).Input(ad).DepFile)
    handles=ddb_dnami_compute(handles);
else
    GiveWarning('Warning','You must first load or generate a model grid and bathymetry!');
end
setHandles(handles);

%%
function PushRedrawFaultArea_CallBack(hObject,eventdata)
handles=getHandles;
handles=ddb_dnami_redrw_Farea(handles);
UpdateFaultAreaData;
setHandles(handles);

%%
function PushSaveFile_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.tsu', 'Select Tsunami File','');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
ddb_saveTsunamiFile(handles,filename);

%%
function PushOpenFile_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.tsu', 'Select Tsunami File','');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles=ddb_readTsunamiFile(handles,filename);
set(handles.EditMagnitude,'String',num2str(handles.Toolbox(tb).Input.Magnitude));
h=findall(gcf,'Tag','TsunamiSegments');
if ~isempty(h)
    delete(h);
end
h=findall(gcf,'Tag','FaultArea');
if ~isempty(h)
    delete(h);
end
DrawTsunamiSegments(handles);
DrawEpicentre(handles);
handles=RefreshAll(handles);
setHandles(handles);

%%
function RefreshDetailedFaultArea(handles)

nseg=handles.Toolbox(tb).Input.NrSegments;

cltp={'editreal','editreal','editreal','editreal','editreal'};
wdt=[60 60 60 60 60];
callbacks={@UpdateFaultAreaData,@UpdateFaultAreaData,@UpdateFaultAreaData,@UpdateFaultAreaData,''};
fmt={'%4.0f','%4.0f','','','%4.1f'};
enab=zeros(4,5)+1;

enab(:,5)=0;
data=[];

for i=1:nseg
    data{i,1}=handles.Toolbox(tb).Input.FaultLength(i);
    data{i,2}=handles.Toolbox(tb).Input.Strike(i);
    data{i,3}=handles.Toolbox(tb).Input.Dip(i);
    data{i,4}=handles.Toolbox(tb).Input.SlipRake(i);
    data{i,5}=handles.Toolbox(tb).Input.FocalDepth(i);
end
%handles = ddb_computeMw(handles);

tbl=table2(gcf,'table','find');
if ~isempty(tbl)
    table2(gcf,'table','change','data',data);
else
    table2(gcf,'table','create','position',[386 40],'nrrows',4,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'format',fmt,'enable',enab,'includenumbers');
end

%%
function UpdateFaultAreaData

handles=getHandles;
data=table2(gcf,'table','getdata');
handles.Toolbox(tb).Input.FaultLength=[];
handles.Toolbox(tb).Input.Strike=[];
handles.Toolbox(tb).Input.Dip=[];
handles.Toolbox(tb).Input.SlipRake=[];
handles.Toolbox(tb).Input.TotalUserFaultLength = 0.;
for i=1:size(data,1)
    handles.Toolbox(tb).Input.FaultLength(i)=data{i,1};
    handles.Toolbox(tb).Input.Strike(i)=data{i,2};
    handles.Toolbox(tb).Input.Dip(i)=data{i,3};
    handles.Toolbox(tb).Input.SlipRake(i)=data{i,4};
end
%handles=ddb_computeMw(handles);

handles=ddb_dnami_redrw_Farea(handles);
handles=RefreshAll(handles);
setHandles(handles);

%%
function SelectEpicentre(x,y)

handles=getHandles;
handles.Toolbox(tb).Input.Longitude=x;
handles.Toolbox(tb).Input.Latitude=y;
DrawEpicentre(handles);
handles=RefreshAll(handles);
setHandles(handles);

%%
function handles=RefreshAll(handles)

if handles.Toolbox(tb).Input.RelatedToEpicentre && handles.Toolbox(tb).Input.NrSegments>1
   ButtonName = questdlg('Only first segment will be used. Continue?','','Cancel', 'OK', 'OK');
   switch ButtonName,
     case 'Cancel',
         handles.Toolbox(tb).Input.RelatedToEpicentre=0;
         set(handles.CheckFaultRelated,'Value',0);
     case 'OK',
         handles.Toolbox(tb).Input.NrSegments=1;
         handles.Toolbox(tb).Input.FaultX=handles.Toolbox(tb).Input.FaultX(1:2);
         handles.Toolbox(tb).Input.FaultY=handles.Toolbox(tb).Input.FaultY(1:2);
         handles.Toolbox(tb).Input.FaultLength=handles.Toolbox(tb).Input.FaultLength(1:2);
         handles.Toolbox(tb).Input.Strike=handles.Toolbox(tb).Input.Strike(1:2);
         handles.Toolbox(tb).Input.Dip=handles.Toolbox(tb).Input.Dip(1:2);
         handles.Toolbox(tb).Input.SlipRake=handles.Toolbox(tb).Input.SlipRake(1:2);
         handles.Toolbox(tb).Input.FocalDepth=handles.Toolbox(tb).Input.FocalDepth(1:2);
         DrawTsunamiSegments(handles);
   end
end
%ddb_computeMw(handles); 

h=findall(gcf,'Tag','FaultArea');
if ~isempty(h)
    delete(h);
end

if handles.Toolbox(tb).Input.NrSegments>0
    handles=ddb_dnami_compFline(handles);
    handles=ddb_computeFocalDepth(handles);
    if handles.Toolbox(tb).Input.Magnitude>=5
        handles=ddb_dnami_compEQpar(handles);
        handles=ddb_dnami_comp_Farea(handles);
    end
set(handles.EditMagnitude,'String',num2str(handles.Toolbox(tb).Input.Magnitude));
    if (abs(handles.Toolbox(tb).Input.TotalUserFaultLength-handles.Toolbox(tb).Input.TotalFaultLength) > handles.Toolbox(tb).Input.ToleranceLength*handles.Toolbox(tb).Input.TotalFaultLength)
        set(handles.EditMagnitude,'BackgroundColor',[1 0 0]);
    else
        set(handles.EditMagnitude,'BackgroundColor',[1 1 1]);
        handles=ddb_dnami_redrw_Farea(handles);
    end
end

set(handles.EditMagnitude    ,'String',num2str(handles.Toolbox(tb).Input.Magnitude));
set(handles.EditDepthFromTop ,'String',num2str(handles.Toolbox(tb).Input.DepthFromTop));
set(handles.EditLat          ,'String',num2str(handles.Toolbox(tb).Input.Latitude));
set(handles.EditLon          ,'String',num2str(handles.Toolbox(tb).Input.Longitude));

set(handles.EditTotalFaultLength,'String',num2str(handles.Toolbox(tb).Input.TotalFaultLength,'%4.0f'));
set(handles.EditFaultWidth,      'String',num2str(handles.Toolbox(tb).Input.FaultWidth,'%4.0f'));
set(handles.EditDislocation,     'String',num2str(handles.Toolbox(tb).Input.Dislocation,'%4.1f'));

h=findall(gcf,'Tag','Epicentre');
if handles.Toolbox(tb).Input.RelatedToEpicentre
    set(handles.CheckFaultRelated,'Value',1);
    set(handles.EditLon,'Enable','on');
    set(handles.EditLat,'Enable','on');
    set(handles.TextLon,'Enable','on');
    set(handles.TextLat,'Enable','on');
    set(handles.TextEpicentre,'Enable','on');
    set(handles.PushClickEpicentre,'Enable','on');
    set(handles.PushDrawSegments,'Enable','off');
    if length(h)>0
        set(h,'Visible','on');
    end
    h=findall(gcf,'Tag','TsunamiSegments');
    if length(h)>0
        set(h,'Visible','off');
    end
else
    set(handles.CheckFaultRelated,'Value',0);
    set(handles.EditLon,'Enable','off');
    set(handles.EditLat,'Enable','off');
    set(handles.TextLon,'Enable','off');
    set(handles.TextLat,'Enable','off');
    set(handles.TextEpicentre,'Enable','off');
    set(handles.PushClickEpicentre,'Enable','off');
    set(handles.PushDrawSegments,'Enable','on');
    if length(h)>0
        set(h,'Visible','off');
    end
    h=findall(gcf,'Tag','TsunamiSegments');
    if length(h)>0
        set(h,'Visible','on');
    end
end

RefreshDetailedFaultArea(handles);

if handles.Toolbox(tb).Input.NrSegments>0
    set(handles.EditSegment,       'String',num2str(handles.Toolbox(tb).Input.TotalUserFaultLength,'%4.0f'));
    if handles.Toolbox(tb).Input.Magnitude>=5
      if get(handles.EditMagnitude,'BackgroundColor') == [1 1 1];
         set(handles.PushComputeTsunami,'Enable','on');
      else
         set(handles.PushComputeTsunami,'Enable','off');   
      end
    else
        set(handles.PushComputeTsunami,'Enable','off');
    end
else
    set(handles.PushComputeTsunami,'Enable','off');
end

%%
function DrawTsunamiSegments(handles)

h=findall(gcf,'Tag','TsunamiSegments');
if ~isempty(h)
    delete(h);
end
z=zeros(size(handles.Toolbox(tb).Input.FaultX))+100;
if ~isempty(handles.Toolbox(tb).Input.FaultX)
    h=plot3(handles.Toolbox(tb).Input.FaultX,handles.Toolbox(tb).Input.FaultY,z,'g');
    set(h,'LineWidth',1.5);
    set(h,'Tag','TsunamiSegments');
    set(h,'HitTest','off');
    for i=1:length(handles.Toolbox(tb).Input.FaultX)
        h=plot3(handles.Toolbox(tb).Input.FaultX(i),handles.Toolbox(tb).Input.FaultY(i),200,'ro');
        set(h,'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4);
        set(h,'ButtonDownFcn',{@MoveVertex});
        set(h,'Tag','TsunamiSegments');
        set(h,'UserData',i);
    end
end

%%
function DrawEpicentre(handles)

h=findall(gcf,'Tag','Epicentre');
if ~isempty(h)
    delete(h);
end
h = plot3(handles.Toolbox(tb).Input.Longitude,handles.Toolbox(tb).Input.Latitude,1000);
set(h,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',15);
set(h,'Tag','Epicentre');
set(h,'ButtonDownFcn',{@MoveEpicentre});

%%
function MoveVertex(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
h=get(gcf,'CurrentObject');
ii=get(h,'UserData');
set(0,'UserData',ii);

%%
function FollowTrack(imagefig, varargins)
handles=getHandles;
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
ii=get(0,'UserData');
handles.Toolbox(tb).Input.FaultX(ii)=xi;
handles.Toolbox(tb).Input.FaultY(ii)=yi;
DrawTsunamiSegments(handles);
setHandles(handles);
ddb_updateCoordinateText('arrow');

%%
function MoveEpicentre(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrackEpi});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});

%%
function FollowTrackEpi(imagefig, varargins)
handles=getHandles;
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
handles.Toolbox(tb).Input.Longitude=xi;
handles.Toolbox(tb).Input.Latitude=yi;
DrawEpicentre(handles);
setHandles(handles);
ddb_updateCoordinateText('arrow');

%%
function StopTrack(imagefig, varargins)
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(0,'UserData',[]);
handles=getHandles;
handles=RefreshAll(handles);
setHandles(handles);
