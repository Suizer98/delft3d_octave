function ddb_selectModelVersion(opt)
%ddb_selectModelVersion - GUI script to select model version.

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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

xmldir=[handles.settingsDir 'xml' filesep];
xmlfile='delftdashboard.modelversion.xml';

switch lower(opt)
    case{'selectversion'}
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
                if strcmpi(xml.model(ii).model.name,model)
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

