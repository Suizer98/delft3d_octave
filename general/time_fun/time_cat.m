%TIME_CAT Concatenate times series.
%   T = TIME_CAT(T1,T2,..,Tn) concatenates the times T1,T2,..,Tn 
%
%   [T I J] = TIME_CAT(T1,T2,..,Tn) also returns index 
%   vectors I and J such that T = TI(J) where I = 1:n
%
%   [T I J] = TIME_CAT(T1,T2,..,Tn) also returns index 
%   vectors I and J such that T = TI(J). If there are repeated common 
%   values in T1,T2,..,Tn then the index of the occurrence specified 
%   in TYPE of each repeated value is returned. Available TYPE are:
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
function varargout = time_cat(varargin)

if any(strcmpi(varargin{end},{'last','first','all'}))
   type  = varargin{end};
   varargin = {varargin{1:end-1}}; %#ok<CCAT1>
else
   type  = 'last';
end

% Collecting all time records
nt = length(varargin);
collector  = [];
for i = 1:nt
    n = length(varargin{i}(:));
    local = [varargin{i}(:) (ones(n,1)*i) (1:n)'];
    collector = [collector; local]; %#ok<AGROW>
end
collector = sortrows(collector,1);


% Finding the index that correspond to the each unique time
if any(strcmpi(type,{'last','first'}))
  [~, iu] = unique(collector(:,1),type);
  collector = collector(iu,:);
end

varargout{1} = collector(:,1);
varargout{2} = collector(:,2);
varargout{3} = collector(:,3);
