function result = DS(varargin)
%DS runs a probabilistic computation by Directional Sampling
%
%   Runs a probabilistic computation by Directional Sampling. The
%   implementation is largely obtained from Grooteman (2011) and is called
%   Adaptive Directional Importance Sampling (ADIS). Besides the
%   conventional directional sampling, importance sampling is automatically
%   applied using a beta sphere with a radius of the minimum beta drawn so
%   far plus a certain threshold. Any samples drawn within this sphere are
%   marked as important and computed exactly. Any samples outside this
%   sphere are of less importance and computed using an Adaptive Response
%   Surface (ARS), if available.
% 
%   Also convergence is automatically determined using a confidence
%   interval and required accuarcy. Finally, it is checked whether the
%   resulting probability of failure is mainly obtained from the exact
%   computed samples. Otherwise, the most important approximated samples
%   are recalculated using the exact method until this requirement is
%   satisfied.
%
%   Grooteman, F. (2011). An adaptive directional importance sampling
%   method for structural reliability, Probabilistic Engineering Mechanics
%   26, p134-141.
%
%   Syntax:
%   result = DS(varargin)
%
%   Input:
%   varargin  = name/value pairs:
%               stochast:       Stochast structure
%               seed:           Seed for random generator
%               x2zFunction:    Function handle to transform x to z
%               x2zVariables:   Additional variables for the x2zFunction
%               P2xFunction:    Function handle to transform P to x
%               P2xVariables:   Additional variables for the P2xFunction
%               z20Function:    Function handle to find z=0 along a line
%               z20Variables:   Additional variables for the z20Function
%               ARS:            Boolean indicating whether to use ARS
%               ARSgetFunction  Function handle to evaluate the z-value for
%                               a combination of unit vector u and distance
%                               beta based on an ARS structure
%               ARSgetVariables Additional variables to the ARSgetFunction
%               ARSsetFunction  Function handle to update ARS structure
%                               based on a set of vectors u and
%                               corresponding z-values
%               ARSsetVariables Additional variables to the ARSsetFunction
%               beta1           Initial beta value in line search
%               dbeta           Initial beta threshold for beta sphere
%               Pratio          Maximum fraction of failure probability
%                               determined by approximated samples
%               minsamples      Minimum number of samples needed before
%                               convergence is being checked
%               confidence      Confidence interval in convergence
%                               criterium
%               accuracy        Accuracy in convergence criterium
%               plot            Boolean indicating whether to plot result
%               animate         Boolean indicating whether to animate
%                               progress
%
%               Future options:
%               method          Evaluation method of z-values (matrix or
%                               loop) used to determine is all samples in a
%                               single loop are evaluated at once in a
%                               matrix or sequential in a loop
%               NrSamples       Determines the number of samples that is
%                               evaluated in a single loop
%
%   Output:
%   result = DS result structure
%
%   Example
%   result = DS('stochast', exampleStochastVar, 'x2zFunction', x2z)
%
%   See also MC, FORM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 12 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: DS.m 16445 2020-06-22 12:38:44Z bieman $
% $Date: 2020-06-22 20:38:44 +0800 (Mon, 22 Jun 2020) $
% $Author: bieman $
% $Revision: 16445 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/DS.m $
% $Keywords: $

%% definitions

%   evaluation:         computation of a single z-value corresponding to a
%                       single combination of unit vector and beta value
%   sample:             single randomly drawn direction with, in case of
%                       conversions, corresponding beta value on the limit
%                       state
%   approximated:       result obtained from ARS
%   exact:              result obtained from model

%% conventions

%   P*                  probability
%   b*                  beta values
%   z*                  z-values
%   u*                  vectors in standard normal space
%   x*                  vectors in real-world space
%   d*                  partial contribution
%   c*                  convergence flag
%   n*                  counter
%   i*                  index

%   *e                  exact values
%   *a                  approximated values
%   *n                  unit vectors
%   *l                  vector magintudes

