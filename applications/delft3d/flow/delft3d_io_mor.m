function varargout = delft3d_io_mor(varargin)
%DELFT3D_IO_MOR   load delft3d online sed *.mor keyword file 
%
%  D   = DELFT3D_IO_MOR(fname)
% 
% loads contents of *.mor file into struct D
%
%  [D,U]   = DELFT3D_IO_MOR(fname)
%  [D,U,M] = DELFT3D_IO_MOR(fname)
%
% optionally loads units and meta-info into structs U and M.
%
% Also works for *.sed files that have the same *.ini structure, in fact
% DELFT3D_IO_MOR is just a different name for DELFT3D_IO_SED.
%
%See also: delft3d, inivalue, DELFT3D_IO_SED

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id: delft3d_io_mor.m 4775 2011-07-07 15:32:26Z boer_g $
% $Date: 2011-07-07 23:32:26 +0800 (Thu, 07 Jul 2011) $
% $Author: boer_g $
% $Revision: 4775 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_mor.m $
% $Keywords: $

OPT.FileOption  = {};

[D,U,M] = delft3d_io_sed(varargin{:},'FileOption',OPT.FileOption);

varargout  = {D,U,M};

% [MorphologyFileInformation]
%    FileCreatedBy    = Delft3D-FLOW-GUI, Version: 3.41.02         
%    FileCreationDate = Thu May 12 2011, 17:58:05         
%    FileVersion      = 02.00                        
% [Morphology]
%    EpsPar           = false                         Vertical mixing distribution according to van Rijn (overrules k-epsilon model)         
%    IopKCW           = 1                             Flag for determining Rc and Rw         
%    RDC              = 0.01                 [m]      Current related roughness height (only used if IopKCW <> 1)
%    RDW              = 0.02                 [m]      Wave related roughness height (only used if IopKCW <> 1)
%    MorFac           =  1.0000000e+000      [-]      Morphological scale factor
%    MorStt           =  7.2000000e+002      [min]    Spin-up interval from TStart till start of morphological changes
%    Thresh           =  5.0000001e-002      [m]      Threshold sediment thickness for transport and erosion reduction
%    MorUpd           = false                         Update bathymetry during FLOW simulation
%    EqmBc            = true                          Equilibrium sand concentration profile at inflow boundaries
%    DensIn           = false                         Include effect of sediment concentration on fluid density
%    AksFac           =  1.0000000e+000      [-]      van Rijn's reference height = AKSFAC * KS
%    RWave            =  2.0000000e+000      [-]      Wave related roughness = RWAVE * estimated ripple height. Van Rijn Recommends range 1-3
%    AlfaBs           =  1.0000000e+000      [-]      Streamwise bed gradient factor for bed load transport
%    AlfaBn           =  1.5000000e+000      [-]      Transverse bed gradient factor for bed load transport
%    Sus              =  1.0000000e+000      [-]      Multiplication factor for suspended sediment reference concentration
%    Bed              =  1.0000000e+000      [-]      Multiplication factor for bed-load transport vector magnitude
%    SusW             =  1.0000000e+000      [-]      Wave-related suspended sed. transport factor
%    BedW             =  1.0000000e+000      [-]      Wave-related bed-load sed. transport factor
%    SedThr           =  1.0000000e-003      [m]      Minimum water depth for sediment computations
%    ThetSD           =  0.0000000e+000      [-]      Factor for erosion of adjacent dry cells
%    HMaxTH           =  1.5000000e+000      [m]      Max depth for variable THETSD. Set < SEDTHR to use global value only
%    FWFac            =  1.0000000e+000      [-]      Vertical mixing distribution according to van Rijn (overrules k-epsilon model)
