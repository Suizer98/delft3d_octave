function y = nanrms(x,varargin)
%NANRMS	Root mean square.
%
% For vectors, NANRMS(x) returns the root mean square.
% For matrices, NANRMS(X) is a row vector containing the
% root mean square of each column. All NaN valuez
% are neglected.
%
% NANRMS(X,DIM) takes the rms along the dimension DIM of X. 
%
%See also: RMS, nanMEAN, nanMAX, nanMIN, STD

% $Id: nanrms.m 5495 2011-11-17 12:42:49Z boer_g $
% $Date: 2011-11-17 20:42:49 +0800 (Thu, 17 Nov 2011) $
% $Author: boer_g $
% $Revision: 5495 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/nanrms.m $
% $Keywords$

if isempty(x)
	y = NaN;
	return
end

    y = sqrt(nanmean(x.^2,varargin{:}));
