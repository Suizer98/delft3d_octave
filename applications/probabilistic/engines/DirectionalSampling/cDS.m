classdef cDS < handle
    %CDS  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also cDS.cDS
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2012 Deltares
    %       Bas Hoonhout
    %
    %       bas.hoonhout@deltares.nl
    %
    %       Rotterdamseweg 185
    %       2629HD Delft
    %       Netherlands
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
    % Created: 19 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id: cDS.m 8605 2013-05-10 10:35:08Z hoonhout $
    % $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
    % $Author: hoonhout $
    % $Revision: 8605 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/cDS.m $
    % $Keywords: $
    
    %% Properties
    properties(SetAccess=private)
        randomVariables             = struct();
        activeVariables             = [];
        randomNumbers               = [];
        randomNumberCount           = 0;
        
        u                           = [];
        un                          = [];
        ul                          = [];
        bi                          = [];
        zi                          = [];
        
        ARS                         = struct();
    end
    
    properties(SetAccess=private, GetAccess=private)
        reevaluate                  = [];
    end
    
    properties(Dependent)
        
        % numerics
        nrVariables                 = 0;
        nrSamples                   = 0;
        
        minCOV                      = 0;
        COV                         = Inf;
        Accuracy                    = 0;
        Pratio                      = 0;
        
        % probabilities
        beta                        = [];
        z                           = [];
        
        dPe                         = 0;
        dPa                         = 0;
        dPo                         = 0;
        dP                          = 0;
        
        Pe                          = 0;
        Pa                          = 0;
        Pf                          = 0;
        
        % status
        converged                   = [];
        exact                       = [];
        notExact                    = [];
        exactButNotConverged        = [];
        
        % result
        result                      = struct();
        
    end
    
    properties
        
        % numerics
        randomSeed                  = NaN;
        
        confidence                  = .95;
        minAccuracy                 = .2;
        minPratio                   = .4;
        
        epsZ                        = 1e-2;
        beta1                       = 4;
        dbeta                       = .1;
        minBetaDist                 = 1;
        minSamples                  = 0;
        maxSamples                  = 1e3;
        
        method                      = 'matrix';
        
        % helper functions
        x2zFunction                 = {@x2z};
        x2zVariables                = {};
        x2zAggregateFunction        = {};
        x2zAggregateVariables       = {};
        
        P2xFunction                 = @P2x;
        P2xVariables                = {};
        
        z20Function                 = @find_zero_poly4;
        z20Variables                = {};
        
        initFunction                = {};
        initVariables               = {};
        
        % adaptive response surface
        enableARS                   = true;
        
        ARSgetFunction              = @prob_ars_get_mult;
        ARSgetVariables             = {};
        
        ARSsetFunction              = @prob_ars_set_mult;
        ARSsetVariables             = {};
        
        enableDesignPointDetection  = false;
        
        % visualization
        animate                     = false;
        
    end
    
    %% Methods
    methods
        
        % constructor
        function this = cDS( randomVariables, varargin )
            this.randomVariables = randomVariables;
        end
        
        % simulation
        function obj = simulate( obj )
            
            %init(obj);
            
            obj.u = [obj.u obj.randomVariables];
            
%             while obj.Pratio > obj.minPratio || ~isempty(obj.reevaluate)
%                 while obj.COV > obj.minCOV || ~isempty(obj.reevaluate)
%                     
%                     get_sample(obj);
%                     
%                     get_first_estimate(obj);
%                     
%                     % approximate line search
%                     line_search(obj);
%                     
%                     % exact line search
%                     if in_beta_sphere(obj)
%                         line_search(obj);
%                         update_response_surface(obj);
%                     end
%                     
%                 end
%                 
%                 update_beta_sphere(obj);
%                 
%             end
        end
        
        % plot
        function plot( obj )
            load clown;
            image(X);
            colormap(map);
        end
    end
        