%% principle

%   compute origin
%
%   LOOP until mimimum ratio Pe/Pa is reached
%       LOOP until minimum accuracy is reached
%
%           draw new sample or select old sample selected for reevaluation
%
%           compute first estimate
%           approximate line seach
%           exact line search
%
%           update ARS
%
%       END LOOP
%
%       update beta sphere
%
%   END LOOP

%% read settings

varargin = prob_checkinput(varargin{:});

OPT = struct(...
    'stochast',         struct(),           ...                             % Stochast structure
    'seed',             NaN,                ...                             % Seed for random generator
    'x2zFunction',      {@x2z},             ...                             % Function handle to transform x to z
    'x2zVariables',     {{}},               ...                             % Additional variables for the x2zFunction
    'aggregate',        true,               ...                             % Boolean indicating the need for aggregation
    'aggregateFunction',[],                 ...                             % Aggregation function for combining multiple failure functions
    'aggregateVariables',{{}},              ...                             % Additional variables for the aggregation function
    'P2xFunction',      @P2x,               ...                             % Function handle to transform P to x
    'P2xVariables',     {{}},               ...                             % Additional variables for the P2xFunction
    'z20Function',      @find_zero_poly4,   ...                             % Function handle to find z=0 along a line
    'z20Variables',     {{}},               ...                             % Additional variables for the z20Function
    'ARS',              true,               ...                             % Boolean indicating whether to use ARS or not
    'ARSgetFunction',   @prob_ars_get_mult, ...                             % Function handle to evaluate the z-value for a combination 
                                            ...                                 of unit vector u and distance beta based on an ARS structure
    'ARSgetVariables',  {{}},               ...                             % Additional variables to the ARSgetFunction
    'ARSsetFunction',   @prob_ars_set_mult, ...                             % Function handle to update ARS structure based on a set
                                            ...                                 of vectors u and corresponding z-values
    'ARSsetVariables',  {{}},               ...                             % Additional variables to the ARSsetFunction
    'DesignPointDetection', false,          ...                             % Boolean switch for using automated detection of DPs (and using multiple ARS's)
    'epsZ',             1e-2,               ...
    'beta1',            4,                  ...                             % Initial beta value in line search
    'dbeta',            .1,                 ...                             % Initial beta threshold for beta sphere
    'dist_betamin',     1,                  ...
    'Pratio',           .4,                 ...                             % Maximum fraction of failure probability determined by approximated samples
    'minsamples',       0,                  ...                             % Minimum number of samples needed before convergence is being checked
    'maxsamples',       1000,               ...                               % Maximum number of samples being renerated
    'confidence',       .95,                ...                             % Confidence interval in convergence criterium
    'accuracy',         .2,                 ...                             % Accuracy in convergence criterium
    'plot',             false,              ...                             % Boolean indicating whether to plot result
    'animate',          false,              ...                             % Boolean indicating whether to animate progress
                                            ...
    'method',           'matrix',           ...                             % Future option: Evaluation method of z-values (matrix or loop) used 
                                            ...                                 to determine is all samples in a single loop are evaluated at once 
                                            ...                                 in a matrix or sequential in a loop
    'NrSamples',        1                   ...                             % Future option: Determines the number of samples that is evaluated in a single loop
);

OPT = setproperty(OPT, varargin{:});

% multiple samples are not yet supported
OPT.NrSamples = 1;

%% directional sampling

% initiate stochast structure
stochast    = OPT.stochast;
N           = length(stochast);                                             % number of stochasts

% determine minimum coefficient of variation for convergence
minCOV      = OPT.accuracy/norm_inv((OPT.confidence+1)/2,0,1);              % minimum value for coefficient of variation

% determine active stochasts
active      = ~cellfun(@isempty, {stochast.Distr}) &     ...
              ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr}, 'UniformOutput', false));

% set random seed
if isnan(OPT.seed)
    OPT.seed = sum(10*clock);
