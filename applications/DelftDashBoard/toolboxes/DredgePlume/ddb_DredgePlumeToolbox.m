function ddb_DredgePlumeToolbox(varargin)
%ddb_DredgePlumeToolbox  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DredgePlumeToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DredgePlumeToolbox
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

% $Id: ddb_DredgePlumeToolbox.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode.m $
% $Keywords: $

if isempty(varargin)
    
    handles=getHandles;
    
    % Update constituent list
    k=0;
    handles.toolbox.dredgeplume.constituentList={''};
    if handles.model.delft3dflow.domain(ad).salinity.include
        k=k+1;
        handles.toolbox.dredgeplume.constituentList{k}='salinity';
    end
    if handles.model.delft3dflow.domain(ad).temperature.include
        k=k+1;
        handles.toolbox.dredgeplume.constituentList{k}='temperature';
    end
    if handles.model.delft3dflow.domain(ad).tracers
        for i=1:handles.model.delft3dflow.domain(ad).nrTracers
            k=k+1;
            handles.toolbox.dredgeplume.constituentList{k}=handles.model.delft3dflow.domain(ad).tracer(i).name;
        end
    end
    if handles.model.delft3dflow.domain(ad).sediments.include
        for i=1:handles.model.delft3dflow.domain(ad).nrSediments
            k=k+1;
            handles.toolbox.dredgeplume.constituentList{k}=handles.model.delft3dflow.domain(ad).sediment(i).name;
        end
    end

    if k==0
        ddb_giveWarning('text','Please add one or more constituents or sediment fractions first before using the Dredge Plume toolbox!');
    end
    
    handles.toolbox.dredgeplume.activeConstituent=handles.toolbox.dredgeplume.constituentList{1};
    
    % Initialize constituents (if they've not already been set)
    for i=1:handles.toolbox.dredgeplume.nrTracks
        for j=1:length(handles.toolbox.dredgeplume.constituentList)
            ii=strmatch(handles.toolbox.dredgeplume.constituentList{j},handles.toolbox.dredgeplume.dredgeTracks(i).constituent,'exact');
            if isempty(ii)
                n=length(handles.toolbox.dredgeplume.dredgeTracks(i).constituent)+1;
                handles.toolbox.dredgeplume.dredgeTracks(i).constituent{n}=handles.toolbox.dredgeplume.constituentList{j};
                handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(n)=0;
                handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(n)=0;
            end
        end
    end
    
    % Set data for table
    j=strmatch(handles.toolbox.dredgeplume.activeConstituent,handles.toolbox.dredgeplume.constituentList,'exact');
    for i=1:handles.toolbox.dredgeplume.nrTracks
        handles.toolbox.dredgeplume.startConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j);
        handles.toolbox.dredgeplume.stopConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j);
    end
    
    setHandles(handles);

    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotDredgePlume('activate');
    gui_updateActiveTab;
    
else
    opt=lower(varargin{1});
    
    switch opt
        case{'selectrackfromlist'}
        case{'addtrack'}
            UIPolyline(gca,'draw','Tag','dredgetrack','Marker','o','Callback',@addDredgeTrack,'closed',0);
        case{'deletetrack'}
            deleteDredgeTrack;
        case{'edittracktable'}
            editTrackTable;
        case{'editcoordinates'}
            editCoordinates;
        case{'edittrackname'}
            editTrackName;
        case{'generatedischarges'}
            generateDischarges;
        case{'selectconstituent'}
            selectConstituent;
        case{'savetrackdata'}
            saveTrackData;
        case{'loadtrackdata'}
            loadTrackData;
        case{'editcyclelength'}
            handles=getHandles;
            iwarn=0;
            for i=1:length(handles.toolbox.dredgeplume.dredgeTracks)
                if handles.toolbox.dredgeplume.dredgeTracks(i).stopTime>handles.toolbox.dredgeplume.cycleLength
                    iwarn=1;
                end
            end
            if iwarn
                ddb_giveWarning('text','Cycle length cannot be smaller than stop time of tracks!');
            end
    end
    
