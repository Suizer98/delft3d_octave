function testresult = nanjoin_test()
% NANJOIN_TEST  One line description goes here
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
% Created: 06 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nanjoin_test.m 8782 2013-06-06 12:53:28Z tda.x $
% $Date: 2013-06-06 20:53:28 +0800 (Thu, 06 Jun 2013) $
% $Author: tda.x $
% $Revision: 8782 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/nan_fun/nanjoin_test.m $
% $Keywords: $


testresult = [];

% basic cases
input    = {1};
expected = 1;
output = nanjoin(input,1);
testresult(end+1) = isequaln(output,expected); 

input    = {1,[2 2 2]};
expected = [1 nan 2 2 2];
output = nanjoin(input,1);
testresult(end+1) = isequaln(output,expected);

input    = {[],1,[],[],2};
expected = [1 nan 2];
output = nanjoin(input,1);
testresult(end+1) = isequaln(output,expected);

input    = {[nan nan nan]};
expected = [nan nan nan];
output = nanjoin(input,1);
testresult(end+1) = isequaln(output,expected);


input    = {[1 1],[2 2]};
expected = [1 1; nan nan; 2 2];
output = nanjoin(input,2);
testresult(end+1) = isequaln(output,expected);

input    = {[1 1]',[2 2]'};
expected = [1 1; nan nan; 2 2]';
output = nanjoin(input,1);
testresult(end+1) = isequaln(output,expected);

% combine results
testresult = all(testresult);