end
rng('default');
rng(OPT.seed);
randmatrix = rand(OPT.maxsamples, sum(active));                             % predetermined samples (with a fixed seed)
nrandmatrix = 1;                                                            % counter for number of times the randmatrix is used

% compute origin
b0          = 0;                                                            % beta value of origin
z0_tot      = beta2z(OPT, zeros(1,N), b0);                                  % z-value of origin

z0  = feval(@prob_aggregate_z, z0_tot, ...
    'aggregateFunction', OPT.aggregateFunction);

if z0<0
    error('Origin is part of failure area. This situation is currently not supported.');
end

% iniate counters
n           = length(OPT.x2zFunction);                                      % exact evaluation counter (counts every evaluation of an individual limit state)
nARS        = nan;                                                          % number of evaluations needed for initial ARS

% initiate computational vectors
b           = [];                                                           % evaluated beta values in a single line search
z           = [];                                                           % evaluated z-values in a single line search

% intialize matrices
un          = nan(0,N);                                                     % unit vectors for all samples (directions)
beta        = nan(0,1);                                                     % final beta values for all samples
zval        = nan(0,1);                                                     % final z-values for all samples
exact2      = false(0,1);
exact       = false(0,1);                                                   % boolean indicating for all samples if the result is converged and exact
notexact    = false(0,1);                                                   % boolean indicating for all samples if the result is converged and not exact
converged   = false(0,1);                                                   % boolean indicating for all samples if the result is converged
reevaluate  = [];                                                           % indices of samples that need to be reevaluated

% initialize response surface (and beta sphere) 

ARS         = prob_ars_struct_mult(     ...
                'active', active,       ...                                 % active stochasts                
                'b', 0,                 ...                                 % vector lengths (beta)
                'u', zeros(1,N),        ...                                 % vectors corresponding to exact samples (un*beta)
                'z', z0_tot,            ...                                 % z-values corresponding to vectors
                'aggregateFunction',    OPT.aggregateFunction, ...
                'dbeta', OPT.dbeta);                                        % beta threshold used to select relevant vectors
            
% initialize stop criterias
Pr          = Inf;                                                          % fraction of failure probability determined by approximated samples 
enoughsamples = true;                                                       % boolean indicating whether the maximum number of samples is enough (OPT.maxsamples)
finalise    = false;                                                        % boolean indicating the final iteration in which all not exact samples 
                                                                            %   left within the beta sphere are reevaluated, if any

COV         = Inf;                                                          % coefficient of variation