end

%%
function addDredgeTrack(x,y,h)

handles=getHandles;
UIPolyline(h,'delete');
nrtr=handles.toolbox.dredgeplume.nrTracks+1;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).plotHandle=UIPolyline(gca,'plot','Tag','dredgetrack','x',x,'y',y, ...
    'Marker','o','Callback',@changeDredgeTrackOnMap,'UserData',nrtr);
handles.toolbox.dredgeplume.trackNames{nrtr}=['Track' num2str(nrtr)];
handles.toolbox.dredgeplume.nrTracks=nrtr;
handles.toolbox.dredgeplume.activeDredgeTrack=nrtr;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).x=x;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).y=y;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).startTime=0;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).stopTime=0;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).startDischarge=0;
handles.toolbox.dredgeplume.dredgeTracks(nrtr).stopDischarge=0;
if length(handles.toolbox.dredgeplume.constituentList)>=1 %&& ~strcmpi(handles.toolbox.dredgeplume.dredgeTracks(nrtr).constituent{1},'no constituents')
    for j=1:length(handles.toolbox.dredgeplume.constituentList)
        handles.toolbox.dredgeplume.dredgeTracks(nrtr).constituent{j}=handles.toolbox.dredgeplume.constituentList{j};
        handles.toolbox.dredgeplume.dredgeTracks(nrtr).startConcentration(j)=0;
        handles.toolbox.dredgeplume.dredgeTracks(nrtr).stopConcentration(j)=0;
    end
end
handles.toolbox.dredgeplume.dredgeTracks(nrtr).trackName=['Track' num2str(nrtr)];
len=computeLength(x,y,'cstype',handles.screenParameters.coordinateSystem.type);
handles.toolbox.dredgeplume.dredgeTracks(nrtr).length=len;
speed=len/max(handles.toolbox.dredgeplume.dredgeTracks(nrtr).stopTime-handles.toolbox.dredgeplume.dredgeTracks(nrtr).startTime,1e-6)/60;
if handles.toolbox.dredgeplume.dredgeTracks(nrtr).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(nrtr).startTime
    speed=0;
end
handles.toolbox.dredgeplume.dredgeTracks(nrtr).speed=speed;

% For use in table
handles.toolbox.dredgeplume.startTimes(nrtr)=0;
handles.toolbox.dredgeplume.stopTimes(nrtr)=0;
handles.toolbox.dredgeplume.startDischarges(nrtr)=0;
handles.toolbox.dredgeplume.stopDischarges(nrtr)=0;
handles.toolbox.dredgeplume.startConcentrations(nrtr)=0;
handles.toolbox.dredgeplume.stopConcentrations(nrtr)=0;
handles.toolbox.dredgeplume.lengths(nrtr)=len;
handles.toolbox.dredgeplume.speeds(nrtr)=speed;

setHandles(handles);

gui_updateActiveTab;

%%
function deleteDredgeTrack

