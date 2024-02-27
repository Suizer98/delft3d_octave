function out = isposition(value)
%ISPOSITION check whether value is a valid position (for figures etc)
%See also: 

% $Id: isposition.m 9909 2013-12-19 21:44:01Z tda.x $
% $Date: 2013-12-20 05:44:01 +0800 (Fri, 20 Dec 2013) $
% $Author: tda.x $
% $Revision: 9909 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/isposition.m $
% $Keywords$
out =  isequal(size(value),[1,4]) && isnumeric(value);

% EOF