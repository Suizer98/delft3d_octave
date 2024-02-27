function [times,src,celm,celn]=getSourcesAndDischarges(xp,yp,xg,yg,q,tModelStart,tModelStop,dtModel,tCycleStart,ncyc,cycleLength,tTrackStart,tTrackStop,varargin)
% Determines m and n locations of discharge points, and generates block
% time series of discharges. Returns cell array 'times' with times in seconds (times) for each
% discharge location, cell array 'src' with the values for the discharge, and vectors 'celm' and 'celn' with m and
% n indices of discharge location.
% All times are in seconds!!!
%
% Input:
% xp - x-coordinates of track 
% yp - y-coordinates of track
% xg - x-coordinates of grid
% yg - y-coordinates of grid
% q  - 2*n matrix with discharge info. First column containes discharges,
%      all other columns contain concentrations. First row contains values
%      at the start of the track, second row contains values at the end of
%      the track. Linear interpolation in between.
% tModelStart - model start time in seconds
% tModelStop  - model stop time in seconds
% dtModel     - model time step in seconds
% tCycleStart - start time first cycle in seconds
% ncyc        - number of cycles to be executed
% cycleLength - cycle length in seconds
% tTrackStart - track start time (within cycle) in seconds
% tTrackStop  - track stop time (within cycle) in seconds

%% Determine coordinate system type
cstype='projected';
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'cstype'}
                cstype=lower(varargin{i+1});
        end
    end
end

%% Round input times to seconds
tModelStart=round(tModelStart);
tModelStop=round(tModelStop);
dtModel=round(dtModel);
tCycleStart=round(tCycleStart);
cycleLength=round(cycleLength);
tTrackStart=round(tTrackStart);
tTrackStop=round(tTrackStop);

nrConstituents=size(q,2);
tModel=tModelStart:dtModel:tModelStop;
ntmodel=(tModelStop-tModelStart)/dtModel+1;

%% Determine time step of points along track

if length(xp)==1
    dtTrack=1;
else
    % Find minimum grid size in order to get maximum time step (try to have at
    % least 2 points within grid cell)
    [dmin,dmax]=findMinMaxGridSize(xg,yg,cstype);
    npminingrid=5;
    len=computeLength(xp,yp);
    tlength=tTrackStop-tTrackStart;
    v=len/tlength;
    dxmin=dmin/npminingrid;
    dtmax=dxmin/v;
    dtmax=min(dtModel,dtmax);
    % Track duration, cycle length, start time of track must be multiple of
    % time step.
    dv=divisor(gcd(gcd(cycleLength,tlength),tTrackStart));
    ii=find(dv<=dtmax,1,'last');
    dtTrack=dv(ii);
end

%% Generate vector with times
tcyc=tCycleStart:dtTrack:tCycleStart+cycleLength*ncyc-1;

%% Determine coordinates of points along track
[x,y]=getPointsAlongTrack(xp,yp,tTrackStart,tTrackStop,dtTrack);

%% Finding grid cells
[celm,celn,mcel,ncel]=findCells(x,y,xg,yg);

%% Find when source is in grid cells
% Return matrix inCel (nrcell*nrtimestep matrix) with ones and zeros, as
% well as tFrac vector with values ranging from 0.0 to 1.0 to determine
% where in the track it is 
[inCel0,tFrac0]=findTimesInCells(celm,celn,mcel,ncel,cycleLength,tTrackStart,dtTrack);

%% Append cycles
inCel=inCel0;
tFrac=tFrac0;
for i=1:ncyc-1;
    inCel=[inCel inCel0];
    tFrac=[tFrac tFrac0];
end

%% Now run through model time steps
src0=zeros(length(celm),ntmodel,nrConstituents);
for it=1:ntmodel
    t1=tModelStart+(it-1)*dtModel;
    t2=t1+dtModel;
    i1=find(tcyc>=t1,1,'first');
    i2=find(tcyc<t2,1,'last');
    qfrac=mean(tFrac(i1:i2));
    if ~isempty(i1) && ~isempty(i2)
        for ic=1:length(celm)
            nrin=sum(inCel(ic,i1:i2));
            frac=nrin/(i2-i1+1);
            if frac>0
                for k=1:nrConstituents
                    if k==1
                        % Discharge
                        src0(ic,it,k)=frac*(q(1,k)+qfrac*(q(2,k)-q(1,k)));
                    else
                        % Constituent
                        src0(ic,it,k)=(q(1,k)+qfrac*(q(2,k)-q(1,k)));
                    end
                end
            end
        end
    end