handles=getHandles;
ntr=handles.toolbox.dredgeplume.activeDredgeTrack;
if handles.toolbox.dredgeplume.nrTracks>0
    for i=1:handles.toolbox.dredgeplume.nrTracks
        UIPolyline(handles.toolbox.dredgeplume.dredgeTracks(i).plotHandle,'delete');
    end
    
    handles.toolbox.dredgeplume.dredgeTracks=removeFromStruc(handles.toolbox.dredgeplume.dredgeTracks,ntr);
    
    handles.toolbox.dredgeplume.startTimes=removeFromVector(handles.toolbox.dredgeplume.startTimes,ntr);
    handles.toolbox.dredgeplume.stopTimes=removeFromVector(handles.toolbox.dredgeplume.stopTimes,ntr);
    handles.toolbox.dredgeplume.startDischarges=removeFromVector(handles.toolbox.dredgeplume.startDischarges,ntr);
    handles.toolbox.dredgeplume.stopDischarges=removeFromVector(handles.toolbox.dredgeplume.stopDischarges,ntr);
    handles.toolbox.dredgeplume.startConcentrations=removeFromVector(handles.toolbox.dredgeplume.startConcentrations,ntr);
    handles.toolbox.dredgeplume.stopConcentrations=removeFromVector(handles.toolbox.dredgeplume.stopConcentrations,ntr);
    handles.toolbox.dredgeplume.lengths=removeFromVector(handles.toolbox.dredgeplume.lengths,ntr);
    handles.toolbox.dredgeplume.speeds=removeFromVector(handles.toolbox.dredgeplume.speeds,ntr);
    
    handles.toolbox.dredgeplume.nrTracks=length(handles.toolbox.dredgeplume.dredgeTracks);
    
    if handles.toolbox.dredgeplume.nrTracks==0
        handles.toolbox.dredgeplume.dredgeTracks(1).x=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).y=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).startTime=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).stopTime=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).startDischarge=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).stopDischarge=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).constituent=[];
        handles.toolbox.dredgeplume.dredgeTracks(1).startConcentration(1)=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).stopConcentration(1)=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).length=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).speed=0;
        handles.toolbox.dredgeplume.dredgeTracks(1).trackName='';
        handles.toolbox.dredgeplume.startTimes(1)=0;
        handles.toolbox.dredgeplume.stopTimes(1)=0;
        handles.toolbox.dredgeplume.startDischarges(1)=0;
        handles.toolbox.dredgeplume.stopDischarges(1)=0;
        handles.toolbox.dredgeplume.startConcentrations(1)=0;
        handles.toolbox.dredgeplume.stopConcentrations(1)=0;
        handles.toolbox.dredgeplume.lengths(1)=0;
        handles.toolbox.dredgeplume.speeds(1)=0;
    end
    
    handles.toolbox.dredgeplume.trackNames=[];
    for i=1:handles.toolbox.dredgeplume.nrTracks
        x=handles.toolbox.dredgeplume.dredgeTracks(i).x;
        y=handles.toolbox.dredgeplume.dredgeTracks(i).y;
        handles.toolbox.dredgeplume.dredgeTracks(i).plotHandle=UIPolyline(gca,'plot','Tag','dredgetrack','x',x,'y',y, ...
            'Marker','o','Callback',@changeDredgeTrackOnMap,'UserData',i);
        handles.toolbox.dredgeplume.trackNames{i}=handles.toolbox.dredgeplume.dredgeTracks(i).trackName;
    end
    handles.toolbox.dredgeplume.activeDredgeTrack=min(handles.toolbox.dredgeplume.activeDredgeTrack,handles.toolbox.dredgeplume.nrTracks);
    handles.toolbox.dredgeplume.activeDredgeTrack=max(handles.toolbox.dredgeplume.activeDredgeTrack,1);
    setHandles(handles);

end

%%
function changeDredgeTrackOnMap(x,y,h)

handles=getHandles;
p=getappdata(h,'parent');
ntr=get(p,'UserData');
handles.toolbox.dredgeplume.activeDredgeTrack=ntr;
handles.toolbox.dredgeplume.dredgeTracks(ntr).x=x;
handles.toolbox.dredgeplume.dredgeTracks(ntr).y=y;

len=computeLength(x,y,'cstype',handles.screenParameters.coordinateSystem.type);

speed=len/max(handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime-handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime,1e-6)/60;
if handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime
    speed=0;
end

handles.toolbox.dredgeplume.dredgeTracks(ntr).length=len;
handles.toolbox.dredgeplume.dredgeTracks(ntr).speed=speed;
handles.toolbox.dredgeplume.lengths(ntr)=len;
handles.toolbox.dredgeplume.speeds(ntr)=speed;

setHandles(handles);

gui_updateActiveTab;

%%
function editTrackTable

handles=getHandles;

