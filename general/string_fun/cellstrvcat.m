function ab = cellstrvcat(a,b)
%CELLSTRVCAT  vertically concatenate cell strings.
%
%      S = STRVCAT(T1,T2)

%   forms the cellstr S containing the text of T1 and T2 as seperate elements.
%   Same as S = cellstr(strvcat(char(T1),T2)
%
%   See also CELLSTR, CHAR, STRVCAT, STRCAT.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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
% Created: 13 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: cellstrvcat.m 2141 2010-01-13 13:24:06Z boer_g $
% $Date: 2010-01-13 21:24:06 +0800 (Wed, 13 Jan 2010) $
% $Author: boer_g $
% $Revision: 2141 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/cellstrvcat.m $
% $Keywords: $

   ab = cellstr(strvcat(char(a),b));

%% EOF