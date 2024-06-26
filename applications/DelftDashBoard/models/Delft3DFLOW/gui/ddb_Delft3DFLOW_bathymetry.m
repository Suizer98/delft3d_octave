function ddb_Delft3DFLOW_bathymetry(varargin)
%DDB_DELFT3DFLOW_BATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_bathymetry(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_bathymetry
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

% $Id: ddb_Delft3DFLOW_bathymetry.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_bathymetry.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.domain.domainpanel.bathymetry');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectdepthfile'}
            selectDepthFile;
    end
end

%%
function selectDepthFile
handles=getHandles;
filename=handles.model.delft3dflow.domain(ad).depFile;
try
    dp=ddb_wldep('read',filename,[handles.model.delft3dflow.domain(ad).MMax,handles.model.delft3dflow.domain(ad).NMax]);
    dp(dp==-999)=NaN;
    handles.model.delft3dflow.domain(ad).depth=-dp(1:end-1,1:end-1);
    handles.model.delft3dflow.domain(ad).depth(handles.model.delft3dflow.domain(ad).depth==999.999)=NaN;
    handles.model.delft3dflow.domain(ad).depthZ=getDepthZ(handles.model.delft3dflow.domain(ad).depth,handles.model.delft3dflow.domain(ad).dpsOpt);
    handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',ad);
    setHandles(handles);
catch
    ddb_giveWarning('text','Bathymetry does not fit grid!');
end
