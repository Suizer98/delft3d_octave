function result = FastARS(varargin)
% FASTARS: probabilistic method of Boucher and Bourgund, 1990
%
% paper: A FAST AND EFFICIENT RESPONSE SURFACE APPROACH FOR STRUCTURAL
% RELIABILITY PROBLEMS, C.G. Bucher and U. Bourgund, Structural Safety, 7
% (1990) 57-66
% 
% This is a very fast method for design point estimation. From the design
% point, the probability of failure is computed as well. However, the
% method is not expected to be very accurate in non-linear problems, but
% can still be very usefull, e.g. if the estimated design point is used as
% a starting point for nore accurate methods. The method has some similarities
% with FORM and makes use of Adaptive response functions (ARS)
%   
% syntax:
% result = FastARS(varargin)
%
% input:
% varargin = series of keyword-value pairs to set properties
%
% output:
% result = structure with settings, input and output
%
% See also setproperty exampleStochastVar

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares 
%       F.L.M. Diermanse
%
%       Fedrinand.diermanse@Deltares.nl	
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

% Created: 29 Nov 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: FastARS.m 7864 2012-12-27 15:59:00Z dierman $
% $Date: 2012-12-27 23:59:00 +0800 (Thu, 27 Dec 2012) $
% $Author: dierman $
% $Revision: 7864 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FastARS/FastARS.m $

%% settings

varargin = prob_checkinput(varargin{:});

% defaults
OPT = struct(...
    'stochast', struct(),...  % stochast structure
    'startU', 0,...           % start value for elements of u-vector
    'x2zFunction', @x2z,...   % Function to transform x to z    
    'x2zVariables', {{}},...  % additional variables to use in x2zFunction
    'maxiter', 2,...          % maximum number of iterations
    'ARSgetFunction',   @prob_ars_get, ...        % Function handle to evaluate the z-value 
    'ARSsetFunction',   @prob_ars_set3, ...       % Function handle to update ARS structure 
    'ARSsetVariables',  {{}},               ...                             % Additional variables to the ARSsetFunction
    'method', 'loop'...    % z-function method 'matrix' (default) or 'loop'
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});



%% initialise procedure
stochast = OPT.stochast;
Nstoch = length(stochast); % number of stochastic variables

% deal with deterministic stochastic variables
% this is an ad hoc solution
for j=1:Nstoch
    if isequal(stochast(j).Distr, @deterministic)
        stochast(j).Distr=@norm_inv;
        stochast(j).Params{2}=0.0001;
    end
end

% starting value
if length(OPT.startU) == Nstoch
    startU = OPT.startU;
elseif isscalar(OPT.startU)
    startU = ones(1,Nstoch)*OPT.startU;
end

% active cells
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));

NextIter = true;            % condition to go to next iteration
Converged = false;          % logical to indicate whether convergence criteria have been reached
Calc = 0;                   % number of calculations so far
Iter = 0;                   % number of iterations so far
%[z, betas, criteriumZ, criteriumZ2, criteriumBeta] = deal(NaN(OPT.maxiter,1));  % preallocate 
[betas] = deal(NaN(OPT.maxiter,1));  % preallocate 
[P, x] = deal(NaN((2*sum(active)+1)*OPT.maxiter,Nstoch));
%z = deal(NaN((2*sum(active)+1)*OPT.maxiter,1));
u = [];

% start point analysis
currentU = startU;       % first estimate of design point: origin in the u-space

% make structure stochast for design point evaluation with the ARS
ARSstochast=stochast;
for jj=find(active)
    ARSstochast(jj).Distr = @norm_inv;  % all standard normally distributed
    ARSstochast(jj).Params = {0 1};
end

% initialize response surface (and beta sphere) 
ARS         = prob_ars_struct(     ...
                'active', active       ...                                 % active stochasts                
                );                                        % beta threshold used to select relevant vectors



