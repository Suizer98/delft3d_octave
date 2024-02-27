function R = slamfat_core_old(varargin)
%SLAMFAT_CORE  Supply Limited Advection Model For Aeolian Transport (SLAMFAT)
%
%   Supply Limited Advection Model For Aeolian Transport (SLAMFAT). This
%   conceptual advection model is a tool to study Aeolian transport
%   situations in supply limited situations, e.g. coastal environments. It
%   is based on a Bagnold (1954) power law for Aeolian transport, extended
%   with a formulation for supply of sediment from the bed.
%
%   The model basics are described in "Physics of Blown Sand and Coastal
%   Dunes", the PhD thesis by De Vries (2013).
%   http://dx.doi.org/10.4233/uuid:9a701423-8559-4a44-be5d-370d292b0df3
%
%   Syntax:
%   result = slamfat_core(varargin)
%
%   Input:
%   varargin  = profile:    beach profile [m]
%               wind:       wind time series matrix size=(nt,nx) [m/s]
%               threshold:  threshold velocity for Aeolian transport per
%                           sediment fraction [m/s]
%               source:     sediment source from the bed size=(nt,nx)
%                           [kg/m2]
%               dx:         spatial step size in input and output [m]
%               dt:         temporal step size in input and output [s]
%               T:          adaptation time scale [s]
%               g:          gravitational constant
%               relvel:     relative velocity of sediment with respect to
%                           wind speed [-]
%               bedcomposition: structure with settings for the
%                               bedcomposition module
%
%   Output:
%   result = result structure with all input variables and output
%            concentrations for transport, supply and capacity
%
%   Example
%   result = slamfat_core('wind', slamfat_wind)
%
%   See also slamfat_wind, slamfat_plot, bedcomposition

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 25 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: slamfat_core_old.m 9884 2013-12-16 09:30:07Z sierd.devries.x $
% $Date: 2013-12-16 17:30:07 +0800 (Mon, 16 Dec 2013) $
% $Author: sierd.devries.x $
% $Revision: 9884 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT/slamfat_core_old.m $
% $Keywords: $

%% read settings

tic;

OPT0 = struct(                      ...
    'profile',              [],     ...
    'wind',                 [],     ... t,x
    'threshold',            4,      ... 
    'source',               [],     ... t,x,fraction
    'dx',                   1,      ...
    'dt',                   0.05,   ...
    'T',                    0.5,    ...
    'g',                    9.81,   ...
    'relvel',               1,      ...
    'progress',             false,  ...
    'plot',                 false,  ...
    'slice',                1000,   ...
    'verbose',              false,  ...
    'bedcomposition',       struct( ...
        'enabled',          false,  ...
        'n_layers',         3,      ...
        'layer_thickness',  .001,     ...
        'initial_deposit',  0,      ...
        'grain_size',       [],     ... fractions
        'distribution',     1,      ... fractions
        'threshold',        [],     ... fractions
        'bed_density',      1600,   ... fractions
        'grain_density',    2650,   ... fractions
        'air_density',      1.25,   ...
        'water_density',    1025,   ...
        'sediment_type',    1,      ...
        'percentiles',      50,     ...
        'logsigma',         1.34,   ...
        'morfac',           1,      ...
        'A',                100));

OPT = setproperty(OPT0, varargin);

if iscell(OPT.bedcomposition)
    OPT.bedcomposition = setproperty(OPT0.bedcomposition, OPT.bedcomposition);
end

OPT_BC = OPT.bedcomposition;

if OPT.plot
    % wait a moment
elseif OPT.progress
    wb = waitbar(0, 'Initializing...');
end

%% check settings

% test for stability
if OPT.dx/OPT.dt < max(OPT.wind)
    OPT.dt = OPT.dx / max(OPT.wind);
    warning('Set dt to %4.3f in order to ensure numerical stability', OPT.dt);
end

