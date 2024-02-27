function grd = ddb_plotCurvilinearGrid(x, y, varargin)
%DDB_PLOTCURVILINEARGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   grd = ddb_plotCurvilinearGrid(x, y, varargin)
%
%   Input:
%   x        =
%   y        =
%   varargin =
%
%   Output:
%   grd      =
%
%   Example
%   ddb_plotCurvilinearGrid
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_plotCurvilinearGrid.m 12632 2016-03-22 10:16:14Z ormondt $
% $Date: 2016-03-22 18:16:14 +0800 (Tue, 22 Mar 2016) $
% $Author: ormondt $
% $Revision: 12632 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_plotCurvilinearGrid.m $
% $Keywords: $

%%
col=[0 0 0];
tag=[];

% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'color'}
                col=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
        end
    end
end

x1=zeros(size(x,1)+1,size(x,2)+1);
x1(x1==0)=NaN;
y1=x1;
x1(1:end-1,1:end-1)=x;
y1(1:end-1,1:end-1)=y;

x2a=reshape(x1,[1 size(x1,1)*size(x1,2)]);
y2a=reshape(y1,[1 size(x1,1)*size(x1,2)]);
x2b=reshape(x1',[1 size(x1,1)*size(x1,2)]);
y2b=reshape(y1',[1 size(x1,1)*size(x1,2)]);
x2=[x2a x2b];
y2=[y2a y2b];

grd=plot(x2,y2,'k');
set(grd,'Color',col);
set(grd,'HitTest','off');
if ~isempty(tag)
    set(grd,'Tag',tag);
end

