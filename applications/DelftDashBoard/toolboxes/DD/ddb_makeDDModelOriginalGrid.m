function [handles mcut ncut] = ddb_makeDDModelOriginalGrid(handles, id1, mdd, ndd)
%DDB_MAKEDDMODELORIGINALGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles mcut ncut] = ddb_makeDDModelOriginalGrid(handles, id1, mdd, ndd)
%
%   Input:
%   handles =
%   id1     =
%   mdd     =
%   ndd     =
%
%   Output:
%   handles =
%   mcut    =
%   ncut    =
%
%   Example
%   ddb_makeDDModelOriginalGrid
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
mmin=mdd(1);
nmin=ndd(1);
mmax=mdd(2);
nmax=ndd(2);

x1=handles.model.delft3dflow.domain(id1).gridX;
y1=handles.model.delft3dflow.domain(id1).gridY;

% Set coordinates where new domain is made to nan
x1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;
y1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;

sz1=size(x1);
iac1=zeros(sz1);
iac1(isfinite(x1))=1;

% Run along dd boundaries to get rid of extra cells

% sides
% bottom
for i=mmin+1:mmax-1
    isn=0;
    if nmin==1
        isn=1;
    elseif ~iac1(i,nmin-1)
        isn=1;
    end
    if isn
        x1(i,nmin)=NaN;
        y1(i,nmin)=NaN;
    end
end
% top
for i=mmin+1:mmax-1
    isn=0;
    if nmax==sz1(2)
        isn=1;
    elseif ~iac1(i,nmax+1)
        isn=1;
    end
    if isn
        x1(i,nmax)=NaN;
        y1(i,nmax)=NaN;
    end
end
% left
for j=nmin+1:nmax-1
    isn=0;
    if mmin==1
        isn=1;
    elseif ~iac1(mmin-1,j)
        isn=1;
    end
    if isn
        x1(mmin,j)=NaN;
        y1(mmin,j)=NaN;
    end
end
% right
for j=nmin+1:nmax-1
    isn=0;
    if mmax==sz1(1)
        isn=1;
    elseif ~iac1(mmax+1,j)
        isn=1;
    end
    if isn
        x1(mmax,j)=NaN;
        y1(mmax,j)=NaN;
    end
end

% And the corner points
% Bottom left
if mmin==1 && nmin==1
    x1(mmin,nmin)=NaN;
end
% Bottom right
if mmax==sz1(1) && nmin==1
    x1(mmax,nmin)=NaN;
end
% Top left
if mmin==1 && nmax==sz1(2)
    x1(mmin,nmax)=NaN;
end
% Top right
if mmax==sz1(1) && nmax==sz1(2)
    x1(mmax,nmax)=NaN;
end

[x1,y1,mcut,ncut]=CutNanRows(x1,y1);

enc1=ddb_enclosure('extract',x1,y1);

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end
ddb_wlgrid('write','FileName',handles.model.delft3dflow.domain(ad).grdFile,'X',x1,'Y',y1,'Enclosure',enc1,'CoordinateSystem',coord);

handles.model.delft3dflow.domain(id1).gridX=x1;
handles.model.delft3dflow.domain(id1).gridY=y1;


