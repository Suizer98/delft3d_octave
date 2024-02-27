function ddb_menuCoordinateSystem(hObject, eventdata, handles)
%DDB_MENUCOORDINATESYSTEM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuCoordinateSystem(hObject, eventdata, handles)
%
%   Input:
%   hObject   =
%   eventdata =
%   handles   =
%
%
%
%
%   Example
%   ddb_menuCoordinateSystem
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

handles=getHandles;
handles.convertModelData=0;
setHandles(handles);

tg=get(hObject,'Tag');

ddb_zoomOff;

switch tg,
    case{'menuCoordinateSystemGeographic'}
        menuCoordinateSystemGeo_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemUTM'}
        menuCoordinateSystemUTM_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemSelectUTMZone'}
        menuCoordinateSystemSelectUTMZone_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemCartesian'}
        menuCoordinateSystemCartesian_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemOtherCartesian'}
        menuCoordinateSystemOtherCartesian_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemOtherGeographic'}
        menuCoordinateSystemOtherGeographic_Callback(hObject,eventdata,handles);
end

%%
function menuCoordinateSystemGeo_Callback(hObject,eventdata,handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');
    handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
    handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
    lab=get(hObject,'Label');
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Geographic';
        setHandles(handles);
        ddb_changeCoordinateSystem;
        ddb_updateDataInScreen;
        ddb_resetAll;        
    end
end

%%
function menuCoordinateSystemUTM_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');
    lab=get(hObject,'Label');
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
        ddb_updateDataInScreen;
        ddb_resetAll;        
    end
end

%%
function menuCoordinateSystemSelectUTMZone_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    
    
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Checked','on');
    
    ddb_zoomOff;
    
    UTMZone=ddb_selectUTMZone;
    
    if ~isempty(UTMZone)
        
        handles.screenParameters.UTMZone=UTMZone;
        
        zn={'C','D','E','F','G','H','J','K','L','M'};
        ii=strmatch(handles.screenParameters.UTMZone{2},zn,'exact');
        if ~isempty(ii)
            str='S';
        else
            str='N';
        end
        
        lab=['WGS 84 / UTM zone ' num2str(handles.screenParameters.UTMZone{1}) str];
        set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',lab);
        if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
            handles.convertModelData=iconv;
            handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
            handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
            handles.screenParameters.coordinateSystem.name=lab;
            handles.screenParameters.coordinateSystem.type='Cartesian';
            setHandles(handles);
            ddb_changeCoordinateSystem;
            ddb_updateDataInScreen;
            ddb_resetAll;            
        end
    end
end

%%
function menuCoordinateSystemCartesian_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    
    set(hObject,'Checked','on');
    lab=get(hObject,'Label');
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
        ddb_updateDataInScreen;
        ddb_resetAll;        
    end
end

%%
function menuCoordinateSystemOtherGeographic_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.CoordinateSystem.Geographic,'Label');
    %    [cs,ok]=ddb_selectCoordinateSystem(handles.coordinateData.coordSysGeo,cs0);
    [cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',cs0,'type','geographic');
    if ok
        handles.convertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Geographic,'Label',cs,'Checked','on');
        handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=cs;
        handles.screenParameters.coordinateSystem.type='Geographic';
        setHandles(handles);
        ddb_changeCoordinateSystem;
        ddb_updateDataInScreen;
        ddb_resetAll;        
    end
end

%%
function menuCoordinateSystemOtherCartesian_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label');
    %    [cs,ok]=ddb_selectCoordinateSystem(handles.coordinateData.coordSysCart,cs0);
    [cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',cs0,'type','projected');
    if ok
        handles.convertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label',cs,'Checked','on');
        handles.screenParameters.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=cs;
        handles.screenParameters.coordinateSystem.type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
        ddb_updateDataInScreen;
        ddb_resetAll;        
    end
end

%%
function [ok,iconv]=checkOK

% ButtonName = questdlg('Also convert existing model input? Otherwise model input will be discarded!', ...
%     'Convert existing model input', ...
%     'Cancel','No', 'Yes', 'Yes');
%
% switch ButtonName,
%     case 'Cancel',
%         ok=0;
%         iconv=0;
%     case 'No',
%         ok=1;
%         iconv=0;
%     case 'Yes',
%         ok=1;
%         iconv=1;
% end

ButtonName = questdlg('All model and toolbox input will be discarded! Continue?', ...
    'Warning', ...
    'No', 'Yes', 'Yes');

switch ButtonName,
    case 'No',
        ok=0;
        iconv=0;
    case 'Yes',
        ok=1;
        iconv=1;
end

