function url = oeturl(varargin)
%OETURL  Returns the URL to the OET repository
%
%   Returns the URL to the OET repository
%
%   Syntax:
%   url = oeturl
%
%   Input:
%   varargin  = none
%
%   Output:
%   url       = URL to repository
%
%   Example
%   url = oeturl
%
%   See also oetroot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 11 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: oeturl.m 5419 2011-11-02 12:33:47Z hoonhout $
% $Date: 2011-11-02 20:33:47 +0800 (Wed, 02 Nov 2011) $
% $Author: hoonhout $
% $Revision: 5419 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oeturl.m $
% $Keywords: $

%% determine url

re = regexp('$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oeturl.m $', ['^\$HeadURL:\s+(.+trunk/matlab/)'], 'tokens');

if ~isempty(re)
    url = re{1}{1};
else
    url = '';
end
