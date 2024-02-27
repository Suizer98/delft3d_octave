function out = isstring(value)
%ISSTRING check whether value is a valid string (for string property in)
%See also: 

% $Id: isstring2.m 12243 2015-09-16 23:50:35Z omouraenko.x $
% $Date: 2015-09-17 07:50:35 +0800 (Thu, 17 Sep 2015) $
% $Author: omouraenko.x $
% $Revision: 12243 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/isstring2.m $
% $Keywords$
out =  ischar(value) || iscellstr(value);

% EOF
