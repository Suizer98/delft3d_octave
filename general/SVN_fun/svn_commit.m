function varargout = svn_commit(varargin)
%SVN_COMMIT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = svn_commit(varargin)
%
%   Input: For <keyword,value> pairs call svn_commit() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   svn_commit
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
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
% Created: 25 Mar 2015
% Created with Matlab version: 8.5.0.173394 (R2015a)

% $Id: svn_commit.m 14852 2018-11-28 08:21:56Z heijer $
% $Date: 2018-11-28 16:21:56 +0800 (Wed, 28 Nov 2018) $
% $Author: heijer $
% $Revision: 14852 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/svn_commit.m $
% $Keywords: $

%%
OPT = struct(...
    'verbose', false,...
    'message', '');
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end

idx = cellfun(@(s) any(strcmp(fieldnames(OPT), s)), varargin);
idx = idx | [false idx(1:end-1)];
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin{idx});
if isempty(OPT.message)
    error('no message provided')
end
%% code
filelist = sprintf('"%s" ', varargin{~idx});

txt = SVNCall(sprintf('commit --message "%s" %s', OPT.message, filelist));

if OPT.verbose
    varargout = {txt};
end