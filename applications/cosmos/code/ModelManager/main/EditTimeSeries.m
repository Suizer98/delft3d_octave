function EditTimeSeries

handles=[];

hm=guidata(findobj('Tag','MainWindow'));
m=hm.ActiveModel;

fig0=gcf;
fig=MakeNewWindow('Edit Time Series Plots',[800 400],'modal');

bckcol=get(gcf,'Color');

cltp={'editstring','editstring','checkbox','checkbox','popupmenu','checkbox','popupmenu'};
wdt=[250 100 20 20 100 20 100];
callbacks={@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable};

if hm.models(m).nrStations>0
    for i=1:hm.models(m).nrStations
        data{i,1}=hm.models(m).stations(i).name2;
        data{i,2}=hm.models(m).stations(i).name1;
        data{i,3}=hm.models(m).stations(i).parameters(1).plotCmp;
        data{i,4}=hm.models(m).stations(i).parameters(1).plotObs;
        data{i,5}=hm.models(m).stations(i).parameters(1).obsCode;
        data{i,6}=hm.models(m).stations(i).parameters(1).plotPrd;
        data{i,7}=hm.models(m).stations(i).parameters(1).prdCode;
    end
else
    data{1,1}='';
    data{1,2}='';
    data{1,3}=0;
    data{1,4}=0;
    data{1,5}='';
    data{1,6}=0;
    data{1,7}='';
end

nr=hm.nrStations;
k=0;
for i=1:nr
    if strcmpi(hm.stations(i).continent,hm.models(m).continent)
        k=k+1;
        for j=1:7
            popuptext{k,j}=hm.stations(i).IDCode;
        end
    end
end
for j=1:7
    popuptext{k+1,j}='none';
end

table2(gcf,'table','create','position',[30 60],'nrrows',10,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'popuptext',popuptext);

for j=1:hm.nrParameters
    handles.parameters{j}=hm.parameters(j).longName;
end
handles.selectParameter= uicontrol(gcf,'Style','popupmenu','Position',[330 300 100 20],'String',handles.parameters,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.LoadObsFile = uicontrol(gcf,'Style','pushbutton','Position',[330 270  100 20],'String','Load Obs File','Tag','UIControl');

handles.pushOK     = uicontrol(gcf,'Style','pushbutton','Position',[400  30  70 20],'String','OK','Tag','UIControl');
handles.pushCancel = uicontrol(gcf,'Style','pushbutton','Position',[320  30  70 20],'String','Cancel','Tag','UIControl');

set(handles.pushOK     ,'CallBack',{@PushOK_CallBack});
set(handles.pushCancel ,'CallBack',{@PushCancel_CallBack});
set(handles.LoadObsFile ,'CallBack',{@LoadObsFile_CallBack});
set(handles.selectParameter ,'CallBack',{@SelectParameter_CallBack});

handles.models=hm.models(m);

guidata(gcf,handles);

RefreshAll(handles);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
hm=guidata(findobj('Tag','MainWindow'));
hm.models(hm.ActiveModel).nrStations=handles.models.nrStations;
hm.models(hm.ActiveModel).stations=handles.models.stations;
guidata(findobj('Tag','MainWindow'),hm);
close(gcf);

%%
function PushCancel_CallBack(hObject,eventdata)
close(gcf);

%%
function LoadObsFile_CallBack(hObject,eventdata)

hm=guidata(findobj('Tag','MainWindow'));

handles=guidata(gcf);

[filename, pathname, filterindex] = uigetfile('*.obs', 'Select Observation Points File');

if pathname~=0

    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end

    m=[];
    n=[];
    name=[];

    [name,m,n] = textread(filename,'%21c%f%f');

    [filename, pathname, filterindex] = uigetfile('*.ann', 'Select Annotation File');
    annfile=[pathname filename];

    if pathname~=0

        fid=fopen(annfile);
        k=0;
        for j=1:1000
            tx0=fgets(fid);
            if and(ischar(tx0), size(tx0>0))
                v0=strread(tx0,'%q');
%                if ~strcmp(v0{1}(1),'#')
                    k=k+1;
                    x(k)=str2num(v0{2});
                    y(k)=str2num(v0{3});
%                end

            end
        end
        fclose(fid);

        handles.models.stations=[];
        handles.models.nrStations=length(m);

        for i=1:length(m)
            handles.models.stations(i).name1=deblank(name(i,:));
            handles.models.stations(i).name2=deblank(name(i,:));
            handles.models.stations(i).m=m(i);
            handles.models.stations(i).N=n(i);
            handles.models.stations(i).Location(1)=x(i);
            handles.models.stations(i).Location(2)=y(i);

            for k=1:hm.nrParameters
                handles.models.stations(i).parameters(k).plotCmp=0;
                handles.models.stations(i).parameters(k).plotObs=0;
                handles.models.stations(i).parameters(k).plotPrd=0;
            end

        end
        guidata(gcf,handles);
        RefreshAll(handles);
    end
end

%%
function RefreshAll(handles)

hm=guidata(findobj('Tag','MainWindow'));
nr=hm.nrStations;

ii=get(handles.selectParameter,'Value');

data{1,1}='';
data{1,2}=0;
data{1,3}=0;
data{1,4}=0;

for i=1:handles.models.nrStations
    data{i,1}=handles.models.stations(i).name2;
    data{i,2}=handles.models.stations(i).name1;
    data{i,3}=handles.models.stations(i).parameters(ii).plotCmp;
    data{i,4}=handles.models.stations(i).parameters(ii).plotObs;
    data{i,5}=handles.models.stations(i).parameters(ii).obsCode;
    data{i,6}=handles.models.stations(i).parameters(ii).plotPrd;
    data{i,7}=handles.models.stations(i).parameters(ii).prdCode;
end

table2(gcf,'table','change','data',data);

%%
function ChangeTable

handles=guidata(gcf);

hm=guidata(findobj('Tag','MainWindow'));
nr=hm.nrStations;
for i=1:nr
    if strcmpi(hm.stations(i).continent,handles.models.continent)
        stations{i}=hm.stations(i).IDCode;
    end
end

data=table2(gcf,'table','getdata');
ii=get(handles.selectParameter,'Value');

for i=1:handles.models.nrStations
    handles.models.stations(i).name2=data{i,1};
    handles.models.stations(i).name1=data{i,2};
    handles.models.stations(i).parameters(ii).plotCmp=data{i,3};
    handles.models.stations(i).parameters(ii).plotObs=data{i,4};
    handles.models.stations(i).parameters(ii).obsCode=data{i,5};
    handles.models.stations(i).parameters(ii).plotPrd=data{i,6};
    handles.models.stations(i).parameters(ii).prdCode=data{i,7};
end
guidata(gcf,handles);

%%
function SelectParameter_CallBack(hObject,eventdata)
handles=guidata(gcf);
RefreshAll(handles);
