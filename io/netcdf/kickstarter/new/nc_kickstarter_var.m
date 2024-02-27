function varargout = nc_kickstarter_var(varargin)
%NC_KICKSTARTER_VAR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_kickstarter_var(varargin)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_var() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_kickstarter_var
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 29 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nc_kickstarter_var.m 9934 2014-01-06 08:32:24Z hoonhout $
% $Date: 2014-01-06 16:32:24 +0800 (Mon, 06 Jan 2014) $
% $Author: hoonhout $
% $Revision: 9934 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/new/nc_kickstarter_var.m $
% $Keywords: $/g

%% add variable data, including standard_names etc.

% support reusing, addition and removal of existing vars

% support overwriting and appending data