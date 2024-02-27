function handles = ddb_makeDDModelNewAttributes(handles, id1, id2, runid2, varargin)
%DDB_MAKEDDMODELNEWATTRIBUTES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_makeDDModelNewAttributes(handles, id1, id2, runid2, varargin)
%
%   Input:
%   handles  =
%   id1      =
%   id2      =
%   runid2   =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_makeDDModelNewAttributes
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
if ~isempty(varargin)
    
    %     % Only adjust bathymetry
    %     fname=varargin{1};
    %
    %     % Make sure depths along boundaries in both domains are the same
    %     z=handles.model.delft3dflow.domain(id2).depth;
    %     z=ddb_matchDDDepths(handles,z,id1,runid1,runid2);
    %     handles.model.delft3dflow.domain(id2).depth=z;
    %     handles.model.delft3dflow.domain(id2).depthZ=GetDepthZ(z,handles.model.delft3dflow.domain(id2).dpsOpt);
    %     ddb_wldep('write',fname,z);
    %     handles.model.delft3dflow.domain(id2).depFile=fname;
    
else
    
    % Adjust all attribute files
    
    % Attribute Files
    handles.model.delft3dflow.domain(id2).nrObservationPoints=0;
    handles.model.delft3dflow.domain(id2).obsFile='';
    handles.model.delft3dflow.domain(id2).observationPoints=[];
    
    handles.model.delft3dflow.domain(id2).nrObservationPoints=0;
    handles.model.delft3dflow.domain(id2).openBoundaries=[];
    
    handles.model.delft3dflow.domain(id2).nrDryPoints=0;
    handles.model.delft3dflow.domain(id2).dryPoints=[];
    
    handles.model.delft3dflow.domain(id2).nrThinDams=0;
    handles.model.delft3dflow.domain(id2).thinDams=[];

    handles.model.delft3dflow.domain(id2).depFile=[runid2 '.dep'];

    % Bathymetry
    if isfield(handles.model.delft3dflow.domain(id1),'depth') && size(handles.model.delft3dflow.domain(id1).depth,1)>1
        datasets(1).name=handles.screenParameters.backgroundBathymetry;
        handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBathymetry(handles,id2, datasets,'filename',[handles.toolbox.dd.attributeName '.dep']);
    end
    
    %     if exist(handles.toolbox.dd.originalDomain.obsFile)
    %         % overall model based on original grid
    %         %         nobs=ddb_obs2obs(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).obsFile,handles.model.delft3dflow.domain(id1).grdFile,handles.model.delft3dflow.domain(id1).obsFile);
    %         %         if nobs>0
    %         %             [name,m,n] = textread([handles.model.delft3dflow.domain(id1).obsFile],'%21c%f%f');
    %         %             handles.model.delft3dflow.domain(id1).observationPoints=[];
    %         %             handles.model.delft3dflow.domain(id1).observationPoints.M=m;
    %         %             handles.model.delft3dflow.domain(id1).observationPoints.N=n;
    %         %             for i=1:length(m)
    %         %                 handles.model.delft3dflow.domain(id1).observationPoints.Name{i}=deblank(name(i,:));
    %         %             end
    %         %             handles.model.delft3dflow.domain(id2).nrObservationPoints = nobs;
    %         %         end
    %         % dd-model
    %         nobs=ddb_obs2obs(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).obsFile,handles.model.delft3dflow.domain(id2).grdFile,[runid2 '.obs']);
    %         if nobs>0
    %             handles.model.delft3dflow.domain(id2).obsFile = [runid2 '.obs'];
    %             handles.activeDomain=id2;
    %             handles=ddb_readObsFile(handles);
    %             handles.activeDomain=id1;
    %             handles.model.delft3dflow.domain(id2).nrObservationPoints = nobs;
    %         end
    %     end
    %     if exist(handles.toolbox.dd.originalDomain.thdFile)
    %         nthd=ddb_thd2thd(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).thdFile,handles.model.delft3dflow.domain(id2).grdFile,[runid2 '.thd']);
    %         if nthd>0
    %             handles.model.delft3dflow.domain(id2).thdFile = [runid2 '.thd'];
    %             handles.activeDomain=id2;
    %             handles=ddb_readThdFile(handles);
    %             handles.activeDomain=id1;
    %             handles.model.delft3dflow.domain(id2).nrThinDams = nthd;
    %         end
    %     end
    %     if exist(handles.toolbox.dd.originalDomain.dryFile)
    %         ndry=ddb_dry2dry(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).dryFile,handles.model.delft3dflow.domain(id2).grdFile,[runid2 '.dry']);
    %         if ndry>0
    %             handles.model.delft3dflow.domain(id2).dryFile = [runid2 '.dry'];
    %             handles.activeDomain=id2;
    %             handles=ddb_readDryFile(handles);
    %             handles.activeDomain=id1;
    %             handles.model.delft3dflow.domain(id2).nrDryPoints = ndry;
    %         end
    %     end
    %     if exist(handles.toolbox.dd.originalDomain.crsFile)
    %         ncrs=ddb_crs2crs(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).crsFile,handles.model.delft3dflow.domain(id2).grdFile,[runid2 '.crs']);
    %         if ncrs>0
    %             handles.model.delft3dflow.domain(id2).crsFile = [runid2 '.crs'];
    %             handles.activeDomain=id2;
    %             handles=ddb_readCrsFile(handles);
    %             handles.activeDomain=id1;
    %             handles.model.delft3dflow.domain(id2).nrCrossSections = ncrs;
    %         end
    %     end
    %     if exist(handles.toolbox.dd.originalDomain.srcFile)
    %         nsrc=ddb_src2src(handles.toolbox.dd.originalDomain.grdFile,handles.model.delft3dflow.domain(id1).srcFile,handles.model.delft3dflow.domain(id2).grdFile,[runid2 '.src']);
    %         if nsrc>0
    %             handles.model.delft3dflow.domain(id2).srcFile = [runid2 '.src'];
    %             handles.activeDomain=id2;
    %             handles=ddb_readSrcFile(handles);
    %             handles.activeDomain=id1;
    %             handles.model.delft3dflow.domain(id2).nrDischarges = nsrc;
    %         end
    %     end
end