% start iterations
while Pr > OPT.Pratio || ~isempty(reevaluate)                               % WHILE: iterate while fraction of failure probability determined by approximated samples 
                                                                            %   is too large or there are samples left to be reevaluated due to an increase 
                                                                            %   of the beta sphere or finalisation of the process
    
    while COV > minCOV || ~isempty(reevaluate)                              % WHILE: iterate while coefficient of variation has not reached it's required minimum or
                                                                            %   there are samples left to be reevaluated due to an increase of the beta sphere 
                                                                            %   or finalisation of the process
        
        % if no samples within beta sphere are left to reevaluate, draw new
        % directions
        if isempty(reevaluate)                                              % IF: check if no samples are left for reevaluation
            
            % determine sample index
            idx             = size(un,1)+[1:OPT.NrSamples];
            exact(idx)      = false;
            converged(idx)  = false;

            P               = nan(OPT.NrSamples, N);
            P(:, active)    = randmatrix(nrandmatrix,:);                    % sampled probability
            P(:,~active)	= .5;                                           % probability of inactive stochasts (expected value)
            
            % transform P to u
            u               = norm_inv(P,0,1);                              % realisations in standard normal space

            % normalize u
            ul              = sqrt(sum(u.^2,2));                            % vector length in standard normal space
            un(idx,:)       = u./repmat(ul,1,N);                            % unit vector in standard normal space (direction)
            
            if nrandmatrix == OPT.maxsamples
                warning('Maximum number of random directions reached!')
                enoughsamples = false;
            else
                nrandmatrix = nrandmatrix + 1;                              % increase counter randmatrix use
            end
            
        else
            % reevaluate first sample in line
            idx             = reevaluate(1);
        end
        
        % determine first estimate
        if OPT.ARS && any([ARS.hasfit]) && any(converged)                     % IF: check if ARS should be used, is available and converged samples are available
            
            ba          = OPT.beta1;                                        % initialize beta vector for approximated results with initial beta value
            za_tot      = feval(                ...                         % initialize z vector for approximated results using evaluation of 
                OPT.ARSgetFunction,             ...                             z-value with initial beta and ARS
                un(idx,active).*OPT.beta1,      ...
                'ARS',ARS,OPT.ARSgetVariables{:}    );
            za          = feval(@prob_aggregate_z, za_tot, ...
                'aggregateFunction', OPT.aggregateFunction);

            be          = [];                                               % initialize beta vector for exact results
            ze          = [];                                               % initialize z vector for exact results
            ze_tot      = [];
        else
            n           = n + length(OPT.x2zFunction);                      % increase evaluation counter
            
            ba          = [];                                               % initialize beta vector for approximated results
            za          = [];                                               % initialize z vector for approximated results
            be          = OPT.beta1;                                        % initialize beta vector for exact results with initial beta value
            ze_tot      = beta2z(OPT, un(idx,:), OPT.beta1);                % initialize z vector for exact results using evaluation of z-value with initial beta
            ze          = feval(@prob_aggregate_z, ze_tot, ...
                'aggregateFunction', OPT.aggregateFunction);
        end
        
        b               = real([b0 ba be]);                                 % initialize beta vector for all results using origin and first estimate
        z               = real([z0 za ze]);                                 % initialize z vector for all results using origin and first estimate
        
        ca              = false;                                            % initialize convergence flag for approximated results
        ce              = false;                                            % initialize convergence flag for exact results

        % approximate line search
        if OPT.ARS && any([ARS.hasfit]) && any(converged)                   % IF: check if ARS should be used, is available and converged samples are available

            [bn zn zn_tot nn ca]    = feval(...                             % start approximated line search to find zero crossing along sampled direction given 
                @OPT.z20Function,           ...                                 the available beta and z values and the ARS and return the evaluated beta and
                un(idx,active),             ...                                 z values, the number of evaluations and a flag indicating convergence
                b, z,                       ...
                'aggregateFunction', OPT.aggregateFunction, ...             % use aggregationfunction
                'zFunction', @(x,y)feval(               ...                 % use ARS as z evaluation function
                    OPT.ARSgetFunction,                 ...
                    x.*y,                               ...
                    'ARS',ARS,                          ...
                    'DesignPointDetection', OPT.DesignPointDetection, ...
                    OPT.ARSgetVariables{:}  ),          ...
                OPT.z20Variables{:}                             );
 
            ba          = [ba bn];                                          % add evaluated beta values to corresponding vector with approximated results
            za          = [za zn];                                          % add evaluated z values to corresponding vector with approximated results
            
            b           = [b  bn];                                          % add evaluated beta values to corresponding vector with all results
            z           = [z  zn];                                          % add evaluated z values to corresponding vector with all results
        end
        
        % exact line search
        if Pr > OPT.Pratio || COV > minCOV || ~finalise

            no_ars_available    = ~OPT.ARS || ~any([ARS.hasfit]) || ~any(converged);
            is_in_beta_sphere   = (prob_ars_inbetasphere(ARS, b(end)) && ca);

            if OPT.DesignPointDetection
                if any(exact2)
                    distances   = triu(pointdistance_pairs(un(end,:)    * min([ARS.betamin]),   ...
                                                           un(exact2,:) * min([ARS.betamin])));
                else
                    distances   = [];
                end
                
                is_close_to_new_dp  = (~ca && isnan(z(end)) && isempty(zn) && isempty(bn));
                is_in_new_sector    = ~any(distances < sqrt(N)*OPT.dist_betamin & distances > 0);
            else
                is_close_to_new_dp  = false;
                is_in_new_sector    = false;
            end
            
            if no_ars_available || is_in_beta_sphere || ...
                    is_close_to_new_dp || is_in_new_sector ...              % IF: check if direction should be evaluated exactly

                ii          = 1;                                            % select origin and initial estimate as starting values for exact line search

                if OPT.ARS && any([ARS.hasfit])                             % also select approximated sample closest to zero, if available
                    ii      = unique([ii find(abs(z)==min(abs(z)),1,'first')]);
                    if length(ii) == 1
                        b       = [b OPT.beta1];
                        z1      = beta2z(OPT, un(idx,:), OPT.beta1);
                        z       = [z feval(@prob_aggregate_z, z1, ...
                                'aggregateFunction', OPT.aggregateFunction)];
                        be      = [be OPT.beta1];
                        ze      = [ze z(end)];
                        ze_tot  = [ze_tot; z1];
                        n       = n + length(OPT.x2zFunction);

                        ii      = [ii find(z==z(end),1,'last')];
                    end
                else
                    ii = [ii 2];
                end

                [bn, zn, ~, nn, ce]    = feval(...                         % start exact line search to find zero crossing along sampled direction given the
                    OPT.z20Function,            ...                          selected beta and z values and return the evaluated beta and z values, the number
                    un(idx,:),                  ...                          of evaluations and a flag indicating convergence
                    b(ii),                      ...
                    z(ii),                      ...
                    'zFunction', @(x,y)beta2z(OPT,x,y), OPT.z20Variables{:});   % use model as z evaluation function

                be          = [be bn];                                      % add evaluated beta values to corresponding vector with exact results
                ze          = [ze zn];                                      % add evaluated z values to corresponding vector with exact results

                b           = [b  bn];                                      % add evaluated beta values to corresponding vector with all results
                z           = [z  zn];                                      % add evaluated z values to corresponding vector with all results

                n           = n + nn*length(OPT.x2zFunction);               % increase evaluation counter

                exact(idx)  = true;                                         % register evaluation as exact (temporarily)
            end
        end

        % store exit status
        converged(idx)  = isfinite(z(end)) && ...                           % register sample as converged in case the z value is finite and the final result is converged
            ((~exact(idx) && ca) || ce);
        exact2(idx)     = exact(idx);
        notexact(idx)   = ~exact(idx) && converged(idx);                    % register sample as not exact in case the result is converged, but approximated
        exact(idx)      = exact(idx) && converged(idx);                     % register sample as exact in case the result is both converged and exact
        beta(idx)       = b(end);                                           % register final beta value for output
        zval(idx)       = z(end);                                           % register final z-value for output
        
        nb              = length(beta);                                     % total number of samples drawn so far
        
        % update response surface
        if OPT.ARS && ~isempty(ze)
            ue          = beta2u(un(idx,:),be(:));                          % determine sample vector in standard normal space (u*beta)  
            ARS        	= feval( ...                                        % compute ARS based on exact samples
                OPT.ARSsetFunction,     ...
                ue,                     ...
                ze_tot,                  ...
                'ARS',ARS,              ...
                'DesignPointDetection', OPT.DesignPointDetection, ...
                OPT.ARSsetVariables{:}      );
            
            if ce
                [ARS.betamin] = deal(min([ARS.betamin be(end)]));           % update beta sphere in case of convergence of exact result
            end
            
            if any([ARS.hasfit]) && isnan(nARS)                             % IF: check if initial ARS is computed
                nARS    = n;                                                % register number of evaluations needed for initial ARS
            end
        end
        
        ndir            = (n-nARS)/(sum(exact)-2*sum(ARS(1).active)+1);     % compute average number of exact evaluations needed per sample, which is
                                                                            %   the quotient of the number of exact evaluations made minus the number of 
                                                                            %   exact evaluations needed for the initial ARS and the number of exact and
                                                                            %   converged samples minus the mimimum number of samples needed for the inital
                                                                            %   ARS (2*N+1)
        
        % update probability of failure
        dPe     = (1-chi2_cdf(beta(   exact&beta>0).^2,sum(active)))/nb;    % contribution of each exact sample to the probability of failure
        dPa     = (1-chi2_cdf(beta(notexact&beta>0).^2,sum(active)))/nb;    % contribution of each approximated sample to the probability of failure
        dPo     = zeros(size(beta(beta<=0)));                               % contribution of each not converged sample to the probability of failure (=0)
        dP      = [dPe dPa dPo];                                            % contribution of all samples to the probability of failure
        Pe      = sum(dPe);                                                 % total contribution of all exact samples to the probability of failure
        Pa      = sum(dPa);                                                 % total contribution of all approximated samples to the probability of failure
        Pf      = Pe+Pa;                                                    % total probability of failure
        
        % check convergence
        if sum(dP>0)>OPT.minsamples && Pf > 0                               % IF: check if the minimum number of samples to check convergence is reached
                                                                            %   and a valid probability of failure is obtained
                                                                            
            sigma       = sqrt(1/(nb*(nb-1))*sum((dP-Pf).^2));              % standard deviation of the contributions to the probability of failure of all samples
            if sigma ~= 0 && isreal(sigma) && ~isnan(sigma)
                COV = sigma/Pf;                                             % updated coefficient of variation (sigma/mu)
            else
                COV = Inf;
            end
