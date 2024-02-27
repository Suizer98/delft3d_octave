function structOut = delwaq_split_subs(FileName,SubstanceNames)
%DELWAQ_SPLIT_SUBS Read and split in substances a Delwaq MAP file.
%
%   STRUCTOUT = DELWAQ_SPLIT_SUBS(FILENAME,SUBSTANCENAMES)
%   Reads FILENAME, split the map file into substances. The substances to be
%   used are specidied in specified in SUBSTANCENAMES.
%   A new file is created ans named as: FILENAME_SUBSTANCENAMES.MAP 
%   
%   NOTE: If SUBSTANCENAMES is not provides or SUBSTANCENAMES==0 then all
%   the substances are used.
%
%   See also: DELWAQ, DELWAQ_SPLIT_LAYES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT, DELWAQ_DATENUM

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Mar-06 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<2
   SubstanceNames = 0;
end

[path1 name1 ext1] = fileparts(FileName);

% Opening Files
struct1 = delwaq('open',FileName);

% Matching SubsName
[SubstanceNames SubstanceNr] = match_names(struct1.SubsName,SubstanceNames);

if isempty(SubstanceNr)
   disp('There is any match in the substance name');
   return 
end


% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

nsub = length(SubstanceNr);

% Read data
for it = 1:struct1.NTimes
    [time alldata] = delwaq('read',struct1,SubstanceNr,0,it);
    disp(['delwaq_split_subs progress:' num2str(it) '/' num2str(struct1.NTimes)])

    for isub = 1:nsub
        data = alldata(isub,:);
        
        % Writing a File
        if it==1
            fileName = [name1 '_' SubstanceNames{isub} ext1];
            File2Save = fullfile(path1,fileName);
            structOut{isub} = delwaq('write',File2Save,Header,SubstanceNames{isub},refTime,time,data);
        else
            structOut{isub} = delwaq('write',structOut{isub},time,data);
        end
    end
        
end


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
