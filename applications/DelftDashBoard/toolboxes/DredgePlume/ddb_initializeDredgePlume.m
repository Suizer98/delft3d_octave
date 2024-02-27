function handles=ddb_initializeDredgePlume(handles,varargin)

handles.toolbox.dredgeplume.trackNames={''};
handles.toolbox.dredgeplume.activeDredgeTrack=1;
handles.toolbox.dredgeplume.nrTracks=0;
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

handles.toolbox.dredgeplume.startTimes=0;
handles.toolbox.dredgeplume.stopTimes=0;
handles.toolbox.dredgeplume.startDischarges=0;
handles.toolbox.dredgeplume.stopDischarges=0;
handles.toolbox.dredgeplume.startConcentrations=0;
handles.toolbox.dredgeplume.stopConcentrations=0;
handles.toolbox.dredgeplume.lengths=0;
handles.toolbox.dredgeplume.speeds=0;
handles.toolbox.dredgeplume.cycleStartTime=floor(now);
handles.toolbox.dredgeplume.nrCycles=1;
handles.toolbox.dredgeplume.cycleLength=720;

handles.toolbox.dredgeplume.constituentList={'no constituents'};
handles.toolbox.dredgeplume.activeConstituent='no constituents';
handles.toolbox.dredgeplume.constituents=[];

handles.toolbox.dredgeplume.trkFile='';
