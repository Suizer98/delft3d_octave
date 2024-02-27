function OK = isurl(str)
%ISURL   boolean whether char is url or not
%
% ok = isurl(string)
%
% See also: urlread

% $Id: isurl.m 10949 2014-07-10 19:55:32Z heijer $
% $Date: 2014-07-11 03:55:32 +0800 (Fri, 11 Jul 2014) $
% $Author: heijer $
% $Revision: 10949 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/isurl.m $
% $Keywords$

%%
% check whether string starts with http:// https:// or ftp://
% check is case insensitive
OK = ~isempty(regexpi(str, '^(h|f)tt?ps?://'));
% return boolean

%% EOF
