function [m n iindex] = ddb_findStations(x, y, xg, yg, zz)
%DDB_FINDSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [m n iindex] = ddb_findStations(x, y, xg, yg, zz)
%
%   Input:
%   x      =
%   y      =
%   xg     =
%   yg     =
%   zz     =
%
%   Output:
%   m      =
%   n      =
%   iindex =
%
%   Example
%   ddb_findStations
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

% $Id: ddb_findStations.m 6807 2012-07-06 17:02:23Z ormondt $
% $Date: 2012-07-07 01:02:23 +0800 (Sat, 07 Jul 2012) $
% $Author: ormondt $
% $Revision: 6807 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/ddb_findStations.m $
% $Keywords: $

%%
posx=[];
m=[];
n=[];
iindex=[];

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(x);

% x=dataSet.xy(:,1);
% y=dataSet.xy(:,2);

% cs0.Name=dataSet.cs.Name;
% cs0.Type=dataSet.cs.Type;
%
% [x,y]=ddb_coordConvert(x,y,cs0,cs1);
ni=0;

for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
            y(i)>ymin && y(i)<ymax
        ni=ni+1;
        posx(ni)=x(i);
        posy(ni)=y(i);
        %        name{n}=deblank(dataSet.Name{i});
        %        longname{n}=deblank(dataSet.LongName{i});
        %        idcode{n}=deblank(dataSet.IDCode{i});
        %        src{n}=deblank(dataSet.Source{i});
        istat(ni)=i;
    end
end

wb = waitbox('Finding Stations ...');

if ~isempty(posx)
    [m0,n0]=findgridcell(posx,posy,xg,yg);
    [m0,n0]=CheckDepth(m0,n0,zz);
    nobs=0;
    %     Names{1}='';
    for i=1:length(m0)
        if m0(i)>0
            %             if isempty(strmatch(name{i},Names,'exact'))
            nobs=nobs+1;
            m(nobs)=m0(i);
            n(nobs)=n0(i);
            iindex(nobs)=istat(i);
            %             end
        end
    end
    
end

close(wb);

