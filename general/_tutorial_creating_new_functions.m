%% 2. Creating new functions
% To keep the OpenEarth toolbox well organised, it is of crucial importance
% that all functions receive a proper help block (in Matlab this is the
% first uninterrupted comment block after the function declaration and/or
% before the first line of code. 
%
% To lower the threshold to add such a helpblock the oetnewfun routine was
% developed. It creates a new function using the input arguments supplied
% by the user or using default arguments.

%% Invoking a new function template
% The following command opens a new function in the matlab editor with the
% name "testfun.m".

oetnewfun('testfun')

%% Function template layout
% The resulting function now comes with a helpblock, a standard LGPL
% copyright block and a list of svn-keywords. See for an example the code 
% below. The only thing you have to do is enter the correct information
% for:
%
% # *h1line* (one line description below the function declaration)
% # *description* (description of the functionality)
% # *syntax* (How should / can we approach your function)
% # *input* (explanation of the input arguments)
% # *Output* (explanation of the output arguments)
% # *Example* (Give an example of how we can use the function)
% # *See also* (Just enter names of related function seperated by a space, like with the matlab documentation)
%

function varargout = testfun(varargin)
%TESTFUN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = testfun(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   testfun
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% Created: 17 May 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: _tutorial_creating_new_functions.m 1018 2009-09-10 14:36:54Z geer $
% $Date: 2009-09-10 22:36:54 +0800 (Thu, 10 Sep 2009) $
% $Author: geer $
% $Revision: 1018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/_tutorial_creating_new_functions.m $
% $Keywords: $

%%
