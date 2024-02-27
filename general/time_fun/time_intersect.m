%TIME_INTERSECT Set intersection in different time series.
%   T = TIME_INTERSECT(T1,T2,..,Tn) for vectors T1, T2,...,Tn returns the
%   values common to the vectors with no repetitions. T will be sorted.
%
%   [T IT1,IT2,..,ITn]= TIME_INTERSECT(T1,T2,..,Tn) also returns index 
%   vectors IT1,IT2,..,ITn such that T = T1(IT1),T = T2(IT2),...,
%   T = T3(IT3). If there are repeated common values in T1,T2,..,Tn
%   then the index of the LAST occurrence of each repeated value is
%   returned.
%
%   [T IT1,IT2,..,ITn]= TIME_INTERSECT(T1,T2,..,Tn,TYPE) also returns index 
%   vectors IT1,IT2,..,ITn such that T = T1(IT1),T = T2(IT2),...,
%   T = T3(IT3). If there are repeated common values in T1,T2,..,Tn
%   then the index of the occurrence specified in TYPE of each repeated 
%   value is returned. Available TYPE are:
%
%       'all'   - all occurrence
%       'first' - first occurrence
%       'last'  - last occurrence
%
%   See also: TIME_CAT, TIME_ROUND 

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 19.06.2008
%      Author: S. Gaytan Aguilar
%--------------------------------------------------------------------------
function varargout = time_intersect(varargin)

if any(strcmpi(varargin{end},{'last','first','all'}))
   type  = varargin{end};
   varargin = {varargin{1:end-1}}; %#ok<CCAT1>
else
   type  = 'all';
end


% Preallocating
nt = length(varargin);
utimes(1:nt) = {[]};
iutimes(1:nt) = {[]};

% Finding the index that correspond to the each unique time
if strcmpi(type,'all')
   for i = 1:nt
      iutimes{i} = false(size(varargin{i}));
      [utimes{i} iu] = unique(varargin{i});
      iutimes{i}(iu) = 1;
   end
else
   for i = 1:nt
      iutimes{i} = false(size(varargin{i}));
      [utimes{i} iu] = unique(varargin{i},type);
      iutimes{i}(iu) = 1;
   end
end

% Finding the unique time
uniqueTime =  utimes{1};
for i = 1:nt
   iut = istime(uniqueTime,utimes{i});
   uniqueTime = uniqueTime(iut);
end

% Finding the intersection time
varargout(1:nt+1) = {[]};
varargout{1} = uniqueTime;
for i = 1:nt
    varargout{1+i} = find(istime(varargin{i},uniqueTime) & iutimes{i});
end

