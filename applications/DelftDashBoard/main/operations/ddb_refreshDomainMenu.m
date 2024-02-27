function ddb_refreshDomainMenu
%DDB_REFRESHDOMAINMENU  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_refreshDomainMenu
%
%   Input:

%
%
%
%
%   Example
%   ddb_refreshDomainMenu
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

% $Id: ddb_refreshDomainMenu.m 17360 2021-06-22 11:52:16Z ormondt $
% $Date: 2021-06-22 19:52:16 +0800 (Tue, 22 Jun 2021) $
% $Author: ormondt $
% $Revision: 17360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_refreshDomainMenu.m $
% $Keywords: $

%%
handles=getHandles;

h=findobj(gcf,'Tag','menuDomain');

if ~isempty(h)
    
    hc=get(h,'Children');
    delete(hc);
    
    model=handles.activeModel.name;
    
    for i=1:handles.model.(model).nrDomains
        str{i}=handles.model.(model).domain(i).runid;
        ui=uimenu(h,'Label',str{i},'Callback',{@selectDomain,i},'Checked','off','UserData',i);
        if i==ad
            set(ui,'Checked','on');
        end
    end
    uimenu(h,'Label','Add Domain','Callback',{@selectDomain,0},'Checked','off','UserData',0,'separator','on');
    uimenu(h,'Label','Delete Domain','Callback',@deleteDomain,'Checked','off','UserData',0);
    
end

%%
function selectDomain(hObject, eventdata, nr)
ddb_zoomOff;
handles=getHandles;
model=handles.activeModel.name;
if nr>0
    switch model
        case{'delft3dflow'}
        case{'sfincs'}
            cd(handles.model.(model).domain(nr).directory);
    end
    changeDomain(nr);
else
    switch model
        case{'delft3dflow'}
            str=GetUIString('Enter Runid New Domain');
            if ~isempty(str)
                id=handles.model.(model).nrDomains+1;
                handles.model.(model).nrDomains=id;
                handles.activeDomain=id;
                handles.model.(model).domain(id).runid=str;
                handles=ddb_initializeFlowDomain(handles,'all',id,handles.model.(model).domain(id).runid);
                setHandles(handles);
                ddb_refreshDomainMenu;
                changeDomain(id);
            end
        case{'sfincs'}
            dirname = uigetdir('','Select folder for new SFINCS domain');
            id=handles.model.(model).nrDomains+1;
            handles.model.(model).nrDomains=id;
            handles.activeDomain=id;
            cd(dirname);
            handles = ddb_initialize_sfincs_domain(handles, 'dummy', id, 'dummy');
            setHandles(handles);
            ddb_refreshDomainMenu;
            changeDomain(id);
    end
end

%%
function changeDomain(nr)
ddb_zoomOff;
handles=getHandles;
% Check and uncheck the proper domains in the menu
handles.activeDomain=nr;
setHandles(handles);
h=findobj(gcf,'Tag','menuDomain');
hc=get(h,'Children');
model=handles.activeModel.name;
for i=1:length(hc)
    set(hc(i),'Checked','off');
end

h=findobj(hc,'UserData',nr);
set(h,'Checked','on');

% Update the figure
for i=1:handles.model.(model).nrDomains
    feval(handles.model.(model).plotFcn,'update','active',0,'visible',1,'domain',i);
end

% Select toolbox tab.
%tabpanel('select','tag',handles.model.(model).name,'tabname','toolbox','runcallback',0);
tabpanel('select','handle',handles.model.(model).GUI.element.element.handle,'tabname','toolbox');
%% And now set all elements and execute active tab!


%%
function deleteDomain(hObject, eventdata)
handles=getHandles;
model=handles.activeModel.name;
if handles.model.(model).nrDomains>1
    feval(handles.model.(model).plotFcn,'delete');
    handles.model.(model).domain=removeFromStruc(handles.model.(model).domain,ad);
    handles.model.(model).nrDomains=handles.model.(model).nrDomains-1;
    handles.activeDomain=1;
    handles.model.(model).DDBoundaries=[];
    setHandles(handles);
    feval(handles.model.(model).plotFcn,'plot','active',0,'visible',1,'domain',0);
    ddb_refreshDomainMenu;
end
%% And now set all elements and execute active tab!


