function handles = ddb_DFlowFM_readObsFile(handles, id)
%ddb_DFlowFM_readObsFile  One line description goes here.

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

% $Id: ddb_DFlowFM_readObsFile.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_readObsFile.m $
% $Keywords: $

%% Get values
filename    = handles.model.dflowfm.domain(id).obsfile;
fileID      = fopen(filename,'r');
%dataArray   = textscan(fileID, '%f%f%q%[^\n\r]', 'Delimiter', ' "''', 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
dataArray   = textscan(fileID, '%f%f%q%[^\n\r]', 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
fclose(fileID);
x           = dataArray{:, 1};
y           = dataArray{:, 2};
name        = dataArray{:, 3};

%         while 1
%             tx0=fgets(fid);
%             if and(ischar(tx0), size(tx0>0))
%                 v0=strread(tx0,'%q');

% for ip=1:length(x)
%     name{ip}=name{ip}(2:end-1); % Get rid of quotes
% end

% Place values in handles
handles.model.dflowfm.domain(id).observationpoints=[];
handles.model.dflowfm.domain(id).observationpointnames={''};

for ip=1:length(x)
    handles.model.dflowfm.domain(id).observationpoints(ip).name=name{ip};
    handles.model.dflowfm.domain(id).observationpoints(ip).x=x(ip);
    handles.model.dflowfm.domain(id).observationpoints(ip).y=y(ip);
    handles.model.dflowfm.domain(id).observationpointnames{ip}=handles.model.dflowfm.domain(id).observationpoints(ip).name;
end

handles.model.dflowfm.domain(id).activeobservationpoint=1;
handles.model.dflowfm.domain(id).nrobservationpoints=length(x);