%% start iteration procedure
while NextIter
   
    Iter = Iter + 1;
    maxIterReached = Iter >= OPT.maxiter;
        
    % define du: step size for permutation in u-space
    fdu=max(1,4-Iter);
    du = zeros(2*sum(active)+1, Nstoch);

    % make matrx with du-values
    du(1:2*sum(active), active) = [eye(sum(active)) * -fdu; eye(sum(active)) * fdu];   
    
    % define u-values
    u = [u; repmat(currentU, size(du,1), 1) + du];
    Calc = Calc(end)+1 : size(u,1);
    
    % convert u to P and x
    [P(Calc,:) x(Calc,:)] = u2Px(stochast, u(Calc,:));
    
    
    % derive z based on x
    z(Calc,1) = prob_zfunctioncall(OPT, stochast, x(Calc,:));
    
    % store z-value of origin
    if Iter==1
        z0=z(Calc(end));
    end
    
    % non-finite x-values will cause problems in z-function
    % warn user in error message which variable(s) cause the problems
    if any(any(~isfinite(x(Calc,:))))
        varnames = {stochast.Name};
        nonfinitevars = varnames(any(~isfinite(x(Calc,:))));
        error('FastARS:xBecameNonFinite', 'x-values became Inf or NaN for variable(s):%s\n\tReconsider stochastic variable and z-function to solve the problem.', sprintf(' "%s"', nonfinitevars{:}))
    end
    
    % fit/update ARS
    ARS.u = u(Calc,:); ARS.z=z(Calc);
    ARS  = feval( ...                                        % compute ARS based on exact samples
        OPT.ARSsetFunction,     ...
        u(Calc,:),                     ...
        z(Calc),                  ...
        'ARS',ARS,              ...
        OPT.ARSsetVariables{:});

        
    % detremine design point of the ARS with FORM 
    resultF = FORM('stochast', ARSstochast, ...
        'startU', currentU,...              % start value for elements of u-vector
        'du', 0.1,...                       % step size for dz/du / Perturbation Value
        'maxdZ', 0.01*z0,...                % second stop criterion for change in z-value
        'method', 'matrix', ...               % z-function method 'matrix' (default) or 'loop'
        'Relaxation', 1,...                 % Relaxation value
        'x2zFunction', 'P2Z_FastARS', ...   % use ARS as z evaluation function
        'x2zVariables', {'Var', ARS}, ...   % ARS description
        'MaxItStepSize', 1 ...              % maximum allowed stepsize per iteration in U-space
        );

    % stop procedure if FORM doesnt converge
    if ~resultF.Output.Converged
        break
    end
    
    % compute z-value in estimated design point
    udn = resultF.Output.u(end,:);   %design point according to FORM
    [Pdn xdn] = u2Px(stochast, udn);
    zdn = prob_zfunctioncall(OPT, stochast, xdn);

    
    % estimate location of design point by interpolation,
    % making "sure" that it's z-value is close to 0
    in = Calc(end); % index of last z-evaluation
    currentU = u(in,:) + (udn-u(in,:))*(z(in)/(z(in)-zdn));
    betas(Iter) = sqrt(currentU*currentU');
    
    % check if iteration should be ended
    if maxIterReached
        
        % compute z-value of last design point
        [P(end+1,:) x(end+1,:)] = u2Px(stochast, currentU);
        zc = prob_zfunctioncall(OPT, stochast, x(end,:));
        u(end+1,:)=currentU;       
        betas(Iter) = sqrt(currentU*currentU');

        
        break
    end
end


%% store results
beta = betas(Iter);
P_f = 1-norm_cdf(beta, 0, 1); % probability of failure
result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
    'Converged', Converged,...
    'P_f', P_f,...
    'Beta', beta,...
    'Iter', Iter,...
    'Betas', betas,...
    'Calc', size(u,1),...
    'u', u,...
    'P', P,...
    'x', x,...
    'z', z,...
    'designpoint', [] ...
    ));

% design point description
designpoint = cell(1, 2*size(x,2));
designpoint(1:2:length(designpoint)) = {stochast.Name};
designpoint(2:2:length(designpoint)) = num2cell(x(end,:));
result.Output.designpoint = struct(designpoint{:},...
    'finalP', result.Output.P(end,:),...
    'finalU', result.Output.u(end,:));

