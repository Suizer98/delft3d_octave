function [val1 lon1 lat1] = getMeteoMatrix(val, lon, lat, xlim, ylim)
%GETMETEOMATRIX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [val1 lon1 lat1] = getMeteoMatrix(val, lon, lat, xlim, ylim)
%
%   Input:
%   val  =
%   lon  =
%   lat  =
%   xlim =
%   ylim =
%
%   Output:
%   val1 =
%   lon1 =
%   lat1 =
%
%   Example
%   getMeteoMatrix
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getMeteoMatrix.m 11445 2014-11-25 23:32:26Z ormondt $
% $Date: 2014-11-26 07:32:26 +0800 (Wed, 26 Nov 2014) $
% $Author: ormondt $
% $Revision: 11445 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/getMeteoMatrix.m $
% $Keywords: $

%%
if size(lon,1)>1
    lon=lon';
end

if lon(end)-lon(1)>350
    % Probably covering the entire globe
    if lon(1)>=0
        lon=[lon-360 lon lon+360];
        val=[val val val];
    else
        lon=[lon lon+360];
        val=[val val];
    end
%     % Add one extra column
%     lon(end+1)=lon(end);
%     val(:,end+1)=val(:,end);
end

if xlim(2)<lon(1)
    lon=lon-360;
elseif xlim(1)>lon(end)
    lon=lon+360;
end

i1=find(lon>xlim(1), 1 )-1;
i2=find(lon<xlim(2), 1, 'last' )+1;
j1=find(lat>ylim(1), 1 )-1;
j2=find(lat<ylim(2), 1, 'last' )+1;

i1=max(i1,1);
i2=min(i2,length(lon));
j1=max(j1,1);
j2=min(j2,length(lat));

lon1=lon(i1:i2);
lat1=lat(j1:j2);
val1=val(j1:j2,i1:i2);

