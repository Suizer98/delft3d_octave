function varargout = svn_add(varargin)
%SVN_ADD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = svn_add(varargin)
%
%   Input: For <keyword,value> pairs call svn_add() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   svn_add
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

% $Id: svn_add.m 11830 2015-03-25 14:34:34Z heijer $
% $Date: 2015-03-25 22:34:34 +0800 (Wed, 25 Mar 2015) $
% $Author: heijer $
% $Revision: 11830 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/svn_add.m $
% $Keywords: $

%%
OPT = struct(...
    'verbose', false);
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin{2:end});
%% code
filelist = sprintf('"%s" ', varargin{:});

txt = SVNCall(sprintf('add %s', filelist));

if OPT.verbose
    varargout = {txt};
end