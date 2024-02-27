function out = islocation(value)
%ISLOCATION check whether value is a valid Location
%See also: 

% $Id: islocation.m 10241 2014-02-18 12:43:53Z tda.x $
% $Date: 2014-02-18 20:43:53 +0800 (Tue, 18 Feb 2014) $
% $Author: tda.x $
% $Revision: 10241 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/islocation.m $
% $Keywords$

out = any(strcmpi(value,{
    'Center'
    'North'
    'South'
    'East'
    'West'
    'NorthEast'
    'SouthEast'
    'NorthWest'
    'SouthWest'    
}));

% EOF
