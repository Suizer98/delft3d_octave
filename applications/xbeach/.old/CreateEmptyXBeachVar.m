function [XB Precision] = CreateEmptyXBeachVar(varargin)
%CREATEEMPTYXBEACHVAR  creates communication variable for XBeach in- and output
%
% The variable contains three main fields:
%   - settings :    In which calculation settings as well as output
%               settings can be specified.
%   - Input :       This contains input like the initial profile, Hs, Tp,
%               grid specification, start and stop times etc.
%   - Output :      In which calculation results can be stored.
%   By use of PropertyName-PropertyValue pairs, the various elements of
%   settings and Input can be set.
%
%   Example
%   createEmptyXBeachVar
%
%   See also XB_run XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer / Kees den Heijer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 04 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: CreateEmptyXBeachVar.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/CreateEmptyXBeachVar.m $

%% main structure
XB = struct(...
    'settings', [],...
    'Input', [],...
    'Output', []);

%% settings
XB.settings = struct(...
    'Info', [],...
    'Grid', [],...
    'Waves', [],...
    'Flow', [],...
    'SedInput', [],...
    'OutputOptions',[]);

%% info settings
XB.settings.Info = struct(...
    'WaveBoundType', '',...
    'n_d', 1,...
    'n_w', 1,...
    'S', 1,...
    'nVarOutDef', 20);

[XB.settings.Info appliedid] = applyInput(XB.settings.Info, varargin{:});

%% Grid settings
XB.settings.Grid = struct(...
    'nx', [],... % scalar, number of cells in x-direction (cross-shore)
    'ny', [],... % scalar, number of cells in y-direction (alongshore)
    'vardx', 0,... % boolean, option of variable grid size (1 = varying grid size 0 = nonvarying grid size)
    'depfile', {''},... % string, bathymetry filename
    ... % only if vardx == 1 (non-equidistant grid):
    'xfile', '',... % string, filename of x-coordinates (matrix file)
    'yfile', '',... % string, filename of y-coordinates (matrix file)
    ... % only if vardx == 0 (equidistant grid):
    'dx', [],... % scalar, grid size in x
    'dy', [],... % scalar, grid size in y
    ...
    'xori', 0,... % scalar, x - origin in world coordinates
    'yori', 0,... % scalar, y - origin in world coordinates
    'alfa', 0,... % angle of grid
    'posdwn', -1,... % depth defined positive down (1 = positive down -1 = positive up)
    'scheme', [],... % Switch numerical schemes for wave action balance: 1 = up-wind, 2 = Lax-Wendroff, 
    'struct', 0,... % option for hard structures: 0 = no revetment, 1 = multiple sediment classes
    'ne_layer','');

[XB.settings.Grid tempid]= applyInput(XB.settings.Grid, varargin{:});
appliedid = appliedid | tempid;
%% Wave settings
XB.settings.Waves = struct(...
    'break', 1,... % option breaker model: 1=roelvink, 2 = baldock, 3 = roelvink adapted
    'Hrms', [],... % rms wave height, instat=0,1 only (in case of varrying conditions: duration in first column, value in second column)
    'Tm01', [],... % spectral period, instat=0-3 only (in case of varrying conditions: duration in first column, value in second column)
    'Trep', [],... % alternative keyword for representative period, overrules value for Tm01
    'Tlong', [],... % long wave / wave group period, instat = 1 only
    'dir0', 270,... % mean wave direction (Nautical convention), for instat == 0,1,2,3 only
    'hmin', .05,... % threshold water depth for concentration and return flow
    'gamma', [],... % breaker parameter in Baldock or Roelvink formulation
    'alpha', 1,... % wave dissipation coefficient
    'delta', .0,...
    'n', [],... % power in roelvink dissipation model
    'm', [],... % power in cos^m directional distribution
    'rho', 1000,... % density of water
    'g', 9.81,... % acceleration of gravity
    'thetamin', -180.0,... % lower directional limit, angle w.r.t computational x-axis
    'thetamax', 180.0,... % upper directional limit, angle w.r.t computational x-axis
    'dtheta', 360.0,... % directional resolution
    'wci', 0,... % wave current interaction option, instat = 0 only
    'instat', 6,... % wave boundary condition type
    'bcfile', {''},... % filename of boundary condition file, required for instat 4,5,6
    'rt', 2261,... % length for the boundary condition file
    'dtbc', .2,... % boundary condition file time step
    'nuh', .1,... % horizontal background
    'nuhfac', 1,... % viscosity coefficient for roller induced turbulent horizontal viscosity
    'roller', 1,... % option roller model
    'beta', .1,... % breaker slope coefficient in roller model
    'random', 1,...
    'back', 1,... % bayside boundary condition, 0 = 1D absorbing, 1 = wall, 2 = 2D absorbing
    'carspan', [],... % free long wave input, 0 = use cg (default); 1 = use sqrt(gh) in instat = 3 for c&g tests
    'swtable', [],...
    'rfb', [],... 
    'gammax', [],... % maximum ratio Hrms/hh
    'lat', []); % latitude

[XB.settings.Waves tempid] = applyInput(XB.settings.Waves, varargin{:});
appliedid = appliedid | tempid;

