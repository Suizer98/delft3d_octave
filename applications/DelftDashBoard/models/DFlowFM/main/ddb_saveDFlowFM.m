function ddb_saveDFlowFM(opt)

%DDB_SAVEDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDFlowFM(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_saveDFlowFM
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

% $Id: ddb_saveDFlowFM.m 14766 2018-10-30 16:52:54Z leijnse $
% $Date: 2018-10-31 00:52:54 +0800 (Wed, 31 Oct 2018) $
% $Author: leijnse $
% $Revision: 14766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/main/ddb_saveDFlowFM.m $
% $Keywords: $

%%
handles=getHandles;

switch lower(opt)
    
    %% Save MDU
    case{'save'}
        inp=handles.model.dflowfm.domain(ad);
        if ~isfield(handles.model.dflowfm.domain(ad),'mduFile')
            handles.model.dflowfm.domain(ad).mduFile=[handles.model.dflowfm.domain(ad).runid '.mdu'];
        end
        ddb_saveMDU(handles.model.dflowfm.domain(ad).mduFile,inp);
        ddb_DFlowFM_saveBatchFile(handles.model.dflowfm.exedir,'dflowfm.exe',handles.model.dflowfm.domain(ad).mduFile);
        
    %% Save MDU with a different name    
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdu', 'Select MDU File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdu');
            handles.model.dflowfm.domain(ad).runid=filename(1:ii-1);
            handles.model.dflowfm.domain(ad).mduFile=filename;
            ddb_saveMDU(filename,handles.model.dflowfm.domain(ad));
            ddb_DFlowFM_saveBatchFile(handles.model.dflowfm.exedir,'dflowfm.exe',handles.model.dflowfm.domain(ad).mduFile);
        end
    
    %% Save all files 
    case{'saveall'}

        % Check on extforcefile
        if ddb_check_write_extfile(handles)
            if isempty(handles.model.dflowfm.domain.extforcefilenew)
                [filename, pathname, filterindex] = uiputfile('*.ext', 'Save external focing file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.model.dflowfm.domain.extforcefilenew=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveExtFile(handles);

            % And now for the boundaries
            boundaries = handles.model.dflowfm.domain(1).boundaries;
            ipol=length(boundaries);
            ddb_DFlowFM_saveBoundaryPolygons('.\',boundaries,ipol); %(dr,boundaries,ipol)
            forcingfile = handles.model.dflowfm.domain.extforcefilenew;
            ddb_DFlowFM_saveBCfile(forcingfile,boundaries); %(forcingfile,boundaries)
        end
        
        % Observation points
        if handles.model.dflowfm.domain.nrobservationpoints>0
            if isempty(handles.model.dflowfm.domain.obsfile);
                [filename, pathname, filterindex] = uiputfile('*.xyn', 'Save observation points file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.model.dflowfm.domain.obsfile=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveObsFile(handles,ad);
        end

        % Cross-sections
        if handles.model.dflowfm.domain.nrcrosssections>0
            if isempty(handles.model.dflowfm.domain.crsfile)
                [filename, pathname, filterindex] = uiputfile('*.xyn', 'Save cross sections file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.model.dflowfm.domain.crsfile=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveCrsFile(handles.model.dflowfm.domain.crsfile,handles.model.dflowfm.domain.crosssections);
        end
        
        % Grid 
        netStruc2nc(handles.model.dflowfm.domain.netfile,handles.model.dflowfm.domain.netstruc,'cstype',handles.screenParameters.coordinateSystem.type, 'csname', handles.screenParameters.coordinateSystem.name);

        % Finalize
        inp=handles.model.dflowfm.domain(ad);
        if ~isfield(handles.model.dflowfm.domain(ad),'mduFile')
            handles.model.dflowfm.domain(ad).mduFile=[handles.model.dflowfm.domain(ad).runid '.mdu'];
        end
        ddb_saveMDU(handles.model.dflowfm.domain(ad).mduFile,inp);
        ddb_DFlowFM_saveBatchFile(handles.model.dflowfm.exedir,'dflowfm.exe',handles.model.dflowfm.domain(ad).mduFile);
        fclose('all'); 
end

setHandles(handles);
