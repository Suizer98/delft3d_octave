%DELWAQ_RENAME Rename values of a field in a Delwaq MAP/HIS file.
%
%   STRUCTOUT = DELWAQ_RENAME(FILENAME,'TSM','TIM','SUBS')
%   Reads FILENAME, remplace VALUE with NEWVALUE in FIELD.
%
%   VALUE and NEWVALUE must be the same length.
%
%   FIELD can take the following options
%       'subs' To change substances
%       'segm' To change segemnts name (stations in HIS files)
%       'time' To change the time stamp
%
%   NOTE: If VALUE==0 then all the calues in FIELD will be changed.
%
%   See also: DELWAQ, DELWAQ_SPLIT_LAYES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT, DELWAQ_DATENUM

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Mar-06 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_rename(FileName,Value,newValue,field)

[path1 name1 ext1] = fileparts(FileName);
FileTest = fullfile(path1, [name1 '_rename' ext1]);

% Opening Files
struct1 = delwaq('open',FileName);
time1 = delwaq_datenum(struct1);

switch  field
    
    % Matching SubsName
    case 'subs'
        if isnumeric(Value) && Value==0
           SubstanceNr = 1:length(struct1.SubsName);
           nValue = newValue;
        else
           [~, SubstanceNr] = match_names(struct1.SubsName,Value);
           if iscell(Value)
              nV = length(Value);
           elseif ischar(Value)
               nV = 1;
           end
           nValue{1} = newValue;
        end
        for isub = 1:nV
            struct1.SubsName{SubstanceNr(isub)} = nValue{isub};
        end
        if isempty(SubstanceNr)
           disp('There is any match in the substance name');
           return 
        end
        
    % Matching SegmentNr
    case 'segm'
        if isnumeric(Value) && Value==0
           SegmentNr = 1:struct1.NumSegm;
           nValue = newValue;
        else
           [~, SegmentNr] = match_names(struct1.SegmentName,Value);
           if iscell(Value)
              nV = length(Value);
           elseif ischar(Value)
               nV = 1;
           end
           nValue{1} = newValue;
        end
        for iseg = 1:nV
            struct1.SegmentName{SegmentNr(iseg)} = nValue{iseg};
        end
        if isempty(SegmentNr)
           disp('There is any match in the segments name');
           return 
        end
        
    % Matching Time
    case 'time'
        if Value==0
           it = 1:struct1.NTimes;
           iv = 1:length(newValue);
        else
           [time, it, iv] = intersect(time1, Value);

        end
           time1(it) = newValue(iv);
        if isempty(time)
           disp('There is any match in time');
           return 
        end
end

% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

% Read data
for it = 1:struct1.NTimes
    [~, data] = delwaq('read',struct1,0,0,it);
    disp(['delwaq_rename:' num2str(it) '/' num2str(struct1.NTimes)])
        
     % Writing a File
     if strcmpi(ext1,'.map')
         if it==1
            File2Save = FileTest;
            structOut = delwaq('write',File2Save,Header,struct1.SubsName,refTime,time1(it),data);
         else
            structOut = delwaq('write',structOut,time1(it),data);
         end
     elseif strcmpi(ext1,'.his')
         if it==1
            File2Save = FileTest;
            structOut = delwaq('write',File2Save,Header,struct1.SubsName,struct1.SegmentName,refTime,time1(it),data);
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
