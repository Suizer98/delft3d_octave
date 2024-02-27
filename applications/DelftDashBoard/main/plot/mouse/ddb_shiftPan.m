function ddb_shiftPan(src, evnt)
%DDB_SHIFTPAN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_shiftPan(src, evnt)
%
%   Input:
%   src  =
%   evnt =
%
%
%
%
%   Example
%   ddb_shiftPan
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

if strcmp(evnt.Modifier,'shift') | strcmp(evnt.Modifier,'control')
    set(gcf,'KeyPressFcn',[]);
    set(gcf,'KeyReleaseFcn',{@StopPan});
    setptr(gcf,'hand');
    set(gcf, 'windowbuttonmotionfcn', {@StartPan});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StartPan(imagefig, varargins)

xl=get(gca,'xlim');
yl=get(gca,'ylim');
pos0=get(gca,'CurrentPoint');
pos0=pos0(1,1:2);
set(gcf, 'windowbuttonmotionfcn', {@Pan2D,gca,xl,yl,pos0});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Pan2D(imagefig, varargins,h,xl0,yl0,pos0)

xl1=get(h,'XLim');
yl1=get(h,'YLim');
pos1=get(h,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
set(h,'XLim',xl,'YLim',yl);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StopPan(imagefig, varargins)

set(gcf, 'windowbuttonmotionfcn',[]);
set(gcf,'KeyPressFcn',{@ddb_shiftPan});
set(gcf,'KeyReleaseFcn',[]);
setptr(gcf,'arrow');


