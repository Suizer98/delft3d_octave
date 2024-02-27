function StructOut = delwaq_intersect(varargin)
%DELWAQ_INTERSECT Gives back Delwaq files intersection characteristics
%
%   StructOut = DELWAQ_INTERSECT(File1,File2,...,FileN)
%   For files File1,File2,...,FileN, returns the common characteristics in 
%   the N files. 
%   Characteristics: substances/segments/stations/times
%   If double time exist a then only the last record will be taked into 
%   account
%
%   Where:
%   StructOut.Subs = matching SubsName
%   StructOut.iSubs = index 
%   StructOut.Subs = File1.SubsName{StructOut.iSubs(1)}
%
%   StructOut.Segm = matching SegmentName
%   StructOut.iSegm = index 
%   StructOut.Segm = File1.SegmentName{StructOut.iSegm(1)}
%
%   StructOut.Time = matching Times
%   StructOut.iTime = index 
%   StructOut.Time = File1.Time{StructOut.iTime(1)}
%
%   Unique Time is usefull when concatenate files
%
%   StructOut.UTime = Unique Times
%   StructOut.iUTime = index 
%   StructOut.iUfile  =  index file
%   StructOut.UTime(1) = File(StructOut.iUfile(1)).Time(StructOut.iUTime(1))
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_DIFF, DELWAQ_RES
%             DELWAQ_TIME, DELWAQ_STAT


%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-11 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if ischar(varargin{end})
   if any(strcmpi(varargin{end},{'first','last','all'}))
      type = varargin{end};
      varargin = {varargin{1:end-1}}; %#ok<CCAT1>
      Nnargin = nargin-1;
    else
      type = 'last';
      Nnargin = nargin;
   end
end 

IdFile(1:Nnargin) = 0;
for inar = 1:Nnargin
    if isstruct(varargin{inar})
       IdFile(inar) = exist(varargin{inar}.FileName,'file')==2;
       structInfo(inar) = varargin{inar}; %#ok<*AGROW>
       varargin{inar} = varargin{inar}.FileName;
       onStruct = 0;
    else
       IdFile(inar) = exist(varargin{inar},'file')==2;
       onStruct = 1;
    end
end

if ~all(IdFile)
    error('One of the files does not exist')
else
    ext1(1:Nnargin) = {[]};
    for ifile = 1:Nnargin
        [~, ~, ext1{ifile}] = fileparts(varargin{ifile});
    end
    if all(strcmpi(ext1,'.map'))
        extId = 'map';
    elseif all(strcmpi(ext1,'.his'))
        extId = 'his';
    else
        error('The files must have the same extension')
    end
end


% Opening Files
for ifile = 1:Nnargin
    if onStruct
        structInfo(ifile) = delwaq('open',varargin{ifile});
    end
    if ifile==1
       T0 = structInfo(ifile).T0;
    else
       T0 = min(T0,structInfo(ifile).T0);
    end
end

% Matching substances name
[StructOut.Subs StructOut.iSubs{1:Nnargin}] = match_names(structInfo(:).SubsName);
StructOut.nSubs = length(StructOut.Subs);

% Matching segments name
if strcmp(extId,'map')
   if ~all(structInfo(1).NumSegm==[structInfo(:).NumSegm])
      error('The number of segments does not match in the files');
   end
   StructOut.Segm = 1:structInfo(1).NumSegm;
   StructOut.iSegm(1:Nnargin) = {0};

elseif strcmp(extId,'his')
   [StructOut.Segm StructOut.iSegm{1:Nnargin}] = match_names(structInfo(:).SegmentName);
end
StructOut.nSegm = length(StructOut.Segm);

% Matching times
[StructOut.Time StructOut.iTime StructOut.UTime  StructOut.iUTime StructOut.iUFile] = match_times(structInfo(:),type);
StructOut.nTime = length(StructOut.Time);
StructOut.nUTime = length(StructOut.UTime);
StructOut.extId = extId;
StructOut.T0 = T0;

%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function varargout = match_names(varargin)

for i = 1:nargin
    namesIn{i} = lower(varargin{i});
end

names = namesIn{1};
nameOut = varargin{1};

for i = 1:nargin
    index = ismember(names,namesIn{i});
    names = names(index);
    nameOut = nameOut(index);
end
varargout{1} = nameOut;

for i = 1:nargin
    varargout{1+i} = find(ismember(namesIn{i},names));
end

%--------------------------------------------------------------------------
% Match times
%--------------------------------------------------------------------------
function [utime, utimeIndex, times, timeIndex, timeFile] = match_times(structIn,type)

if nargin==1
   type = 'last';
end 


nfile = length(structIn);

for i = 1:nfile
    times{i,1} = delwaq_datenum(structIn(i));
    timeFile{i,1} = ones(length(times{i}),1)*i; 
    timeIndex{i,1} = (1:length(times{i}))';    
end

for i = 1:nfile
    [utimes{i} uindex] = unique(times{i,1},'last');
    utimeIndex{i} = timeIndex{i,1}(uindex);
end

utime = utimes{1};
for i = 1:nfile
    it = ismember(utime,utimes{i});
    utime = utime(it);
end

for i = 1:nfile
    it = ismember(utimes{i},utime);
    utimeIndex{i} = utimeIndex{i}(it);
end

% all times
fnr = 1;
for i = 1:nfile
    mtimeIndex{i} = find(ismember(times{i},utime));
    if i>1
        if length(mtimeIndex{i})>length(mtimeIndex{fnr})
           fnr = i;
        end
    end
end

mtime = times{fnr}(mtimeIndex{fnr});
if strcmpi(type,'all')
   utime = mtime;
   for i = 1:nfile
       [~, utimeIndex{i}] = ismember(utime,times{i});
   end
end

times = cell2mat(times);
timeFile = cell2mat(timeFile);
timeIndex = cell2mat(timeIndex);

[times, index] = sort(times,1);
timeFile = timeFile(index);
timeIndex = timeIndex(index);

if any(strcmpi(type,{'first','last'}))
   [times, index] = unique(times,type);
   timeFile = timeFile(index);
   timeIndex = timeIndex(index);
end