if OPT.bedcomposition.enabled
    
    % align bed composition input
    OPT_BC = align_options(OPT_BC, ...
        {'grain_size' 'distribution' 'bed_density' 'grain_density' 'sediment_type' 'logsigma'});

    if isempty(OPT_BC.threshold) && isempty(OPT_BC.grain_size)
        OPT_BC.threshold = OPT.threshold;
    end
    
    % if grain size is given, compute threshold velocities or vice versa
    if isempty(OPT_BC.threshold) && ~isempty(OPT_BC.grain_size)

        % Bagnold formulation for threshold velocity:
        %     u* = A * sqrt(((rho_p - rho_a) * g * D) / rho_p)
        OPT_BC.threshold = OPT_BC.A * sqrt(((OPT_BC.bed_density - OPT_BC.air_density) .* ...
            OPT.g .* OPT_BC.grain_size) ./ OPT_BC.bed_density);

    elseif ~isempty(OPT_BC.threshold) && isempty(OPT_BC.grain_size)
        warning('Computing grain size from threshold velocity. It is better to define the threshold velocity.')

        % Inversed Bagnold formulation for threshold velocity:
        %     D = (u* / A)^2 * rho_p / g / (rho_p - rho_a)
        OPT_BC.grain_size = (OPT_BC.threshold ./ OPT_BC.A).^2 .* OPT_BC.bed_density ./ ...
            OPT.g ./ (OPT_BC.bed_density - OPT_BC.air_density);
    end
    
    % normalize distribution
    OPT_BC.distribution = OPT_BC.distribution / sum(OPT_BC.distribution);
    
    % distribute bed composition options
    OPT.bedcomposition = OPT_BC;
    OPT.threshold      = OPT_BC.threshold;
    
    nf = length(OPT.threshold);
else
    nf = 1;
end

% if wind is not space-varying or source not space-varying, make it as such
OPT = align_options(OPT, {'wind' 'source' 'profile'});
nt  = size(OPT.wind,1);
nx  = size(OPT.source,2);

% initialize profile
if isempty(OPT.profile)
    OPT.profile = zeros(nt,nx);
end

% expand matrices for numerical reasons
OPT.threshold = shiftdim(repmat(OPT.threshold(:),[1 nt nx]),1);
OPT.wind      = repmat(OPT.wind,[1 1 nf]);
OPT.source    = repmat(OPT.source,[1 1 nf]);
for i = 1:nf
    OPT.source(:,:,i) = OPT.source(:,:,i) * OPT_BC.distribution(i);
end

% number of percentiles
np = length(OPT_BC.percentiles);

% number of layers
nl = OPT_BC.n_layers;

%% initialize output

R = struct( ...
    'input', OPT,               ...
    'performance', struct(      ...
        'initialization', 0,    ...
        'transport',      0,    ...
        'bedcomposition', 0,    ...
        'grain_size',     0,    ...
        'plot',           0),   ...
    'dimensions', struct(       ...
        'time',         nt,     ...
        'space',        nx,     ...
        'fractions',    nf,     ...
        'layers',       nl,     ...
        'percentiles',  np),    ...
    'output',   struct(         ...
        'supply_limited',   false(nt,nx,nf),    ...
        'transport',        zeros(nt,nx,nf),    ...
        'supply',           zeros(nt,nx,nf,nl+2), ...
        'capacity',         zeros(nt,nx,nf),    ...
        'profile',          zeros(nt,nx),       ...
        'grain_size_perc',  zeros(nt,nx,np,nl+2)));

% concentration in transport
transport_tl = zeros(nt,nx,nf); % transport limited
transport_sl = zeros(nt,nx,nf); % supply limited

% concentration at bed
R.output.supply(:,:,:,1) = repmat(OPT.source(1,:,:),[nt 1 1]);

% concentration capacity (Bagnold)
%ff = repmat(linspace(2,1,20),[nt 1 nf]);
%OPT.threshold(R.output.supply(:,:,:,1)>0) = ff(:) .* OPT.threshold(R.output.supply(:,:,:,1)>0);
R.output.capacity = 1.5e-4 * ((OPT.wind - OPT.threshold).^3) ./ ...
                              (OPT.wind * OPT.relvel);
R.output.capacity = max(R.output.capacity, 0);

% grain size percentiles
if OPT.bedcomposition.enabled
    R.output.grain_size_perc(1,:,:,:) = compute_percentiles(OPT_BC.grain_size, squeeze(R.output.supply(1,:,:,:)), OPT_BC.percentiles);
end

% initialize plot
if OPT.plot
    fig = slamfat_plot_old(R,'start',1,'length',1);
end

%% initialize bed composition module

