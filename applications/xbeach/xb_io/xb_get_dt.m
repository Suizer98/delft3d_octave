function [dt progress] = xb_get_dt(XBlog, varargin)
%XB_GET_DT  Read series of (average) dt values from XBlog.txt file
%
%   Function to extract dt values from XBlog.txt file by means of regular
%   expression.
%
%   Syntax:
%   dt = xb_average_dt(XBlog, varargin)
%
%   Input:
%   XBlog  = filename including path of XBlog.txt
%
%   Output:
%   dt = array of dt values
%
%   Example
%   xb_average_dt
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 05 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_get_dt.m 5570 2011-12-05 14:03:43Z heijer $
% $Date: 2011-12-05 22:03:43 +0800 (Mon, 05 Dec 2011) $
% $Author: heijer $
% $Revision: 5570 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_get_dt.m $
% $Keywords: $

%% read XBlog.txt
% open XBlog file
fid = fopen(XBlog);

% read the entire file as characters
% transpose so that F is a row vector
F = fread(fid, '*char')';

% close file
fclose(fid);

%% Extract dt values
% extract dt from log file using a regular expression
progress_char = regexp(F, '(?<=Simulation)(\s*[\d\.]+\s*)(?=percent complete.)', 'match');
dt_char = regexp(F, '(?<=Average dt )([\d\.]+)(?= seconds)', 'match');

% convert the cell arrays of strings to a double arrays
progress = cellfun(@str2double, progress_char) / 100;
dt = cellfun(@str2double, dt_char);