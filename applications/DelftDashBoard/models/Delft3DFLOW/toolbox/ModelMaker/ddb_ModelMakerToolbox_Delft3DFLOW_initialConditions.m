function ddb_ModelMakerToolbox_initialConditions(varargin)
%DDB_MODELMAKERINITIALCONDITIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_modelMakerInitialConditions
%
%   Input:

%
%
%
%
%   Example
%   ddb_modelMakerInitialConditions
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_ModelMakerToolbox_initialConditions.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_initialConditions.m $
% $Keywords: $

%%



handles=getHandles;
ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_refreshScreen;

    handles.toolbox.modelmaker.initialConditions.parameter=[];

    % Update lists in popupmenus
    str{1}='Water Level';
    str{2}='Velocity';

    handles.toolbox.modelmaker.initialConditions.parameter(1).type='wl';
    handles.toolbox.modelmaker.initialConditions.parameter(2).type='cur';
        
    k=2;
    
    if handles.model.delft3dflow.domain(ad).salinity.include
        k=k+1;
        str{k}='Salinity';
        handles.toolbox.modelmaker.initialConditions.parameter(k).type='sal';
    end
    
    if handles.model.delft3dflow.domain(ad).temperature.include
        k=k+1;
        str{k}='Temperature';
        handles.toolbox.modelmaker.initialConditions.parameter(k).type='tem';
    end
    
    if handles.model.delft3dflow.domain(ad).sediments.include
        for j=1:handles.model.delft3dflow.domain(ad).nrSediments
            k=k+1;
            str{k}=handles.model.delft3dflow.domain(ad).sediment(j).name;
            handles.toolbox.modelmaker.initialConditions.parameter(k).type='sediment';
            handles.toolbox.modelmaker.initialConditions.parameter(k).nr=j;
        end
    end
    
    if handles.model.delft3dflow.domain(ad).tracers
        for j=1:handles.model.delft3dflow.domain(ad).nrTracers
            k=k+1;
            str{k}=handles.model.delft3dflow.domain(ad).tracer(j).name;
            handles.toolbox.modelmaker.initialConditions.parameter(k).type='tracer';
            handles.toolbox.modelmaker.initialConditions.parameter(k).nr=j;
        end
    end
    
    handles.toolbox.modelmaker.initialConditions.parameterList=str;
    
    handles.toolbox.modelmaker.initialConditions.activeParameter=1;
    handles.toolbox.modelmaker.initialConditions.parameter='Water Level';
    handles.toolbox.modelmaker.initialConditions.activeDataSource=1;
    handles.toolbox.modelmaker.initialConditions.dataSource='Constant';
    
    
    setHandles(handles);

    % setUIElements('modelmakerpanel.initialconditions');

    %    ddb_plotModelMaker('activate');
%    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
%        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
%            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
%    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'selectparameter'}
            selectParameter;
        case{'removedataset'}
            removeDataset;
        case{'datasetup'}
            datasetUp;
        case{'datasetdown'}
            datasetDown;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'pickselecteddataset'}
%             selectDataset;
    end
    
end

%%
function selectParameter

handles=getHandles;

iac=handles.toolbox.modelmaker.initialConditions.activeParameter;

handles.toolbox.modelmaker.initialConditions.activeDataSource=1;

