function ddb_deleteDelft3DFLOWObject(id, tag, callback)
%DDB_DELETEDELFT3DFLOWOBJECT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_deleteDelft3DFLOWObject(id, tag, callback)
%
%   Input:
%   id       =
%   tag      =
%   callback =
%
%
%
%
%   Example
%   ddb_deleteDelft3DFLOWObject
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
ddb_setWindowButtonMotionFcn;
set(gcf,'windowbuttondownfcn',{@Click,id,tag,callback});
set(gcf,'windowbuttonupfcn',[]);

%%
function Click(src,eventdata,id,tag,callback)

h=gco;

usd=get(gco,'UserData');
tg=get(gco,'Tag');

if  strcmpi(tg,tag)
    if usd(1)==id
        feval(callback,usd(2));
    end
end

