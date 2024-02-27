function handles = ddb_readCrsFile(handles, id)
%DDB_READCRSFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readCrsFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readCrsFile
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
n1=[];
m2=[];
n2=[];
name=[];

if ~exist(handles.model.delft3dflow.domain(id).crsFile,'file')
    ddb_giveWarning('text',['Crs file ' handles.model.delft3dflow.domain(id).crsFile ' does not exist!']);
    return
end

[name,m1,n1,m2,n2] = textread(handles.model.delft3dflow.domain(id).crsFile,'%21c%f%f%f%f');

for i=1:length(m1)
    handles.model.delft3dflow.domain(id).crossSections(i).name=deblank(name(i,:));
    handles.model.delft3dflow.domain(id).crossSections(i).M1=m1(i);
    handles.model.delft3dflow.domain(id).crossSections(i).N1=n1(i);
    handles.model.delft3dflow.domain(id).crossSections(i).M2=m2(i);
    handles.model.delft3dflow.domain(id).crossSections(i).N2=n2(i);
    handles.model.delft3dflow.domain(id).crossSectionNames{i}=handles.model.delft3dflow.domain(id).crossSections(i).name;
end

handles.model.delft3dflow.domain(id).nrCrossSections=length(m1);

