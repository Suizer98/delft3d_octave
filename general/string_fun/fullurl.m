function url = fullurl(varargin)
%FULLURL  Construct url based on elements
%
%   Construct a complete url based on a series of elements.
%
%   Syntax:
%   url = fullurl(varargin)
%
%   Input:
%   varargin = series of strings containing url elements
%
%   Output:
%   url      = url string
%
%   Example
%   fullurl('http://', 'opendap.deltares.nl', 'opendap')
%
%   See also fullfile

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 01 Dec 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: fullurl.m 3472 2010-12-01 13:18:00Z heijer $
% $Date: 2010-12-01 21:18:00 +0800 (Wed, 01 Dec 2010) $
% $Author: heijer $
% $Revision: 3472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/fullurl.m $
% $Keywords: $

%%
% split up url in elements
elements = {};
for iarg = 1:length(varargin)
    elements = [elements; strread(varargin{iarg}, '%s',...
        'delimiter', '/')];
end

% construct url
url = sprintf('%s/', elements{~cellfun(@isempty,elements)});
% omit / at the end and bring in // (TODO: make more generic)
url = strrep(url(1:end-1), ':/', '://');