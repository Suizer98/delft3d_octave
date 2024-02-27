function ddb_Delft3DFLOW_addTideStations
%DDB_DELFT3DFLOW_ADDTIDESTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_addTideStations
%
%   Input:

%
%
%
%
%   Example
%   ddb_Delft3DFLOW_addTideStations
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

% $Id: ddb_Delft3DFLOW_addTideStations.m 15814 2019-10-04 06:15:57Z ormondt $
% $Date: 2019-10-04 14:15:57 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15814 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/toolbox/TideStations/ddb_Delft3DFLOW_addTideStations.m $
% $Keywords: $

%%
handles=getHandles;

posx=[];

iac=handles.toolbox.tidestations.activeDatabase;

% % In gehackt op 30-Oct-15
% load 'p:\1201428-delftdashboard\Validation\noordzee\Observations\Total.mat'
% for ii = 1:length(waterlevels_obs)
%     xloc(ii) = waterlevels_obs(ii).lon;
%     yloc(ii) = waterlevels_obs(ii).lat;
%     name{:,ii} = waterlevels_obs(ii).stationname;
% end
% handles.toolbox.tidestations.database(iac).stationShortNames    = name;
% handles.toolbox.tidestations.database(iac).stationList          = name;
% handles.toolbox.tidestations.database(iac).xLocLocal            = xloc;
% handles.toolbox.tidestations.database(iac).yLocLocal            = yloc;
% handles.toolbox.tidestations.database(iac).xLoc                 = xloc;
% handles.toolbox.tidestations.database(iac).yLoc                 = yloc;
% handles.toolbox.tidestations.database(iac).idCodes = [];
% for ii = 1:length(xloc);
%     handles.toolbox.tidestations.database(iac).idCodes{ii} = num2str(ii);
% end
% % Uitgehackt

names=handles.toolbox.tidestations.database(iac).stationShortNames;

xg=handles.model.delft3dflow.domain(ad).gridX;
yg=handles.model.delft3dflow.domain(ad).gridY;

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(handles.toolbox.tidestations.database(iac).xLoc);
n=0;

x=handles.toolbox.tidestations.database(iac).xLocLocal;
y=handles.toolbox.tidestations.database(iac).yLocLocal;

% First find points within grid bounding box
for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
            y(i)>ymin && y(i)<ymax
        n=n+1;
        posx(n)=x(i);
        posy(n)=y(i);
        name{n}=names{i};
        istat(n)=i;

        xml.station(n).station.id=handles.toolbox.tidestations.database(iac).idCodes{i};
        xml.station(n).station.longname=handles.toolbox.tidestations.database(iac).stationList{i};
        xml.station(n).station.lon=handles.toolbox.tidestations.database(iac).x(i);
        xml.station(n).station.lat=handles.toolbox.tidestations.database(iac).y(i);
        xml.station(n).station.database=handles.toolbox.tidestations.database(iac).longName;
    
    end
end

% if n>0
%     struct2xml('stations.xml',xml,'structuretype','short');
% end

% Find stations within grid
nrp=0;
if ~isempty(posx)
    [m,n]=findgridcell(posx,posy,xg,yg);
    [m,n]=CheckDepth(m,n,handles.model.delft3dflow.domain(ad).depthZ);
    for i=1:length(m)
        if m(i)>0
            nrp=nrp+1;
            istation(nrp)=istat(i);
            mm(nrp)=m(i);
            nn(nrp)=n(i);
            posx_ori(nrp)=posx(i);
            posy_ori(nrp)=posy(i);
            posx2(nrp)=handles.model.delft3dflow.domain(ad).gridXZ(m(i),n(i));
            posy2(nrp)=handles.model.delft3dflow.domain(ad).gridYZ(m(i),n(i));
        end
    end
end

for i=1:nrp
    
    k=istation(i);
        
    if handles.toolbox.tidestations.showstationnames
        name=handles.toolbox.tidestations.database(iac).stationShortNames{k};
    else
        name=handles.toolbox.tidestations.database(iac).idCodes{k};
    end
        
    nobs=handles.model.delft3dflow.domain(ad).nrObservationPoints;
    Names{1}='';
    for n=1:nobs
        Names{n}=handles.model.delft3dflow.domain(ad).observationPoints(n).name;
    end
    
    if isempty(strmatch(name,Names,'exact'))
        nobs=nobs+1;
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).M=mm(i);
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).N=nn(i);
%         handles.model.delft3dflow.domain(ad).observationPoints(nobs).xori=posx_ori(i);
%         handles.model.delft3dflow.domain(ad).observationPoints(nobs).yori=posy_ori(i);
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).x=posx2(i);
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).y=posy2(i);
        lname=length(name);
        shortName=name(1:min(lname,20));
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).name=name;
        handles.model.delft3dflow.domain(ad).observationPointNames{nobs}=name;
        Names{nobs}=name;
        
        % Add some extra information for CoSMoS toolbox
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).longname=handles.toolbox.tidestations.database(iac).stationList{k};
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).type='tidegauge';
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).source=handles.toolbox.tidestations.database(iac).shortName;
        handles.model.delft3dflow.domain(ad).observationPoints(nobs).id=handles.toolbox.tidestations.database(iac).idCodes{k};
        
    end
    
    handles.model.delft3dflow.domain(ad).nrObservationPoints=nobs;
    
end

if nrp>0
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);
end

setHandles(handles);


