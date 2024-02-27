function handles = ddb_readBccFile(handles, id)
%DDB_READBCCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readBccFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readBccFile
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

kmax=Flow.KMax;

fname=Flow.bccFile;

Info=ddb_bct_io('read',fname);

for nb=1:Flow.nrOpenBoundaries
    if Flow.salinity.include
        nt=FindTable(Info,Flow.openBoundaries(nb).name,'salinity');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.openBoundaries(nb).salinity.timeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).salinity.profile='Uniform';
                case{'step'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).salinity.discontinuity=tab.Data(:,4);
                    Flow.openBoundaries(nb).salinity.profile='Step';
                case{'3d-profile'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.openBoundaries(nb).salinity.profile='3d-profile';
            end
        else
            t=[Flow.startTime;Flow.stopTime];
            Flow.openBoundaries(nb).salinity.timeSeriesT=t;
            Flow.openBoundaries(nb).salinity.timeSeriesA=[0;0];
            Flow.openBoundaries(nb).salinity.timeSeriesB=[0;0];
            Flow.openBoundaries(nb).salinity.profile='Uniform';
        end
    end
    if Flow.temperature.include
        nt=FindTable(Info,Flow.openBoundaries(nb).name,'temperature');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.openBoundaries(nb).temperature.timeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).temperature.profile='Uniform';
                case{'step'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).temperature.discontinuity=tab.Data(:,4);
                    Flow.openBoundaries(nb).temperature.profile='Step';
                case{'3d-profile'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.openBoundaries(nb).temperature.profile='3d-profile';
            end
        else
            t=[Flow.startTime;Flow.stopTime];
            Flow.openBoundaries(nb).temperature.timeSeriesT=t;
            Flow.openBoundaries(nb).temperature.timeSeriesA=[0;0];
            Flow.openBoundaries(nb).temperature.timeSeriesB=[0;0];
            Flow.openBoundaries(nb).temperature.profile='Uniform';
        end
    end
    if Flow.sediments.include
        for j=1:Flow.nrSediments
            nt=FindTable(Info,Flow.openBoundaries(nb).name,Flow.sediment(j).name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.openBoundaries(nb).sediment(j).timeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).sediment(j).profile='Uniform';
                    case{'step'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).sediment(j).discontinuity=tab.Data(:,4);
                        Flow.openBoundaries(nb).sediment(j).profile='Step';
                    case{'3d-profile'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.openBoundaries(nb).sediment(j).profile='3d-profile';
                end
            else
                t=[Flow.startTime;Flow.stopTime];
                Flow.openBoundaries(nb).sediment(j).timeSeriesT=t;
                Flow.openBoundaries(nb).sediment(j).timeSeriesA=[0;0];
                Flow.openBoundaries(nb).sediment(j).timeSeriesB=[0;0];
                Flow.openBoundaries(nb).sediment(j).Profile='Uniform';
            end
        end
    end
    if Flow.tracers
        for j=1:Flow.nrTracers
            nt=FindTable(Info,Flow.openBoundaries(nb).name,Flow.tracer(j).name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.openBoundaries(nb).tracer(j).timeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).tracer(j).profile='Uniform';
                    case{'step'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).tracer(j).discontinuity=tab.Data(:,4);
                        Flow.openBoundaries(nb).tracer(j).profile='Step';
                    case{'3d-profile'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.openBoundaries(nb).tracer(j).profile='3d-profile';
                end
            else
                t=[Flow.startTime;Flow.stopTime];
                Flow.openBoundaries(nb).tracer(j).timeSeriesT=t;
                Flow.openBoundaries(nb).tracer(j).timeSeriesA=[0;0];
                Flow.openBoundaries(nb).tracer(j).timeSeriesB=[0;0];
                Flow.openBoundaries(nb).tracer(j).profile='Uniform';
            end
            
        end
    end
end
handles.model.delft3dflow.domain(id)=Flow;


function nt=FindTable(Info,bndname,par)

ifound=0;
nt=0;
for i=1:Info.NTables
    if strcmpi(deblank(Info.Table(i).Location),bndname)
        tab=Info.Table(i);
        p=tab.Parameter(2).Name;
        lstr=length(par);
        if length(p)>=lstr
            if strcmpi(p(1:lstr),par)
                nt=i;
                ifound=1;
            end
        end
    end
end
% if ifound==0
%     ddb_giveWarning('text',['Error reading bcc file for boundary ' bndname ' parameter: ' par]);
% end


