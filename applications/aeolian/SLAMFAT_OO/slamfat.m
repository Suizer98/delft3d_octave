classdef slamfat < handle
    %SLAMFAT  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat.slamfat
    
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
    
    % $Id: slamfat.m 9936 2014-01-06 09:05:45Z hoonhout $
    % $Date: 2014-01-06 17:05:45 +0800 (Mon, 06 Jan 2014) $
    % $Author: hoonhout $
    % $Revision: 9936 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        dx                      = 1
        relaxation              = 0.5
        g                       = 9.81
        relative_velocity       = 1
        output_timesteps        = 100
        output_file             = ''
        
        max_source              = 'none'
        max_threshold           = []
        
        profile                 = zeros(1,100)
        wind                    = []
        bedcomposition          = []
        
        animate                 = false;
        progress                = true;
    end
    
    properties(GetAccess = public, SetAccess = protected)
        number_of_gridcells     = 100
        
        transport               = 0
        capacity                = 0
        supply                  = 0
        supply_limited          = false
        
        data                    = struct()
        timestep                = 0
        output_timestep         = 0
        output_time             = 0
        size_of_output          = 0
        
        initial_profile         = []
        
        progressbar             = []
        figure                  = []
        
        isinitialized           = false
    end
    
    properties(GetAccess = protected, SetAccess = protected)
        it                      = 1
        io                      = 1
        transport_transportltd  = []
        transport_supplyltd     = []
        total_transport         = []
        performance             = struct()
        start                   = 0
    end
    
    %% Methods
    methods
        function this = slamfat(varargin)
            setproperty(this, varargin);
            
            if isempty(this.wind)
                this.wind = slamfat_wind;
            end
            
            if isempty(this.bedcomposition) || ~ishandle(this.bedcomposition)
                this.bedcomposition = slamfat_bedcomposition_basic;
            end
            
            if isempty(this.figure)
                this.figure = slamfat_plot;
            end
            
            if isempty(this.max_threshold)
                this.max_threshold = slamfat_threshold_basic;
            end
        end
        
        function initialize(this)
            if ~this.isinitialized
                
                if isscalar(this.output_timesteps)
                    this.output_timesteps = 1:this.output_timesteps:sum(this.wind.number_of_timesteps);
                else
                    this.output_timesteps = this.output_timesteps;
                end
                
                this.output_time         = this.output_timesteps * this.wind.dt;
                this.size_of_output      = length(this.output_timesteps);
                this.number_of_gridcells = length(this.profile);
                
                this.bedcomposition.number_of_gridcells = this.number_of_gridcells;
                this.bedcomposition.dt                  = this.wind.dt;
                this.bedcomposition.initialize;
                
                this.transport              = this.empty_matrix;
                this.transport_transportltd = this.empty_matrix;
                this.transport_supplyltd    = this.empty_matrix;
                this.supply                 = this.empty_matrix;
                this.capacity               = this.empty_matrix;
                this.total_transport        = this.empty_matrix;
                
                n  = this.size_of_output;
                nx = this.number_of_gridcells;
                nf = this.bedcomposition.number_of_fractions;
                nl = this.bedcomposition.get_number_of_actual_layers;
                
                this.data = struct();
                
                if ~isempty(this.output_file)
                    if exist(this.output_file, 'file')
                        switch questdlg('Overwrite existing netCDF file?', 'File exists', 'Yes', 'No', 'Yes')
                            case 'Yes'
                                delete(this.output_file);
                            case 'No'
                                return
                        end
                    end
                end
                
                this.add_dimension('time',      this.output_time);
                this.add_dimension('x',         0:this.dx:nx-1);
                this.add_dimension('fractions', this.bedcomposition.grain_size);
                
                this.add_variable('profile',                {'time' n 'x' nx});
                this.add_variable('wind',                   {'time' n});
                this.add_variable('transport',              {'time' n 'x' nx 'fractions' nf});
                this.add_variable('cummulative_transport',  {'time' n 'x' nx 'fractions' nf});
                this.add_variable('supply',                 {'time' n 'x' nx 'fractions' nf});
                this.add_variable('capacity',               {'time' n 'x' nx 'fractions' nf});
                this.add_variable('supply_limited',         {'time' n 'x' nx 'fractions' nf});
                
                % rainfall output
                this.add_variable('threshold',              {'time' n 'x' nx 'fractions' nf});
                this.add_variable('moisture',               {'time' n 'x' nx});
                this.add_variable('cummulative_evaporation',{'time' n 'x' nx});
                this.add_variable('cummulative_rainfall',   {'time' n 'x' nx});
                
                % bedcomposition output
                this.add_variable('d50',                    {'time' n 'x' nx 'layers' nl});
                this.add_variable('thickness',              {'time' n 'x' nx 'layers' nl});
                
                this.add_meta();
                
                this.performance = struct(  ...
                    'initialization',   0,  ...
                    'transport',        0,  ...
                    'bedcomposition',   0,  ...
                    'grainsize',        0,  ...
                    'visualization',    0,  ...
                    'write_output',     0);
                
                this.initial_profile = this.profile;
                this.max_threshold.initialize(this.dx, this.profile);
                
                this.isinitialized = true;
            end
            
            if this.animate
                this.plot;
            elseif this.progress
                if isempty(this.progressbar)
                    this.progressbar = waitbar(0,'SLAMFAT model running...');
                end
            end
        end
        
        function run(this)
            tic;
            
            this.initialize;
            this.output;
            
            this.performance.initialization = toc;
            
            this.start = now;
            this.it = this.it + 1;
            while this.it < sum(this.wind.number_of_timesteps)
                this.next;
                
                tt = tic;
                this.output;
                this.performance.write_output = this.performance.write_output + toc(tt);
            end
            
            this.finalize;
        end
        
        function next(this)
            
            if this.isinitialized
                
                tic;
                
                threshold = this.get_maximum_threshold;
                
                % transport capacity according to Bagnold
                this.capacity = max(0, 1.5e-4 * ((this.wind.time_series(this.it-1) - threshold).^3) ./ ...
                    (this.wind.time_series(this.it-1) * this.relative_velocity));
                
                % transport limited concentration
                this.transport_transportltd(2:end,:) = ((-this.relative_velocity * this.wind.time_series(this.it-1) .* ...
                    (this.transport(2:end,:) - this.transport(1:end-1,:)) / this.dx) * this.wind.dt + ...
                    this.transport(2:end,:) + this.capacity(2:end,:) / (this.relaxation / this.wind.dt)) / (1 + 1/(this.relaxation/this.wind.dt));
                
                % supply limited concentration
                this.transport_supplyltd(2:end,:)    = (-this.relative_velocity * this.wind.time_series(this.it-1) .* ...
                    (this.transport(2:end,:) - this.transport(1:end-1,:)) / this.dx) * this.wind.dt + ...
                    this.transport(2:end,:) + this.supply   (2:end  ,:)  / (this.relaxation/this.wind.dt);
                
                idx = (this.capacity - this.transport_transportltd) / (this.relaxation/this.wind.dt) > this.supply;
                
                this.transport(~idx) = this.transport_transportltd(~idx);
                this.transport( idx) = this.transport_supplyltd   ( idx);
                
                this.total_transport = this.total_transport + this.transport*(this.wind.time_series(this.it) * this.relative_velocity) * this.wind.dt;
                
                this.performance.transport = this.performance.transport + toc; tic;
                
                source = this.get_maximum_source;
                
                % compute added mass
                mass       = zeros(this.number_of_gridcells,this.bedcomposition.number_of_fractions);
                mass( idx) = source( idx) / this.dx - this.supply(idx) / (this.relaxation/this.wind.dt);
                mass(~idx) = source(~idx) / this.dx - (this.capacity(~idx) - this.transport(~idx)) / (this.relaxation / this.wind.dt);
                
                dz = this.bedcomposition.deposit(mass);
                
                this.profile        = this.profile + dz;
                this.supply         = this.bedcomposition.get_top_layer_mass;
                this.supply_limited = idx;
                
                this.performance.bedcomposition = this.performance.bedcomposition + toc;
                
                this.it = this.it + 1;
            else
                error('SLAMFAT model is not initialized');
            end
        end
        
        function finalize(this)
            if this.progress
                if ishandle(this.progressbar)
                    close(this.progressbar);
                end
            end
            
            if this.animate && ~isempty(this.figure)
                this.figure.reinitialize;
            end
        end
        
        function threshold = get_maximum_threshold(this)
            threshold = repmat(this.bedcomposition.threshold_velocity, this.number_of_gridcells, 1);
            threshold = this.max_threshold.maximize_threshold(threshold, this.wind.dt, this.profile, this.wind.time_series(this.it-1));
            threshold = max(0, threshold);
        end
        
        function source = get_maximum_source(this)
            source = this.bedcomposition.source;
            switch this.max_source
                case 'initial_profile'
                    nf = this.bedcomposition.number_of_fractions;
                    source = min(source, max(0,repmat((this.initial_profile - this.profile)',1,nf) .* this.bedcomposition.initial_mass_unit));
            end
        end
        
        function output(this)
            if ismember(this.it, this.output_timesteps)
                
                this.output_timestep = find(this.output_timesteps <= this.it,1,'last');
                
                % update output matrices
                this.write_variable('profile',                  this.profile);
                this.write_variable('wind',                     this.wind.time_series(this.it));
                this.write_variable('transport',                this.transport);
                this.write_variable('cummulative_transport',    this.total_transport);
                this.write_variable('supply',                   this.supply);
                this.write_variable('capacity',                 this.capacity);
                this.write_variable('supply_limited',           this.supply_limited);
                
                this.write_variables(this.max_threshold.output);
                
                tic;
                
                this.write_variables(this.bedcomposition.output);
                
                this.performance.grainsize = this.performance.grainsize + toc; tic;
                
                ETA = (now - this.start) * (this.size_of_output - this.io) / this.io;
                
                if this.animate
                    this.figure.timestep = this.io;
                    this.figure.update;
                elseif this.progress
                    waitbar(this.io/this.size_of_output, this.progressbar, ...
                        sprintf('[%s / %s]', datestr(now - this.start, 'HH:MM:SS'), datestr(ETA, 'HH:MM:SS')));
                elseif mod(this.io, 100) == 0
                    fprintf('%3.1f%% [%s / %s]\n', this.io/this.size_of_output*100, ...
                        datestr(now - this.start, 'HH:MM:SS'), datestr(ETA, 'HH:MM:SS'));
                end
                
                this.performance.visualization = this.performance.visualization + toc;
                
                this.io = this.io + 1;
            end
        end
        
        function add_dimension(this, dim, value)
            if isempty(this.output_file)
                this.data.(dim) = value;
            else
                nccreate(this.output_file, dim, 'Dimensions', {dim length(value)});
                ncwrite(this.output_file, dim, value);
            end
        end
        
        function add_variable(this, var, dims)
            if isempty(this.output_file)
                this.data.(var) = zeros([dims{2:2:end} 1]);
            else
                nccreate(this.output_file, var, 'Dimensions', dims);
            end
        end
        
        function add_meta(this)
            info = getlocalsettings;
            
            url     = regexprep('$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat.m $', '\s*[^\s]*\$[^\s]*\s*', '');
            comment = regexprep('SLAMFAT revision $Revision: 9936 $ $Author: hoonhout $ $Date: 2014-01-06 17:05:45 +0800 (Mon, 06 Jan 2014) $', '[^\s]*\$[^\s]*\s*', '');
            
            if isempty(this.output_file)
                this.data.info_ = struct( ...
                    'title','SLAMFAT model output', ...
                    'creator_name',info.NAME, ...
                    'creator_email',info.EMAIL, ...
                    'date_created',datestr(now), ...
                    'references',url, ...
                    'comment',comment);
            else
                ncwriteatt(this.output_file,'/','title','SLAMFAT model output');
                ncwriteatt(this.output_file,'/','creator_name',info.NAME);
                ncwriteatt(this.output_file,'/','creator_email',info.EMAIL);
                ncwriteatt(this.output_file,'/','date_created',datestr(now));
                ncwriteatt(this.output_file,'/','references',url);
                ncwriteatt(this.output_file,'/','comment',comment);
            end
        end
        
        function write_variable(this, var, value)
            if isempty(this.output_file)
                idx = [{this.io} num2cell(repmat(':',1,ndims(this.data.(var))-1))];
                this.data.(var)(idx{:}) = value;
            else
                info  = ncinfo(this.output_file, var);
                sz    = info.Size;
                sz(1) = 1;
                if isscalar(value)
                    value = zeros(sz) + value;
                else
                    value = reshape(value, sz);
                end
                idx = [this.io ones(1,numel(sz)-1)];
                
                % Hier heeft Sierd er Quick & Dirty voor gezorgd dat de
                % netcdf in het juiste format wordt opgeschreven als er
                % slechts met 1 fractie wordt gerekend. Dit kan mogelijk
                % beter maar het werkt wel.
                if size(idx,2) == size(sz,2)
                    ncwrite(this.output_file, var, double(value), idx);
                else
                    ncwrite(this.output_file, var, double(value'), [idx 1]);
                end
                % Einde van Sierd zijn gepruts.
            end
        end
        
        function write_variables(this, vars)
            if isstruct(vars)
                vars = reshape([fieldnames(vars) struct2cell(vars)]',1,[]);
            end
            for i = 1:2:length(vars)
                this.write_variable(vars{i}, vars{i+1});
            end
        end
        
        function val = get.data(this)
            if isempty(this.output_file)
                val = this.data;
            else
                info = ncinfo(this.output_file);
                vars = {info.Variables.Name};
                val  = cell2struct(cellfun(@(x) ncread(this.output_file,x), vars, 'UniformOutput', false), vars, 2);
            end
        end
        
        function val = get.timestep(this)
            val = this.it;
        end
        
        function mtx = empty_matrix(this)
            nx = this.number_of_gridcells;
            nf = this.bedcomposition.number_of_fractions;
            mtx = zeros(nx,nf);
        end
        
        function fig = plot(this)
            if ~isempty(this.figure)
                if isempty(this.figure.obj)
                    this.figure.obj = this;
                end
                this.figure.timestep = this.output_timestep;
                this.figure.update;
            end
            
            fig = this.figure;
        end
        
        function delete(this)
            % clean up
            this.wind           = [];
            this.bedcomposition = [];
            this.max_threshold  = [];
            this.figure         = [];
        end
        
        function show_performance(this)
            tm  = cell2mat(struct2cell(this.performance));
            tmp = tm(2:end)./sum(tm(2:end))*100;
            
            fprintf('%20s : %10.4f s\n', 'initialization', this.performance.initialization);
            fprintf('%20s : %10.4f s [%5.1f%%]\n', ...
                'transport',        this.performance.transport,         tmp(1), ...
                'bed composition',  this.performance.bedcomposition,    tmp(2), ...
                'grain size',       this.performance.grainsize,         tmp(3), ...
                'visualization',    this.performance.visualization,     tmp(4), ...
                'write output',     this.performance.write_output,      tmp(5), ...
                'total', sum(tm), this.it/sum(this.wind.number_of_timesteps)*100);
        end
    end
end
