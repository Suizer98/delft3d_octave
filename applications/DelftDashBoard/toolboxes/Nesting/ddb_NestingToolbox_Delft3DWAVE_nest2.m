function ddb_NestingToolbox_Delft3DWAVE_nest2(varargin)
%ddb_NestingToolbox_Delft3DWAVE_nest2

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

% $Id: ddb_NestingToolbox_Delft3DWAVE_nest2.m 15807 2019-10-04 06:00:45Z ormondt $
% $Date: 2019-10-04 14:00:45 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15807 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_Delft3DWAVE_nest2.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Merge SP2 Files in order to generate boundary conditions from the overall model', ...
                'The detailed model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest2'}
            nest2;
        case{'selectcs'}
            selectCS;            
    end
end

%%
function nest2

handles=getHandles;

if handles.model.delft3dwave.domain.nrboundaries>0
    
    ButtonName = questdlg('Existing boundary sections will be removed! Continue?', ...
        '', ...
        'Cancel', 'OK', 'OK');
    switch ButtonName,
        case 'Cancel',
            return;
    end
end

% [filename, pathname, filterindex] = uigetfile('*.sp2', 'Select files to merge (select just one file)','');
fname=handles.toolbox.nesting.singleSP2file;

if ~isempty(fname)

    [dr,fname,ext]=fileparts(fname);

    ii=strfind(fname,'.');
    prefix=fname(1:ii-1);
    
    [filename, pathname, filterindex] = uiputfile('*.sp2', 'Boundary SP2 File Name',handles.model.delft3dwave.domain.boundaries(1).spectrum);
    
    handles = ddb_Delft3DWAVE_plotBoundaries(handles,'delete');

    handles.model.delft3dwave.domain.nrboundaries=1;
    handles.model.delft3dwave.domain.boundarynames{1}=filename;
    handles.model.delft3dwave.domain.activeboundary=1;
    handles.model.delft3dwave.domain.boundaries=[];
    handles.model.delft3dwave.domain.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.model.delft3dwave.domain.boundaries,1);
    handles.model.delft3dwave.domain.boundaries(1).definition='fromsp2file';
    handles.model.delft3dwave.domain.boundaries(1).overallspecfile=filename;
    handles.model.delft3dwave.domain.boundaries(1).name=filename;
    
    fout=handles.model.delft3dwave.domain.boundaries(1).overallspecfile;

    if ~strcmpi(handles.toolbox.nesting.delft3dwave.overallmodelcsname,'unspecified')
        cs1.name=handles.toolbox.nesting.delft3dwave.overallmodelcsname;
        cs1.type=handles.toolbox.nesting.delft3dwave.overallmodelcstype;
    else
        cs1=[];
    end

    cs2=handles.screenParameters.coordinateSystem;
    
    wb = waitbox('Merging SP2 Files ...');

    try
        swan_io_mergesp2(dr,fout,'prefix',prefix,'CS1',cs1,'CS2',cs2);
    catch
        close(wb);
        ddb_giveWarning('txt','Something went wrong while merging sp2 files!');
    end
    
    close(wb);
        
    setHandles(handles);
    
end

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok    
    handles.toolbox.nesting.delft3dwave.overallmodelcsname=cs;
    handles.toolbox.nesting.delft3dwave.overallmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;
