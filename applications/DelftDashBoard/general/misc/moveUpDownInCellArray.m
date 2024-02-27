function [array1 iac] = moveUpDownInCellArray(array, iac, opt)
%moveUpDownInCellArray  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [array iac] = moveUpDownInCellArray(array, iac, opt)
%
%   Input:
%   struc =
%   iac   =
%   opt   =
%
%   Output:
%   struc =
%   iac   =
%   nr    =
%
%   Example
%   moveUpDownInCellArray
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

% $Id: moveUpDownInCellArray.m 5602 2011-12-08 16:59:13Z ormondt $
% $Date: 2011-12-09 00:59:13 +0800 (Fri, 09 Dec 2011) $
% $Author: ormondt $
% $Revision: 5602 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/misc/moveUpDownInCellArray.m $
% $Keywords: $

%%
nr=length(array);
array1=array;
switch lower(opt)
    case{'up','moveup'}
        if nr>1 && iac>1
            array1{iac-1}=array{iac};
            array1{iac}=array{iac-1};
            iac=iac-1;
        end
    case{'down','movedown'}
        if nr>1 && iac<nr
            array1{iac+1}=array{iac};
            array1{iac}=array{iac+1};
            iac=iac+1;
        end
end
