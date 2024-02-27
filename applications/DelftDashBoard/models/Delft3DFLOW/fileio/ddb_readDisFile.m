function handles = ddb_readDisFile(handles, id)
%DDB_READDISFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readDisFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readDisFile
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
Flow=handles.model.delft3dflow.domain(id);

fname=Flow.disFile;

%Info=ddb_bct_io('read',fname);
Info=bct_io('read',fname);

for n=1:Flow.nrDischarges
    
    nt=FindTable(Info,Flow.discharges(n).name);
    tab=Info.Table(nt);
    itd=tab.ReferenceTime;
    itd=datenum(num2str(itd),'yyyymmdd');
    t=itd+tab.Data(:,1)/1440;
    
    Flow.discharges(n).timeSeriesT=t;
    Flow.discharges(n).timeSeriesQ=zeros(size(t));
    Flow.discharges(n).timeSeriesM=zeros(size(t));
    Flow.discharges(n).timeSeriesD=zeros(size(t));
    Flow.discharges(n).salinity.timeSeries=zeros(size(t));
    Flow.discharges(n).temperature.timeSeries=zeros(size(t));
    
    for k=1:Flow.nrSediments
        Flow.discharges(n).sediment(k).timeSeries=zeros(size(t));
    end
    for k=1:Flow.nrTracers
        Flow.discharges(n).tracer(k).timeSeries=zeros(size(t));
    end
    
    Flow.discharges(n).timeSeriesQ=tab.Data(:,2);
    
    if Flow.salinity.include
        np=findParameter(Info,nt,'Salinity');
        if np>0
            Flow.discharges(n).salinity.timeSeries=tab.Data(:,np);
        end
    end
    if Flow.temperature.include
        np=findParameter(Info,nt,'Temperature');
        if np>0
            Flow.discharges(n).temperature.timeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.nrSediments
        Flow.discharges(n).sediment(k).timeSeries=zeros(size(t));
        np=findParameter(Info,nt,Flow.sediment(k).name);
        if np>0
            Flow.discharges(n).sediment(k).timeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.nrTracers
        Flow.discharges(n).tracer(k).timeSeries=zeros(size(t));
        np=findParameter(Info,nt,Flow.tracer(k).name);
        if np>0
            Flow.discharges(n).tracer(k).timeSeries=tab.Data(:,np);
        end
    end
    if strcmpi(Flow.discharges(n).type,'momentum')
        np=findParameter(Info,nt,'flow magnitude');
        if np>0
            Flow.discharges(n).timeSeriesM=tab.Data(:,np);
        end
        np=findParameter(Info,nt,'flow direction');
        if np>0
            Flow.discharges(n).timeSeriesD=tab.Data(:,np);
        end
    end
end

handles.model.delft3dflow.domain(id)=Flow;

%%
function nt=FindTable(Info,bndname)

nt=0;
for i=1:Info.NTables
    if strcmpi(deblank(Info.Table(i).Location),bndname)
        nt=i;
    end
end

%%
function np=findParameter(Info,nt,name)
np=0;
tab=Info.Table(nt);
npar=length(tab.Parameter);
for i=1:npar
    if strcmpi(name,tab.Parameter(i).Name)
        np=i;
    end
end

