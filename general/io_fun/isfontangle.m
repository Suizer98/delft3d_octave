function out = isfontangle(fontangle)
%ISFONTANGLE check whether fontangle is a valid value
%See also: 

% $Id: isfontangle.m 9909 2013-12-19 21:44:01Z tda.x $
% $Date: 2013-12-20 05:44:01 +0800 (Fri, 20 Dec 2013) $
% $Author: tda.x $
% $Revision: 9909 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/isfontangle.m $
% $Keywords$

out = any(fontangle(value,set(text,'FontAngle')));

% EOF