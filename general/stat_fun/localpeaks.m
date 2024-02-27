function [locs,vals] = localpeaks(data,minmax)
%LOCALPEAKS  Find local peaks in 1D data array.
%
%   Find local peaks in 1D data array. Similar to findpeaks.m, but does not
%   need statistical toolbox.
%
%   Syntax:
%   [locs,vals] = localpeaks(data,minmax)
%
%   Input:
%   data      = data array in which peaks should be found
%   minmax    = string ('min' or 'max') for local minima or maxima
%
%   Output:
%   locs      = indices of local maxima/minima
%   vals      = values of local maxima/minima
%
%   Example:
%   
%   t = 0:0.1:15;
%   h = sin(t)+cos(3*t);
%   [imax,vals_max] = localpeaks(h,'max');
%   [imin,vals_min] = localpeaks(h,'min');
%   figure()
%   plot(t,h,'b'); hold on
%   plot(t(imax),h(imax),'r*');
%   plot(t(imin),h(imin),'g*');
%
%   See also  findpeaks.m

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 DELTARES
%       rooijen
%
%       arnold.vanrooijen@deltares.nl
%
%       Rotterdamseweg 182, Delft (The Netherlands)
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
% Created: 26 Jun 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: localpeaks.m 8857 2013-06-26 12:47:17Z rooijen $
% $Date: 2013-06-26 20:47:17 +0800 (Wed, 26 Jun 2013) $
% $Author: rooijen $
% $Revision: 8857 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/localpeaks.m $
% $Keywords: $

%%
dtmp = diff(data);
if strcmp(minmax,'min')
    locmin = [];
    for i = 1:length(dtmp)-1
        if dtmp(i) <= 0 && dtmp(i+1) >= 0
            [val,iloc] = min(dtmp(i:i+1));
            locmin = [locmin (i+iloc)];
        end
    end
    locs = locmin;
    vals = data(locs);    
elseif strcmp(minmax,'max')
    locmax = [];
    for i = 1:length(dtmp)-1
        if dtmp(i) >= 0 && dtmp(i+1) <= 0
            [val,iloc] = min(dtmp(i:i+1));
            locmax = [locmax (i+iloc-1)];
        end
    end
    locs = locmax;
    vals = data(locs);
end
