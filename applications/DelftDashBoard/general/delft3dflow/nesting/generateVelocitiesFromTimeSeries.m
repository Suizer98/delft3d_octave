function [times vel] = generateVelocitiesFromTimeSeries(flow, openBoundaries, opt)
%GENERATEVELOCITIESFROMTIMESERIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [times vel] = generateVelocitiesFromTimeSeries(flow, openBoundaries, opt)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%
%   Output:
%   times          =
%   vel            =
%
%   Example
%   generateVelocitiesFromTimeSeries
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateVelocitiesFromTimeSeries.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateVelocitiesFromTimeSeries.m $
% $Keywords: $

%%
t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;
dt=dt/1440;

times=t0:dt:t1;

for j=1:length(openBoundaries)
    ii=strmatch(openBoundaries(j).name(1:3),opt.Current.BC.BndPrefix,'exact');
    t=[];
    val=[];
    if isempty(ii)
        t=[t0 t1];
        val=[0 0];
    else
        tsfile=opt.Current.BC.File{ii};
        fi=tekal('open',tsfile);
        data=tekal('read',fi,1);
        for k=1:size(data,1)
            k;
            dat=num2str(data(k,1));
            tim=num2str(data(k,2),'%0.6i');
            t(k)=datenum([dat tim],'yyyymmddHHMMSS');
            val(k)=data(k,3);
        end
    end
    ddt=t(2:end)-t(1:end-1);
    % plot(ddt)    ;
    vals=interp1(t,val,times);
    for k=1:flow.KMax
        for i=1:length(times)
            vel(j,1,k,i) = vals(i);
            vel(j,2,k,i) = vals(i);
        end
    end
end