for i=1:handles.toolbox.dredgeplume.nrTracks

    % Copy data from table
    handles.toolbox.dredgeplume.dredgeTracks(i).startTime=handles.toolbox.dredgeplume.startTimes(i);
    handles.toolbox.dredgeplume.dredgeTracks(i).stopTime=handles.toolbox.dredgeplume.stopTimes(i);
    handles.toolbox.dredgeplume.dredgeTracks(i).startDischarge=handles.toolbox.dredgeplume.startDischarges(i);
    handles.toolbox.dredgeplume.dredgeTracks(i).stopDischarge=handles.toolbox.dredgeplume.stopDischarges(i);
    
    j=strmatch(handles.toolbox.dredgeplume.activeConstituent,handles.toolbox.dredgeplume.constituentList,'exact');
    handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j)=handles.toolbox.dredgeplume.startConcentrations(i);
    handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j)=handles.toolbox.dredgeplume.stopConcentrations(i);

    speed=handles.toolbox.dredgeplume.dredgeTracks(i).length/max(handles.toolbox.dredgeplume.dredgeTracks(i).stopTime-handles.toolbox.dredgeplume.dredgeTracks(i).startTime,1e-6)/60;
    if handles.toolbox.dredgeplume.dredgeTracks(i).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(i).startTime
        speed=0;
    end

    handles.toolbox.dredgeplume.dredgeTracks(i).speed=speed;

    handles.toolbox.dredgeplume.speeds(i)=speed;

    % Provide some warnings
    if handles.toolbox.dredgeplume.dredgeTracks(i).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(i).startTime
        ddb_giveWarning('text',['Stop time of ' handles.toolbox.dredgeplume.dredgeTracks(i).trackName ' must be greater than start time!']);
    end
    if handles.toolbox.dredgeplume.dredgeTracks(i).stopTime>handles.toolbox.dredgeplume.cycleLength
        ddb_giveWarning('text',['Stop time of ' handles.toolbox.dredgeplume.dredgeTracks(i).trackName ' cannot be greater than cycle length!']);
    end

end

setHandles(handles);

gui_updateActiveTab;

%%
function editCoordinates

handles=getHandles;

ntr=handles.toolbox.dredgeplume.activeDredgeTrack;

x=handles.toolbox.dredgeplume.dredgeTracks(ntr).x;
y=handles.toolbox.dredgeplume.dredgeTracks(ntr).y;
len=computeLength(x,y,'cstype',handles.screenParameters.coordinateSystem.type);

handles.toolbox.dredgeplume.dredgeTracks(ntr).length=len;
handles.toolbox.dredgeplume.lengths(ntr)=len;

speed=handles.toolbox.dredgeplume.dredgeTracks(ntr).length/max(handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime-handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime,1e-6)/60;
if handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime
    speed=0;
end
handles.toolbox.dredgeplume.speeds(ntr)=speed;
handles.toolbox.dredgeplume.dredgeTracks(ntr).speed=speed;

UIPolyline(handles.toolbox.dredgeplume.dredgeTracks(ntr).plotHandle,'delete');
handles.toolbox.dredgeplume.dredgeTracks(ntr).plotHandle=UIPolyline(gca,'plot','Tag','dredgetrack','x',x,'y',y, ...
    'Marker','o','Callback',@changeDredgeTrackOnMap,'UserData',ntr);

setHandles(handles);

gui_updateActiveTab;

%%
function editTrackName
handles=getHandles;
ntr=handles.toolbox.dredgeplume.activeDredgeTrack;
handles.toolbox.dredgeplume.trackNames{ntr}=handles.toolbox.dredgeplume.dredgeTracks(ntr).trackName;
setHandles(handles);

%%
function selectConstituent
handles=getHandles;
j=strmatch(handles.toolbox.dredgeplume.activeConstituent,handles.toolbox.dredgeplume.constituentList,'exact');
for i=1:handles.toolbox.dredgeplume.nrTracks
    handles.toolbox.dredgeplume.startConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j);
    handles.toolbox.dredgeplume.stopConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j);
end
setHandles(handles);

%%
function saveTrackData

