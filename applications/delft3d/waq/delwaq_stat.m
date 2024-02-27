function structOut = delwaq_stat(File,File2Save,SubstanceNames,IntervalTime,Type)
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
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_DATENUM, DELWAQ_DIFF, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<5
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
   headerFlag = 'Statistics:';
else
   headerFlag = ['Statistics: (' Type ')'];   
end

if nargin<3
    SubstanceNames = struct1.SubsName;
elseif (nargin>=3 && isnumeric(SubstanceNames))
    if SubstanceNames==0
       SubstanceNames = struct1.SubsName;
    end
end

if nargin<4
    IntervalTime(1) = delwaq('read',struct1,1,1,1);
    IntervalTime(2) = delwaq('read',struct1,1,1,struct1.NTimes);
elseif(nargin>=4 && isscalar(IntervalTime) && IntervalTime==0)
    IntervalTime(1) = delwaq('read',struct1,1,1,1);
    IntervalTime(2) = delwaq('read',struct1,1,1,struct1.NTimes);
end
if nargin<2
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
Ntimes = length(Times);
Nsub   = length(SubsName);

% S = delwaq_intersect(File);
% S = delwaq_match(S,SubstanceNames,0, IntervalTime,1);

% New substance name
stat = getStatistics(nan,0,statId,Type);
nameStat = fieldnames(stat);
k = 1;
for iname = 1:length(nameStat)
    for isub = 1:length(SubsName)
        SubsName2{k} = [SubsName{isub} '_' nameStat{iname}];
        k = k+1;
    end
end
dataNaN = nan(length(SubsName2),struct1.NumSegm);


% Map file
if strcmp(extId,'map')    
   structOut = delwaq('write',File2Save,Header,SubsName2,refTime,Times(1),dataNaN);
% His file
elseif strcmp(extId,'his')
    structOut = delwaq('write',File2Save,Header,SubsName2,struct1.SegmentName,refTime,Times(1),dataNaN);
end


for it = 2:Ntimes
    data = dataNaN;
   fprintf('delwaq_stat progress:%1.0f/%1.0f(period) \n', it-1, Ntimes-1)

    if ~isempty(itime1{it-1})
       for iseg = 1:struct1.NumSegm
           %iseg
           [~, dataseg] = delwaq('read',struct1,isub1,iseg,itime1{it-1});    
           dataseg = squeeze(dataseg);
           if Nsub==1
              dataseg = dataseg(:)';
           end
               
           %-999
           dataseg(dataseg==-999) = nan;
           if any(~isnan(dataseg))
              stat = getStatistics(dataseg,2,statId,Type);
             D = cell2mat(struct2cell(stat));
	         D = D';
	         data(:,iseg) = D(:);
%              data(:,iseg) = cell2mat(struct2cell(stat));
           end
        end %iseg
        structOut = delwaq('write',structOut,Times(it),data);
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
function xStats = getStatistics(x,dim,statId,Type)

if dim == 0
   x = x(:); 
elseif dim == 2
   x = x';    
end

xStats = statistics(x,statId,Type);

%--------------------------------------------------------------------------
% Local Statistics
%--------------------------------------------------------------------------
function xStats = statistics(x,statId,Type)

switch Type
    case 'log'        
        x(x<=0) = nan;
        x = log(x);
    case 'log10'        
        x(x<=0) = nan;
        x = log10(x);
    case 'exp'        
        x = exp(x);
    case 'exp10'        
        x = 10.^x;
end


xStats.min = nanmin(x);
xStats.max = nanmax(x);
xStats.n = sum(~isnan(x));
P = perctile(x,[5 50 95]);
xStats.prc05 = P(1,:);
xStats.prc50 = P(2,:);
xStats.prc95 = P(3,:);
xStats.mean  = nanmean(x);
xStats.var   = nanvar(x);
xStats.std   = nanstd(x);

%if strcmp(statId,'error');
   xStats.mse  = nanmean(x.^2);
   xStats.rmse = sqrt(xStats.mse);
%end
%--------------------------------------------------------------------------
% Percentile
%--------------------------------------------------------------------------
function Xperc = perctile(x,prc)

Xperc = nan(length(prc),size(x,2));

for i = 1:size(x,2)
    xl = x(:,i);
    xl = xl(:);
    xl(isnan(xl)) = [];
    xl = sort(xl);
    n = length(xl);
    xperc = nan(length(prc),1);
    if n==1
        xperc(:) = xl;
    elseif n>=2
        xperc = interp1((1:n)/n,xl,(prc/100),'nearest','extrap');    
    end
    Xperc(:,i) = xperc;
end
