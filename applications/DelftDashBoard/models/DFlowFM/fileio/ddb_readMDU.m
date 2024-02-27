 function handles = ddb_readMDU(handles, filename, id)
%DDB_READMDU  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_readMDU.m 15715 2019-09-11 13:21:53Z leijnse $
% $Date: 2019-09-11 21:21:53 +0800 (Wed, 11 Sep 2019) $
% $Author: leijnse $
% $Revision: 15715 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_readMDU.m $
% $Keywords: $

%%

s = ddb_readDelft3D_keyWordFile(filename,'firstcharacterafterdata','#');
fldnames=fieldnames(s);
for ii=1:length(fldnames)
    fldnames2=fieldnames(s.(fldnames{ii}));
    for jj=1:length(fldnames2)
        handles.model.dflowfm.domain(id).(fldnames2{jj})=s.(fldnames{ii}).(fldnames2{jj});
    end
end

% Time
handles.model.dflowfm.domain(id).refdate=datenum(num2str(handles.model.dflowfm.domain(id).refdate),'yyyymmdd');

switch lower(handles.model.dflowfm.domain(id).tunit)
    case{'h'}
        tstart=handles.model.dflowfm.domain(id).tstart/24+handles.model.dflowfm.domain(id).refdate;
        tstop =handles.model.dflowfm.domain(id).tstop/24+handles.model.dflowfm.domain(id).refdate;
    case{'m'}
        tstart=handles.model.dflowfm.domain(id).tstart/1440+handles.model.dflowfm.domain(id).refdate;
        tstop =handles.model.dflowfm.domain(id).tstop/1440+handles.model.dflowfm.domain(id).refdate;
    case{'s'}
        tstart=handles.model.dflowfm.domain(id).tstart/86400+handles.model.dflowfm.domain(id).refdate;
        tstop =handles.model.dflowfm.domain(id).tstop/86400+handles.model.dflowfm.domain(id).refdate;
end

handles.model.dflowfm.domain(id).tstart=tstart;
handles.model.dflowfm.domain(id).tstop =tstop;