if OPT.bedcomposition.enabled
    if ~exist('bedcomposition.m','file')
        fpath = fullfile(fileparts(which(mfilename)), ...
            '../../../../programs/SandMudBedModule/02_Matlab/');
        if exist(fpath,'dir')
            warning('Added %s to path', fpath);
            addpath(fpath);
        else
            error('Bed composition module not found');
        end
    end

    fprintf('LOADED: %s\n\n', bedcomposition.version);

    bc = bedcomposition;

    bc.number_of_columns            = nx;
    bc.number_of_fractions          = nf;
    bc.bed_layering_type            = 2;
    bc.base_layer_updating_type     = 1;
    bc.number_of_lagrangian_layers  = 0;
    bc.number_of_eulerian_layers    = nl;
    bc.diffusion_model_type         = 0;
    bc.number_of_diffusion_values   = 5;
    bc.flufflayer_model_type        = 0;

    bc.initialize

    bc.thickness_of_transport_layer     = OPT_BC.layer_thickness * ones(nx,1);
    bc.thickness_of_lagrangian_layers   = OPT_BC.layer_thickness;
    bc.thickness_of_eulerian_layers     = OPT_BC.layer_thickness;

    bc.fractions(                           ...
        OPT_BC.sediment_type,               ...
        OPT_BC.grain_size,                  ...
        OPT_BC.logsigma,                    ...
        OPT_BC.bed_density);
    
    % initial deposit
    initial_mass_unit = repmat(OPT_BC.bed_density .* OPT_BC.distribution,nx,1);
    mass = OPT_BC.initial_deposit * initial_mass_unit;
    bc.deposit(mass', 0, OPT_BC.grain_density, zeros(size(mass')), OPT_BC.morfac);
end

% verbose helper variable
if OPT.verbose
    delayed_messages = struct( ...
        'mass', 0, ...
        'dz',   0);
end
    
R.performance.initialization = toc;

%% transport model

