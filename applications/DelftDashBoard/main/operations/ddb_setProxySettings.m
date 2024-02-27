function ddb_setProxySettings(varargin)
%DDB_SETPROXYSETTINGS  Set the proxy settings on initialization or when changed in menu.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_setProxySettings.m 17244 2021-04-30 11:36:03Z ormondt $
% $Date: 2021-04-30 19:36:03 +0800 (Fri, 30 Apr 2021) $
% $Author: ormondt $
% $Revision: 17244 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_setProxySettings.m $
% $Keywords: $

%%
handles=getHandles;

if isempty(varargin)

    % Changing proxy settings from menu

    ddb_zoomOff;
    
    % Open GUI
    xmldir=[handles.settingsDir 'xml' filesep];
    xmlfile='delftdashboard.proxysettings.xml';    
    h=handles.proxysettings;    
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

    if ok
        
        handles.proxysettings=h;
        
        if handles.proxysettings.use
            com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(true);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost(handles.proxysettings.host);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort(handles.proxysettings.port);
        else
            com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(false);
        end

        % Read ddb config xml
        xmldir=handles.xmlConfigDir;
        xmlfile='delftdashboard.xml';
        filename=[xmldir xmlfile];
                
        xml=xml2struct(filename);
        if handles.proxysettings.use
            xml.proxysettings.proxysettings.use='yes';
        else
            xml.proxysettings.proxysettings.use='no';
        end
        xml.proxysettings.proxysettings.host=handles.proxysettings.host;
        xml.proxysettings.proxysettings.port=handles.proxysettings.port;
        
        % Now write ddb xml config file
        struct2xml(filename,xml,'structuretype','short');
                
    end
    
else
    
    % Changing proxy settings on initialization
    handles.proxysettings.use=0;
    handles.proxysettings.host='';
    handles.proxysettings.port='';

    % Read ddb config xml
    xmldir=handles.xmlConfigDir;
    xmlfile=handles.xml_config_file;
    filename=[xmldir xmlfile];

    % File always exists
    xml=xml2struct(filename);

    if isfield(xml,'proxysettings')
        switch lower(xml.proxysettings.proxysettings.use(1))
            case{'1','y','t'}
                handles.proxysettings.use=1;
        end
        handles.proxysettings.host=xml.proxysettings.proxysettings.host;
        handles.proxysettings.port=xml.proxysettings.proxysettings.port;
        % If use proxy
        if handles.proxysettings.use
            com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(true);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost(handles.proxysettings.host);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort(handles.proxysettings.port);
        end
    end
    
end

setHandles(handles);
 