handles=getHandles;
fname=handles.toolbox.dredgeplume.trkFile;
s.cyclestarttime=datestr(handles.toolbox.dredgeplume.cycleStartTime,'yyyymmdd HHMMSS');
s.nrcycles=handles.toolbox.dredgeplume.nrCycles;
s.cyclelength=handles.toolbox.dredgeplume.cycleLength;
for i=1:handles.toolbox.dredgeplume.nrTracks

    s.tracks(i).track.name=handles.toolbox.dredgeplume.dredgeTracks(i).trackName;
    
    xstr=num2str(handles.toolbox.dredgeplume.dredgeTracks(i).x(1));
    ystr=num2str(handles.toolbox.dredgeplume.dredgeTracks(i).y(1));
    for j=2:length(handles.toolbox.dredgeplume.dredgeTracks(i).x);
        xstr=[xstr ',' num2str(handles.toolbox.dredgeplume.dredgeTracks(i).x(j))];
        ystr=[ystr ',' num2str(handles.toolbox.dredgeplume.dredgeTracks(i).y(j))];
    end

    s.tracks(i).track.x=xstr;
    s.tracks(i).track.y=ystr;
    
    s.tracks(i).track.tstart=handles.toolbox.dredgeplume.dredgeTracks(i).startTime;
    s.tracks(i).track.tstop=handles.toolbox.dredgeplume.dredgeTracks(i).stopTime;
    s.tracks(i).track.qstart=handles.toolbox.dredgeplume.dredgeTracks(i).startDischarge;
    s.tracks(i).track.qstop=handles.toolbox.dredgeplume.dredgeTracks(i).stopDischarge;
    
    for j=1:length(handles.toolbox.dredgeplume.dredgeTracks(i).constituent);
        s.tracks(i).track.constituents(j).constituent.name=handles.toolbox.dredgeplume.dredgeTracks(i).constituent{j};
        s.tracks(i).track.constituents(j).constituent.cstart=handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j);
        s.tracks(i).track.constituents(j).constituent.cstop=handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j);
    end
    
end
struct2xml(fname,s);

%%
function loadTrackData

handles=getHandles;

ddb_plotDredgePlume('delete');

fname=handles.toolbox.dredgeplume.trkFile;
s=xml2struct(fname);


% First check if constituents match the ones in Delft3D-FLOW input
for i=1:handles.toolbox.dredgeplume.nrTracks
    constOkay=zeros(length(handles.toolbox.dredgeplume.constituentList),1);
    for j=1:length(s.tracks(i).track.constituents)
        name=s.tracks(i).track.constituents(j).constituent.name;
        % First check if constituent is dealt with by Delft3D-FLOW
        ii=strmatch(name,handles.toolbox.dredgeplume.constituentList,'exact');
        if isempty(ii)
            GiveWarning('text',['Constituent ' name ' in track file not available in Delft3D-FLOW input!']);
            return
        else
            constOkay(ii)=1;
        end
    end
    ii=find(constOkay==0,1,'first');
    if ~isempty(ii)
        GiveWarning('text',['Constituent ' handles.toolbox.dredgeplume.constituentList{ii} ' not found in track ' num2str(i) ' of track file!']);
        return
    end
end

handles.toolbox.dredgeplume.trackNames=[];
handles.toolbox.dredgeplume.dredgeTracks=[];

handles.toolbox.dredgeplume.startTimes=[];
handles.toolbox.dredgeplume.stopTimes=[];
handles.toolbox.dredgeplume.startDischarges=[];
handles.toolbox.dredgeplume.stopDischarges=[];
handles.toolbox.dredgeplume.startConcentrations=[];
handles.toolbox.dredgeplume.stopConcentrations=[];
handles.toolbox.dredgeplume.speeds=[];
handles.toolbox.dredgeplume.lengths=[];

handles.toolbox.dredgeplume.cycleStartTime=datenum(s.cyclestarttime,'yyyymmdd HHMMSS');
handles.toolbox.dredgeplume.nrCycles=str2double(s.nrcycles);
handles.toolbox.dredgeplume.cycleLength=str2double(s.cyclelength);
handles.toolbox.dredgeplume.nrTracks=length(s.tracks);

handles.toolbox.dredgeplume.activeConstituent=handles.toolbox.dredgeplume.constituentList{1};
handles.toolbox.dredgeplume.activeTrack=1;

