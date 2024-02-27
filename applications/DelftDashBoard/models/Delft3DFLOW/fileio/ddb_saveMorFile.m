function handles = ddb_saveMorFile(handles, id)
%DDB_SAVEMORFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveMorFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveMorFile
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

% $Id: ddb_saveMorFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_saveMorFile.m $
% $Keywords: $

%%
s.MorphologyFileInformation.FileCreatedBy.value      = ['Delft DashBoard v' handles.delftDashBoardVersion];
s.MorphologyFileInformation.FileCreationDate.value   = datestr(now);
s.MorphologyFileInformation.FileVersion.value        = '02.00';

%%
s.Morphology.EpsPar.value     = handles.model.delft3dflow.domain(id).morphology.epsPar;
s.Morphology.EpsPar.type      = 'boolean';
s.Morphology.EpsPar.unit      = '-';
s.Morphology.EpsPar.comment   = 'Vertical mixing distribution according to van Rijn (overrules k-epsilon model)';

s.Morphology.IopKCW.value     = handles.model.delft3dflow.domain(id).morphology.iOpKcw;
s.Morphology.IopKCW.type      = 'integer';
s.Morphology.IopKCW.unit      = '-';
s.Morphology.IopKCW.comment   = 'Flag for determining Rc and Rw';

s.Morphology.RDC.value     = handles.model.delft3dflow.domain(id).morphology.rdc;
s.Morphology.RDC.type      = 'real';
s.Morphology.RDC.unit      = 'm';
s.Morphology.RDC.comment   = 'Current-related roughness height (only used if IopKCW <> 1)';

s.Morphology.RDW.value     = handles.model.delft3dflow.domain(id).morphology.rdw;
s.Morphology.RDW.type      = 'real';
s.Morphology.RDW.unit      = 'm';
s.Morphology.RDW.comment   = 'Wave-related roughness height (only used if IopKCW <> 1)';

s.Morphology.MorFac.value     = handles.model.delft3dflow.domain(id).morphology.morFac;
s.Morphology.MorFac.type      = 'real';
s.Morphology.MorFac.unit      = '-';
s.Morphology.MorFac.comment   = 'Morphological scale factor';

s.Morphology.MorStt.value     = handles.model.delft3dflow.domain(id).morphology.morStt;
s.Morphology.MorStt.type      = 'real';
s.Morphology.MorStt.unit      = 'min';
s.Morphology.MorStt.comment   = 'Spin-up interval from TStart till start of morphological changes';

s.Morphology.Thresh.value     = handles.model.delft3dflow.domain(id).morphology.thresh;
s.Morphology.Thresh.type      = 'real';
s.Morphology.Thresh.unit      = 'm';
s.Morphology.Thresh.comment   = 'Threshold sediment thickness for transport and erosion reduction';

s.Morphology.MorUpd.value     = handles.model.delft3dflow.domain(id).morphology.morUpd;
s.Morphology.MorUpd.type      = 'boolean';
s.Morphology.MorUpd.comment   = 'Update bathymetry during Delft3D-FLOW simulation';

s.Morphology.EqmBc.value     = handles.model.delft3dflow.domain(id).morphology.eqmBc;
s.Morphology.EqmBc.type      = 'boolean';
s.Morphology.EqmBc.comment   = 'Equilibrium sand concentration profile at inflow boundaries';

s.Morphology.DensIn.value     = handles.model.delft3dflow.domain(id).morphology.densIn;
s.Morphology.DensIn.type      = 'boolean';
s.Morphology.DensIn.comment   = 'Include effect of sediment concentration on fluid density';

s.Morphology.AlfaBs.value     = handles.model.delft3dflow.domain(id).morphology.alphaBs;
s.Morphology.AlfaBs.type      = 'real';
s.Morphology.AlfaBs.unit      = '-';
s.Morphology.AlfaBs.comment   = 'Streamwise bed-gradient factor for bed load transport';

s.Morphology.AlfaBn.value     = handles.model.delft3dflow.domain(id).morphology.alphaBn;
s.Morphology.AlfaBn.type      = 'real';
s.Morphology.AlfaBn.unit      = '-';
s.Morphology.AlfaBn.comment   = 'Transverse bed-gradient factor for bed load transport';

s.Morphology.Sus.value     = handles.model.delft3dflow.domain(id).morphology.sus;
s.Morphology.Sus.type      = 'real';
s.Morphology.Sus.unit      = '-';
s.Morphology.Sus.comment   = 'Calibration factor current-related suspended transport';

s.Morphology.Bed.value     = handles.model.delft3dflow.domain(id).morphology.bed;
s.Morphology.Bed.type      = 'real';
s.Morphology.Bed.unit      = '-';
s.Morphology.Bed.comment   = 'Calibration factor current-related bedload transport';

s.Morphology.SusW.value     = handles.model.delft3dflow.domain(id).morphology.susW;
s.Morphology.SusW.type      = 'real';
s.Morphology.SusW.unit      = '-';
s.Morphology.SusW.comment   = 'Calibration factor wave-related suspended transport';

s.Morphology.BedW.value     = handles.model.delft3dflow.domain(id).morphology.bedW;
s.Morphology.BedW.type      = 'real';
s.Morphology.BedW.unit      = '-';
s.Morphology.BedW.comment   = 'Calibration factor wave-related bedload transport';

s.Morphology.SedThr.value     = handles.model.delft3dflow.domain(id).morphology.sedThr;
s.Morphology.SedThr.type      = 'real';
s.Morphology.SedThr.unit      = 'm';
s.Morphology.SedThr.comment   = 'Minimum water depth for sediment computations';

s.Morphology.ThetSD.value     = handles.model.delft3dflow.domain(id).morphology.thetSd;
s.Morphology.ThetSD.type      = 'real';
s.Morphology.ThetSD.unit      = '-';
s.Morphology.ThetSD.comment   = 'Factor for erosion of adjacent dry cells';

s.Morphology.HMaxTh.value     = handles.model.delft3dflow.domain(id).morphology.hMaxTh;
s.Morphology.HMaxTh.type      = 'real';
s.Morphology.HMaxTh.unit      = 'm';
s.Morphology.HMaxTh.comment   = 'Max depth for variable THETSD. Set < SEDTHR to use global value only';

s.Morphology.FWFac.value     = handles.model.delft3dflow.domain(id).morphology.fwFac;
s.Morphology.FWFac.type      = 'real';
s.Morphology.FWFac.unit      = '-';
s.Morphology.FWFac.comment   = 'Wave-streaming factor';

ddb_saveDelft3D_keyWordFile(handles.model.delft3dflow.domain(id).morFile,s)

