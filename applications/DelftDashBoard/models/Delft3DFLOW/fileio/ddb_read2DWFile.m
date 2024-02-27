function handles = ddb_read2DWFile(handles, id)
%DDB_READ2DWFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_read2DWFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_read2DWFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_read2DWFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_read2DWFile.m $
% $Keywords: $

%%
m1=[];
m2=[];
n1=[];
n2=[];
uv=[];

[uv,m1,n1,m2,n2,fric,hgt,dummy] = textread(handles.model.delft3dflow.domain(id).w2dFile,'%s%f%f%f%f%f%f%f');

for i=1:length(m1)
    handles.model.delft3dflow.domain(id).weirs2D(i).M1=m1(i);
    handles.model.delft3dflow.domain(id).weirs2D(i).N1=n1(i);
    handles.model.delft3dflow.domain(id).weirs2D(i).M2=m2(i);
    handles.model.delft3dflow.domain(id).weirs2D(i).N2=n2(i);
    handles.model.delft3dflow.domain(id).weirs2D(i).UV=uv{i};
    handles.model.delft3dflow.domain(id).weirs2D(i).crestHeight=hgt(i);
    handles.model.delft3dflow.domain(id).weirs2D(i).frictionCoefficient=fric(i);
end

handles.model.delft3dflow.domain(id).nrWeirs2D=length(m1);
for i=1:length(m1)
    handles.model.delft3dflow.domain(id).weirs2D(i).name=['(' num2str(m1(i)) ',' num2str(n1(i)) ')...(' num2str(m2(i)) ',' num2str(n2(i)) ')'];
    handles.model.delft3dflow.domain(id).weir2DNames{i}=handles.model.delft3dflow.domain(id).weirs2D(i).name;
end

