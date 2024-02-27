function s = num2strll(lat,lon,varargin)
%num2strll print coordinate tuple for matlab title
%
%   s = num2strll(lat,lon,<fmt>)
%
% 
%
%See also: tickmap, axislat

fmt = '%g';

if nargin==3
   fmt = varargin{1};
end

s   = ['[',num2str(lat,fmt),'\circN,',num2str(lon,fmt),'\circE]'];