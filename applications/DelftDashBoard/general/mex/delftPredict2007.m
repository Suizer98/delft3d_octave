function [p,pTime]=delftPredict2007(cmp,A,G,startTime,endTime,dt)

% DelftPredict uses the Delft-Tide module for predicting tidal signals
% 
% usage 
%        [prediction,times]=delftPredict(cmp,A,G,startTime,endTime,dt)
%
%in which:
%        cmp          = cell array with component names [Nx1]
%        A            = amplitudes for specified components [NxP]
%        G            = phases for specified components [NxP]
%           N= number of components (max 234)
%           P= number of output points (max 2000)
%        startTime    = start time in Matlab datenum
%        endTime      = end time in Matlab datenum
%        dt           = timestep in hours
%
%   NB: maximum predicted timesteps in case of one point is 200000 and 200
%   in case of multiple points (max 2000 points)
%
% Uses the predictMex.dll mex-file
%
% R. Morelissen, 2006

pts=size(A,2);

id=find(strcmp(upper(cmp),'A0'));
if ~isempty(id)
    A0=A(id,:);
    cmp(id)=[];
    A(id,:)=[];
    G(id,:)=[];
else
    A0=zeros(1,pts);
end
id=find(strcmp(upper(cmp),'B0'));
if ~isempty(id)
    B0=A(id,:);
    cmp(id)=[];
    A(id,:)=[];
    G(id,:)=[];
else
    B0=zeros(1,pts);
end

k=length(cmp);

cmps=[];
for ii=1:k
    cmps=[cmps upper(cmp{ii}) repmat(' ',1,8-length(cmp{ii}))];
end

if str2num(datestr(startTime,10))<1949|str2num(datestr(startTime,10))>2049|...
       str2num(datestr(endTime,10))<1949|str2num(datestr(endTime,10))>2049
   error('Please specify dates between 1949 and 2049');
   return
end

%start hour
year=round((1+str2num(datestr(startTime,10))+str2num(datestr(endTime,10)))/2);
startH=(startTime-datenum(year,1,1,0,0,0))*24;
endH=(endTime-datenum(year,1,1,0,0,0))*24;

[pTS,pPts]=predictMex2007(k,pts,cmps,A,G,A0,B0,startH,endH,dt,year);

pTime=datenum(year,1,1)+[startH/24:dt/24:endH/24];

if pts>1
    p=pPts(1:pts,:);
else
    p(1,:)=pTS';
end

p=p(:,1:length(pTime));
