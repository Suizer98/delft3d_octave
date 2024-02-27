function handles = ddb_saveSedFile(handles, id)
%DDB_SAVESEDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveSedFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveSedFile
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

% $Id: ddb_saveSedFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_saveSedFile.m $
% $Keywords: $

%%
s.SedimentFileInformation.FileCreatedBy.value      = ['Delft DashBoard v' handles.delftDashBoardVersion];
s.SedimentFileInformation.FileCreationDate.value   = datestr(now);
s.SedimentFileInformation.FileVersion.value        = '02.00';

%%
s.SedimentOverall.Cref.value     =  1.6000000e+003;
s.SedimentOverall.Cref.type      =  'real';
s.SedimentOverall.Cref.unit      = 'kg/m3';
s.SedimentOverall.Cref.comment   = 'CSoil Reference density for hindered settling calculations';

s.SedimentOverall.IopSus.value   =  0;
s.SedimentOverall.IopSus.type    =  'integer';
s.SedimentOverall.IopSus.comment =  'If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%%
for i=1:handles.model.delft3dflow.domain(id).nrSediments
    
    switch lower(handles.model.delft3dflow.domain(id).sediment(i).type)
        case{'non-cohesive'}
            tp='sand';
        case{'cohesive'}
            tp='mud';
    end
    
    s.Sediment(i).Name.value     =  handles.model.delft3dflow.domain(id).sediment(i).name;
    s.Sediment(i).Name.comment   =  'Name of sediment fraction';
    
    s.Sediment(i).SedTyp.value   =  tp;
    s.Sediment(i).SedTyp.comment =  'Must be "sand", "mud" or "bedload"';
    
    s.Sediment(i).RhoSol.value   =  handles.model.delft3dflow.domain(id).sediment(i).rhoSol;
    s.Sediment(i).RhoSol.unit    = 'kg/m3';
    s.Sediment(i).RhoSol.type    =  'real';
    s.Sediment(i).RhoSol.comment =  'Specific density';
    
    s.Sediment(i).CDryB.value    =  handles.model.delft3dflow.domain(id).sediment(i).cDryB;
    s.Sediment(i).CDryB.unit     = 'kg/m3';
    s.Sediment(i).CDryB.type     = 'real';
    s.Sediment(i).CDryB.comment  = 'Dry bed density';
    
    if handles.model.delft3dflow.domain(id).sediment(i).uniformThickness
        s.Sediment(i).IniSedThick.value    =  handles.model.delft3dflow.domain(id).sediment(i).iniSedThick;
        s.Sediment(i).IniSedThick.unit     = 'm';
        s.Sediment(i).IniSedThick.type     = 'real';
        s.Sediment(i).IniSedThick.comment  = 'Initial sediment layer thickness at bed (uniform value or filename)';
    else
        s.Sediment(i).IniSedThick.value    =  handles.model.delft3dflow.domain(id).sediment(i).sdbFile;
        s.Sediment(i).IniSedThick.unit     = 'm';
        s.Sediment(i).IniSedThick.type     = 'string';
        s.Sediment(i).IniSedThick.comment  = 'Initial sediment layer thickness at bed (uniform value or filename)';
    end
    
    s.Sediment(i).FacDSS.value    =  handles.model.delft3dflow.domain(id).sediment(i).facDSS;
    s.Sediment(i).FacDSS.unit     = '-';
    s.Sediment(i).FacDSS.type     = 'real';
    s.Sediment(i).FacDSS.comment  = 'FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]';
    
    switch lower(handles.model.delft3dflow.domain(id).sediment(i).type)
        
        case{'non-cohesive'}
            s.Sediment(i).SedDia.value    =  handles.model.delft3dflow.domain(id).sediment(i).sedDia/1000;
            s.Sediment(i).SedDia.unit     = 'm';
            s.Sediment(i).SedDia.type     = 'real';
            s.Sediment(i).SedDia.comment  = 'Median sediment diameter (D50)';
            
        case{'cohesive'}
            s.Sediment(i).SalMax.value    =  handles.model.delft3dflow.domain(id).sediment(i).salMax;
            s.Sediment(i).SalMax.unit     = 'ppt';
            s.Sediment(i).SalMax.type     = 'real';
            s.Sediment(i).SalMax.comment  = 'Salinity for saline settling velocity';
            
            s.Sediment(i).WS0.value    =  handles.model.delft3dflow.domain(id).sediment(i).wS0/1000;
            s.Sediment(i).WS0.unit     = 'm/s';
            s.Sediment(i).WS0.type     = 'real';
            s.Sediment(i).WS0.comment  = 'Settling velocity fresh water';
            
            s.Sediment(i).WSM.value    =  handles.model.delft3dflow.domain(id).sediment(i).wSM/1000;
            s.Sediment(i).WSM.unit     = 'm/s';
            s.Sediment(i).WSM.type     = 'real';
            s.Sediment(i).WSM.comment  = 'Settling velocity saline water';
            
            
            if handles.model.delft3dflow.domain(id).sediment(i).uniformEroPar
                s.Sediment(i).EroPar.value = handles.model.delft3dflow.domain(id).sediment(i).eroPar;
                s.Sediment(i).EroPar.unit     = 'kg/m2/s';
                s.Sediment(i).EroPar.type     = 'real';
                s.Sediment(i).EroPar.comment  = 'Erosion Parameter';
            else
                s.Sediment(i).EroPar.value = handles.model.delft3dflow.domain(id).sediment(i).eroFile;
                s.Sediment(i).EroPar.unit     = 'kg/m2/s';
                s.Sediment(i).EroPar.type     = 'string';
                s.Sediment(i).EroPar.comment  = 'Erosion Parameter';
            end
            
            if handles.model.delft3dflow.domain(id).sediment(i).uniformTCrSed
                s.Sediment(i).TcrSed.value    = handles.model.delft3dflow.domain(id).sediment(i).tCrSed;
                s.Sediment(i).TcrSed.unit     = 'N/m2';
                s.Sediment(i).TcrSed.type     = 'real';
                s.Sediment(i).TcrSed.comment  = 'Critical bed shear stress for sedimentation (uniform value or filename)';
            else
                s.Sediment(i).TcrSed.value = handles.model.delft3dflow.domain(id).sediment(i).tcdFile;
                s.Sediment(i).TcrSed.unit     = 'N/m2';
                s.Sediment(i).TcrSed.type     = 'string';
                s.Sediment(i).TcrSed.comment  = 'Critical bed shear stress for sedimentation (uniform value or filename)';
            end
            
            if handles.model.delft3dflow.domain(id).sediment(i).uniformTCrEro
                s.Sediment(i).TcrEro.value    = handles.model.delft3dflow.domain(id).sediment(i).tCrEro;
                s.Sediment(i).TcrEro.unit     = 'N/m2';
                s.Sediment(i).TcrEro.type     = 'real';
                s.Sediment(i).TcrEro.comment  = 'Critical bed shear stress for erosion (uniform value or filename)';
            else
                s.Sediment(i).TcrEro.value = handles.model.delft3dflow.domain(id).sediment(i).tceFile;
                s.Sediment(i).TcrEro.unit     = 'N/m2';
                s.Sediment(i).TcrEro.type     = 'string';
                s.Sediment(i).TcrEro.comment  = 'Critical bed shear stress for erosion (uniform value or filename)';
            end
            
    end
    
end

ddb_saveDelft3D_keyWordFile(handles.model.delft3dflow.domain(id).sedFile,s)

