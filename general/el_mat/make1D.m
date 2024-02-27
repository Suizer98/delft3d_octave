function Y = make1D(X,varargin)
%MAKE1D   reshape multi-dimensional matrix to vector
%
% same as Y = X(:) but very useful in
% expressions with subindexing like 
% Y = make1d(X(m1:m2,n1:n2,k1:k2))
%
% Y = make1D(x,'row')      returns a row    [1 x length(y)]
% Y = make1D(x,'col<umn>') returns a column [length(y) x 1]
%
% See also: RESHAPE, PERMUTE, SQUEEZE

% $Id: make1D.m 5449 2011-11-08 10:55:18Z boer_g $
% $Date: 2011-11-08 18:55:18 +0800 (Tue, 08 Nov 2011) $
% $Author: boer_g $
% $Revision: 5449 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/make1D.m $
% $Keywords$

% G.J. de Boer, 2004

%Y = reshape(X,[prod(size(X)),1]);

Y = X(:); % [column x 1]
if nargin > 1
    if strcmpi(varargin{1}(1:3),'row')
        Y = Y'; % [1 x row]
    end
end