for i=1:handles.toolbox.dredgeplume.nrTracks
    
    % Initialize constituents
    for j=1:length(handles.toolbox.dredgeplume.constituentList)
        handles.toolbox.dredgeplume.dredgeTracks(i).constituent{j}=s.tracks(i).track.constituents(j).constituent.name;
        handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j)=str2double(s.tracks(i).track.constituents(j).constituent.cstart);
        handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j)=str2double(s.tracks(i).track.constituents(j).constituent.cstop);
    end

    handles.toolbox.dredgeplume.dredgeTracks(i).trackName=s.tracks(i).track.name;
    handles.toolbox.dredgeplume.trackNames{i}=s.tracks(i).track.name;
    xstr=s.tracks(i).track.x;
    ystr=s.tracks(i).track.y;
    x=strread(xstr,'%f','delimiter',',');
    y=strread(ystr,'%f','delimiter',',');
    handles.toolbox.dredgeplume.dredgeTracks(i).x=x;
    handles.toolbox.dredgeplume.dredgeTracks(i).y=y;
    
    handles.toolbox.dredgeplume.dredgeTracks(i).startTime=str2double(s.tracks(i).track.tstart);
    handles.toolbox.dredgeplume.dredgeTracks(i).stopTime=str2double(s.tracks(i).track.tstop);
    handles.toolbox.dredgeplume.dredgeTracks(i).startDischarge=str2double(s.tracks(i).track.qstart);
    handles.toolbox.dredgeplume.dredgeTracks(i).stopDischarge=str2double(s.tracks(i).track.qstop);

    handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration=0;
    handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration=0;
    
    for j=1:length(s.tracks(i).track.constituents)
        handles.toolbox.dredgeplume.dredgeTracks(i).constituent{j}=s.tracks(i).track.constituents(j).constituent.name;
        handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(j)=str2double(s.tracks(i).track.constituents(j).constituent.cstart);
        handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(j)=str2double(s.tracks(i).track.constituents(j).constituent.cstop);
    end
    
    len=computeLength(x,y,'cstype',handles.screenParameters.coordinateSystem.type);
    
    speed=len/max(handles.toolbox.dredgeplume.dredgeTracks(i).stopTime-handles.toolbox.dredgeplume.dredgeTracks(i).startTime,1e-6)/60;
    if handles.toolbox.dredgeplume.dredgeTracks(i).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(i).startTime
        speed=0;
    end
    
    handles.toolbox.dredgeplume.startTimes(i)=handles.toolbox.dredgeplume.dredgeTracks(i).startTime;
    handles.toolbox.dredgeplume.stopTimes(i)=handles.toolbox.dredgeplume.dredgeTracks(i).stopTime;
    handles.toolbox.dredgeplume.startDischarges(i)=handles.toolbox.dredgeplume.dredgeTracks(i).startDischarge;
    handles.toolbox.dredgeplume.stopDischarges(i)=handles.toolbox.dredgeplume.dredgeTracks(i).stopDischarge;
    handles.toolbox.dredgeplume.startConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).startConcentration(1);
    handles.toolbox.dredgeplume.stopConcentrations(i)=handles.toolbox.dredgeplume.dredgeTracks(i).stopConcentration(1);
    handles.toolbox.dredgeplume.lengths(i)=len;
    handles.toolbox.dredgeplume.speeds(i)=speed;
    
    handles.toolbox.dredgeplume.dredgeTracks(i).length=len;
    handles.toolbox.dredgeplume.dredgeTracks(i).speed=speed;
    
    handles.toolbox.dredgeplume.dredgeTracks(i).plotHandle=UIPolyline(gca,'plot','Tag','dredgetrack','x',x,'y',y, ...
    'Marker','o','Callback',@changeDredgeTrackOnMap,'UserData',i);

end

setHandles(handles);

%%
function generateDischarges

handles=getHandles;

