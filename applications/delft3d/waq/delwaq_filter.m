%DELWAQ_FILTER Filters values of a given field in a Delwaq MAP/HIS file.
%
%   STRUCTOUT = DELWAQ_RENAME(FILENAME,SUBSTANCE,SEGMENT,TIME,ACTION)
%
%   STRUCTOUT = DELWAQ_RENAME(FILENAME,'TSM','STATION1',0,'HOLD')
%   Reads FILENAME and only keeps the corresponding values to TSM at
%   STATION1 for all times in the MAP/HIS file.
%
%   STRUCTOUT = DELWAQ_RENAME(FILENAME,0,0,1:50,'HOLD')
%   Reads FILENAME and only keeps the corresponding values to all substances
%   in all segments from the first time to the 50th time record in the 
%   MAP/HIS file.
%
%   STRUCTOUT = DELWAQ_RENAME(FILENAME,[],[],1:50,'HOLD')
%   Reads FILENAME and only cuts the corresponding values to all substances
%   in all segments from the first time to the 50th time record in the 
%   MAP/HIS file.
%
%   ACTION can take the following options
%       'hold' To keep values
%       'cut'  To cut the values
%
%   NOTE: If SUBSTANCE==0 means all substances in the file.
%         If SUBSTANCE==[] means none substances in the file.
%
%   See also: DELWAQ_RENAME, DELWAQ_SPLIT_LAYES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT, DELWAQ_DATENUM

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Mar-06 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_filter(FileName,substanceName,segmentName,Time,action)

[path1 name1 ext1] = fileparts(FileName);
FileTest = fullfile(path1, [name1 '_filter' ext1]);

% Opening Files
struct1 = delwaq('open',FileName);
time1 = delwaq_datenum(struct1);

% Matching SubsName
if isnumeric(substanceName) 
   if isempty(substanceName)
      SubstanceNr = [];
   elseif substanceName==0
    SubstanceNr = 1:length(struct1.SubsName);
   end
else
    [~, SubstanceNr] = match_names(struct1.SubsName,substanceName);
end
           
        
% Matching SegmentNr
if isnumeric(segmentName)
   if isempty(segmentName)
       SegmentNr = [];
   elseif segmentName==0
      SegmentNr = 1:struct1.NumSegm;
    end
else
   [~, SegmentNr] = match_names(struct1.SegmentName,segmentName);
end

  
% Matching Time
if Time==0
   it = 1:struct1.NTimes;
elseif max(Time)<=struct1.NTimes && min(Time)>=1
   it = Time;
else
   [~, it] = intersect(time1, Time);
end
        

switch  action
    case 'hold'
        isub = SubstanceNr;
        iseg = SegmentNr;
        itime = it;
    case 'cut'
        isub = setxor(1:length(struct1.SubsName), SubstanceNr);
        iseg = setxor(1:struct1.NumSegm, SegmentNr);
        itime = setxor(1:struct1.NTimes, it);                       
end

if isempty(isub)
   disp('There is any match in the substance name');
   return 
end

if isempty(iseg)
   disp('There is any match in the segments name');
   return 
end

if isempty(time1)
   disp('There is any match in time');
   return 
end

time1 = time1(itime);

% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

% Read data
for it = 1:length(time1)
    [~, data] = delwaq('read',struct1,isub,iseg,it);
    disp(['delwaq_rename:' num2str(it) '/' num2str(struct1.NTimes)])
        
     % Writing a File
     if strcmpi(ext1,'.map')
         if it==1
            File2Save = FileTest;
            structOut = delwaq('write',File2Save,Header,{struct1.SubsName{isub}},refTime,time1(it),data);
         else
            structOut = delwaq('write',structOut,time1(it),data);
         end
     elseif strcmpi(ext1,'.his')
         if it==1
            File2Save = FileTest;
            structOut = delwaq('write',File2Save,Header,{struct1.SubsName{isub}},{struct1.SegmentName{iseg}},refTime,time1(it),data);
         else
            structOut = delwaq('write',structOut,time1(it),data);
         end
     end
end
copyfile(FileTest,FileName)
delete(FileTest)

%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function [names iname1 iname2] = match_names(name1,name2)

iname1 = [];
iname2 = [];
names  = [];
name1 = lower(name1);
name2 = lower(name2);

if ischar(name2)
   name2 = cellstr(name2);
elseif isnumeric(name2);
    if length(name2)==1 && name2==0
       name2 = 1:length(name1);
    end
    name2 = name1(name2);
end

k = 0;
for i = 1:length(name2)
    isub1 = find(strcmp(name1,name2{i}));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end
