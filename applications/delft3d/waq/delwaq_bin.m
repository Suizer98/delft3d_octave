function inbin = delwaq_bin(File,bin,SubstanceNames,IntervalTime,Segments,Type)
%DELWAQ_STAT Read Delwaq files values and write a statistics file.
%
%   STRUCTOUT = DELWAQ_STAT(FILE,BIN,SUBSTANCENAMES,INTERVALTIME,TYPE)
%   writes the data to a Delwaq HIS/MAP file.
%
%   STRUCTOUT = DELWAQ_STAT(FILE1,BIN)
%   Reads FILE1 computes statistics and write results in BIN map file.
%
%   STRUCTOUT = DELWAQ_STAT(...,INTERVALTIME,...) specifies the time
%   intervals that will be used to compute the statistics. If INTERVALTIME
%   is empty then the statistics computed correspond to all times in FILE
%
%   STRUCTOUT = DELWAQ_STAT(...,SUBSTANCESNAME,...) specifies substances to
%   be used. SUBSTANCESNAME = 0 for all substances.      
%
%   STRUCTOUT = DELWAQ_STAT(...,TYPE) specifies alternate methods.  
%   The default is 'none'.  Available methods are:
%  
%       'log'  - Natural logarithm: log(File)
%       'log10'- Base 10 logarithm: log10(File)
% 
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_DIFF, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<6
    Type = 'none';
end

[~, ~, ext] = fileparts(File);

if strcmpi(ext,'.map')
   extId = 'map';
elseif strcmpi(ext,'.his')
   extId = 'his';
else
   error('unknow extension')
end

% Opening Files
struct1 = delwaq('open',File);


if nargin<3
    SubstanceNames = struct1.SubsName;
elseif (nargin>=3 && isnumeric(SubstanceNames))
    if SubstanceNames==0
       SubstanceNames = struct1.SubsName;
    end
end


if nargin<3
    SubstanceNames = struct1.SubsName{1};
elseif (nargin>=3 && isnumeric(SubstanceNames))
    if SubstanceNames==0
       SubstanceNames = struct1.SubsName{1};
    end
end
if  iscell(SubstanceNames) && length(SubstanceNames)>1
    SubstanceNames = SubstanceNames{1};
    disp('Only the first substance will be used')
end

if nargin<4
    iseg = 1:struct1.NumSegm;
elseif (nargin>=3 && isnumeric(Segments))
    if Segments==0
       iseg = 1:struct1.NumSegm;
    else
       iseg = Segments;
    end
end
if nargin<5
    IntervalTime(1) = delwaq('read',struct1,1,1,1);
    IntervalTime(2) = delwaq('read',struct1,1,1,struct1.NTimes);
elseif(nargin>=4 && isscalar(IntervalTime) && IntervalTime==0)
    IntervalTime(1) = delwaq('read',struct1,1,1,1);
    IntervalTime(2) = delwaq('read',struct1,1,1,struct1.NTimes);
elseif(nargin>=4 && isempty(IntervalTime))
    IntervalTime = delwaq_datenum(struct1);
end
if nargin<2
   Type = 'none';
end

if any(ismember( cellstr(struct1.Header),'Difference:'))
   statId = 'error';
else
   statId = 'stat';
end


% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

% Matching SubsName
[SubsName isub1] = match_names(struct1.SubsName,SubstanceNames);
if isempty(SubsName)
   disp('There is any match in the substance name');
   return 
end
    
% Matching times
[Times itime1] = match_times(struct1,IntervalTime);
if isempty(Times)
   disp('There is any match in the times');
   return 
end
% Ntimes = length(Times);
% [~, systemview] = memory;
% maxarray = systemview.VirtualAddressSpace.Available/100;
% tt = min(floor(maxarray/struct1.NumSegm),struct1.NTimes);
% 1:tt:struct1.NTimes
% 
inbin = zeros(1,length(bin));

for it = 1:struct1.NTimes
   fprintf('delwaq_bin progress:%1.0f/%1.0f(times) \n', it, struct1.NTimes)
   [~, data] = delwaq('read',struct1,isub1,iseg,it);    
   data(data==-999) = nan;
   data = data(:);
   lbin = getbin(data,bin,Type);
   inbin = nansum([inbin; lbin],1);
end%it

    
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
    if length(name2)==1 && name==0
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

%--------------------------------------------------------------------------
% Match times
%--------------------------------------------------------------------------
function [tinterval, itime1 itime2] = match_times(struct1,tinterval)

% Time1 = delwaq_time(struct1,'datenum',1);
Time1 = delwaq_datenum(struct1);

for it = 1:length(tinterval)-1
    if it==length(tinterval)-1
       itime1{it} = find((Time1 >= tinterval(it)) & (Time1 <= tinterval(it+1)));
    else
       itime1{it} = find((Time1 >= tinterval(it)) & (Time1 < tinterval(it+1)));
    end
    itime2(it) = it;
    
end


%--------------------------------------------------------------------------
% Local Statistics
%--------------------------------------------------------------------------
function [nbin bin] = getbin(x,bin,Type)


switch Type
    case 'log'        
        x(x<=0) = nan;
        x = log(x);
    case 'log10'        
        x(x<=0) = nan;
        x = log10(x);
    case 'clog'        
        x(x<0) = nan;
        x = log(x+1);
    case 'clog10'        
        x(x<0) = nan;
        x = log10(x+1);
    case 'exp'        
        x = exp(x);
    case 'exp10'        
        x = 10.^x;
end

nbin = histc(x,bin)';