%% Flow settings
XB.settings.Flow = struct(...
    ... for backwards compatibility
    'tint', 1,... % time interval output global values
    ...
    'tstart', 100,... % start time of simulation
    'tstop', 2261,... % stop time simulation
    'nonh', [],... % nonhydrostatic option
    'tideloc', [],... % number of input
    'zs0file', {''},...
    'tidelen', {''},... % length of tidal record, (length(XB.settings.Flow.zs0)
    'paulrevere', [],... % option of sea/sea corner or sea/land corner specification
    'zs0', [],... % water level due to tide alone
    'cf', [],... % friction coefficient
    'C', 65.,... % Chezy coefficient, alternative for cf, overrules cf if set
    'eps', .001,... % threshold depth for drying and flooding
    'umin', .0,... % threshold velocity upwind scheme
    'CFL', 0.9,... % maximum courant number, actual CFL number varies during calculation
    'epsi', 0.01); % weighting factor between steady flow and particle velocity, 0=waves, 1=steady flow for seaward and bayward boundaries only

[XB.settings.Flow tempid] = applyInput(XB.settings.Flow, varargin{:});
appliedid = appliedid | tempid;

%% Sediment settings
XB.settings.SedInput = struct(...
    'A', .002,...
    'dico', 1.0,... % diffusion coefficient
    'D50', .0002,... % D50 grain diameter first (or only) class of sediment
    'D90', .0003,... % D90 grain diameter first (or only) class of sediment
    'rhos', 2650,... % density of sediment
    'morfac', 10,... % morfological factor
    'morstart', 100,... % start time of morphological updates
    'por', .4,... % porosity
    'dryslp', 1.0,... % critical avalanching slope above water
    'wetslp', .15,... % critical avalanching slope under water
    'hswitch', .1,... % water depth at interface from wetslp to dryslp
    'form', [],... % equilibrium sediment concentration formulation: 1 = Soulsby van Rijn, 2 = Van Rijn 2008
    'facua', [],...
    'dzmax', [],...
    'turb', [],...
    'Tsmin', []);

[XB.settings.SedInput tempid] = applyInput(XB.settings.SedInput, varargin{:});
appliedid = appliedid | tempid;

%% Output option settings
XB.settings.OutputOptions = struct(...
    ... for backwards compatibility
    'nglobalvar', [],...
    'OutVars', {{'cc' 'dims' 'D' 'E' 'Fx' 'Fy' 'Gd' 'hh' 'H' 'R' 'Su' 'Sv' 'u' 'ue' 'urms' 'v' 've' 'zb' 'zs'}},...
    ...
    'globalvars',{{'cc' 'dims' 'D' 'E' 'Fx' 'Fy' 'Gd' 'hh' 'H' 'R' 'Su' 'Sv' 'u' 'ue' 'urms' 'v' 've' 'zb' 'zs'}},...
    'tintg',1,... % time interval output global values
    'tsglobal',[],... % file with list of output times for global values
    'points',[],...
    'tintp',1,... % time interval output point
    'tspoints',[],... % file with list of output times for point values
    'meanvars',[],...
    'tintm',1,...
    'tsmean',[]); % file with list of output times for meanglobal values

[XB.settings.OutputOptions tempid] = applyInput(XB.settings.OutputOptions, varargin{:});

XB.settings.OutputOptions.nglobalvar = length(XB.settings.OutputOptions.OutVars);

appliedid = appliedid | tempid;
%% input
XB.Input = struct(...
    'xInitial', [],...
    'yInitial', [],...
    'zInitial', []);

[XB.Input tempid] = applyInput(XB.Input, varargin{:});
appliedid = appliedid | tempid;

%% specification of precision to write in the input files
Precision = {...
    'nx', '%g';...
    'ny', '%g';...
    'vardx', '%g';...
    'dx', '%g';...
    'dy', '%g';...
    'posdwn', '%g';...
    'break', '%g';...
    'n', '%g';...
    'rho', '%g';...
    'wci', '%g';...
    'instat', '%g';...
    'rt', '%g';...
    'nuhfac', '%g';...
    'roller', '%g';...
    'random', '%g';...
    'back', '%g';...
    'nonh', '%g';...
    'tideloc', '%g';...
    'tstart', '%g';...
    'tint', '%g';...
    'zs0file', '%s';...
    'tstop', '%g';...
    'rhos', '%g';...
    'morfac', '%g';...
    'morstart', '%g';...
    'bcfile', '%s';...
    'depfile', '%s';...
    'nglobalvar', '%f'};

%% warning if one of the input was not stored
% remove the string 'empty' from varargin if available
emptyid = strcmpi(varargin, 'empty');
varargin = varargin(~emptyid);
appliedid = appliedid(~emptyid);

% give warning if necessary
if any(~appliedid)
    pos = 1:2:length(appliedid);
    pos = pos(~appliedid(1:2:end));
    for ipos = 1:length(pos)
        warning('XBeach:ValueNotSet',['The parameter "' varargin{pos(ipos)} '" could not be found in the XBeach settings struct and is therefore not set.']);
    end
end

%% apply predefined input
function varargout = applyInput(OPT, varargin)
% subfunction to assign values which are specified in varargin to the
% related fields of the XB structure
if any(strcmp(varargin, 'empty'))
    inputvar(1:2:length(fieldnames(OPT))*2) = fieldnames(OPT)';
    inputvar(length(fieldnames(OPT))*2) = {[]};
    OPT = setproperty(OPT, inputvar);
end
id = false(size(varargin));
i = 1;
while i < length(varargin)
    if any(strcmpi(varargin{i}, fieldnames(OPT)))
        [id(i) id(i+1)] = deal(any(strcmpi(varargin{i}, fieldnames(OPT))));
        i = i+2;
    elseif strcmpi(varargin{i}, 'empty')
        id(i) = false;
        i = i+1;
    else
        i = i+2;
    end
end

varargout = {setproperty(OPT, varargin{id}), id};