switch lower(handles.toolbox.modelmaker.initialConditions.parameter(iac).type)
    case{'wl'}
        val=handles.model.delft3dflow.domain(ad).waterLevel.ICConst;
        handles.toolbox.modelmaker.initialConditions.dataSourceList={'Constant'};
    case{'cur'}
        val=handles.model.delft3dflow.domain(ad).velocity.ICConst;
    case{'sal','tem','sediment','tracer'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        handles.toolbox.modelmaker.initialConditions.dataSourceList=str;
end

handles

setHandles(handles);

% setUIElements('modelmakerpanel.initialconditions');

% ddb_refreshScreen('Toolbox','Initial Conditions');
% 
% handles=getHandles;
% 
% str{1}='Water Level';
% str{2}='Velocity';
% handles.GUIData.ConstType{1}='Water Level';
% handles.GUIData.ConstType{2}='Velocity';
% 
% k=2;
% 
% handles.GUIData.NSalTem=0;
% 
% if handles.model.delft3dflow.domain(ad).Salinity.Include
%     k=k+1;
%     handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
%     str{k}='Salinity';
%     handles.GUIData.ConstType{k}='Salinity';
% end
% 
% if handles.model.delft3dflow.domain(ad).Temperature.Include
%     k=k+1;
%     handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
%     str{k}='Temperature';
%     handles.GUIData.ConstType{k}='Temperature';
% end
% 
% if handles.model.delft3dflow.domain(ad).sediments.include
%     for j=1:handles.model.delft3dflow.domain(ad).NrSediment
%         k=k+1;
%         str{k}=handles.model.delft3dflow.domain(ad).Sediment(j).Name;
%         handles.GUIData.ConstType{k}='Sediment';
%         handles.GUIData.ConstNr(k)=j;
%     end
% end
% 
% if handles.model.delft3dflow.domain(ad).Tracers
%     for j=1:handles.model.delft3dflow.domain(ad).NrTracers
%         k=k+1;
%         str{k}=handles.model.delft3dflow.domain(ad).Tracer(j).Name;
%         handles.GUIData.ConstType{k}='Tracer';
%         handles.GUIData.ConstNr(k)=j;
%     end
% end
% 
% handles.GUIHandles.SelectParameter   = uicontrol(gcf,'Style','popupmenu','String',str,'Value',1,   'Position',[ 40 120 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
% handles.GUIHandles.SelectDataSource  = uicontrol(gcf,'Style','popupmenu','String','ddb_test','Value',1,'Position',[170 120 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
% 
% handles.GUIHandles.TextICConst        = uicontrol(gcf,'Style','text','String','Value','Position',[350 117 50 20],'Tag','UIControl');
% handles.GUIHandles.EditICConst        = uicontrol(gcf,'Style','edit','String','ddb_test', 'Position',[410 120 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
% 
% handles.GUIHandles.TextDepth          = uicontrol(gcf,'Style','text','String','Depth','Position',[395 130 70 15],'HorizontalAlignment','center','Tag','UIControl');
% handles.GUIHandles.TextValue          = uicontrol(gcf,'Style','text','String','Value','Position',[465 130 70 15],'HorizontalAlignment','center','Tag','UIControl');
% 
% 
% handles.GUIHandles.PushGenerateInitialConditions  = uicontrol(gcf,'Style','pushbutton','String','Generate Initial Conditions', 'Position',[40  30 170 20],'Tag','UIControl');
% 
% set(handles.GUIHandles.SelectParameter, 'CallBack',   {@SelectParameter_CallBack});
% set(handles.GUIHandles.SelectDataSource,'CallBack',   {@SelectDataSource_CallBack});
% set(handles.GUIHandles.EditICConst,     'CallBack',   {@EditICConst_CallBack});
% set(handles.GUIHandles.PushGenerateInitialConditions,     'CallBack',   {@PushGenerateInitialConditions_CallBack});
% 
% SetUIBackgroundColors;
% 
% RefreshInitialConditions(handles);
% 
% setHandles(handles);
% 
% %%
% function PushGenerateInitialConditions_CallBack(hObject,eventdata)
% 
% handles=getHandles;
% 
% f=str2func(['ddb_generateInitialConditions' handles.Model(md).Name]);
% 
% try
%     handles=feval(f,handles,ad,'ddb_test','ddb_test');
% catch
%     ddb_giveWarning('text',['Initial conditions generation not supported for ' handles.Model(md).LongName]);
%     return
% end
% 
% [filename, pathname, filterindex] = uiputfile('*.ini', 'Select Ini File',handles.model.delft3dflow.domain(ad).IniFile);
% if pathname~=0
%     curdir=[lower(cd) '\'];
%     if ~strcmpi(curdir,pathname)
%         filename=[pathname filename];
%     end
%     handles.model.delft3dflow.domain(ad).IniFile=filename;
%     handles.model.delft3dflow.domain(ad).InitialConditions='ini';
%     handles.model.delft3dflow.domain(ad).SmoothingTime=0.0;
%     handles=feval(f,handles,ad,filename);
%     setHandles(handles);
% end
% 
% %%
% function SelectParameter_CallBack(hObject,eventdata)
% handles=getHandles;
% RefreshInitialConditions(handles);
% setHandles(handles);
% 
% %%
% function EditICConst_CallBack(hObject,eventdata)
% handles=getHandles;
% val=str2double(get(hObject,'String'));
% ival=get(handles.GUIHandles.SelectParameter,'Value');
% 
% switch lower(handles.GUIData.ConstType{ival})
%     case{'water level'}
%         handles.model.delft3dflow.domain(ad).WaterLevel.ICConst=val;
%     case{'velocity'}
%         handles.model.delft3dflow.domain(ad).Velocity.ICConst=val;
%     case{'salinity'}
%         handles.model.delft3dflow.domain(ad).Salinity.ICConst=val;
%     case{'temperature'}
%         handles.model.delft3dflow.domain(ad).Temperature.ICConst=val;
%     case{'sediment'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Sediment(j).ICConst=val;
%     case{'tracer'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Tracer(j).ICConst=val;
% end
% setHandles(handles);
% 
% %%
% function SelectDataSource_CallBack(hObject,eventdata)
% handles=getHandles;
% ii=get(hObject,'Value');
% str=get(hObject,'String');
% ival=get(handles.GUIHandles.SelectParameter,'Value');
% 
% switch lower(handles.GUIData.ConstType{ival})
%     case{'water level'}
%         handles.model.delft3dflow.domain(ad).WaterLevel.ICOpt=str{ii};
%         handles.TideModels.ActiveTideModelIC=handles.TideModels.Name{ii};
%     case{'velocity'}
%         handles.model.delft3dflow.domain(ad).Velocity.ICOpt=str{ii};
%     case{'salinity'}
%         handles.model.delft3dflow.domain(ad).Salinity.ICOpt=str{ii};
%     case{'temperature'}
%         handles.model.delft3dflow.domain(ad).Temperature.ICOpt=str{ii};
%     case{'sediment'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Sediment(j).ICOpt=str{ii};
%     case{'tracer'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Tracer(j).ICOpt=str{ii};
% end
% RefreshInitialConditions(handles);
% setHandles(handles);
% 
% 
% %%
% function RefreshInitialConditions(handles)
% 
% ival=get(handles.GUIHandles.SelectParameter,'Value');
% 
% switch lower(handles.GUIData.ConstType{ival})
%     case{'water level'}
%         set(handles.GUIHandles.SelectDataSource,'String',handles.TideModels.longName);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).WaterLevel.ICOpt),lower(handles.TideModels.Name),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).WaterLevel.ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).WaterLevel.ICConst;
%     case{'velocity'}
%         str{1}='Constant';
%         str{2}='Logarithmic';
%         str{3}='Linear';
%         str{4}='Block';
%         str{4}='Per Layer';
%         set(handles.GUIHandles.SelectDataSource,'Value',1);
%         set(handles.GUIHandles.SelectDataSource,'String',str);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).Velocity.ICOpt),lower(str),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).Velocity.ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).Velocity.ICConst;
%     case{'salinity'}
%         str{1}='Constant';
%         str{2}='Linear';
%         str{3}='Block';
%         str{4}='Per Layer';
%         set(handles.GUIHandles.SelectDataSource,'Value',1);
%         set(handles.GUIHandles.SelectDataSource,'String',str);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).Salinity.ICOpt),lower(str),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).Salinity.ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).Salinity.ICConst;
%     case{'temperature'}
%         str{1}='Constant';
%         str{2}='Linear';
%         str{3}='Block';
%         str{4}='Per Layer';
%         set(handles.GUIHandles.SelectDataSource,'Value',1);
%         set(handles.GUIHandles.SelectDataSource,'String',str);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).Temperature.ICOpt),lower(str),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).Temperature.ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).Temperature.ICConst;
%     case{'sediment'}
%         str{1}='Constant';
%         str{2}='Linear';
%         str{3}='Block';
%         str{4}='Per Layer';
%         set(handles.GUIHandles.SelectDataSource,'Value',1);
%         set(handles.GUIHandles.SelectDataSource,'String',str);
%         j=handles.GUIData.ConstNr(ival);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).Sediment(j).ICOpt),lower(str),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).Sediment(j).ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).Sediment(j).ICConst;
%     case{'tracer'}
%         str{1}='Constant';
%         str{2}='Linear';
%         str{3}='Block';
%         str{4}='Per Layer';
%         set(handles.GUIHandles.SelectDataSource,'Value',1);
%         set(handles.GUIHandles.SelectDataSource,'String',str);
%         j=handles.GUIData.ConstNr(ival);
%         ii=strmatch(lower(handles.model.delft3dflow.domain(ad).Tracer(j).ICOpt),lower(str),'exact');
%         set(handles.GUIHandles.SelectDataSource,'Value',ii);
%         icpar=handles.model.delft3dflow.domain(ad).Tracer(j).ICPar;
%         icconst=handles.model.delft3dflow.domain(ad).Tracer(j).ICConst;
% end
% 
% str=get(handles.GUIHandles.SelectDataSource,'String');
% ii=get(handles.GUIHandles.SelectDataSource,'Value');
% tp=str{ii};
% 
% table2(gcf,'ictable','delete');
% set(handles.GUIHandles.EditICConst,'Visible','off');
% set(handles.GUIHandles.TextICConst,'Visible','off');
% set(handles.GUIHandles.TextValue,'Visible','off');
% set(handles.GUIHandles.TextDepth,'Visible','off');
% 
% switch lower(tp)
%     case{'constant','logarithmic'}
%         set(handles.GUIHandles.EditICConst,'Visible','on');
%         set(handles.GUIHandles.TextICConst,'Visible','on');
%         set(handles.GUIHandles.EditICConst,'String',num2str(icconst));
%     case{'linear','block'}
%         for i=1:size(icpar,1)
%             data{i,1}=icpar(i,1);
%             data{i,2}=icpar(i,2);
%         end
%         callbacks={@ChangeICTable,@ChangeICTable};
%         coltp={'editreal','editreal'};
%         table2(gcf,'ictable','create','position',[370 30],'nrrows',5,'columntypes',coltp,'width',[70 70],'data',data,'callbacks',callbacks,'includenumbers','includebuttons');
%         set(handles.GUIHandles.TextValue,'Visible','on');
%         set(handles.GUIHandles.TextDepth,'Visible','on');
%     case{'per layer'}
%         kmax=handles.model.delft3dflow.domain(ad).KMax;
%         if size(icpar,1)~=kmax
%             icpar=[];
%             for i=1:kmax
%                 icpar(i,1)=0;
%                 icpar(i,2)=0;
%             end
%         end
%         for i=1:kmax
%             data{i,1}=icpar(i,1);
%         end
%         callbacks={@ChangeICTable};
%         coltp={'editreal'};
%         table2(gcf,'ictable','create','position',[440 30],'nrrows',5,'columntypes',coltp,'width',70,'data',data,'callbacks',callbacks,'includenumbers');
%         set(handles.GUIHandles.TextValue,'Visible','on');
%     otherwise
% end
% 
% %%
% function ChangeICTable
% 
% handles=getHandles;
% data=table2(gcf,'ictable','getdata');
% icpar=[];
% for i=1:size(data,1)
%     for j=1:size(data,2)
%         icpar(i,j)=data{i,j};
%     end
%     if size(data,2)==1
%         icpar(i,2)=0;
%     end
% end
% 
% ival=get(handles.GUIHandles.SelectParameter,'Value');
% 
% switch lower(handles.GUIData.ConstType{ival})
%     case{'velocity'}
%         handles.model.delft3dflow.domain(ad).Velocity.ICPar=icpar;
%     case{'salinity'}
%         handles.model.delft3dflow.domain(ad).Salinity.ICPar=icpar;
%     case{'temperature'}
%         handles.model.delft3dflow.domain(ad).Temperature.ICPar=icpar;
%     case{'sediment'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Sediment(j).ICPar=icpar;
%     case{'tracer'}
%         j=handles.GUIData.ConstNr(ival);
%         handles.model.delft3dflow.domain(ad).Tracer(j).ICPar=icpar;
% end
% 
% setHandles(handles);
% 
