function [handles mdd ndd] = ddb_makeDDModelNewGrid(handles, id1, id2, mdd, ndd, runid)
%DDB_MAKEDDMODELNEWGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles mdd ndd] = ddb_makeDDModelNewGrid(handles, id1, id2, mdd, ndd, runid)
%
%   Input:
%   handles =
%   id1     =
%   id2     =
%   mdd     =
%   ndd     =
%   runid   =
%
%   Output:
%   handles =
%   mdd     =
%   ndd     =
%
%   Example
%   ddb_makeDDModelNewGrid
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
refm=handles.toolbox.dd.mRefinement;
refn=handles.toolbox.dd.nRefinement;

mmin=mdd(1);mmax=mdd(2);
nmin=ndd(1);nmax=ndd(2);

x0=handles.model.delft3dflow.domain(id1).gridX;
y0=handles.model.delft3dflow.domain(id1).gridY;

x2coarse=x0(mmin:mmax,nmin:nmax);
y2coarse=y0(mmin:mmax,nmin:nmax);

[x2coarse,y2coarse,mcut,ncut]=CutNanRows(x2coarse,y2coarse);
mdd(1)=mdd(1)+mcut(1);
mdd(2)=mdd(2)-mcut(2);
ndd(1)=ndd(1)+ncut(1);
ndd(2)=ndd(2)-ncut(2);
[x2,y2]=ddb_refineD3DGrid(x2coarse,y2coarse,refm,refn);

enc2=ddb_enclosure('extract',x2,y2);
grd2=[runid '.grd'];

%ddb_wlgrid('write',grd2,x2,y2,enc2,handles.ScreenParameters.CoordinateSystem.Type);
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end
ddb_wlgrid('write','FileName',grd2,'X',x2,'Y',y2,'Enclosure',enc2,'CoordinateSystem',coord);

handles.model.delft3dflow.domain(id2).grdFile=[runid '.grd'];
handles.model.delft3dflow.domain(id2).encFile=[runid '.enc'];
handles.model.delft3dflow.domain(id2).gridX=x2;
handles.model.delft3dflow.domain(id2).gridY=y2;
[handles.model.delft3dflow.domain(id2).gridXZ,handles.model.delft3dflow.domain(id2).gridYZ]=getXZYZ(x2,y2);
handles.model.delft3dflow.domain(id2).MMax=size(x2,1)+1;
handles.model.delft3dflow.domain(id2).NMax=size(x2,2)+1;
handles.model.delft3dflow.domain(id2).kcs=determineKCS(handles.model.delft3dflow.domain(id2).gridX,handles.model.delft3dflow.domain(id2).gridY);