for ntr=1:handles.toolbox.dredgeplume.nrTracks
    if handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime<=handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime
        ddb_giveWarning('text',['Stop time track ' num2str(ntr) ' must be greater than start time!']);
        return
    end
end

if isempty(handles.toolbox.dredgeplume.constituentList{1})
    ddb_giveWarning('text','Please add one or more constituents or sediment fractions first!');
    return
end

wb = waitbox('Generating Discharge Locations ...');%pause(0.1);

xg=handles.model.delft3dflow.domain(ad).gridX;
yg=handles.model.delft3dflow.domain(ad).gridY;

tModelStart=(handles.model.delft3dflow.domain(ad).startTime-handles.model.delft3dflow.domain(ad).itDate)*86400;
tModelStop=(handles.model.delft3dflow.domain(ad).stopTime-handles.model.delft3dflow.domain(ad).itDate)*86400;
dtModel=handles.model.delft3dflow.domain(ad).timeStep*60;

ncyc=handles.toolbox.dredgeplume.nrCycles;
tCycleStart=(handles.toolbox.dredgeplume.cycleStartTime-handles.model.delft3dflow.domain(ad).itDate)*86400;
cycleLength=handles.toolbox.dredgeplume.cycleLength*60;

k=0;
iremove=[];
for j=1:handles.model.delft3dflow.domain(ad).nrDischarges
    disname=handles.model.delft3dflow.domain(ad).discharges(j).name;
    if length(disname)>5
        if strcmpi(disname(1:5),'track')
            % Delete this source
            k=k+1;
            iremove(k)=j;
        end
    end
end
% Sort so starting at last discharge
iremove=sort(iremove,'descend');
for j=1:length(iremove)
    handles.model.delft3dflow.domain(ad).discharges=removeFromStruc(handles.model.delft3dflow.domain(ad).discharges,iremove(j));
    handles.model.delft3dflow.domain(ad).dischargeNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).dischargeNames,iremove(j));
end

handles.model.delft3dflow.domain(ad).nrDischarges=length(handles.model.delft3dflow.domain(ad).discharges);

if ~isempty(handles.model.delft3dflow.domain(ad).discharges)
    if isempty(handles.model.delft3dflow.domain(ad).discharges(1).M)
        handles.model.delft3dflow.domain(ad).nrDischarges=0;
    end
end

if handles.model.delft3dflow.domain(ad).nrDischarges==0
    handles.model.delft3dflow.domain(ad).dischargeNames={''};
    handles.model.delft3dflow.domain(ad).activeDischarge=1;
    handles.model.delft3dflow.domain(ad).discharges(1).M=[];
    handles.model.delft3dflow.domain(ad).discharges(1).N=[];
    handles.model.delft3dflow.domain(ad).discharges(1).type='normal';
end

