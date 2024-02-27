function str = deblank2(str)
%DEBLANK2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   str = deblank2(str)
%
%   Input:
%   str =
%
%   Output:
%   str =
%
%   Example
%   deblank2
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: deblank2.m 7187 2012-09-05 09:49:34Z ormondt $
% $Date: 2012-09-05 17:49:34 +0800 (Wed, 05 Sep 2012) $
% $Author: ormondt $
% $Revision: 7187 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/misc/deblank2.m $
% $Keywords: $

%% Removes starting and trailing spaces from string

if ischar(str)
    spaces=str==' ';
    ifirstchar=[];
    for i=1:length(spaces)
        if ~spaces(i)
            ifirstchar=i;
            break
        end
    end
    if ~isempty(ifirstchar)
        str=str(ifirstchar:end);
    end
    str=deblank(str);
end

