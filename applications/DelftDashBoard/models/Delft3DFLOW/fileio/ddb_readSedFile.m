function handles = ddb_readSedFile(handles, id)
%DDB_READSEDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readSedFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readSedFile
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

% $Id: ddb_readSedFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_readSedFile.m $
% $Keywords: $

%%

if ~exist(handles.model.delft3dflow.domain(id).sedFile,'file')
    ddb_giveWarning('text',['Sed file ' handles.model.delft3dflow.domain(id).sedFile ' does not exist!']);
    return
end

s=ddb_readDelft3D_keyWordFile(handles.model.delft3dflow.domain(id).sedFile,'firstcharacterafterdata',' ');

handles.model.delft3dflow.domain(id).nrSediments=length(s.sediment);

handles.model.delft3dflow.domain(id).sediment=[];
handles.model.delft3dflow.domain(id).sediments=[];

handles.model.delft3dflow.domain(id).sediments.include=1;
handles.model.delft3dflow.domain(id).sediments.cRef=1600;
handles.model.delft3dflow.domain(id).sediments.iOpSus=0;
handles.model.delft3dflow.domain(id).sediments.sedimentNames={''};
handles.model.delft3dflow.domain(id).sediments.activeSediment=1;

if isfield(s.sedimentoverall,'cref')
    handles.model.delft3dflow.domain(id).sediments.cRef=s.sedimentoverall.cref;
end
if isfield(s.sedimentoverall,'iopsus')
    handles.model.delft3dflow.domain(id).sediments.iOpSus=s.sedimentoverall.iopsus;
end

for i=1:handles.model.delft3dflow.domain(id).nrSediments
    
    handles.model.delft3dflow.domain(id).sediment(i).type=s.sediment(i).sedtyp;
    
    handles.model.delft3dflow.domain(id).sediment(i).name=s.sediment(i).name;
    
    handles.model.delft3dflow.domain(id).sediments.sedimentNames{i}=handles.model.delft3dflow.domain(id).sediment(i).name;
    
    handles=ddb_initializeSediment(handles,id,i);
    
    if isfield(s.sediment(i),'rhosol')
        handles.model.delft3dflow.domain(id).sediment(i).rhoSol=s.sediment(i).rhosol;
    end
    if isfield(s.sediment(i),'cdryb')
        handles.model.delft3dflow.domain(id).sediment(i).cDryB=s.sediment(i).cdryb;
    end
    if isfield(s.sediment(i),'inisedthick')
        if ischar(s.sediment(i).inisedthick)
            handles.model.delft3dflow.domain(id).sediment(i).uniformThickness=0;
            handles.model.delft3dflow.domain(id).sediment(i).sdbFile=s.sediment(i).inisedthick;
        else
            handles.model.delft3dflow.domain(id).sediment(i).uniformThickness=1;
            handles.model.delft3dflow.domain(id).sediment(i).iniSedThick=s.sediment(i).inisedthick;
        end
    end
    if isfield(s.sediment(i),'facdss')
        handles.model.delft3dflow.domain(id).sediment(i).facDSS=s.sediment(i).facdss;
    end
    
    
    switch lower(s.sediment(i).sedtyp)
        case{'sand'}
            handles.model.delft3dflow.domain(id).sediment(i).type='non-cohesive';
            if isfield(s.sediment(i),'seddia')
                handles.model.delft3dflow.domain(id).sediment(i).sedDia=s.sediment(i).seddia*1000;
            end
            if isfield(s.sediment(i),'sedd10')
                handles.model.delft3dflow.domain(id).sediment(i).sedD10=s.sediment(i).sedd10*1000;
            end
            if isfield(s.sediment(i),'sedd90')
                handles.model.delft3dflow.domain(id).sediment(i).sedD90=s.sediment(i).sedd90*1000;
            end
        case{'mud'}
            handles.model.delft3dflow.domain(id).sediment(i).type='cohesive';
            if isfield(s.sediment(i),'salmax')
                handles.model.delft3dflow.domain(id).sediment(i).salMax=s.sediment(i).salmax;
            end
            if isfield(s.sediment(i),'ws0')
                handles.model.delft3dflow.domain(id).sediment(i).wS0=s.sediment(i).ws0*1000;
            end
            if isfield(s.sediment(i),'wsm')
                handles.model.delft3dflow.domain(id).sediment(i).wSM=s.sediment(i).wsm*1000;
            end
            
            if isfield(s.sediment(i),'eropar')
                if ischar(s.sediment(i).eropar)
                    handles.model.delft3dflow.domain(id).sediment(i).uniformEroPar=0;
                    handles.model.delft3dflow.domain(id).sediment(i).eroFile=s.sediment(i).eropar;
                else
                    handles.model.delft3dflow.domain(id).sediment(i).uniformEroPar=1;
                    handles.model.delft3dflow.domain(id).sediment(i).eroPar=s.sediment(i).eropar;
                end
            end
            
            if isfield(s.sediment(i),'tcrsed')
                if ischar(s.sediment(i).tcrsed)
                    handles.model.delft3dflow.domain(id).sediment(i).uniformTCrSed=0;
                    handles.model.delft3dflow.domain(id).sediment(i).tcdFile=s.sediment(i).tcrsed;
                else
                    handles.model.delft3dflow.domain(id).sediment(i).uniformTCrSed=1;
                    handles.model.delft3dflow.domain(id).sediment(i).tCrSed=s.sediment(i).tcrsed;
                end
            end
            
            if isfield(s.sediment(i),'tcrero')
                if ischar(s.sediment(i).tcrero)
                    handles.model.delft3dflow.domain(id).sediment(i).uniformTCrEro=0;
                    handles.model.delft3dflow.domain(id).sediment(i).tceFile=s.sediment(i).tcrero;
                else
                    handles.model.delft3dflow.domain(id).sediment(i).uniformTCrEro=1;
                    handles.model.delft3dflow.domain(id).sediment(i).tCrEro=s.sediment(i).tcrero;
                end
            end
            
    end
end


