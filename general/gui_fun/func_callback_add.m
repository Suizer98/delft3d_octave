function func_callback_add(obj, callback, fcn)
%FUNC_CALLBACK_ADD  Add a callback function to possibly existing callback function
%
%   Reads a callback function from an object and joins it with the given
%   function and replaces it by the joined function.
%
%   Syntax:
%   func_callback_add(obj, callback, fcn)
%
%   Input:
%   obj       = Object with the callback function
%   callback  = String representing the callback function
%   fcn       = Callback function call to be added
%
%   Output:
%   none
%
%   Example
%   figure;
%   event1 = {@(o,e,x) disp(x), 'This is my first event!'};
%   event2 = {@(o,e,x) disp(x), 'This is my second event!'};
%   func_callback_add(gcf, 'ResizeFcn', event1);
%   func_callback_add(gcf, 'ResizeFcn', event2);
%
%   See also func_join

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
% Created: 09 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: func_callback_add.m 7421 2012-10-09 16:43:01Z hoonhout $
% $Date: 2012-10-10 00:43:01 +0800 (Wed, 10 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7421 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/gui_fun/func_callback_add.m $
% $Keywords: $

%% add callback function

fcn0 = get(obj, callback);
set(obj, callback, {@func_join, fcn0, fcn});
