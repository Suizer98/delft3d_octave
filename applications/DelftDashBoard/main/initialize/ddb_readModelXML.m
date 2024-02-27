function handles = ddb_readModelXML(handles, name)
%DDB_READMODELXML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readModelXML(handles, j)
%
%   Input:
%   handles =
%   j       =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readModelXML
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

% $Id: ddb_readModelXML.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_readModelXML.m $
% $Keywords: $

%%
fname=['model.' name '.xml'];

xmldir= handles.model.(name).xmlDir;

if exist([xmldir fname],'file')
    
    handles.model.(name).useXML=1;
    
    xml=gui_readXMLfile(fname,xmldir);
    
    handles.model.(name).longName=xml.longname;    
    handles.model.(name).supportsMultipleDomains=xml.multipledomains;    
    handles.model.(name).enable=xml.enable;
    handles.model.(name).element=xml.element;
    
end

handles.model.(name).GUI.element=xml.element;

%% Menu File
if isfield(xml.menu.menu,'menuopenfile')
    for i=1:length(xml.menu.menu.menuopenfile.menuopenfile.menuitem)
        handles.model.(name).GUI.menu.openFile(i).string=xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.string;
        handles.model.(name).GUI.menu.openFile(i).callback=str2func(xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.callback);
        handles.model.(name).GUI.menu.openFile(i).option=xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.option;
    end
else
    handles.model.(name).GUI.menu.openFile=[];
end

if isfield(xml.menu.menu,'menusavefile')
    for i=1:length(xml.menu.menu.menusavefile.menusavefile.menuitem)
        handles.model.(name).GUI.menu.saveFile(i).string=xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.string;
        handles.model.(name).GUI.menu.saveFile(i).callback=str2func(xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.callback);
        handles.model.(name).GUI.menu.saveFile(i).option=xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.option;
    end
else
    handles.model.(name).GUI.menu.saveFile=[];
end

%% Menu View
handles.model.(name).GUI.menu.view=[];
if isfield(xml.menu.menu,'menuview')
    if ~isempty(xml.menu.menu.menuview)
        for i=1:length(xml.menu.menu.menuview.menuview.attribute)
            handles.model.(name).GUI.menu.view(i).string   = xml.menu.menu.menuview.menuview.attribute(i).attribute.string;
            handles.model.(name).GUI.menu.view(i).callback = str2func(xml.menu.menu.menuview.menuview.attribute(i).attribute.callback);
            handles.model.(name).GUI.menu.view(i).option   = xml.menu.menu.menuview.menuview.attribute(i).attribute.option;
        end
    end
end


