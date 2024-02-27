function varargout = fig2data(varargin)
%FIG2DATA  Extract data from .fig-file.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = fig2data(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   fig2data
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Apr 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: fig2data.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/fig2data.m $
% $Keywords: $

%%
OPT = struct(...
    'figfile', '',...
    'DisplayName', '',...
    'data', {{'XData' 'YData'}});

OPT = setproperty(OPT, varargin{:});

if isempty(OPT.figfile)
    error('"figfile" must be specified')
end
if isempty(OPT.DisplayName)
    error('"DisplayName" must be specified')
end

%%
fig = open(OPT.figfile);

ax = gca;

lines = get(ax, 'children');

DisplayNames = get(lines, 'DisplayName');

durosta_id = strcmpi(DisplayNames, OPT.DisplayName);

for idata = 1:length(OPT.data)
    varargout{idata} = get(lines(durosta_id), OPT.data{idata});
end

close(fig)