function handles = ddb_readShorelines(handles)
%DDB_READSHORELINES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readShorelines(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readShorelines
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

% $Id: ddb_readShorelines.m 16775 2020-11-09 08:37:14Z leijnse $
% $Date: 2020-11-09 16:37:14 +0800 (Mon, 09 Nov 2020) $
% $Author: leijnse $
% $Revision: 16775 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_readShorelines.m $
% $Keywords: $

%% When enabled on OpenDAP
% Check for updates on OpenDAP and add data to structure
localdir = handles.shorelineDir;
url = 'https://opendap.deltares.nl/static/deltares/delftdashboard/shorelines/shorelines.xml';
xmlfile = 'shorelines.xml';
handles.shorelines = ddb_getXmlData(localdir,url,xmlfile);

% Add specific fields to structure
fld = fieldnames(handles.shorelines);
names = '';longNames = '';
for ii=1:length(handles.shorelines.(fld{1}))
    handles.shorelines.(fld{1})(ii).useCache = str2double(handles.shorelines.(fld{1})(ii).useCache);
    names{ii}= handles.shorelines.(fld{1})(ii).name;
    longNames{ii} = handles.shorelines.(fld{1})(ii).longName;
end
handles.shorelines.longName = longNames;
handles.shorelines.names = names;
handles.shorelines.nrShorelines = length(handles.shorelines.(fld{1}));

%% For the time being...
% if exist([handles.shorelineDir filesep 'Shorelines.def'])==2
%     txt=ReadTextFile([handles.shorelineDir filesep 'Shorelines.def']);
% else
%     error(['Shorelines defintion file ''' [handles.shorelineDir filesep 'Shorelines.def'] ''' not found!']);
% end
% 
% k=0;
% 
% for i=1:length(txt)
%     switch lower(txt{i})
%         case{'shoreline'}
%             k=k+1;
%             handles.shorelines.longName{k}=txt{i+1};
%             handles.shorelines.nrShorelines=k;
%             handles.shorelines.shoreline(k).longName=txt{i+1};
%             handles.shorelines.shoreline(k).useCache=1;
%         case{'name'}
%             handles.shorelines.shoreline(k).name=txt{i+1};
%             handles.shorelines.name{k}=txt{i+1};
%         case{'type'}
%             handles.shorelines.shoreline(k).type=txt{i+1};
%         case{'url'}
%             handles.shorelines.shoreline(k).URL=txt{i+1};
%         case{'usecache'}
%             if strcmpi(txt{i+1}(1),'y')
%                 handles.shorelines.shoreline(k).useCache=1;
%             else
%                 handles.shorelines.shoreline(k).useCache=0;
%             end
%     end
% end
