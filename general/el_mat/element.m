function e = element(x,i)
%ELEMENT selects ith indexed element from numeric or cell array
%
%   e = element(x,i)
%
% selects the ith indexed element from cell array or num array x.
%
% Example: 
%
%   element([7 8 9],2)           is  8
%   element({'a','b','c'},2)     is 'b'
%
%See also: sub2ind, ind2sub, cellfun, structfun

if iscell(x)
    e = x{i};
else
    e = x(i);
end