%             COV = sqrt((1-Pf)/(nb*Pf));

        end
        
        Accuracy        = norm_inv((OPT.confidence+1)/2,0,1)*COV;           % back-calculated accuracy within given confidence interval
        
        % update approximation ratio
        Pr              = Pa/Pf;                                            % updated fraction of failure probability determined by approximated samples
        
        % determine progress
        if OPT.animate
            nPr         = max([0 find(cumsum(sort(dPa,'descend'))> ...      % estimation of number of reevaluations needed to match the minimum required fraction
                Pa-OPT.Pratio*Pf,1,'first')-1]);                            %   of the failure probability determined by approximated samples
            
            nCOV        = max([0 .5+sqrt(.25+sum((dP-Pf).^2)/ ...           % estimation of number of reevaluations needed to match the criterion of convergence
                (minCOV*Pf)^2)]);
            
            progress    = min([1 nb/(nCOV+nPr)]);                           % estimation of progress
            
            plotDS(un, beta, ARS, Pf, Pe, Pa, Accuracy, ...                 % call plot routine
                n, nARS, ndir, progress, exact, notexact, converged);
        end
        
        if ~isempty(reevaluate)
            reevaluate(1) = [];                                             % reevaluation of first sample in line finished, pop it from the list
        end
        
        if enoughsamples == false
            break;                                                          % break from outer loop if maxsamples is not enough
        end
        
    end
    
    if enoughsamples == false
        break;                                                              % break from outer loop if maxsamples is not enough
    end
    
    % update beta threshold
    if Pr > OPT.Pratio                                                      % IF: check if required ratio of failure probability determined by approximated 
                                                                            %   samples is not yet reached
                                                                            
        betas       = beta(notexact&beta>min([ARS.betamin]));               % determine approximated beta values candidate for reevaluation
        idx         = isort(betas);                                         % sort selected beta values
        
        if ~isempty(idx)
            [ARS.dbeta] = deal(betas(idx(1))-min([ARS.betamin]));
            
            reevaluate  = ...                                               % determine indices of approximated samples within new beta sphere
                find(prob_ars_inbetasphere(ARS, beta) & notexact);
        end
        
        finalise = false;
    end
    
    if isempty(reevaluate) && ~finalise                                     % IF: check if no samples are left for reevaluation and finalisation has not yet started
        
        reevaluate  = find(~exact);                                         % select all approximated points for reevaluation (if they happen to be in the beta sphere)
        finalise    = true;                                                 % start finalisation
        
        if OPT.DesignPointDetection
            [ARS.dbeta] = deal(max([ARS.b_DP]) - min([ARS.betamin]));
        end
    end
