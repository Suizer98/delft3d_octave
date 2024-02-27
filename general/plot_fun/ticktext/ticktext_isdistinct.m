function distinct = ticktext_isdistinct(labels)
%TICKTEXT_ISDISTINCT  Check if labels are distinct
%
%   Check if labels are distinct by mering all lines per tick and comparing
%   the resulting strings.
%
%   Syntax:
%   distinct = ticktext_isdistinct(labels)
%
%   Input:
%   labels    = Cell array structure with ticktext labels
%
%   Output:
%   distinct  = Boolean indicating whether values are distinct
%
%   Example
%   if ticktext_isdistinct(labels)
%       break
%   end
%
%   See also ticktext, ticktext_multiline_scalable

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 10 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ticktext_isdistinct.m 7423 2012-10-10 08:13:03Z hoonhout $
% $Date: 2012-10-10 16:13:03 +0800 (Wed, 10 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7423 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/ticktext/ticktext_isdistinct.m $
% $Keywords: $

%% check if labels are distinct

merged   = cellfun(@cell2mat, labels, 'UniformOutput', false);
distinct = length(unique(merged)) == length(merged);