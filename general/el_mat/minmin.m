function [varargout] = minmin(x,varargin);
%MINMIN    Calculates minimum of all dimensions of an array.
%
%   min_of_x = minmin(x) calculates minimum of all dimensions
%   of array x. Similar to min(array(:)), but useful when you 
%   would like to have the minimum of a subset of an n-dimensional 
%   array, in which case it is not possible to use a single
%   colon symbol ':' to treat the array as 1-dimensional.
%
%   mix_of_x = minmin(x,'no_inf') does not take into account -Inf
%   if such a value is present in the array. So
%   minmin = ([-Inf,-1]) is -1;
%
%    Example:
%    minmin(array(1:floor(end/2),ceil(end/2):end,:))
%
%   See also: MAXMAX

%   G.J. de Boer, Delft Univeristy of Technology
%   Feb 2004, version 1.0

% $Id: minmin.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/minmin.m $
% $Keywords$

if nargin == 2
   x(isinf(x))=nan;
end

 varargout = {min(x(:))};
%varargout = {min(reshape(x,prod(size(x)),1))};
