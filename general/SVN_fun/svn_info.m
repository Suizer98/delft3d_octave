function varargout = svn_info(varargin)
%SVN_INFO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = svn_info(varargin)
%
%   Input: For <keyword,value> pairs call svn_info() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   svn_info
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
% Created: 29 Jan 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = struct(...
    'revision', NaN);
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin{2:end});
%% code
if ~isnan(OPT.revision)
    rev = sprintf('--revision %i', OPT.revision);
else
    rev = '';
end

txt = SVNCall(sprintf('info "%s" %s', varargin{1}, rev));

s = regexp(strtrim(txt), '(: |\n)', 'split');

s(1:2:end) = cellfun(@(ss) lower(strrep(ss, ' ', '_')), s(1:2:end),...
    'UniformOutput', false);

varargout = {struct(s{:})};