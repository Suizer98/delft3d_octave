function delft3dflow_saveBccFile(flow, openBoundaries, fname)
%DELFT3DFLOW_SAVEBCCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   delft3dflow_saveBccFile(flow, openBoundaries, fname)
%
%   Input:
%   flow           =
%   openBoundaries =
%   fname          =
%
%
%
%
%   Example
%   delft3dflow_saveBccFile
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

% $Id: delft3dflow_saveBccFile.m 9249 2013-09-20 12:31:51Z rooijen $
% $Date: 2013-09-20 20:31:51 +0800 (Fri, 20 Sep 2013) $
% $Author: rooijen $
% $Revision: 9249 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/fileio/delft3dflow_saveBccFile.m $
% $Keywords: $

%%
Info.Check='OK';
Info.FileName=fname;

kmax=flow.KMax;

k=0;
for n=1:length(openBoundaries);
    if flow.salinity.include
        k=k+1;
        Info=SetInfo(Info,flow.itDate,openBoundaries(n),openBoundaries(n).salinity,'Salinity','[ppt]',k,n,kmax);
    end
    if flow.temperature.include
        k=k+1;
        Info=SetInfo(Info,flow.itDate,openBoundaries(n),openBoundaries(n).temperature,'Temperature','[C]',k,n,kmax);
    end
    if flow.sediments.include
        for i=1:flow.nrSediments
            k=k+1;
            Info=SetInfo(Info,flow.itDate,openBoundaries(n),openBoundaries(n).sediment(i),flow.sediments.sedimentNames{i},'[kg/m3]',k,n,kmax);
        end
    end
    if flow.tracers
        for i=1:flow.nrTracers
            k=k+1;
            Info=SetInfo(Info,flow.itDate,openBoundaries(n),openBoundaries(n).tracer(i),flow.tracer(i).name,'[kg/m3]',k,n,kmax);
        end
    end
end
ddb_bct_io('write',fname,Info);

function Info=SetInfo(Info,itDate,Bnd,Par,quant,unit,k,nr,kmax)
Info.NTables=k;
Info.Table(k).Name=['Boundary Section : ' num2str(nr)];
Info.Table(k).Contents=lower(Par.profile);
Info.Table(k).Location=Bnd.name;
Info.Table(k).TimeFunction='non-equidistant';
itd=str2double(datestr(itDate,'yyyymmdd'));
Info.Table(k).ReferenceTime=itd;
Info.Table(k).TimeUnit='minutes';
Info.Table(k).Interpolation='linear';
Info.Table(k).Parameter(1).Name='time';
Info.Table(k).Parameter(1).Unit='[min]';
quant=deblank(quant);
quant=[quant repmat(' ',1,21-length(quant))];

switch lower(Par.profile)
    case{'uniform'}
        Info.Table(k).Parameter(2).Name=[quant 'end A uniform'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end B uniform'];
        Info.Table(k).Parameter(3).Unit=unit;
        t=(Par.timeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.timeSeriesA;
        Info.Table(k).Data(:,3)=Par.timeSeriesB;
    case{'step','linear'}
        Info.Table(k).Parameter(2).Name=[quant 'end A surface'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end A bed'];
        Info.Table(k).Parameter(3).Unit=unit;
        Info.Table(k).Parameter(4).Name=[quant 'end B surface'];
        Info.Table(k).Parameter(4).Unit=unit;
        Info.Table(k).Parameter(5).Name=[quant 'end B bed'];
        Info.Table(k).Parameter(5).Unit=unit;
        if strcmpi(deblank(lower(Par.profile)),'step')
            Info.Table(k).Parameter(6).Name='discontinuity';
            Info.Table(k).Parameter(6).Unit='[m]';
        end
        t=(Par.timeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.timeSeriesA(:,1);
        Info.Table(k).Data(:,3)=Par.timeSeriesA(:,2);
        Info.Table(k).Data(:,4)=Par.timeSeriesB(:,1);
        Info.Table(k).Data(:,5)=Par.timeSeriesB(:,2);
        if strcmpi(deblank(lower(Par.profile)),'step')
            dis=zeros(Par.nrTimeSeries,1)+Par.discontinuity;
            Info.Table(k).Data(:,6)=dis;
        end
    case{'3d-profile'}
        j=1;
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Parameter(j).Name=[quant 'end A layer ' num2str(kk)];
            Info.Table(k).Parameter(j).Unit=unit;
        end
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Parameter(j).Name=[quant 'end B layer ' num2str(kk)];
            Info.Table(k).Parameter(j).Unit=unit;
        end
        t=(Par.timeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        j=1;
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.timeSeriesA(:,kk);
        end
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.timeSeriesB(:,kk);
        end
end

