function handles = ddb_readBctFile(handles, id)
%DDB_READBCTFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readBctFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readBctFile
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
nr=handles.model.delft3dflow.domain(id).nrOpenBoundaries;
kmax=handles.model.delft3dflow.domain(id).KMax;

fname=handles.model.delft3dflow.domain(id).bctFile;

Info=ddb_bct_io('read',fname);

for i=1:nr
    str{i}=handles.model.delft3dflow.domain(id).openBoundaries(i).name;
end

for i=1:Info.NTables
    kk=strmatch(lower(Info.Table(i).Location),lower(str),'exact');
    if length(kk)==1
        tab=Info.Table(i);
        itd=Info.Table(i).ReferenceTime;
        itd=datenum(num2str(itd),'yyyymmdd');
        t=itd+Info.Table(i).Data(:,1)/1440;
        handles.model.delft3dflow.domain(id).openBoundaries(kk).timeSeriesT=t;
        handles.model.delft3dflow.domain(id).openBoundaries(kk).nrTimeSeries=length(t);
        switch lower(deblank(tab.Contents))
            case{'uniform','logarithmic'}
                handles.model.delft3dflow.domain(id).openBoundaries(kk).timeSeriesA=tab.Data(:,2);
                handles.model.delft3dflow.domain(id).openBoundaries(kk).timeSeriesB=tab.Data(:,3);
            case{'3d-profile'}
                handles.model.delft3dflow.domain(id).openBoundaries(kk).timeSeriesA=tab.Data(:,2:kmax+1);
                handles.model.delft3dflow.domain(id).openBoundaries(kk).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
        end
    end
end

