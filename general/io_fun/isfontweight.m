function out = isfontweight(value)
%ISFONTWEIGHT check whether fontweight is a valid value
%See also: 

% $Id: isfontweight.m 10101 2014-01-30 15:53:54Z rho.x $
% $Date: 2014-01-30 23:53:54 +0800 (Thu, 30 Jan 2014) $
% $Author: rho.x $
% $Revision: 10101 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/isfontweight.m $
% $Keywords$

% out = any(fontweight(value,set(text,'FontWeight')));
out = any(strcmpi(value,set(text,'FontWeight')));

% EOF