function handles = ddb_removeDDModelAttributes(handles, id)
%DDB_REMOVEDDMODELATTRIBUTES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_removeDDModelAttributes(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_removeDDModelAttributes
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

% $Id: ddb_removeDDModelAttributes.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/ddb_removeDDModelAttributes.m $
% $Keywords: $

%%
x=handles.model.delft3dflow.domain(id).gridX;

% Observation points
k=0;
iRemove=[];
if handles.model.delft3dflow.domain(id).nrObservationPoints>0
    % Check which points need to be removed
    for i=1:handles.model.delft3dflow.domain(id).nrObservationPoints
        m=handles.model.delft3dflow.domain(id).observationPoints(i).M;
        n=handles.model.delft3dflow.domain(id).observationPoints(i).N;
        if isnan(x(m,n))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.model.delft3dflow.domain(id).observationPoints=removeFromStruc(handles.model.delft3dflow.domain(id).observationPoints,i);
            handles.model.delft3dflow.domain(id).observationPointNames=removeFromCellArray(handles.model.delft3dflow.domain(id).observationPointNames,i);
        end
        handles.model.delft3dflow.domain(id).nrObservationPoints=handles.model.delft3dflow.domain(id).nrObservationPoints-length(iRemove);
        handles.model.delft3dflow.domain(id).activeObservationPoint=1;
        if handles.model.delft3dflow.domain(id).nrObservationPoints==0
            handles.model.delft3dflow.domain(id).observationPointNames={''};
            handles.model.delft3dflow.domain(id).activeObservationPoint=1;
            handles.model.delft3dflow.domain(id).observationPoints(1).M=[];
            handles.model.delft3dflow.domain(id).observationPoints(1).N=[];
        end
    end
end

% Cross sections
k=0;
iRemove=[];
if handles.model.delft3dflow.domain(id).nrCrossSections>0
    % Check which points need to be removed
    for i=1:handles.model.delft3dflow.domain(id).nrCrossSections
        m1=handles.model.delft3dflow.domain(id).crossSections(i).M1;
        n1=handles.model.delft3dflow.domain(id).crossSections(i).N1;
        m2=handles.model.delft3dflow.domain(id).crossSections(i).M2;
        n2=handles.model.delft3dflow.domain(id).crossSections(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.model.delft3dflow.domain(id).crossSections=removeFromStruc(handles.model.delft3dflow.domain(id).crossSections,i);
            handles.model.delft3dflow.domain(id).crossSectionNames=removeFromCellArray(handles.model.delft3dflow.domain(id).crossSectionNames,i);
        end
        handles.model.delft3dflow.domain(id).nrCrossSections=handles.model.delft3dflow.domain(id).nrCrossSections-length(iRemove);
        handles.model.delft3dflow.domain(id).activeCrossSection=1;
        if handles.model.delft3dflow.domain(id).nrCrossSections==0
            handles.model.delft3dflow.domain(id).crossSectionNames={''};
            handles.model.delft3dflow.domain(id).crossSections(1).M1=[];
            handles.model.delft3dflow.domain(id).crossSections(1).M2=[];
            handles.model.delft3dflow.domain(id).crossSections(1).N1=[];
            handles.model.delft3dflow.domain(id).crossSections(1).N2=[];
            handles.model.delft3dflow.domain(id).crossSections(1).name='';
        end
    end
end

%% TODO
% drogues and open boundaries

% Dry points
k=0;
iRemove=[];
if handles.model.delft3dflow.domain(id).nrDryPoints>0
    % Check which points need to be removed
    for i=1:handles.model.delft3dflow.domain(id).nrDryPoints
        m1=handles.model.delft3dflow.domain(id).dryPoints(i).M1;
        n1=handles.model.delft3dflow.domain(id).dryPoints(i).N1;
        m2=handles.model.delft3dflow.domain(id).dryPoints(i).M2;
        n2=handles.model.delft3dflow.domain(id).dryPoints(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.model.delft3dflow.domain(id).dryPoints=removeFromStruc(handles.model.delft3dflow.domain(id).dryPoints,i);
            handles.model.delft3dflow.domain(id).dryPointNames=removeFromCellArray(handles.model.delft3dflow.domain(id).dryPointNames,i);
        end
        handles.model.delft3dflow.domain(id).nrDryPoints=handles.model.delft3dflow.domain(id).nrDryPoints-length(iRemove);
        handles.model.delft3dflow.domain(id).activeDryPoint=1;
        if handles.model.delft3dflow.domain(id).nrDryPoints==0
            handles.model.delft3dflow.domain(id).dryPointNames={''};
            handles.model.delft3dflow.domain(id).dryPoints(1).M1=[];
            handles.model.delft3dflow.domain(id).dryPoints(1).M2=[];
            handles.model.delft3dflow.domain(id).dryPoints(1).N1=[];
            handles.model.delft3dflow.domain(id).dryPoints(1).N2=[];
        end
    end
end

% Thin dams
k=0;
iRemove=[];
if handles.model.delft3dflow.domain(id).nrThinDams>0
    % Check which points need to be removed
    for i=1:handles.model.delft3dflow.domain(id).nrThinDams
        m1=handles.model.delft3dflow.domain(id).thinDams(i).M1;
        n1=handles.model.delft3dflow.domain(id).thinDams(i).N1;
        m2=handles.model.delft3dflow.domain(id).thinDams(i).M2;
        n2=handles.model.delft3dflow.domain(id).thinDams(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.model.delft3dflow.domain(id).thinDams=removeFromStruc(handles.model.delft3dflow.domain(id).thinDams,i);
            handles.model.delft3dflow.domain(id).thinDamNames=removeFromCellArray(handles.model.delft3dflow.domain(id).thinDamNames,i);
        end
        handles.model.delft3dflow.domain(id).nrThinDams=handles.model.delft3dflow.domain(id).nrThinDams-length(iRemove);
        handles.model.delft3dflow.domain(id).activeThinDam=1;
        if handles.model.delft3dflow.domain(id).nrThinDams==0
            handles.model.delft3dflow.domain(id).thinDamNames={''};
            handles.model.delft3dflow.domain(id).thinDams(1).M1=[];
            handles.model.delft3dflow.domain(id).thinDams(1).M2=[];
            handles.model.delft3dflow.domain(id).thinDams(1).N1=[];
            handles.model.delft3dflow.domain(id).thinDams(1).N2=[];
            handles.model.delft3dflow.domain(id).thinDams(1).UV=[];
        end
    end
end

% Discharges
k=0;
iRemove=[];
if handles.model.delft3dflow.domain(id).nrDischarges>0
    % Check which points need to be removed
    for i=1:handles.model.delft3dflow.domain(id).nrDischarges
        m=handles.model.delft3dflow.domain(id).discharges(i).M;
        n=handles.model.delft3dflow.domain(id).discharges(i).N;
        if isnan(x(m,n))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.model.delft3dflow.domain(id).discharges=removeFromStruc(handles.model.delft3dflow.domain(id).discharges,i);
            handles.model.delft3dflow.domain(id).dischargeNames=removeFromCellArray(handles.model.delft3dflow.domain(id).dischargeNames,i);
        end
        handles.model.delft3dflow.domain(id).nrDischarges=handles.model.delft3dflow.domain(id).nrDischarges-length(iRemove);
        handles.model.delft3dflow.domain(id).activeDischarge=1;
        if handles.model.delft3dflow.domain(id).nrDischarges==0
            handles.model.delft3dflow.domain(id).dischargeNames={''};
            handles.model.delft3dflow.domain(id).discharges(1).M=[];
            handles.model.delft3dflow.domain(id).discharges(1).N=[];
            handles.model.delft3dflow.domain(id).discharges(1).type='normal';
        end
    end
end

