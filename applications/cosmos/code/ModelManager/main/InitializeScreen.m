function InitializeScreen

hm=guidata(findobj('Tag','MainWindow'));

bckcol=get(gcf,'Color');

hm.ActiveModel=1;
hm.ActiveContinent=1;

hm.selectContinents1 = uicontrol(gcf,'Style','popupmenu','Position',[ 30 435  195 20],'String',hm.continentNames,'BackgroundColor',[1 1 1],'Tag','UIControl');
% hm.selectContinents2 = uicontrol(gcf,'Style','popupmenu','Position',[520 435  195 20],'String',hm.continentNames,'BackgroundColor',[1 1 1],'Tag','UIControl');
hm.ListModels1 = uicontrol(gcf,'Style','listbox','Position',[ 30  30 195 400],'String',hm.continents(1).modelNames,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
% hm.ListModels2 = uicontrol(gcf,'Style','listbox','Position',[520 230 195 200],'String',hm.continents(1).modelNames,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.editName       = uicontrol(gcf,'Style','edit','Position',[330 460 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
str={'Delft3D-FLOW','Delft3D-FLOW/WAVE','Wavewatch III','X-Beach'};
hm.selectType     = uicontrol(gcf,'Style','popupmenu','Position',[330 435 130 20],'String',str,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editAbbr       = uicontrol(gcf,'Style','edit','Position',[330 410 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editRunid      = uicontrol(gcf,'Style','edit','Position',[330 385 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.selectContinent= uicontrol(gcf,'Style','popupmenu','Position',[330 360 100 20],'String',hm.continentNames,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editPosition1  = uicontrol(gcf,'Style','edit','Position',[330 335  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editPosition2  = uicontrol(gcf,'Style','edit','Position',[385 335  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.selectSize     = uicontrol(gcf,'Style','popupmenu','Position',[330 310 100 20],'String',{'Very Large','Large','Medium','Small','Very Small'},'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editXLim1      = uicontrol(gcf,'Style','edit','Position',[330 285  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editXLim2      = uicontrol(gcf,'Style','edit','Position',[385 285  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editYLim1      = uicontrol(gcf,'Style','edit','Position',[330 260  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editYLim2      = uicontrol(gcf,'Style','edit','Position',[385 260  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
str{1}='0';
for i=1:10
    str{i+1}=num2str(i);
end    
hm.selectPriority = uicontrol(gcf,'Style','popupmenu','Position',[330 235 100 20],'String',str,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.toggleNesting  = uicontrol(gcf,'Style','checkbox','Position',[330 185 100 20],'String','Nested','Tag','UIControl');
hm.editSpinUp     = uicontrol(gcf,'Style','edit','Position',[330 160 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editRunTime    = uicontrol(gcf,'Style','edit','Position',[330 135 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editTimeStep   = uicontrol(gcf,'Style','edit','Position',[330 110 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editMapTimeStep= uicontrol(gcf,'Style','edit','Position',[330  85 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editHisTimeStep= uicontrol(gcf,'Style','edit','Position',[330  60 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.editComTimeStep= uicontrol(gcf,'Style','edit','Position',[330  35 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.textName       = uicontrol(gcf,'Style','text','Position',[235 456 90 20],'BackgroundColor',bckcol,'String','Name','HorizontalAlignment','right','Tag','UIControl');
hm.textAbbr       = uicontrol(gcf,'Style','text','Position',[235 406 90 20],'BackgroundColor',bckcol,'String','Abbreviation','HorizontalAlignment','right','Tag','UIControl');
hm.textRunid      = uicontrol(gcf,'Style','text','Position',[235 381 90 20],'BackgroundColor',bckcol,'String','Runid','HorizontalAlignment','right','Tag','UIControl');
hm.textContinent  = uicontrol(gcf,'Style','text','Position',[235 356 90 20],'BackgroundColor',bckcol,'String','Continent','HorizontalAlignment','right','Tag','UIControl');
hm.textPosition   = uicontrol(gcf,'Style','text','Position',[235 331 90 20],'BackgroundColor',bckcol,'String','Location','HorizontalAlignment','right','Tag','UIControl');
hm.textSize       = uicontrol(gcf,'Style','text','Position',[235 306 90 20],'BackgroundColor',bckcol,'String','Size','HorizontalAlignment','right','Tag','UIControl');
hm.textXLim       = uicontrol(gcf,'Style','text','Position',[235 281 90 20],'BackgroundColor',bckcol,'String','X Lim','HorizontalAlignment','right','Tag','UIControl');
hm.textYLim       = uicontrol(gcf,'Style','text','Position',[235 256 90 20],'BackgroundColor',bckcol,'String','Y Lim','HorizontalAlignment','right','Tag','UIControl');
hm.textPriority   = uicontrol(gcf,'Style','text','Position',[235 231 90 20],'BackgroundColor',bckcol,'String','Priority','HorizontalAlignment','right','Tag','UIControl');
hm.textSpinUp     = uicontrol(gcf,'Style','text','Position',[235 156 90 20],'BackgroundColor',bckcol,'String','Spin Up Time','HorizontalAlignment','right','Tag','UIControl');
hm.textRunTime    = uicontrol(gcf,'Style','text','Position',[235 131 90 20],'BackgroundColor',bckcol,'String','Run Time','HorizontalAlignment','right','Tag','UIControl');
hm.textTimeStep   = uicontrol(gcf,'Style','text','Position',[235 106 90 20],'BackgroundColor',bckcol,'String','Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.textMapTimeStep= uicontrol(gcf,'Style','text','Position',[235  81 90 20],'BackgroundColor',bckcol,'String','Map Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.textHisTimeStep= uicontrol(gcf,'Style','text','Position',[235  56 90 20],'BackgroundColor',bckcol,'String','His Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.textComTimeStep= uicontrol(gcf,'Style','text','Position',[235  31 90 20],'BackgroundColor',bckcol,'String','Com Time Step','HorizontalAlignment','right','Tag','UIControl');

hm.pushAddModel      = uicontrol(gcf,'Style','pushbutton','Position',[590  30 130  25],'String','Add Model','Tag','UIControl');
hm.pushDeleteModel   = uicontrol(gcf,'Style','pushbutton','Position',[450  30 130  25],'String','Delete Model','Tag','UIControl');
hm.pushSaveModel     = uicontrol(gcf,'Style','pushbutton','Position',[590  60 130  25],'String','Save Model','Tag','UIControl');
hm.pushSaveAllModels = uicontrol(gcf,'Style','pushbutton','Position',[450  60 130  25],'String','Save All Models','Tag','UIControl');

hm.pushTimeSeries    = uicontrol(gcf,'Style','pushbutton','Position',[590 90 130  25],'String','Time Series','Tag','UIControl');
hm.pushMaps          = uicontrol(gcf,'Style','pushbutton','Position',[450 90 130  25],'String','Maps','Tag','UIControl');

%%

set(hm.selectContinents1,'CallBack',{@SelectContinents1_CallBack});
% set(hm.selectContinents2,'CallBack',{@SelectContinents2_CallBack});
set(hm.ListModels1      ,'CallBack',{@ListModels1_CallBack});
% set(hm.ListModels2      ,'CallBack',{@ListModels2_CallBack});

set(hm.editName       ,'CallBack',{@EditName_CallBack});
set(hm.selectType     ,'CallBack',{@SelectType_CallBack});
set(hm.editAbbr       ,'CallBack',{@EditAbbr_CallBack});
set(hm.editRunid      ,'CallBack',{@EditRunid_CallBack});
set(hm.selectContinent,'CallBack',{@SelectContinent_CallBack});
set(hm.editPosition1  ,'CallBack',{@EditPosition1_CallBack});
set(hm.editPosition2  ,'CallBack',{@EditPosition2_CallBack});
set(hm.selectSize     ,'CallBack',{@SelectSize_CallBack});
set(hm.editXLim1      ,'CallBack',{@EditXLim1_CallBack});
set(hm.editXLim2      ,'CallBack',{@EditXLim2_CallBack});
set(hm.editYLim1      ,'CallBack',{@EditYLim1_CallBack});
set(hm.editYLim2      ,'CallBack',{@EditYLim2_CallBack});
set(hm.selectPriority ,'CallBack',{@SelectPriority_CallBack});
set(hm.toggleNesting  ,'CallBack',{@ToggleNesting_CallBack});
set(hm.editSpinUp     ,'CallBack',{@EditSpinUp_CallBack});
set(hm.editRunTime    ,'CallBack',{@EditRunTime_CallBack});
set(hm.editTimeStep   ,'CallBack',{@EditTimeStep_CallBack});
set(hm.editMapTimeStep,'CallBack',{@EditMapTimeStep_CallBack});
set(hm.editHisTimeStep,'CallBack',{@EditHisTimeStep_CallBack});
set(hm.editComTimeStep,'CallBack',{@EditComTimeStep_CallBack});

set(hm.pushAddModel     ,'CallBack',{@PushAddModel_CallBack});
set(hm.pushDeleteModel  ,'CallBack',{@PushDeleteModel_CallBack});
set(hm.pushSaveModel    ,'CallBack',{@PushSaveModel_CallBack});
set(hm.pushSaveAllModels,'CallBack',{@PushSaveAllModels_CallBack});

set(hm.pushTimeSeries   ,'CallBack',{@PushTimeSeries_CallBack});
set(hm.pushMaps         ,'CallBack',{@PushMaps_CallBack});

guidata(findobj('Tag','MainWindow'),hm);

RefreshScreen;

%%
function SelectContinents1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
hm.ActiveContinent=get(hObject,'Value');
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function ListModels1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=get(hObject,'Value');
str=get(hObject,'String');
name=str{i};
k=strmatch(name,hm.modelNames,'exact');
hm.ActiveModel=k;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

% %%
% function SelectContinents2_CallBack(hObject,eventdata)
% hm=guidata(findobj('Tag','MainWindow'));
% guidata(findobj('Tag','MainWindow'),hm);
% RefreshScreen;
% 
% %%
% function ListModels2_CallBack(hObject,eventdata)
% hm=guidata(findobj('Tag','MainWindow'));
% i=get(hObject,'Value');
% str=get(hObject,'String');
% name=str{i};
% k=strmatch(name,hm.modelNames,'exact');
% name2=hm.models(hm.ActiveModel).name;
% if ~strcmpi(name,name2)
%     hm.models(hm.ActiveModel).nestModel=hm.modelAbbrs{k};
%     hm.ActiveNestModel=i;
% end    
% guidata(findobj('Tag','MainWindow'),hm);
% RefreshScreen;

%%
function EditName_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.models(i).name=str;
hm=DetermineModelsInContinent(hm);
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function SelectType_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
ii=get(hObject,'Value');
switch ii
    case 1
        hm.models(i).type='Delft3DFLOW';
    case 2
        hm.models(i).type='Delft3DFLOWWAVE';
    case 3
        hm.models(i).type='WW3';
    case 4
        hm.models(i).type='XBeach';
end
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditAbbr_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.models(i).Abbr=str;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditRunid_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.models(i).runid=str;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectContinent_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.models(i).continent=hm.continents(k).Abbr;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function EditPosition1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).Location(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditPosition2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).Location(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectSize_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.models(i).size=k;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditXLim1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).xLim(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditXLim2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).xLim(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditYLim1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).yLim(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditYLim2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).yLim(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectPriority_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.models(i).priority=k-1;
guidata(findobj('Tag','MainWindow'),hm);

%%
function ToggleNesting_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.models(i).nested=k;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function EditSpinUp_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).spinUp=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditRunTime_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).runTime=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).timeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditMapTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).mapTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditHisTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).hisTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditComTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.models(i).comTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function PushSaveModel_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
WriteModels(hm,hm.models(hm.ActiveModel).Abbr);

%%
function PushSaveAllModels_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
WriteModels(hm);

%%
function PushAddModel_CallBack(hObject,eventdata)
AddModel;

%%
function PushTimeSeries_CallBack(hObject,eventdata)
EditTimeSeries;

%%
function PushMaps_CallBack(hObject,eventdata)
EditMaps;
