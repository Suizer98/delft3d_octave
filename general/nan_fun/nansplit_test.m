function testresult = nansplit_test()
% NANSPLIT_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       TDA
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 05 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nansplit_test.m 8861 2013-06-27 15:24:59Z tda.x $
% $Date: 2013-06-27 23:24:59 +0800 (Thu, 27 Jun 2013) $
% $Author: tda.x $
% $Revision: 8861 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/nan_fun/nansplit_test.m $
% $Keywords: $

testresult = [];

% basic cases
input    = 1;
expected = {1};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

input    = [1 nan 2 2 2 nan nan];
expected = {1,[2 2 2]};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

input    = nan;
output = nansplit(input);
testresult(end+1) = isempty(output);

input    = [nan nan nan];
output = nansplit(input);
testresult(end+1) = isempty(output);

input    = [nan nan nan 1];
expected = {1};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

input    = [1 1 nan nan nan 2 2];
expected = {[1 1],[2 2]};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

% columns
input    = [1 1 1]';
expected = {[1 1 1]'};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

input    = [1 nan 2 2]';
expected = {1,[2 2]'};
output = nansplit(input);
testresult(end+1) = isequal(output,expected);

% multiple inputs
input1    = [1 1 nan 2 2 2];
input2    = [1 2 3 4 5 6;1 2 3 4 5 6];
expected1 = {[1 1],[2 2 2]};
expected2 = {[1 2;1 2],[4 5 6;4 5 6]};
[output1, output2] = nansplit(input1,input2);
testresult(end+1) = isequal(output1,expected1) && isequal(output2,expected2);

input1    = [1 1 nan 2 2 2]';
input2    = [1 2 3 4 5 6;1 2 3 4 5 6]';
expected1 = {[1 1]',[2 2 2]'};
expected2 = {[1 2;1 2]',[4 5 6;4 5 6]'};
[output1, output2] = nansplit(input1,input2);
testresult(end+1) = isequal(output1,expected1) && isequal(output2,expected2);

% combine results
testresult = all(testresult);