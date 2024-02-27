function testresult = KMLtrack_test()
% KMLtrack_TEST  unit test for KMLtrack
%  
% See also: KMLline, line, plot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: KMLtrack_test.m 7860 2012-12-24 05:54:27Z tda.x $
% $Date: 2012-12-24 13:54:27 +0800 (Mon, 24 Dec 2012) $
% $Author: tda.x $
% $Revision: 7860 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtrack_test.m $
% $Keywords: $

MTestCategory.Unit;
disp(['... running test:',mfilename])

%generate test data;
n    = 10;
time = now + (1:n)/30;
lat  = 10*abs(sin(time))+20;
lon  = 10*cos(time) + (1:n)/40;
z    = 'clampedToGround';

% test simple case
KMLtrack(lat,lon,z,time);

% add data
data(1).name  = 'a number';
data(1).value = 1:n;

data(2).name  = 'Some text';
data(2).value = cellstr(num2str(sqrt(1:n)'));

KMLtrack(lat,lon,'clampedToGround',time,'data',data,...
    'trackName','test track','lineColor',[0 1 0],'lineWidth',2);
testresult = 1;



% test multiple tracks
