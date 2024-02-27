function testresult = datenum2udunits_test()
% DATENUM2UDUNITS_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 24 Aug 2012
% Created with Matlab version: 8.0.0.755 (R2012b)

% $Id: datenum2udunits_test.m 7285 2012-09-25 15:04:24Z tda.x $
% $Date: 2012-09-25 23:04:24 +0800 (Tue, 25 Sep 2012) $
% $Author: tda.x $
% $Revision: 7285 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/datenum2udunits_test.m $
% $Keywords: $



%% test when epoc is matlab epoch
t_original = datenum('24-Aug-2012 14:24:06');
isounits   = 'days since 0000-00-00 00:00:00 +00:00';
t_udunits  = datenum2udunits(t_original,isounits);
t_datenum  = udunits2datenum(t_udunits,isounits);
    
testresult(1) = isequal(t_original,t_udunits,t_datenum);
   

%% test for random epocs
isounits_list = {
    'years since 0699-01-13 16:42:27 -10:00'
    'milliseconds since 0451-02-06 15:19:16 -2:00'
    'days since 0914-10-16 18:47:56 -9:00'
    'days since 2549-04-07 11:11:54 -4:00'
    'years since 1318-07-02 13:35:16 -2:00'
    'minutes since 1839-11-26 11:15:09 +3:00'
    'days since 2672-02-17 20:48:47 +9:00'
    'minutes since 2514-08-06 09:42:01 -5:00'
    'milliseconds since 0310-05-15 07:53:42 -9:00'
    'days since 2832-10-18 22:06:52 +6:00'
    'milliseconds since 2158-08-04 13:20:40 -4:00'
    };


for ii = length(isounits_list):-1:1
    isounits = isounits_list{ii};
    
    t_udunits  = datenum2udunits(t_original,isounits);
    t_datenum  = udunits2datenum(t_udunits,isounits);

    difference(ii) = abs(t_original - t_datenum);
end

testresult(2) = all(difference == 0);

%%
testresult = all(testresult);

%% generate list of random epochs for testing
% units = {
%     'years'
%     'minutes'
%     'milliseconds'
%     'days'
%     };
% 
% for ii = 100:-1:1
%     isounits = sprintf('%s since %04.0f-%02.0f-%02.0f %02.0f:%02.0f:%02.0f %+02.0f:00',...
%         units{ceil(4*rand)},...
%         round(3000*rand(1)),... years
%         ceil(12*rand(1)),...    months
%         ceil(28*rand(1)),...days
%         floor(24*rand(1)),...hours
%         floor(60*rand(1)),...minutes
%         floor(60*rand(1)),...seconds
%         round(24*rand(1)-12)...zone
%         );
%     disp(isounits);
% end