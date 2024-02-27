function ddb_saveWndFile(handles, id)
%DDB_SAVEWNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveWndFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveWndFile
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
fname=handles.model.delft3dflow.domain(id).wndFile;

data(:,1)=1440*(handles.model.delft3dflow.domain(id).windTimeSeriesT-handles.model.delft3dflow.domain(id).itDate);
data(:,2)=handles.model.delft3dflow.domain(id).windTimeSeriesSpeed;
data(:,3)=handles.model.delft3dflow.domain(id).windTimeSeriesDirection;

fid=fopen(fname,'w');
fprintf(fid,'%16.7e %16.7e %16.7e\n',data');
fclose(fid);

