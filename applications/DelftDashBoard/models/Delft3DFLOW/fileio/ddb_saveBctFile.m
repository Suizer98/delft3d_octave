function ddb_saveBctFile(handles, id)
%DDB_SAVEBCTFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveBctFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveBctFile
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
fname=handles.model.delft3dflow.domain(id).bctFile;

nr=handles.model.delft3dflow.domain(id).nrOpenBoundaries;
kmax=handles.model.delft3dflow.domain(id).KMax;

Info.Check='OK';
Info.FileName=fname;

iok=1;
k=0;
for n=1:nr
    quant2=[];
    unit2=[];
    if handles.model.delft3dflow.domain(id).openBoundaries(n).forcing=='T'
        k=k+1;
        Info.NTables=k;
        Info.Table(k).Name=['Boundary Section : ' num2str(n)];
        Info.Table(k).Contents=lower(handles.model.delft3dflow.domain(id).openBoundaries(n).profile);
        Info.Table(k).Location=handles.model.delft3dflow.domain(id).openBoundaries(n).name;
        Info.Table(k).TimeFunction='non-equidistant';
        itd=str2double(datestr(handles.model.delft3dflow.domain(id).itDate,'yyyymmdd'));
        Info.Table(k).ReferenceTime=itd;
        Info.Table(k).TimeUnit='minutes';
        Info.Table(k).Interpolation='linear';
        Info.Table(k).Parameter(1).Name='time';
        Info.Table(k).Parameter(1).Unit='[min]';
        switch handles.model.delft3dflow.domain(id).openBoundaries(n).type,
            case{'Z'}
                quant='Water elevation (Z)  ';
                unit='[m]';
            case{'C'}
                quant='Current         (C)  ';
                unit='[m/s]';
            case{'N'}
                quant='Neumann         (N)  ';
                unit='[-]';
            case{'T'}
                quant='Total discharge (T)  ';
                unit='[m3/s]';
            case{'Q'}
                quant='Flux/discharge  (Q)  ';
                unit='[m3/s]';
            case{'R'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
            case{'X'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
            case{'P'}
                quant='Current         (C)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
        end
        t=(handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesT-handles.model.delft3dflow.domain(id).itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).profile)
            case{'uniform','logarithmic'}
                Info.Table(k).Parameter(2).Name=[quant 'End A uniform'];
                Info.Table(k).Parameter(2).Unit=unit;
                Info.Table(k).Parameter(3).Name=[quant 'End B uniform'];
                Info.Table(k).Parameter(3).Unit=unit;
                Info.Table(k).Data(:,2)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesA;
                Info.Table(k).Data(:,3)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesB;
                if ~isempty(quant2)
                    Info.Table(k).Parameter(4).Name=[quant2 'End A layer uniform'];
                    Info.Table(k).Parameter(4).Unit=unit2;
                    Info.Table(k).Parameter(5).Name=[quant2 'End B layer uniform'];
                    Info.Table(k).Parameter(5).Unit=unit2;
                    Info.Table(k).Data(:,4)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesAV;
                    Info.Table(k).Data(:,5)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesBV;
                end
            case{'3d-profile'}
                j=1;
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Parameter(j).Name=[quant 'End A layer: ' num2str(kk)];
                    Info.Table(k).Parameter(j).Unit=unit;
                end
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Parameter(j).Name=[quant 'End B layer: ' num2str(kk)];
                    Info.Table(k).Parameter(j).Unit=unit;
                end
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End A layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End B layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                end
                j=1;
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesA(:,kk);
                end
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesB(:,kk);
                end
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Data(:,j)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesAV(:,kk);
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Data(:,j)=handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesBV(:,kk);
                    end
                end
        end
        
        % Check times
        if handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesT(1)>handles.model.delft3dflow.domain(id).startTime
            iok=0;
        end
        if handles.model.delft3dflow.domain(id).openBoundaries(n).timeSeriesT(end)<handles.model.delft3dflow.domain(id).stopTime
            iok=0;
        end
        
    end
end
ddb_bct_io('write',fname,Info);

% Give warning if time series do not match simulation time
if ~iok
    ddb_giveWarning('text','Time series in bct file do not cover entire simulation period!');
end


