function ddb_NestingToolbox_Delft3DWAVE_nest1(varargin)
%ddb_NestingToolbox_Delft3DWAVE_nest1

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_NestingToolbox_Delft3DWAVE_nest1.m 12132 2015-07-24 15:13:02Z ormondt $
% $Date: 2015-07-24 23:13:02 +0800 (Fri, 24 Jul 2015) $
% $Author: ormondt $
% $Revision: 12132 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_Delft3DWAVE_nest1.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Observation Points in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest1'}
            nest1;
        case{'selectcs'}
            selectCS;
    end
end

%%
function nest1

handles=getHandles;

if isempty(handles.model.delft3dwave.domain.domains(awg).gridx)
    ddb_giveWarning('text','Please first load or create model grid!');
    return
end

switch lower(handles.toolbox.nesting.delft3dwave.detailmodeltype)
    
    case{'delft3dwave'}
        
        if isempty(handles.toolbox.nesting.delft3dwave.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end        
        if isempty(handles.toolbox.nesting.delft3dwave.depFile)
            ddb_giveWarning('text','Please first load depth file of nested model!');
            return
        end
                
        overall.cs=handles.screenParameters.coordinateSystem;
        detail.cs.name=handles.toolbox.nesting.delft3dwave.detailmodelcsname;
        detail.cs.type=handles.toolbox.nesting.delft3dwave.detailmodelcstype;
        detail.grdfile=handles.toolbox.nesting.delft3dwave.grdFile;
        detail.depfile=handles.toolbox.nesting.delft3dwave.depFile;
        method=handles.toolbox.nesting.delft3dwave.spacing_method;
        switch method
            case{'distance'}
                len=handles.toolbox.nesting.delft3dwave.max_distance_per_section;
            case{'number_of_cells'}
                len=handles.toolbox.nesting.delft3dwave.nr_cells_per_section;
        end
        
        [xx,yy]=nest1_delft3dwave_in_delft3dwave(overall,detail,-5,method,len);

    case{'xbeach'}
        
        [xg,yg,enc,cs,nodatavalue] = wlgrid('read',handles.toolbox.nesting.delft3dwave.grdFile);
        xg1=0.5*(xg(1,1)+xg(end,1));
        yg1=0.5*(yg(1,1)+yg(end,1));
        sections(1).x=xg1;
        sections(1).y=yg1;
        sections(1).z=-100;
        
end

[xg,yg,enc,cs,nodatavalue] = wlgrid('read',handles.toolbox.nesting.delft3dwave.grdFile);
depth = wldep('read',handles.toolbox.nesting.delft3dwave.depFile,[size(xg,1)+1 size(xg,2)+1]);
depth=depth(1:end-1,1:end-1);

bnd=findboundarysectionsonregulargrid(xg,yg,depth);

nbnd=length(bnd);

nlocsets=handles.model.delft3dwave.domain.nrlocationsets;

% File name locations file
[filename, pathname, filterindex] = uiputfile('*.loc','File name locations file (length of file name should be less than 5 characters!)');
if ~pathname==0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    if nlocsets>0
        ii=strmatch(filename,handles.model.delft3dwave.domain.locationfile,'exact');
    else
        ii=[];
    end
    if isempty(ii)
        % New location set
        nlocsets=nlocsets+1;
    end
    handles.model.delft3dwave.domain.locationfile{nlocsets}=filename;
else
    return
end

handles.model.delft3dwave.domain.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.model.delft3dwave.domain.locationsets,nlocsets);

np=length(xx);
handles.model.delft3dwave.domain.locationsets(nlocsets).x=xx;
handles.model.delft3dwave.domain.locationsets(nlocsets).y=yy;
handles.model.delft3dwave.domain.locationsets(nlocsets).nrpoints=np;

for ii=1:np
    handles.model.delft3dwave.domain.locationsets(nlocsets).pointtext{ii}=num2str(ii);
end

handles.model.delft3dwave.domain.nrlocationsets=nlocsets;
handles.model.delft3dwave.domain.activelocationset=nlocsets;

% Save locations file
ddb_Delft3DWAVE_saveLocationFile(handles.model.delft3dwave.domain.locationfile{nlocsets},handles.model.delft3dwave.domain.locationsets(nlocsets));

handles.model.delft3dwave.domain.writespec2d=1;

handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',0);

setHandles(handles);

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok    
    handles.toolbox.nesting.delft3dwave.detailmodelcsname=cs;
    handles.toolbox.nesting.delft3dwave.detailmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;