for t = 2:nt
    
    tic;
    
    current_top_layer = R.output.supply(t-1,:,:,1);
    
    % transport limited concentration
    transport_tl(t,2:end,:) = ((-OPT.relvel * OPT.wind(t-1,1:end-1,:) .*              ...
        (R.output.transport(t-1,2:end,:) - R.output.transport(t-1,1:end-1,:)) / OPT.dx) * OPT.dt +    ...
         R.output.transport(t-1,2:end,:) + R.output.capacity (t-1,2:end  ,:) / (OPT.T / OPT.dt)) / (1+1/(OPT.T/OPT.dt));
    
    % supply limited concentration
    transport_sl(t,2:end,:) =  (-OPT.relvel * OPT.wind(t-1,1:end-1,:) .*              ...
        (R.output.transport(t-1,2:end,:) - R.output.transport(t-1,1:end-1,:)) / OPT.dx) * OPT.dt +    ...
         R.output.transport(t-1,2:end,:) + current_top_layer (1  ,2:end  ,:)  / (OPT.T/OPT.dt);
        
    % determine where transport exceeds supply
    idx = (R.output.capacity(t-1,:,:) - transport_tl(t,:,:)) / (OPT.T/OPT.dt) > current_top_layer;

    R.output.transport(t,~idx) = transport_tl(t,~idx);
    R.output.transport(t, idx) = transport_sl(t, idx);
   
    R.performance.transport = R.performance.transport + toc; tic;
    
    % compute bed level change and/or change in supply
    if OPT.bedcomposition.enabled
        %OPT.source(t,:,:) = min(squeeze(OPT.source(t,:,:)), max(0,repmat((OPT.profile(1,:)-R.output.profile(t-1,:))',1,nf) .* initial_mass_unit));
        
        mass       = zeros(nx,nf);
        mass( idx) = OPT.source(t, idx) / OPT.dx - current_top_layer(1,idx) / (OPT.T/OPT.dt);
        mass(~idx) = OPT.source(t,~idx) / OPT.dx - (R.output.capacity(t-1,~idx) - R.output.transport(t,~idx)) / (OPT.T/OPT.dt);
        
        dz = bc.deposit(mass', OPT.dt, OPT_BC.grain_density, zeros(size(mass')), OPT_BC.morfac);
        R.output.profile(t,:) = R.output.profile(t-1,:) + dz;
        
        R.output.supply(t,:,:,:) = permute(bc.layer_mass(:,:,:),[3 1 2]); % lyr, frac, x -> x, frac, lyr
        
        if OPT.verbose
            delayed_messages.mass = delayed_messages.mass + mass(:);
            delayed_messages.dz   = delayed_messages.dz   + dz(:);
        end
    else
        R.output.supply(t, idx)    = R.output.supply(t-1, idx) + OPT.source(t, idx) / OPT.dx - ...
            R.output.supply(t-1,idx) / (OPT.T/OPT.dt);
        R.output.supply(t,~idx)    = R.output.supply(t-1,~idx) + OPT.source(t,~idx) / OPT.dx - ...
            (R.output.capacity(t-1,~idx) - R.output.transport(t,~idx)) / (OPT.T/OPT.dt);
    end

    R.output.supply_limited(t,:,:) = idx;
    
    R.performance.bedcomposition = R.performance.bedcomposition + toc; tic;
    
    % compute percentiles
    if OPT.bedcomposition.enabled
        R.output.grain_size_perc(t,:,:,:) = compute_percentiles(OPT_BC.grain_size, squeeze(R.output.supply(t,:,:,:)), OPT_BC.percentiles);
    end
    
    R.performance.grain_size = R.performance.grain_size + toc; tic;
    
    if mod(t,OPT.slice) == 0
        if OPT.plot
            slamfat_plot_old(R,'start',t,'length',1,'figure',fig);
        elseif OPT.progress
            waitbar(t/nt, wb, sprintf('Simulating... %d%%', round(t/nt*100)));
        elseif OPT.verbose
            
            fprintf('%20s : %10.4f g/m2\n', 'max. mass deposit',    max(delayed_messages.mass)    * 1000);
            fprintf('%20s : %10.4f g/m2\n', 'max. mass erosion',   -min(delayed_messages.mass)    * 1000);
            fprintf('%20s : %10.4f mm\n',   'max. profile change',  max(abs(delayed_messages.dz)) * 1000);

            delayed_messages.mass_max = 0;
            delayed_messages.mass_min = 0;
            delayed_messages.dz_max   = 0;
            
            tm = cell2mat(struct2cell(R.performance));
            tm_sum = sum(tm(2:end));
            
            fprintf('%s\n',repmat('-',1,60));
            
            fprintf('%20s : %10.4f s\n', 'initialization', tm(1));

            fprintf('%20s : %10.4f s [%5.1f%%]\n', ...
                'transport',            tm(2), tm(2)/tm_sum*100, ...
                'bed composition',      tm(3), tm(3)/tm_sum*100, ...
                'median grain size',    tm(4), tm(4)/tm_sum*100, ...
                'plot',                 tm(5), tm(5)/tm_sum*100, ...
                'total',                sum(tm), t/nt*100);
            
            fprintf('%s\n',repmat('-',1,60));
        end
    end
    
    R.performance.plot = R.performance.plot + toc;
end

if OPT.progress
    close(wb);
end

if OPT.bedcomposition.enabled
    bc.delete();
end

end

function d50 = compute_percentiles(grain_size, fractions, percentiles)

    nx = size(fractions,1);
    nf = size(fractions,2);
    nl = size(fractions,3);
    
    % repeat grain sizes
    grain_size = repmat(grain_size(:)',nx*nl,1);

    % normalize fractions
    fractions = cumsum(fractions,2)./repmat(sum(fractions,2),1,nf);
    fractions = reshape(permute(fractions,[1 3 2]),[nx*nl,nf]);
    
    idx = false(size(fractions));
    for i = 2:nf
        idx(squeeze(fractions(:,i)) > .5 & ~any(idx,2), i-1:i) = true;
    end
    
    n               = sum(idx(:))/2;
    fractions       = reshape(fractions(idx),n,2);
    factors         = (.5 - fractions(:,1)) ./ diff(fractions,1,2);
    grain_size      = reshape(log(grain_size(idx)),n,2);
    
    d50             = nan(nx*nl,1);
    d50(any(idx,2)) = exp(grain_size(:,1) + factors .* diff(grain_size,1,2));
    d50             = reshape(d50,nx,nl);
end

function OPT = align_options(OPT, fields)
    sizes = cell(size(fields));
    for i = 1:length(fields)
        if isfield(OPT, fields{i})
            sizes{i} = size(OPT.(fields{i}));
        end
    end
    
    ndims = max(cellfun(@length, sizes));
    
    for i = 1:length(fields)
        d = ndims - length(sizes{i});
        if d > 0
            sizes{i} = [sizes{i} ones(1,d)];
        end
    end
    
    sizes = reshape([sizes{:}],ndims,length(sizes))';
    
    for i = 1:length(fields)
        for j = 1:ndims
            n = max([1 min(sizes(sizes(:,j)>1,j))]);
            if n ~= sizes(i,j)
                if sizes(i,j) == 1
                    new_dims    = ones(1,ndims);
                    new_dims(j) = n;
                    OPT.(fields{i}) = repmat(OPT.(fields{i}),new_dims);
                elseif sizes(i,j) > 1
                    warning('Truncating dimension %d of %s to match other input', j, fields{i});
                    new_dims    = repmat({':'},1,ndims);
                    new_dims{j} = 1:n;
                    OPT.(fields{i}) = OPT.(fields{i})(new_dims{:});
                end
            end
        end
    end
end
