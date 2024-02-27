function handles = ddb_initializeTideDatabase(handles, varargin)
%DDB_INITIALIZETIDEDATABASE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTideDatabase(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTideDatabase
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

% $Id: ddb_initializeTideDatabase.m 16797 2020-11-11 18:17:16Z ormondt $
% $Date: 2020-11-12 02:17:16 +0800 (Thu, 12 Nov 2020) $
% $Author: ormondt $
% $Revision: 16797 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideDatabase/ddb_initializeTideDatabase.m $
% $Keywords: $

%%

handles.toolbox.tidedatabase.activeModel=1;
handles.toolbox.tidedatabase.xLim(1)=0;
handles.toolbox.tidedatabase.yLim(1)=0;
handles.toolbox.tidedatabase.xLim(2)=0;
handles.toolbox.tidedatabase.yLim(2)=0;

handles.toolbox.tidedatabase.point_x=0;
handles.toolbox.tidedatabase.point_y=0;

handles.toolbox.tidedatabase.exportFormats={'tek','mat'};
handles.toolbox.tidedatabase.exportFormatExtensions={'*.tek','*.mat'};
handles.toolbox.tidedatabase.exportFormatNames={'Tekal file','Mat file'};

handles.toolbox.tidedatabase.activeExportFormatIndex=1;
handles.toolbox.tidedatabase.activeExportFormat=handles.toolbox.tidedatabase.exportFormats{1};
handles.toolbox.tidedatabase.activeExportFormatExtension=handles.toolbox.tidedatabase.exportFormatExtensions{1};

handles.toolbox.tidedatabase.tideDatabaseBoxHandle=[];
handles.toolbox.tidedatabase.fourierFile='';
handles.toolbox.tidedatabase.fourierOutFile='';
handles.toolbox.tidedatabase.exportFile='';

handles.toolbox.tidedatabase.constituentList={''};
handles.toolbox.tidedatabase.activeConstituent=1;

%% Get list
ii=handles.toolbox.tidedatabase.activeModel;
name=handles.tideModels.model(ii).name;
if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
    tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end
cnst=nc_varget(tidefile,'tidal_constituents');
for ii=1:length(cnst)
    cnstlist{ii}=deblank(upper(cnst(ii,:)));
end
handles.toolbox.tidedatabase.constituentList=cnstlist;
handles.toolbox.tidedatabase.activeConstituent=1;

setHandles(handles);