%% private methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = private)
        
        function obj = init( obj )
            
            % determine active variables
            obj.activeVariables  = ~cellfun(@isempty, {obj.randomVariables.Distr}) & ...
                                   ~strcmp('deterministic', cellfun(@func2str, {obj.randomVariables.Distr}, 'UniformOutput', false));

            % draw random numbers
            if isnan(obj.randomSeed)
                obj.randomSeed = sum(10*clock);
            end
            
            rng('default');
            rng(obj.randomSeed);
            
            obj.randomNumbers       = rand(obj.maxSamples, obj.nrVariables);
            obj.randomNumberCount   = 1;
            
            % compute origin
            b0          = 0;
            z0_tot      = beta2z(zeros(1, obj.nrVariables), b0);

            z0          = feval(@prob_aggregate_z, z0_tot, ...
                                'aggregateFunction', OPT.x2zAggregateFunction);

            if z0<0
                error('Origin is part of failure area. This situation is currently not supported.');
            end

            % initialize response surface (and beta sphere)
            obj.ARS     = prob_ars_struct_mult(                             ...
                            'active',            obj.activeVariables,       ...
                            'b',                 0,                         ...
                            'u',                 zeros(1,obj.nrVariables),  ...
                            'z',                 z0_tot,                    ...
                            'aggregateFunction', obj.x2zAggregateFunction,  ...
                            'dbeta',             obj.dbeta                      );
        end
        
        function get_sample( obj )
        end
        
        function get_first_estimate( obj )
        end
        
        function get_output( obj )
        end
        
        function line_search( obj )
        end
        
        function update_response_surface( obj )
        end
        
        function update_beta_sphere( obj )
        end
        
        function in_beta_sphere(obj)
        end
    end
    
%% getters and setters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods
        
        function nrSamples = get.nrSamples( obj )
            nrSamples   = length(obj.beta);
        end
        
        function nrVariables = get.nrVariables( obj )
            nrVariables = sum(obj.activeVariables);
        end
        
        function Accuracy = get.Accuracy( obj )
            Accuracy    = norm_inv((obj.confidence+1)/2,0,1) * obj.COV;
        end
        
        function COV = get.COV( obj )
            COV         = sqrt((1 - obj.Pf)/(obj.nrSamples * obj.Pf));
        end
        
        function COV = get.minCOV( obj )
            COV         = obj.minAccuracy / norm_inv((obj.confidence+1)/2,0,1);
        end
        
        function Pratio = get.Pratio( obj )
            Pratio      = obj.Pa / obj.Pf;
        end
        
        function obj = set.beta( obj, beta )
            obj.beta    = beta;
            
            idxe        = obj.exact&obj.beta>0;
            idxa        = obj.notExact&obj.beta>0;
            idxo        = obj.beta<=0;
            
            obj.dPe     = calc_probability_contribution( obj, obj.beta(idxe) );
            obj.dPa     = calc_probability_contribution( obj, obj.beta(idxa) );
            obj.dPo     = zeros(size(obj.beta(idxo)));
            
            obj.dP      = [obj.dPe obj.dPa obj.dPo];
            
            obj.Pe      = sum(obj.dPe);
            obj.Pa      = sum(obj.dPa);
            obj.Pf      = obj.Pe + obj.Pa;
        end
        
        function result = get.result( obj )
            result = struct(...
                'settings',     struct(),             ...
                'Input',        obj.randomVariables,  ...
                'Output',       struct()                    );
        end
    end
    
%% helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = private)
        
        function dP = calc_probability_contribution( obj, beta )
            M           = sum(obj.activeVariables);
            N           = obj.nrSamples;
            
            dP          = (1 - chi2_cdf(beta.^2, M)) / N;
            dP(beta<=0) = 0;
        end
        
        % transform unit vector and beta value in standard normal space into z-value
        function [z x u P] = beta2z( obj, un, beta )
            [x u P] = beta2x(obj, un, beta);

            nf      = ~any(~isfinite(x),2);

            if ~iscell(obj.x2zFunction)
                obj.x2zFunction = {obj.x2zFunction};
            end

            if length(obj.x2zFunction) > 1
                aggregate = false;
            else
                aggregate = true;
            end

            if any(nf); 
                z(nf,:) = prob_zfunctioncall(obj, obj.randomVariables, x(nf,:), 'aggregate', aggregate); 
            end;
            z(~nf)  = -Inf;
        end

        % transform unit vector and beta value in standard normal space into real-world vector
        function [x u P] = beta2x( obj, un, beta)
            u       = beta2u(un, beta);
            [x P]   = u2x(obj, u);
        end

        % transform vector in standard normal space into real-world vector
        function [x P] = u2x( obj, u )
            P       = norm_cdf(u,0,1);
            x       = feval(obj.P2xFunction, obj.randomVariables, P, obj.P2xVariables{:});
        end

        % transform unit vector and beta value in vector in standard normal space
        function u = beta2u( obj, un, beta )
            u = zeros(length(beta), size(un,2));
            for i = 1:length(beta)
                u(i) = beta(i).*un;
            end
        end
        
    end
end
