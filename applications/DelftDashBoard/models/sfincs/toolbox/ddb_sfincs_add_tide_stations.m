function ddb_sfincs_add_tide_stations
%ddb_sfincs_add_tide_stations  One line description goes here.

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
% $Date: 2019-10-04 14:15:03 +0800 (vr, 04 okt 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/toolbox/TideStations/ddb_DFlowFM_addTideStations.m $
% $Keywords: $

%%
handles=getHandles;

posx=[];

iac=handles.toolbox.tidestations.activeDatabase;
names=handles.toolbox.tidestations.database(iac).stationShortNames;


% xmin=min(min(xg));
% xmax=max(max(xg));
% ymin=min(min(yg));
% ymax=max(max(yg));
% 
% ns=length(handles.toolbox.tidestations.database(iac).xLoc);
n=0;

x=handles.toolbox.tidestations.database(iac).xLocLocal;
y=handles.toolbox.tidestations.database(iac).yLocLocal;

% xg=handles.model.sfincs.domain(ad).input.x0;
% yg=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y;

cosrot=cos(handles.model.sfincs.domain(ad).input.rotation*pi/180);
sinrot=sin(handles.model.sfincs.domain(ad).input.rotation*pi/180);
lenx=handles.model.sfincs.domain(ad).input.mmax*handles.model.sfincs.domain(ad).input.dx;
leny=handles.model.sfincs.domain(ad).input.nmax*handles.model.sfincs.domain(ad).input.dy;

xbox(1)=handles.model.sfincs.domain(ad).input.x0;
xbox(2)=xbox(1)+lenx*cosrot;
xbox(3)=xbox(2)-leny*sinrot;
xbox(4)=xbox(3)-lenx*cosrot;

ybox(1)=handles.model.sfincs.domain(ad).input.y0;
ybox(2)=ybox(1)+lenx*sinrot;
ybox(3)=ybox(2)+leny*cosrot;
ybox(4)=ybox(3)-lenx*sinrot;

inpol=inpolygon(x,y,xbox,ybox);
% First find points within grid bounding box
for i=1:length(inpol)
    if inpol(i)
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
        
    nobs=length(handles.model.sfincs.domain(ad).obspoints.x);
%    Names{1}='';
    if nobs>0
        names=handles.model.sfincs.domain(ad).obspoints.names;
    else
        names={''};
    end
%     for n=1:nobs
%         Names{n}=handles.model.sfincs.domain(ad).obspoints.names{n};
%     end
    
    if isempty(strmatch(name,names,'exact'))
        % Station does not yet exist
        nobs=nobs+1;
        handles.model.sfincs.domain(ad).obspoints.x(nobs)=posx2(i);
        handles.model.sfincs.domain(ad).obspoints.y(nobs)=posy2(i);
        handles.model.sfincs.domain(ad).obspoints.names{nobs}=name;
        
%        handles.model.sfincs.domain(ad).obsnames{nobs}=name;
        
%        Names{nobs}=name;
        
        % Add some extra information for CoSMoS toolbox
%        handles.model.dflowfm.domain(ad).observationpoints(nobs).longname=name;
%        handles.model.dflowfm.domain(ad).observationpoints(nobs).type='tidegauge';
%        handles.model.dflowfm.domain(ad).observationpoints(nobs).source=handles.toolbox.tidestations.database(iac).shortName;
%        handles.model.dflowfm.domain(ad).observationpoints(nobs).id=handles.toolbox.tidestations.database(iac).idCodes{k};
        
    end
    
    handles.model.sfincs.domain.activeobservationpoint=1;

end

if nrp>0
    handles=ddb_sfincs_plot_observation_points(handles,'plot','active',0);
end

setHandles(handles);


