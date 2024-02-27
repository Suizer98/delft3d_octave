function StructOut = delwaq_match(StructIn,SubstanceNames, SegmentNames,Time,binTime)
%DELWAQ_INTERSECT Gives back Delwaq files intersection characteristics
%
%   STRUCTOUT = DELWAQ_INTERSECT(STRUCTIN,SUBSTANCENAMES,SEGMENTNAMES,TIME)
%   STRUCTIN  = DELWAQ_INTERSECT(File1,File2,...,FileN)
%   STRUCTOUT returns the common characteristics in STRUCTIN
%   Characteristics: SubstanceNames/SegmentNames/Time
%   If double time exist a then only the last record will be taked into 
%   account
%
%   STRUCTOUT = DELWAQ_INTERSECT(...,FLAGTIME)
%   BINTIME = 1 If the vector TIME should be used as time intervals
%
%   See also: DELWAQ, DELWAQ_INTERSECT, DELWAQ_CONC, DELWAQ_DIFF, DELWAQ_RES
%             DELWAQ_TIME, DELWAQ_STAT


%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-11 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

StructOut = StructIn;

if  nargin<2
    SubstanceNames = 0;
end
if  nargin<3
    SegmentNames = 0;
end
if  nargin<4
    Time = 0;
end
if  nargin<5
    binTime = 0;
end


if ischar(SubstanceNames)
   SubstanceNames = cellstr(SubstanceNames);
elseif isnumeric(SubstanceNames);
    if SubstanceNames==0
       SubstanceNames = 1:StructIn.nSubs;
    end
    SubstanceNames = {StructIn.Subs{SubstanceNames}}; %#ok<*CCAT1>
end

if ischar(SegmentNames)
   SegmentNames = cellstr(SegmentNames);
elseif isnumeric(SegmentNames);
    if SegmentNames==0
       SegmentNames = 1:StructIn.nSegm;
    end
    SegmentNames = {StructIn.Segm{SegmentNames}};
end

% Matching substances name
[~, isub] = match_names(StructIn.Subs, SubstanceNames);
StructOut.Subs = {StructOut.Subs{isub}};
StructOut.nSubs = length(isub);
StructIn.iSubs
for i = 1:length(StructIn.iSubs)
    StructOut.iSubs{i} = StructIn.iSubs{i}(isub);
end

% Matching segments name
if strcmp(StructIn.extId,'map')
   StructOut.Segm = SegmentNames;
   for i = 1:length(StructIn.iSegm)
       StructOut.iSegm = SegmentNames;
   end
elseif strcmp(StructIn.extId,'his')
    [~, iseg] = match_names(StructIn.Segm, SegmentNames);
    StructOut.Segm = {StructOut.Segm{iseg}};
    StructOut.nSegm = length(iseg);
    for i = 1:length(StructIn.iSegm)
        StructOut.iSegm{i} = StructIn.iSegm{i}(iseg);
    end
end

% Matching times
if Time~=0
   if binTime
      [StructOut.Time itime] = match_interval_times(StructIn.Time, Time);
      StructOut.nTime = length(itime);
      StructOut.iTime = {[]};
      for i = 1:length(StructIn.iTime)
          for j = 1:StructOut.nTime
              StructOut.iTime{i,j} = StructIn.iTime{i}(itime{j});
          end          
      end

   else
      [StructOut.Time itime] = match_times(StructIn.Time, Time);
      StructOut.nTime = length(itime);
      for i = 1:length(StructIn.iTime)
          StructOut.iTime{i} = StructIn.iTime{i}(itime);
      end 
    end
   
end


%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function varargout = match_names(varargin)

for i = 1:nargin
    varargin{i} = lower(varargin{i});
end

names = varargin{1};
for i = 1:nargin
    index = ismember(names,varargin{i});
    names = names(index);
end
varargout{1} = names;

for i = 1:nargin
    varargout{1+i} = find(ismember(varargin{i},names));
end

%--------------------------------------------------------------------------
% Match times
%--------------------------------------------------------------------------
function [times, timeIndex] = match_times(time1,time2)

[times, timeIndex] = intersect(time1, time2);

%--------------------------------------------------------------------------
% Match interval times
%--------------------------------------------------------------------------
function [tinterval, itime1 itime2] = match_interval_times(time1,tinterval)

for it = 1:length(tinterval)-1
    if it==length(tinterval)-1
       itime1{it} = find((time1 >= tinterval(it)) & (time1 <= tinterval(it+1))); %#ok<*AGROW>
    else
       itime1{it} = find((time1 >= tinterval(it)) & (time1 < tinterval(it+1)));
    end
    itime2(it) = it;
    
end
