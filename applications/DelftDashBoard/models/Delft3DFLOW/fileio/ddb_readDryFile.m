function handles = ddb_readDryFile(handles, id)
%DDB_READDRYFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readDryFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readDryFile
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
m1=[];
m2=[];
n1=[];
n2=[];

dat=load(handles.model.delft3dflow.domain(id).dryFile);

m1=dat(:,1);
n1=dat(:,2);
m2=dat(:,3);
n2=dat(:,4);

for i=1:length(m1);
    handles.model.delft3dflow.domain(id).dryPoints(i).M1=m1(i);
    handles.model.delft3dflow.domain(id).dryPoints(i).N1=n1(i);
    handles.model.delft3dflow.domain(id).dryPoints(i).M2=m2(i);
    handles.model.delft3dflow.domain(id).dryPoints(i).N2=n2(i);
    handles.model.delft3dflow.domain(id).dryPoints(i).name=['(' num2str(m1(i)) ',' num2str(n1(i)) ')...(' num2str(m2(i)) ',' num2str(n2(i)) ')'];
    handles.model.delft3dflow.domain(id).dryPointNames{i}=handles.model.delft3dflow.domain(id).dryPoints(i).name;
end
handles.model.delft3dflow.domain(id).nrDryPoints=length(m1);

