%ALLCLEAR  Clear workspace and close files (inclusing netcdf files)
%
%   Alternative to wellknown combination of clc, clear all, fclose all,
%   etc. Breakpoints for debugging are not cleared (meant as feature!).
%   Clear all breakpints with 'clear all'.
%
%   The matlab native netcdf function is also modified to keep track
%   of open nc files. These are closed by allclear
%
%   Syntax:
%   allclear
%
%   Example
%   allclear
%
%   See also: clear, fclose, netcdf.close  

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>     
%
%       <ADDRESS>
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
% Created: 02 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: allclear.m 4429 2011-04-09 17:33:01Z thijs@damsma.net $
% $Date: 2011-04-10 01:33:01 +0800 (Sun, 10 Apr 2011) $
% $Author: thijs@damsma.net $
% $Revision: 4429 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/allclear/allclear.m $
% $Keywords: $

%% clear the command prompt
clc

%% close all open files
fclose all;

%% close all figures
% including hidden figures like waitbars
set(0,'ShowHiddenHandles','on')
delete(get(0,'Children'))

%% close serial com ports
priorPorts = instrfindall;  % finds any existing Serial Ports in MATLAB
delete(priorPorts)          % and deletes them

%% clear variables 
% but not breakpoints (that's what 'clear all' does)
clear mex
clear