end

% prepare output
u           = un.*repmat(beta(:),1,size(un,2));                             % sample vectors in standard normal space (u*beta)
[x P]       = u2x(OPT, u);                                                  % corresponding sample vectors in real-world space and probability

%% create result structure

result = struct(...
    'settings',     rmfield(OPT, {'stochast'}),             ...             % input settings
    'Input',        stochast,                               ...             % input stochast structure
    'Output',       struct(                                 ...             
        'P_f',          Pf,                                 ...             % probability of failure
        'P_e',          Pe,                                 ...             % contribution of exact samples to probability of failure
        'P_a',          Pa,                                 ...             % contribution of approximated samples to probability of failure
        'Beta',         norm_inv(1-Pf, 0, 1),               ...             % beta value in standard normal space corresponding to probability of failure
        'Calc',         n,                                  ...             % number of exact evaluations
        'Calc_ARS',     nARS,                               ...             % number of exact evaluations necessary for initial ARS
        'Calc_dir',     ndir,                               ...             % average number of exeact evaluations needed per direction, after initial ARS is present
        'enoughsamples',enoughsamples,                      ...             % boolean indicating whether OPT.maxsamples was enough 
        'un',           un,                                 ...             % unit vectors for all samples (directions)
        'beta',         beta(:),                            ...             % beta values for all samples
        'u',            u,                                  ...             % vectors in standard normal space for all samples (u*beta)
        'P',            P,                                  ...             % probabilities for all samples
        'x',            x,                                  ...             % vectors in real-world space for all samples
        'z',            zval(:),                            ...             % z-values for all samples
        'exact',        exact(:),                           ...             % boolean vector indicating all exact samples
        'notexact',     notexact(:),                        ...             % boolean vector indicating all approximated samples
        'converged',    converged(:),                       ...             % boolean vector indicating all converged samples
        'COV',          COV,                                ...             % final coefficient of variation obtained
        'Accuracy',     Accuracy,                           ...             % final accuracy obtained
        'Pratio',       Pr,                                 ...             % fraction of probability of failure determined by exact samples
        'ARS',          ARS,                                ...             % final ARS structure
        'seed',         OPT.seed                            ...             % save seed used in this specific computation (NaN = random seed)
    )                                                       ...
);

