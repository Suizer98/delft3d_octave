function nout = delwaq_thist(File,nbins,SubstanceNames,Segments,IntervalTime,Type)
%DELWAQ_STAT Read Delwaq files values and write a statistics file.
%
%   STRUCTOUT = DELWAQ_STAT(FILE,FILE2SAVE,SUBSTANCENAMES,INTERVALTIME,TYPE)
%   writes the data to a Delwaq HIS/MAP file.
%
%   STRUCTOUT = DELWAQ_STAT(FILE1,FILE2SAVE)
%   Reads FILE1 computes statistics and write results in FILE2SAVE map file.
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

%   Copyright 2012 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Feb-17 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<6
    Type = 'none';
end

[~, name, ext] = fileparts(File);

if strcmpi(ext,'.map')
   extId = 'map';
elseif strcmpi(ext,'.his')
   extId = 'his';
else
   error('unknow extension')
end

% Opening Files
struct1 = delwaq('open',File);

if strcmp(Type,'none')
   fileFlag = 'STAT';
   headerFlag = 'Statistics: ';
elseif strcmp(Type,'log')
   fileFlag = 'STATLOG';
   headerFlag = 'Statistics: (log)';
elseif strcmp(Type,'log10')
   fileFlag = 'STATLOG10';
   headerFlag = 'Statistics: (log10)';
elseif strcmp(Type,'exp')
   fileFlag = 'STATEXP';
   headerFlag = 'Statistics: (exp)';
elseif strcmp(Type,'exp10')
   fileFlag = 'STATEXP10';
   headerFlag = 'Statistics: (exp10)';
end

% if nargin<2 ||(nargin>=2 && isempty(File2Save))
%     File2Save = [fileFlag '(' name1 ')' ext1];
% end

if nargin<3
    SubstanceNames = struct1.SubsName;
elseif (nargin>=3 && isnumeric(SubstanceNames))
    if SubstanceNames==0
       SubstanceNames = struct1.SubsName;
    end
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
end
if nargin<6
   Type = 'none';
end

if any(ismember( cellstr(struct1.Header),'Difference:'))
   statId = 'error';
else
   statId = 'stat';
end


% Header
Header = {headerFlag ; [ name ext ]};
Header = char(Header);


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
Ntimes = 1;
Nsub   = length(SubsName);

% S = delwaq_intersect(File);
% S = delwaq_match(S,SubstanceNames,0, IntervalTime,1);

% New substance name
% stat = getStatistics(nan,0,statId,Type);
% n = getbin(x,nbins,Type);
% nameStat = fieldnames(stat);
% k = 1;
% for iname = 1:length(nameStat)
%     for isub = 1:length(SubsName)
%         SubsName2{k} = [SubsName{isub} '_' nameStat{iname}];
%         k = k+1;
%     end
% end
nout = nan(length(Segments),length(nbins));
% SegName = ['seg(' num2str(min(iseg)) ':' num2str(max(iseg)) ')'];

% % Map file
% if strcmp(extId,'map')    
%    structOut = delwaq('write',File2Save,Header,SubsName2,SegName,refTime,Times(1),dataNaN);
% % His file
% elseif strcmp(extId,'his')
%     structOut = delwaq('write',File2Save,Header,SubsName2,SegName,refTime,Times(1),dataNaN);
% end


for it = 1:Ntimes
%    fprintf('delwaq_stat progress:%1.0f/%1.0f(period) \n', it-1, Ntimes-1)

    if ~isempty(itime1{it})
        [~, dataseg] = delwaq('read',struct1,isub1,iseg,itime1{it});    
        dataseg = squeeze(dataseg);
         if Nsub==1
            dataseg = dataseg(:)';
         end
               
        %-999
        dataseg(dataseg==-999) = nan;
        if any(~isnan(dataseg))
           n = getbin(dataseg,nbins,Type);
           nout = n;
        end
%         structOut = delwaq('write',structOut,Times(it),data);
    end
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
    isub1 = find(strcmpi(name1,name2{i}));
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
% Statistics
%--------------------------------------------------------------------------
function n = getbin(x,nbins,Type)

switch Type
    case 'log'        
        x(x<=0.002) = nan;
        x = log(x);
    case 'log10'        
        x(x<=0) = nan;
        x = log10(x);
    case 'exp'        
        x = exp(x);
    case 'exp10'        
        x = 10.^x;
end
for i = 1:size(x,1)
    xlocal = x(i,:);
    xlocal = xlocal(:);
    xlocal(isnan(xlocal)) = [];
    n(i,:) = hist(xlocal,nbins);
end

