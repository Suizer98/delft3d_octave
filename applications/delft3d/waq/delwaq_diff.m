%DELWAQ_DIFF Read Delwaq files and write a Difference file.
%
%   STRUCTOUT = DELWAQ_DIFF(FILE1,FILE2,FILE2SAVE,SUBSTANCENAMES,SEGMENTS,TYPE)
%   Reads FILE1 and FILE2, find the matchig fields:
%   substances/segments/stations/times in both files and write the
%   differences in FILE2SAVE map file.
%
%   STRUCTOUT = DELWAQ_DIFF(...,SUBSTANCESNAME,...) specifies substances to
%   be used. SUBSTANCESNAME = 0 for all substances.      
%
%   STRUCTOUT = DELWAQ_DIFF(...,TYPE) specifies alternate methods.  
%   The default is 'none'.  Available methods are:
%  
%       'none'    - Difference: File1-File2
%       'abs'     - Difference: abs(File1-File2)
%       'perc'    - Percentage difference: (File1-File2)/File1
%       'log'     - Difference of natural logarithm: log(File1)-log(File2)
%       'log10'   - Difference of base 10 logarithm: log10(File1)-log10(File2)
%       'absperc' - Absolute Percentage difference: abs(File1-File2)/File1
%       'abslog'  - Absolute Difference of natural logarithm:
%                   abs(log(File1)-log(File2))
%       'abslog10'- Absolute Difference of base 10 logarithm:
%                 abs(log10(File1)-log10(File2))
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_diff(File1,File2,File2Save,SubstanceNames,Segments,Type)

if nargin<4
   SubstanceNames = 0;
end
if nargin<5
   Segments = 0;
end
if nargin<6
    Type = 'none';
end

[~, name1, ext1] = fileparts(File1);
[~, name2, ext2] = fileparts(File2);

if strcmp(Type,'none')
   headerFlag = 'Difference:';
else
   headerFlag = ['Difference: (' Type ')'];   
end

S = delwaq_intersect(File1,File2,'all');

% Matching SubsName
[S.Subs isub] = match_names(S.Subs,SubstanceNames);
for i = 1:length(S.iSubs)
    S.iSubs{i} = S.iSubs{i}(isub);
end

if isempty(S.Subs)
   disp('There is any match in the substance name');
   return 
end


% Header
Header = {headerFlag; ['(' name1 ext1 ') - (' name2 ext2 ')']};
Header = char(Header);

% Opening Files
struct1 = delwaq('open',File1);
struct2 = delwaq('open',File2);

% Setting time reference
T0 = S.T0;
refTime =  [T0 1];

% Matching Subs
if isempty(S.Subs)
   disp('There is no match in the substance');
   return 
end


% Matching Segm
if isempty(S.Segm)
   disp('There is no match in the segments');
   return 
end

% Matching Times
if isempty(S.Time)
   disp('There is no match in the times');
   return 
end

        
  
switch S.extId
    case 'map'
    S.Segm = Segments;
    S.iSegm{1} = Segments;
    S.iSegm{2} = Segments;

    for it = 1:S.nTime
        disp(['delwaq_diff progress:' num2str(it) '/' num2str(S.nTime)])

        [time1 data1] = delwaq('read',struct1,S.iSubs{1},S.iSegm{1},S.iTime{1}(it));
        [~,    data2] = delwaq('read',struct2,S.iSubs{2},S.iSegm{2},S.iTime{2}(it));
        
        % Difference
         data = diff_data(data1,data2,Type);

        % Writing a File
        if it == 1
            structOut = delwaq('write',File2Save,Header,S.Subs,refTime,time1,data);
        else
            structOut = delwaq('write',structOut,time1,data);
        end
    end

    
   case 'his'
    intertime = 0:100:S.nTime;
    if ~ismember(S.nTime,intertime)
        intertime = [intertime S.nTime];
    end
    nTimes = length(intertime);
    
    for it = 2:nTimes
        t1 = intertime(it-1)+1;
        t2 = intertime(it);
        
        disp(['delwaq_diff progress:' num2str(t2) '/' num2str(S.nTime)])

        [time1 data1] = delwaq('read',struct1,S.iSubs{1},S.iSegm{1},S.iTime{1}(t1:t2));
        [~,    data2] = delwaq('read',struct2,S.iSubs{2},S.iSegm{2},S.iTime{2}(t1:t2));
        
        % Difference
         data = diff_data(data1,data2,Type);
         
        % Writing a File
        if it == 2
           structOut = delwaq('write',File2Save,Header,S.Subs,S.Segm,refTime,time1,data);
        else
           structOut = delwaq('write',structOut,time1,data);
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
    isub1 = find(strcmpi(name1,name2{i}));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end

%--------------------------------------------------------------------------
% Difference in data
%--------------------------------------------------------------------------
function data = diff_data(data1,data2,Type)

data1(data1==-999) = nan;
data2(data2==-999) = nan;   

switch Type
    case 'none'
        data = data1-data2;
    case 'abs'
        data = abs(data1-data2);
    case 'perc'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log10(data1);
        data2 = log10(data2);
        data = (data1-data2)./data1;
    case 'log'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log(data1);
        data2 = log(data2);
        data = data1-data2;
    case 'log10'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log10(data1);
        data2 = log10(data2);
        data = data1-data2;
    case 'absperc'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log10(data1);
        data2 = log10(data2);
        data = abs(data1-data2)./data1;
    case 'abslog'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log(data1);
        data2 = log(data2);
        data = abs(data1-data2);
    case 'abslog10'        
        data1(data1<=0) = nan;
        data2(data2<=0) = nan;
        data1 = log10(data1);
        data2 = log10(data2);
        data = abs(data1-data2);

end


