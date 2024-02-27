function [color marker linestyle] = plotstyles
%plotstyles  generates matrixes with vectors filled with colors, markers
%            and linestyles
%
%   Syntax:
%   [color marker linestyle] = plotstyles
%
%   Input: 
%   No input
%
%   Output:
%   color is a matrix with at each row a numeric color
%   marker is a matrix with at each row a marker
%   linestyle is a matrix with at each row a linestyle

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       hengst
%
%       Simon.denHengst@deltares.nl	
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
% Created: 06 Mar 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: plotstyles.m 8346 2013-03-18 12:32:56Z hengst $
% $Date: 2013-03-18 20:32:56 +0800 (Mon, 18 Mar 2013) $
% $Author: hengst $
% $Revision: 8346 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plotstyles_fun/plotstyles.m $
% $Keywords: $

%% code
color = repmat([[1 0 0];[0 1 0];[0 0 1];[0 0 0];[1 0 1];[0 1 1];[1 1 0]],ceil(12/7),1);
marker = repmat(['o';'+';'.';'*';'s';'>';'d';'^'],ceil(12/8),1);
linestyle = repmat([' -';'--';' :';'-.'],ceil(12/4),1);