for ntr=1:handles.toolbox.dredgeplume.nrTracks
    
    q(1,1)=handles.toolbox.dredgeplume.dredgeTracks(ntr).startDischarge;
    q(2,1)=handles.toolbox.dredgeplume.dredgeTracks(ntr).stopDischarge;
    
    for j=1:length(handles.toolbox.dredgeplume.dredgeTracks(ntr).constituent)
        q(1,j+1)=handles.toolbox.dredgeplume.dredgeTracks(ntr).startConcentration(j);
        q(2,j+1)=handles.toolbox.dredgeplume.dredgeTracks(ntr).stopConcentration(j);
    end
    
    xp=handles.toolbox.dredgeplume.dredgeTracks(ntr).x;
    yp=handles.toolbox.dredgeplume.dredgeTracks(ntr).y;
    
    tTrackStart=handles.toolbox.dredgeplume.dredgeTracks(ntr).startTime*60;
    tTrackStop=handles.toolbox.dredgeplume.dredgeTracks(ntr).stopTime*60;
    
    [times,src,celm,celn]=getSourcesAndDischarges(xp,yp,xg,yg,q,tModelStart,tModelStop,dtModel,tCycleStart,ncyc,cycleLength,tTrackStart,tTrackStop);
    
    for i=1:length(celm)
        m=celm(i);
        n=celn(i);
        if m>0 && n>0
            nr=handles.model.delft3dflow.domain(ad).nrDischarges+1;
            handles.model.delft3dflow.domain(ad).nrDischarges=nr;
            handles=ddb_initializeDischarge(handles,ad,nr);
            handles.model.delft3dflow.domain(ad).discharges(nr).M=m;
            handles.model.delft3dflow.domain(ad).discharges(nr).N=n;
            xz=0.25*(xg(m,n)+xg(m,n-1)+xg(m-1,n)+xg(m-1,n-1));
            yz=0.25*(yg(m,n)+yg(m,n-1)+yg(m-1,n)+yg(m-1,n-1));
            handles.model.delft3dflow.domain(ad).discharges(nr).x=xz;
            handles.model.delft3dflow.domain(ad).discharges(nr).y=yz;
            handles.model.delft3dflow.domain(ad).discharges(nr).interpolation='block';
            handles.model.delft3dflow.domain(ad).discharges(nr).name=[handles.toolbox.dredgeplume.dredgeTracks(ntr).trackName ' ' num2str(i,'%0.4i')];
            handles.model.delft3dflow.domain(ad).dischargeNames{nr}=[handles.toolbox.dredgeplume.dredgeTracks(ntr).trackName ' ' num2str(i,'%0.4i')];
            handles.model.delft3dflow.domain(ad).activeDischarge=nr;
            t=handles.model.delft3dflow.domain(ad).itDate+times{i}/86400;
            handles.model.delft3dflow.domain(ad).discharges(nr).timeSeriesT=t;

            handles.model.delft3dflow.domain(ad).discharges(nr).timeSeriesQ=src{i}(:,1);

            for j=1:length(handles.toolbox.dredgeplume.dredgeTracks(ntr).constituent)
                switch lower(handles.toolbox.dredgeplume.dredgeTracks(ntr).constituent{j})
                    case{'salinity'}
                        handles.model.delft3dflow.domain(ad).discharges(nr).salinity.timeSeries=src{i}(:,j+1);
                    case{'temperature'}
                        handles.model.delft3dflow.domain(ad).discharges(nr).temperature.timeSeries=src{i}(:,j+1);
                    otherwise
                        % Find the right sediment
                        if handles.model.delft3dflow.domain(ad).sediments.include
                            ii=strmatch(handles.toolbox.dredgeplume.dredgeTracks(ntr).constituent{j},handles.model.delft3dflow.domain(ad).sediments.sedimentNames,'exact');
                            if ~isempty(ii)
                                handles.model.delft3dflow.domain(ad).discharges(nr).sediment(ii).timeSeries=src{i}(:,j+1);
                            end
                        end
                        % Find the right tracer
                        if handles.model.delft3dflow.domain(ad).tracers
                            for jj=1:handles.model.delft3dflow.domain(ad).nrTracers
                                tracerNames{jj}=handles.model.delft3dflow.domain(ad).tracer(jj).name;
                            end
                            ii=strmatch(handles.toolbox.dredgeplume.dredgeTracks(ntr).constituent{j},tracerNames,'exact');
                            if ~isempty(ii)
                                handles.model.delft3dflow.domain(ad).discharges(nr).tracer(ii).timeSeries=src{i}(:,j+1);
                            end
                        end
                end
            end
            
        end
        stop=1;
    end
    
end

close(wb);

[srcfile, srcpath, filterindex] = uiputfile('*.src', 'New source file',handles.model.delft3dflow.domain(ad).srcFile);
if srcpath==0
    return
end
[disfile, dispath, filterindex] = uiputfile('*.dis', 'New discharge file',handles.model.delft3dflow.domain(ad).disFile);
if dispath==0
    return
end
handles.model.delft3dflow.domain(ad).srcFile=srcfile;
ddb_saveSrcFile(handles,ad);
handles.model.delft3dflow.domain(ad).disFile=disfile;
ddb_saveDisFile(handles,ad);

handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','discharges');
handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges','domain',ad,'visible',1,'active',0);

setHandles(handles);
