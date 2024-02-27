function varargout = svn_log(varargin)
%SVN_LOG  get subversion log.
%
%   Function to wrap the subversion command line client log command. The
%   result is provided as a structure.
%
%   Syntax:
%   varargout = svn_log(path, 'limit', 3)
%   varargout = svn_log(url)
%
%   Input: For <keyword,value> pairs call svn_log() without arguments.
%   varargin  =  'limit'   - maximum number of log entries
%
%   Output:
%   varargout =
%
%   Example
%   svn_log
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Jan 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: svn_log.m 14852 2018-11-28 08:21:56Z heijer $
% $Date: 2018-11-28 16:21:56 +0800 (Wed, 28 Nov 2018) $
% $Author: heijer $
% $Revision: 14852 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/svn_log.m $
% $Keywords: $

%%
OPT = struct(...
    'limit', []);
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin{2:end});
%% code
if ~isempty(OPT.limit)
    rev = sprintf('--limit %i', OPT.limit);
else
    rev = '';
end

txt = SVNCall(sprintf('log "%s" %s', varargin{1}, rev));

lines = regexp(txt, '^r\d+.*?$', 'match', 'lineanchors');

pat = 'r(?<revision>\d+) \| (?<user>\w+) ';
varargout = {cellfun(@(l) regexp(l, pat, 'names'), lines)};