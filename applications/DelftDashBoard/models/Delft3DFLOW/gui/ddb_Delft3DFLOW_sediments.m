function ddb_Delft3DFLOW_sediments(varargin)
%DDB_DELFT3DFLOW_SEDIMENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_sediments(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_sediments
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

% $Id: ddb_Delft3DFLOW_sediments.m 6494 2012-06-21 00:26:12Z ormondt $
% $Date: 2012-06-21 08:26:12 +0800 (Thu, 21 Jun 2012) $
% $Author: ormondt $
% $Revision: 6494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_sediments.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
else
    opt=varargin{1};
    switch lower(opt)
        case{'opensedfile'}
            handles=getHandles;
            handles=ddb_readSedFile(handles,ad);
            setHandles(handles);
            % setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
        case{'savesedfile'}
            handles=getHandles;
            ddb_saveSedFile(handles,ad);
            % setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
        case{'selectfromlist'}
            % setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
    end
end