end

%% Get blocks from time series
for ic=1:length(celm)
    times{ic}(1)=tModel(1);
    for k=1:nrConstituents
        src{ic}(1,k)=src0(ic,1,k);
    end
end
for ic=1:length(celm)
    n=1;
    for it=2:ntmodel
        isame=1;
        for k=1:nrConstituents
            if src0(ic,it,k)~=src0(ic,it-1,k)
                isame=0;
                break
            end
        end
        if ~isame
            n=n+1;
            times{ic}(n)=tModel(it);
            for k=1:nrConstituents
                src{ic}(n,k)=src0(ic,it,k);
            end
        end
    end
end
% Make sure that last time in discharge time series is stop time of model
for ic=1:length(celm)
    if times{ic}(end)<tModel(end);
        times{ic}(end+1)=tModel(end);
        src{ic}(end+1,:)=0;
    end
end

%%
function [x,y]=getPointsAlongTrack(xp,yp,t1,t2,dt,varargin)
% Determines x and y locations of points along a track, given start,
% and stop times (in seconds) along track and a time step.

geofac=111111;
cstype='projected';
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'cstype'}
                cstype=lower(varargin{i+1});
        end
    end
end

np=length(xp)-1;
len=computeLength(xp,yp);
tlength=t2-t1;
v=len/tlength;

nt=tlength/dt;

if length(xp)==1
    % Single point
    x=zeros(nt,1)+xp;
    y=zeros(nt,1)+yp;
else
    % Track
    for i=1:np
        dx=xp(i+1)-xp(i);
        dy=yp(i+1)-yp(i);
        if strcmpi(cstype(1:3),'geo')
            dx=dx*geofac*cos(pi*0.5*(yp(i+1)+yp(i))/180);
            dy=dy*geofac;
        end
        sublen(i)=sqrt(dx^2+dy^2);
    end
    cumlen(i)=0;
    for i=2:np
        cumlen(i)=cumlen(i-1)+sublen(i-1);
    end
    
    x(1)=xp(1);
    y(1)=yp(1);
    dx=v*dt;
    for it=2:nt
        dist=(it-1)*dx;
        isec=find(cumlen<=dist,1,'last');
        frac=(dist-cumlen(isec))/sublen(isec);
        x(it)=xp(isec)+frac*(xp(isec+1)-xp(isec));
        y(it)=yp(isec)+frac*(yp(isec+1)-yp(isec));
    end
    
end

%%
function [celm,celn,mcel,ncel]=findCells(x,y,xg,yg)
% Return vectors celm and celn with m and n indices for each discharge location that is found,
% and vectors mcel and ncel with m and n indices for each point in x and y
% celm and celn are smaller than mcel and ncel, because they only only contain each cell once.

nrCells=0;
celm=[];
celn=[];
nt=length(x);
[m,n]=findgridcell(x,y,xg,yg);
for it=1:nt
    ii=find(celm==m(it) & celn==n(it));
    if isempty(ii)
        % New grid cell
        nrCells=nrCells+1;
        icel=nrCells;
        celm(icel)=m(it);
        celn(icel)=n(it);
    else
        icel=ii;
    end     
    mcel(it)=celm(icel);
    ncel(it)=celn(icel);
end

%%
function [inCel,tFrac]=findTimesInCells(celm,celn,mcel,ncel,cycleLength,tTrackStart,dtTrack)
% Finds when source is in grid cells
% Return matrix inCel (nrcell*nrtimestep matrix) with ones and zeros, as
% well as tFrac vector with values ranging from 0.0 to 1.0 to determine
% where in the track it is 
ntCycle=round(cycleLength/dtTrack);
it0track=round(tTrackStart/dtTrack)+1;
ntTrack=length(mcel);
nrcells=length(celm);
inCel=zeros(nrcells,ntCycle);
tFrac=zeros(1,ntCycle);
for it=1:ntTrack
    itcyc=it0track+it-1;
    tFrac(itcyc)=(it-1)/ntTrack;
    for j=1:nrcells
        m=celm(j);
        n=celn(j);
        if mcel(it)==m && ncel(it)==n
            inCel(j,itcyc)=1;
        end
    end
end

