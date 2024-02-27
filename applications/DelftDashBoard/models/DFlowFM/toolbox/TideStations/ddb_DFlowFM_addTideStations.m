function ddb_DFlowFM_addTideStations
%ddb_DFlowFM_addTideStations  One line description goes here.

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

% $Id: ddb_DFlowFM_addTideStations.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/toolbox/TideStations/ddb_DFlowFM_addTideStations.m $
% $Keywords: $

%%
handles=getHandles;

posx=[];

iac=handles.toolbox.tidestations.activeDatabase;
names=handles.toolbox.tidestations.database(iac).stationShortNames;

xg=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x;
yg=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y;

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
    end
end

% % Find stations within grid
% nrp=0;
% if ~isempty(posx)
%     xx=handles.model.dflowfm.domain(ad).circumference.x;
%     yy=handles.model.dflowfm.domain(ad).circumference.y;
%     inp1=inpolygon(posx,posy,xx,yy);
%     if ~isempty(handles.toolbox.tidestations.polygonx)
%         inp2=inpolygon(posx,posy,handles.toolbox.tidestations.polygonx,handles.toolbox.tidestations.polygony);
%     else
%         inp2=zeros(size(inp1))+1;
%     end
%     for i=1:length(posx)
%         if inp1(i)==1 && inp2(i)==1
%             nrp=nrp+1;
%             istation(nrp)=istat(i);
%             posx2(nrp)=posx(i);
%             posy2(nrp)=posy(i);
%         end
%     end
% end
posx2=posx;
posy2=posy;
nrp=length(posx);
istation=istat;

for i=1:nrp
    
    k=istation(i);
        
    if handles.toolbox.tidestations.showstationnames
        name=handles.toolbox.tidestations.database(iac).stationShortNames{k};
    else
        name=handles.toolbox.tidestations.database(iac).idCodes{k};
    end
        
    nobs=handles.model.dflowfm.domain(ad).nrobservationpoints;
    Names{1}='';
    for n=1:nobs
        Names{n}=handles.model.dflowfm.domain(ad).observationpoints(n).name;
    end
    
    if isempty(strmatch(name,Names,'exact'))
        nobs=nobs+1;
        handles.model.dflowfm.domain(ad).observationpoints(nobs).x=posx2(i);
        handles.model.dflowfm.domain(ad).observationpoints(nobs).y=posy2(i);
        lname=length(name);
        shortName=name(1:min(lname,20));
        handles.model.dflowfm.domain(ad).observationpoints(nobs).name=name;
        handles.model.dflowfm.domain(ad).observationpointnames{nobs}=name;
        Names{nobs}=name;
        
        % Add some extra information for CoSMoS toolbox
        handles.model.dflowfm.domain(ad).observationpoints(nobs).longname=handles.toolbox.tidestations.database(iac).stationList{k};
        handles.model.dflowfm.domain(ad).observationpoints(nobs).type='tidegauge';
        handles.model.dflowfm.domain(ad).observationpoints(nobs).source=handles.toolbox.tidestations.database(iac).shortName;
        handles.model.dflowfm.domain(ad).observationpoints(nobs).id=handles.toolbox.tidestations.database(iac).idCodes{k};
        
    end
    
    handles.model.dflowfm.domain(ad).nrobservationpoints=nobs;
    
end

if nrp>0
    handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',0);
end

setHandles(handles);


