function ddb_getToolboxData(handles, localdir, name, varargin)
%DDB_GETTOOLBOXDATA  Download toolbox related files (data, exe, mat) from
%   OpenDAP server
%
%   Syntax:
%   ddb_getToolboxData(localdir, a)
%
%   Input:
%   localdir = directory on local pc to which the file must be copied
%   a        = toolbox index
%
%
%
%
%   Example
%   ddb_getToolboxData('D:\Dashboard_data\',1)
%
%   See also ddb_getXmlData

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Wiebe de Boer
%
%       Wiebe.deBoer@deltares.nl
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
% Created: 13 Jan 2012
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_getToolboxData.m 17404 2021-07-13 13:22:30Z ormondt $
% $Date: 2021-07-13 21:22:30 +0800 (Tue, 13 Jul 2021) $
% $Author: ormondt $
% $Revision: 17404 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/data/ddb_getToolboxData.m $
% $Keywords: $

%%

% Try to download data from server

try

    servername=name;

    if ~isempty(varargin)
        servername=varargin{1};
    end
    
    url = ['https://opendap.deltares.nl/static/deltares/delftdashboard/toolboxes/' servername '/' servername '.xml'];
    xmlfile = [name '.xml'];
    toolboxdata = ddb_getXmlData(localdir,url,xmlfile);
    
    switch lower(name)
        case{'observationstations'}
            % Very (!) dirty work around for now
            vrsn=str2double(handles.delftDashBoardVersion(end-3:end));
            if vrsn>=7213
%                urlwrite(['http://opendap.deltares.nl/static/deltares/delftdashboard/toolboxes/' servername '/ObservationStations.new.xml'],[localdir 'ObservationStations.xml']);
%                urlwrite(['http://opendap.deltares.nl/static/deltares/delftdashboard/toolboxes/' servername '/ndbc.new.mat'],[localdir 'ndbc.mat']);
            end
    end

    if ~isempty(toolboxdata)
        if isfield(toolboxdata,'file')
            % Copy files from server
            for ii=1:length(toolboxdata.file)
                if  toolboxdata.file(ii).update == 1 || ~exist([handles.toolbox.(name).dataDir filesep toolboxdata.file(ii).name],'file')
                    ddb_urlwrite(toolboxdata.file(ii).URL,[handles.toolbox.(name).dataDir filesep toolboxdata.file(ii).name]);
                end
            end
        end
    end
catch
    disp(['Could not retrieve data from server for ' name ' toolbox']);
end
