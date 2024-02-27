function ddb_setModelSettings(varargin)
%ddb_readConfigXML  Reads model versions, default coordinate system etc.

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

% $Id: ddb_setProxySettings.m 8254 2013-03-01 13:55:47Z ormondt $
% $Date: 2013-03-01 14:55:47 +0100 (Fri, 01 Mar 2013) $
% $Author: ormondt $
% $Revision: 8254 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_setProxySettings.m $
% $Keywords: $

%%
handles=getHandles;

switch varargin{1}
            
    case{'initialize'}
        
        % Initialization
        
        % Set defaults
        models=fieldnames(handles.model);
        for imdl=1:length(models)
            model=models{imdl};
            
            handles.model.(model).versionlist = {'N/A'};
            handles.model.(model).version = 'N/A';
            handles.model.(model).exedir='d:\unknownfolder\';
            
            switch lower(model)
                case{'delft3dflow'}
                    
                    % Version list (used in GUI)
                    handles.model.(model).versionlist = {'5.00.xx','6.00.xx','N/A'};
                    
                    % Set default
                    handles.model.(model).version='6.00.xx';
                    
                    % Delft3D-FLOW
                    if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin\d_hydro.exe'],'file')
                        handles.model.(model).version='6.00.xx';
                        handles.model.(model).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin'];
                    elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
                        handles.model.(model).version='5.00.xx';
                        handles.model.(model).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin'];
                    end
                    
                case{'delft3dwave'}
                    if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe'],'file')
                        handles.model.(model).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin'];
                        handles.model.(model).swandir=[getenv('D3D_HOME') '\' getenv('ARCH') '\swan'];
                    end
                    
                    
                case{'xbeach'}
                    if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe'],'file')
                        handles.model.(model).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin'];
                        handles.model.(model).swandir=[getenv('D3D_HOME') '\' getenv('ARCH') '\swan'];
                    end

%                 case{'ww3'}
%                     handles.model.(model).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\'];
                    
            end
        end
        
        % And now read the config file
        xmldir=handles.xmlConfigDir;
        xmlfile=handles.xml_config_file;
        filename=[xmldir xmlfile];
        
        models=fieldnames(handles.model);
        
        if exist(filename,'file')
            
            % Read xml file
            xml=xml2struct(filename);
            
            % Set model versions
            for ii=1:length(xml.model)
                imdl=strmatch(lower(xml.model(ii).model.name),models,'exact');
                if ~isempty(imdl)
                    model=lower(xml.model(ii).model.name);
                    % Version
                    handles.model.(model).version=xml.model(ii).model.version;
                    if isempty(handles.model.(model).version)
                        handles.model.(model).version='N/A';
                    end
                    % Exe dir
                    handles.model.(model).exedir=xml.model(ii).model.exedir;
                    handles.model.(model).swandir=[];
                    if isfield(xml.model(ii).model,'swandir')
                        handles.model.(model).swandir=xml.model(ii).model.swandir;
                    end
                    if isempty(handles.model.(model).exedir)
                        handles.model.(model).version='d:\unknownfolder\';
                    end
                end
            end
            
        else
            
            % File does not yet exist, save xml file
            for ii=1:length(models)
                xml.model(ii).model.name=models{ii};
                xml.model(ii).model.version=handles.model.(models{ii}).version;
                xml.model(ii).model.exedir=handles.model.(models{ii}).exedir;
            end
            struct2xml(filename,xml,'structuretype','short');
            
        end

    case{'selectversion'}
        
        % Changing model settings from menu
        
        % Open GUI
        xmldir=[handles.settingsDir 'xml' filesep];
        xmlfile='delftdashboard.modelversion.xml';
        ddb_zoomOff;
        model=handles.activeModel.name;
        h.versionlist=handles.model.(model).versionlist;
        h.version=handles.model.(model).version;
        h.exedir=handles.model.(model).exedir;
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
        
        if ok
            handles.model.(model).version=h.version;
            handles.model.(model).exedir=h.exedir;
            % Things have changed, so save xml file
            xmldir=handles.xmlConfigDir;
            xmlfile='delftdashboard.xml';
            filename=[xmldir xmlfile];
            xml=xml2struct(filename);
            for ii=1:length(xml.model)
                if strcmpi(xml.model(ii).model.name,handles.model.(model).name)
                    xml.model(ii).model.name=handles.model.(model).name;
                    xml.model(ii).model.version=h.version;
                    xml.model(ii).model.exedir=h.exedir;
                    struct2xml(filename,xml,'structuretype','short');
                    break
                end
            end
        end        
end

setHandles(handles);
