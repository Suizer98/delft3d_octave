function ddb_setSNCSettings(varargin)
%DDB_SETPROXYSETTINGS  Set SNC settings on initialization or when changed in menu.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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

% $Id: ddb_setProxySettings.m 8254 2013-03-01 13:55:47Z ormondt $
% $Date: 2013-03-01 14:55:47 +0100 (Fri, 01 Mar 2013) $
% $Author: ormondt $
% $Revision: 8254 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_setProxySettings.m $
% $Keywords: $

%%
handles=getHandles;

if isempty(varargin)

    % Changing SNC settings from menu

    ddb_zoomOff;
    
    % Where xml GUI files sit
    xmldir=[handles.settingsDir 'xml' filesep];
    xmlfile='delftdashboard.sncsettings.xml';
    
    h=handles.sncsettings;
    
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

    if ok
        
        handles.sncsettings=h;
        
        setpref('SNCTOOLS','USE_JAVA',h.use_java);
        setpref('SNCTOOLS','USE_NETCDF_JAVA',h.use_netcdf_java);
        
        % Read ddb config xml 
        xmldir=handles.xmlConfigDir;
        xmlfile='delftdashboard.xml';
        filename=[xmldir xmlfile];
        xml=xml2struct(filename);
        
        if h.use_java
            xml.sncsettings.sncsettings.use_java='yes';
        else
            xml.sncsettings.sncsettings.use_java='no';
        end
        if h.use_netcdf_java
            xml.sncsettings.sncsettings.use_netcdf_java='yes';
        else
            xml.sncsettings.sncsettings.use_netcdf_java='no';
        end
                    
        % Now write ddb xml config file
        struct2xml(filename,xml,'structuretype','short');
                
    end
    
else
    
    % Changing snc settings on initialization

    % Defaults
    handles.sncsettings.use_java=1;
    handles.sncsettings.use_netcdf_java=1;

    % Read ddb config xml
    xmldir=handles.xmlConfigDir;
    xmlfile=handles.xml_config_file;
    filename=[xmldir xmlfile];

    % File always exists
    xml=xml2struct(filename);
    if isfield(xml,'sncsettings')
        switch lower(xml.sncsettings.sncsettings.use_java(1))
            case{'1','y','t'}
                handles.sncsettings.use_java=1;
            otherwise
                handles.sncsettings.use_java=0;
        end
        switch lower(xml.sncsettings.sncsettings.use_netcdf_java(1))
            case{'1','y','t'}
                handles.sncsettings.use_netcdf_java=1;
            otherwise
                handles.sncsettings.use_netcdf_java=0;
        end
    end

    % And set the values
    setpref('SNCTOOLS','USE_JAVA',handles.sncsettings.use_java);
    setpref('SNCTOOLS','USE_NETCDF_JAVA',handles.sncsettings.use_netcdf_java);
    
end

setHandles(handles);