% plot result
if OPT.plot
    plotDS(result);                                                         % plot final result
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% transform unit vector and beta value in standard normal space into z-value
function [z x u P] = beta2z(OPT, un, beta)
    [x u P] = beta2x(OPT, un, beta);
    
    nf      = ~any(~isfinite(x),2);
    
    if ~iscell(OPT.x2zFunction)
        OPT.x2zFunction = {OPT.x2zFunction};
    end
    
    if length(OPT.x2zFunction) > 1
        aggregate = false;
    else
        aggregate = true;
    end
    
    if any(nf); 
        z(nf,:) = prob_zfunctioncall(OPT, OPT.stochast, x(nf,:),'aggregate',aggregate); 
    end;
    z(~nf)  = -Inf;
end

% transform unit vector and beta value in standard normal space into real-world vector
function [x u P] = beta2x(OPT, un, beta)
    u       = beta2u(un, beta);
    [x P]   = u2x(OPT, u);
end

% transform vector in standard normal space into real-world vector
function [x P] = u2x(OPT, u)
    P       = norm_cdf(u,0,1);
    x       = feval(OPT.P2xFunction, OPT.stochast, P, OPT.P2xVariables{:});
end

% transform unit vector and beta value in vector in standard normal space
function u = beta2u(un, beta)
    u = zeros(0,size(un,2));
    for i = 1:length(beta)
    	u = [u ; beta(i).*un];
    end
end