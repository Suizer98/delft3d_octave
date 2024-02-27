function ddb_updateOutputTimesDelft3DFLOW(varargin)
%ddb_Delft3DFLOW_changeStartStopTimes
%
%   This function updates start and stop times of output, when start or
%   stop time of model is changed. Start and stop times of wind input are
%   also updated.
%   To be used within Delft Dashboard only

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 05 Dec 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ddb_updateOutputTimesDelft3DFLOW.m 10913 2014-07-01 09:53:39Z boer_we $
% $Date: 2014-07-01 17:53:39 +0800 (Tue, 01 Jul 2014) $
% $Author: boer_we $
% $Revision: 10913 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/main/ddb_updateOutputTimesDelft3DFLOW.m $
% $Keywords: $

handles=getHandles;
model=handles.activeModel.name;

nrdomains=length(handles.model.(model).domain);

% Start and stop times of other domains
for id=1:nrdomains
    if id~=ad
        handles.model.(model).domain(id).startTime=handles.model.(model).domain(id).startTime;
        handles.model.(model).domain(id).stopTime=handles.model.(model).domain(ad).stopTime;
    end
end
% Output times for all domains
for id=1:nrdomains
    if isfield(handles.model.(model).domain(id),'mapStartTime')
        handles.model.(model).domain(id).mapStartTime=handles.model.(model).domain(id).startTime;
    end
    if isfield(handles.model.(model).domain(id),'mapStopTime')
        handles.model.(model).domain(id).mapStopTime=handles.model.(model).domain(id).stopTime;
    end
    if isfield(handles.model.(model).domain(id),'comStartTime')
        handles.model.(model).domain(id).comStartTime=handles.model.(model).domain(id).startTime;
    end
    if isfield(handles.model.(model).domain(id),'comStopTime')
        handles.model.(model).domain(id).comStopTime=handles.model.(model).domain(id).stopTime;
    end
    if isfield(handles.model.(model).domain(id),'windTimeSeriesSpeed')
        if length(handles.model.(model).domain(id).windTimeSeriesSpeed)==2
            if handles.model.(model).domain(id).windTimeSeriesSpeed(1)==handles.model.(model).domain(id).windTimeSeriesSpeed(2) && ...
                handles.model.(model).domain(id).windTimeSeriesDirection(1)==handles.model.(model).domain(id).windTimeSeriesDirection(2)
                handles.model.(model).domain(id).windTimeSeriesT(1)=handles.model.(model).domain(id).startTime;
                handles.model.(model).domain(id).windTimeSeriesT(2)=handles.model.(model).domain(id).stopTime;
            end
        end        
    end
end
setHandles(handles);

