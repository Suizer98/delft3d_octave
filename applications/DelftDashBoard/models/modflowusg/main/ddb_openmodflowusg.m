function ddb_openDelft3DFLOW(opt)
%DDB_OPENDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_openDelft3DFLOW(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_openDelft3DFLOW
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
handles=getHandles;

switch opt
    case {'opendomains'}
        % DD
        [filename, pathname, filterindex] = uigetfile('*.ddb', 'Select ddbound file');
        if pathname~=0
            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end
            ddb_plotDelft3DFLOW('delete');
            handles.model.delft3dflow.domain=[];
            handles=ddb_readDDBoundFile(handles,filename);
            for i=1:handles.model.delft3dflow.nrDomains
                handles.activeDomain=i;
                runid=handles.model.delft3dflow.domain(i).runid;
                handles=ddb_initializeFlowDomain(handles,'all',i,runid);
                filename=[runid '.mdf'];
                handles=ddb_readMDF(handles,filename,i);
                handles=ddb_readAttributeFiles(handles,i);
            end
            % Get coordinates of DD boundaries
            handles=ddb_getDDBoundCoordinates(handles);
            handles.activeDomain=1;
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',0);
            gui_updateActiveTab;
        end
    case {'openpresent'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end
        else
            return
        end
        id=handles.activeDomain;
        ddb_plotDelft3DFLOW('delete');
        handles.model.delft3dflow.domain=clearStructure(handles.model.delft3dflow.domain,id);
        runid=filename(1:end-4);
        handles.model.delft3dflow.domains{id}=runid;
        handles.model.delft3dflow.DDBoundaries=[];
        handles=ddb_initializeFlowDomain(handles,'all',id,runid);
        filename=[runid '.mdf'];
        handles=ddb_readMDF(handles,filename,id);
        handles=ddb_readAttributeFiles(handles,id);
        
        % Also read in wave model if necessary
        waveok=1;
        if handles.model.delft3dflow.domain(id).waves
            [filename, pathnamewave, filterindex] = uigetfile('*.mdw', 'Select MDW file');
            if pathname~=0
                pathnamewave=pathnamewave(1:end-1); % Get rid of last file seperator
            else
                return
            end
            if ~strcmpi(pathname,pathnamewave)
                ddb_giveWarning('txt','The WAVE model must be in the same directory as the FLOW model!');
                waveok=0;
            else
                % Delete all domains
                ddb_plotDelft3DWAVE('delete','domain',0);
                handles.model.delft3dwave.domain = [];
                handles.activeWaveGrid                      = 1;
                handles  = ddb_initializeDelft3DWAVEInput(handles,runid);
                filename =[runid '.mdw'];
                handles  = ddb_readMDW(handles,filename);
                handles  = ddb_Delft3DWAVE_readAttributeFiles(handles);
                handles.model.delft3dwave.domain.referencedate=handles.model.delft3dflow.domain(1).itDate;
                handles.model.delft3dwave.domain.mapwriteinterval=handles.model.delft3dflow.domain(1).mapInterval;
                handles.model.delft3dwave.domain.comwriteinterval=handles.model.delft3dflow.domain(1).comInterval;
                handles.model.delft3dwave.domain.writecom=1;
                handles.model.delft3dwave.domain.coupling='ddbonline';
                handles.model.delft3dwave.domain.mdffile=handles.model.delft3dflow.domain(1).mdfFile;
                for id=1:handles.model.delft3dflow.nrDomains
                    handles.model.delft3dflow.domain(id).waves=1;
                    handles.model.delft3dflow.domain(id).onlineWave=1;
                end
                if handles.model.delft3dflow.domain(1).comInterval==0 || handles.model.delft3dflow.domain(1).comStartTime==handles.model.delft3dflow.domain(1).comStopTime
                    ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
                end
                if ~handles.model.delft3dflow.domain(1).wind
                    % Turn off wind
                    for id=1:handles.model.delft3dwave.domain.nrgrids
                        handles.model.delft3dwave.domain.domains(id).flowwind=0;
                    end
                end
            end
            
        end
        
        xl(1)=min(min(handles.model.delft3dflow.domain(id).gridX));
        xl(2)=max(max(handles.model.delft3dflow.domain(id).gridX));
        yl(1)=min(min(handles.model.delft3dflow.domain(id).gridY));
        yl(2)=max(max(handles.model.delft3dflow.domain(id).gridY));
        handles=ddb_zoomTo(handles,xl,yl,0.1);
        
        setHandles(handles);
                
        if handles.model.delft3dflow.domain(id).waves && waveok
            ddb_plotDelft3DWAVE('plot','active',0,'visible',1,'wavedomain',awg);
        end
        
        ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',ad);
        
        ddb_updateDataInScreen;
        gui_updateActiveTab;

    case {'opennew'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end
            ddb_plotDelft3DFLOW('delete');
            handles.model.delft3dflow.nrDomains=handles.model.delft3dflow.nrDomains+1;
            handles.activeDomain=handles.model.delft3dflow.nrDomains;
            id=handles.activeDomain;
            handles.model.delft3dflow.domain=appendStructure(handles.model.delft3dflow.domain);
            runid=filename(1:end-4);
            handles.model.delft3dflow.domains{id}=runid;
            handles.model.delft3dflow.DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,'all',id,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,filename,id);
            handles=ddb_readAttributeFiles(handles,id);

            xl(1)=min(min(handles.model.delft3dflow.domain(id).gridX));
            xl(2)=max(max(handles.model.delft3dflow.domain(id).gridX));
            yl(1)=min(min(handles.model.delft3dflow.domain(id).gridY));
            yl(2)=max(max(handles.model.delft3dflow.domain(id).gridY));
            handles=ddb_zoomTo(handles,xl,yl,0.1);
            
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',0);
            ddb_updateDataInScreen;
            gui_updateActiveTab;
        end
end

ddb_refreshDomainMenu;
