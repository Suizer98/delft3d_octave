function ddb_openDFlowFM(opt)
%DDB_OPENDFlowFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_openDFlowFM(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_openDFlowFM
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

% $Id: ddb_openDFlowFM.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/main/ddb_openDFlowFM.m $
% $Keywords: $

%%
handles=getHandles;

switch opt
    case {'openpresent'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdu', 'Select MDU file');
        if pathname~=0
            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end
            ddb_plotDFlowFM('delete');
            id=handles.activeDomain;
            handles.model.dflowfm.domain=clearStructure(handles.model.dflowfm.domain,id);
            runid=filename(1:end-4);
            handles=ddb_initializeDFlowFMdomain(handles,'all',id,runid);
            filename=[runid '.mdu'];
            handles.model.dflowfm.domain.mduFile=filename;
            handles=ddb_readMDU(handles,filename,id);
            handles=ddb_DFlowFM_readAttributeFiles(handles,id);

            xl(1)=min(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_x);
            xl(2)=max(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_x);
            yl(1)=min(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_y);
            yl(2)=max(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_y);
            handles=ddb_zoomTo(handles,xl,yl,0.1);
            
            setHandles(handles);
            
            ddb_plotDFlowFM('plot','active',1,'visible',1,'domain',0);
            
        end
end
ddb_updateDataInScreen;
