classdef slamfat_bedcomposition < slamfat_bedcomposition_basic
    %SLAMFAT_BEDCOMPOSITION  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_bedcomposition.slamfat_bedcomposition
    
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
    %   This library is free software: you can redistribute it and/or
    %   modify it under the terms of the GNU Lesser General Public
    %   License as published by the Free Software Foundation, either
    %   version 2.1 of the License, or (at your option) any later version.
    %
    %   This library is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %   Lesser General Public License for more details.
    %
    %   You should have received a copy of the GNU Lesser General Public
    %   License along with this library. If not, see <http://www.gnu.org/licenses/>.
    %   --------------------------------------------------------------------
    
    % This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 05 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: slamfat_bedcomposition.m 9936 2014-01-06 09:05:45Z hoonhout $
    % $Date: 2014-01-06 17:05:45 +0800 (Mon, 06 Jan 2014) $
    % $Author: hoonhout $
    % $Revision: 9936 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_bedcomposition.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        layer_thickness     = 1e-3
        
        sediment_type       = 1
        logsigma            = 1.34
        morfac              = 1
    end
    
    properties(GetAccess = public, SetAccess = protected)
        layer_mass          = []
        d50                 = []
    end
    
    properties(GetAccess = protected, SetAccess = protected)
        bedcomposition_module   = []
    end
    
    %% Methods
    methods(Static)    
        function addpath()
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
        end
    end
    
    methods
        function this = slamfat_bedcomposition(varargin)
            %SLAMFAT_BEDCOMPOSITION  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_bedcomposition(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_bedcomposition"
            %
            %   Example
            %   slamfat_bedcomposition
            %
            %   See also slamfat_bedcomposition
            
            setproperty(this, varargin);
        end
        
        function initialize(this)
            if ~this.isinitialized
                initialize@slamfat_bedcomposition_basic(this);
                
                this.number_of_fractions = length(this.grain_size);
                
                this.logsigma      = this.unify_series(this.logsigma);
                this.sediment_type = this.unify_series(this.sediment_type);
                
                this.addpath;

                fprintf('LOADED: %s\n\n', bedcomposition.version);

                this.bedcomposition_module = bedcomposition;

                this.bedcomposition_module.number_of_columns            = this.number_of_gridcells;
                this.bedcomposition_module.number_of_fractions          = this.number_of_fractions;
                this.bedcomposition_module.bed_layering_type            = 2;
                this.bedcomposition_module.base_layer_updating_type     = 1;
                this.bedcomposition_module.number_of_lagrangian_layers  = 0;
                this.bedcomposition_module.number_of_eulerian_layers    = this.number_of_layers;
                this.bedcomposition_module.diffusion_model_type         = 0;
                this.bedcomposition_module.number_of_diffusion_values   = 5;
                this.bedcomposition_module.flufflayer_model_type        = 0;

                this.bedcomposition_module.initialize

                this.bedcomposition_module.thickness_of_transport_layer   = this.get_layer_thickness * ones(this.number_of_gridcells,1);
                this.bedcomposition_module.thickness_of_lagrangian_layers = this.get_layer_thickness;
                this.bedcomposition_module.thickness_of_eulerian_layers   = this.get_layer_thickness;

                this.bedcomposition_module.fractions(           ...
                    this.sediment_type, ...
                    this.grain_size,    ...
                    this.logsigma,      ...
                    this.bed_density);

                th = zeros(this.get_number_of_actual_layers, this.number_of_gridcells) + this.get_layer_thickness;
                p  = zeros(this.get_number_of_actual_layers, this.number_of_gridcells) + this.porosity;

                this.bedcomposition_module.init_layer_thickness(th);
                this.bedcomposition_module.init_porosity(p);

                this.isinitialized = true;

                % initial bed composition
                mass = permute(repmat(th',[1 1 this.number_of_fractions]) .* ...
                    repmat(reshape(this.initial_mass_unit, [this.number_of_gridcells, 1, this.number_of_fractions]), [1 this.get_number_of_actual_layers 1]), [3 2 1]);
                this.bedcomposition_module.init_layer_mass(mass);

                % source
                if isempty(this.source)
                    nx = this.number_of_gridcells;
                    nf = this.number_of_fractions;
                    this.source = zeros(nx,nf);
                elseif isvector(this.source) && this.number_of_fractions > 1
                    this.source = this.source(:) * this.distribution(:)';
                end
            end
        end
        
        function dz = deposit(this, mass)
            if this.isinitialized
                dz = this.bedcomposition_module.deposit(mass', this.dt, this.grain_density, zeros(size(mass')), this.morfac);
            else
                error('bedcomposition module is not initialized');
            end
        end
        
        function p = compute_percentile(this, perc)
            if nargin < 2
                perc = .5;
            elseif perc > 1
                perc = perc / 100;
            end
            
            nx = this.number_of_gridcells;
            nf = this.number_of_fractions;
            nl = this.get_number_of_actual_layers;
                
            if this.isinitialized

                % repeat grain sizes
                gs = repmat(this.grain_size(:)', nx*nl, 1);

                % normalize mass fractions
                m  = reshape(this.get_layer_mass, nx*nl, nf);
                m  = cumsum(m,2)./repmat(sum(m,2),1,nf);

                idx = false(size(m));
                for i = 2:nf
                    idx(squeeze(m(:,i)) > perc & ~any(idx,2), i-1:i) = true;
                end

                n  = sum(idx(:))/2;
                m  = reshape(m(idx),n,2);
                f  = (perc - m(:,1)) ./ diff(m,1,2);
                gs = reshape(log(gs(idx)),n,2);

                p             = nan(nx*nl,1);
                p(any(idx,2)) = exp(gs(:,1) + f .* diff(gs,1,2));
                p             = reshape(p,nx,nl);
            else
                p             = zeros(nx,nl);
            end
        end
        
        function data = output(this)
            data = output@slamfat_bedcomposition_basic(this);
            data.d50       = this.get_d50;
            data.thickness = this.get_layer_thickness;
        end
        
        function mass = get_top_layer_mass(this)
            if this.isinitialized
                mass = permute(this.bedcomposition_module.layer_mass(:,1,:),[3 2 1]); % frac, lyr, x -> x, lyr, frac
                mass = reshape(mass, [size(mass,1) size(mass,3)]);
            else
                error('bedcomposition module is not initialized');
            end
        end
        
        function val = get_number_of_actual_layers(this)
            val = this.number_of_layers + 2;
        end
        
        function val = get_d50(this)
            val = this.compute_percentile(.5);
        end
        
        function mass = get_layer_mass(this)
            if this.isinitialized
                mass = permute(this.bedcomposition_module.layer_mass,[3 2 1]); % frac, lyr, x -> x, lyr, frac
            else
                error('bedcomposition module is not initialized');
            end
        end
        
        function thickness = get_layer_thickness(this)
            if this.isinitialized
                thickness = this.bedcomposition_module.layer_thickness';
            else
                thickness = this.layer_thickness;
            end
        end
    end
end
