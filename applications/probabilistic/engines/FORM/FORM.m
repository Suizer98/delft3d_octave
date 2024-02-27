function result = FORM(varargin)
%FORM  routine for First Order Reliability Method (FORM)
%
% Routine to perform the probabilistic First Order Reliability Method. At 
% least the 'stochast' and the 'x2zFunction' are required as input. The 
% stochast structure should contain the fields 'Name', 'Distr' and 'Params'.
%   
% syntax:
% result = FORM(stochast)
% result = FORM('stochast', stochast,...
%               'x2zFunction', @x2z)
%
% input:
% varargin = series of keyword-value pairs to set properties. The stochast
%              structure with fields 'Name', 'Distr' and 'Params' as well
%              as the x2zFunction are required input.
%
% output:
% result = structure with settings, input and output
%
% See also setproperty exampleStochastVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: FORM.m 10918 2014-07-01 17:58:08Z ottevan $
% $Date: 2014-07-02 01:58:08 +0800 (Wed, 02 Jul 2014) $
% $Author: ottevan $
% $Revision: 10918 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/FORM.m $

%% settings

varargin = prob_checkinput(varargin{:});

% defaults
OPT = struct(...
    'stochast', struct(),...  % stochast structure
    'meta', struct(),...      % metadata structure
    'CorrMatrix',[], ...      % matrix with correlation coefficients (for Gaussian correlation)
    'x2zFunction', @x2z,...   % Function to transform x to z    
    'x2zVariables', {{}},...  % additional variables to use in x2zFunction
    'method', 'matrix',...    % z-function method 'matrix' (default) or 'loop'
    'maxiter', 50,...         % maximum number of iterations
    'DerivativeSides', 1,...  % 1 or 2 sided derivatives
    'startU', 0,...           % start value for elements of u-vector
    'du', .3,...              % step size for dz/du / Perturbation Value
    'epsZ', .01,...           % stop criteria for change in z-value
    'maxdZ', 0.1,...          % second stop criterion for change in z-value
    'epsBeta', .01,...        % stop criteria for change in Beta-value
    'Relaxation', .25,...     % Relaxation value
    'dudistfactor', 0,...     % power factor to apply different du to each variable based on the response
    'MaxItStepSize', inf, ... % maximum allowed stepsize per iteration in U-space
    'logconvergence', '' ...  % optionally specify file here to log convergence status
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if ~ismember(OPT.DerivativeSides, 1:2)
    error('"DerivativeSides" should be either 1 or 2')
end

%% series of FORM calculations
Resistance = [];
if any(cellfun(@ischar, OPT.x2zVariables))
    char_id = find(cellfun(@ischar, OPT.x2zVariables));
    Resistance_id = char_id(ismember(OPT.x2zVariables(char_id), 'Resistance')) + 1;
    if ~isempty(Resistance_id)
        Resistance = OPT.x2zVariables{Resistance_id};
    end
end

% in case of multiple Resistance-values
if ~isempty(Resistance) && ~isscalar(Resistance)
    variables_id = find(ismember(varargin(1:2:end), 'x2zVariables'))*2;
    % a series of z-criteria
    if issorted(Resistance)
        startU = OPT.startU; % startU for the first FORM run
        modified_varargin = varargin;
        for iFORM = 1:length(Resistance)
            modified_varargin{variables_id}{Resistance_id} = Resistance(iFORM);
            result(iFORM) = FORM(modified_varargin{:},...
                'startU', startU); %#ok<AGROW>
            % base startU for the next FORM run on the latest one
            startU = result(iFORM).Output.u(end,:);
        end
        return
    else
        error('FORM:criteriaZnotsorted', 'The series of z-criteria should be sorted')
    end
end

%%
stochast = OPT.stochast;

% input
Nstoch = length(stochast); % number of stochastic variables
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~cellfun(@(f) isequal(@deterministic, f), {stochast.Distr});

% define du
[id_low id_upp] = deal(NaN(1,Nstoch));
du = zeros(sum(active)*OPT.DerivativeSides+1, Nstoch);
if OPT.DerivativeSides == 1
    % one sided derivatives
    du(1:sum(active), active) = eye(sum(active)) * OPT.du;
    id_low(active) = deal(size(du,1));
    id_upp(active) = 1:sum(active);
elseif OPT.DerivativeSides == 2
    % two sided derivatives
    du(1:sum(active)*OPT.DerivativeSides, active) = [eye(sum(active)) * -OPT.du/2; eye(sum(active)) * OPT.du/2];
    id_low(active) = 1:sum(active);
    id_upp(active) = sum(active)+(1:sum(active));
end
rel_ids = {id_low id_upp};

% predefine series of u-combinations
if isa(OPT.startU, 'function_handle')
    % evaluate function
    startU = OPT.startU();
    if isempty(startU)
        % use zeros if startU is empty
        startU = zeros(1,Nstoch);
    elseif isscalar(startU)
        % repeat Nstoch times if startU is single value
        startU = ones(1,Nstoch)*startU;
    end
elseif length(OPT.startU) == Nstoch
    startU = OPT.startU;
elseif isscalar(OPT.startU)
    startU = ones(1,Nstoch)*OPT.startU;
else
    error('FORM:startU', 'The parameter "startU" should be either a scalar or a vector with the length of the # stochasts')
end
u = [];
currentU = startU + eps;    % add a perturbation based on machine precision to converge when you start in the design point (e.g. z=R-S, R=norm(6,2), S=norm(6,4)).
Relaxation = OPT.Relaxation;

%% initialise FORM-procedure
NextIter = true;            % condition to go to next iteration
Converged = false;          % logical to indicate whether convergence criteria have been reached
Calc = 0;                   % number of calculations so far
Iter = 0;                   % number of iterations so far
[z, betas, criteriumZ, criteriumZ2, criteriumBeta] = deal(NaN(OPT.maxiter,1));  % preallocate 
[P x] = deal(NaN(OPT.DerivativeSides*sum(active)*OPT.maxiter+1,Nstoch));
alphas = NaN(OPT.maxiter,Nstoch);
dzdu = zeros(OPT.maxiter,Nstoch);


setpref('FORM', 'info', struct())

%% start FORM iteration procedure
while NextIter
    % derive a new series of u-values for the next iteration
    [u id_low id_upp] = prescribeU(currentU, u, du, Relaxation, rel_ids, OPT.MaxItStepSize);
    
    Iter = Iter + 1;
    % check whether current iteration is the first one
    FirstIter = Iter == 1;
    % check whether current iteration exceeds the maximum number of
    % iterations
    maxIterReached = Iter >= OPT.maxiter;
    % define identifier of series of calculations to perform at once
    Calc = Calc(end)+1 : size(u,1);
    
    % convert u to P and x
    [P(Calc,:) x(Calc,:)] = u2Px(stochast, u(Calc,:), 'CorrMatrix', OPT.CorrMatrix);
    
    if any(any(~isfinite(x(Calc,:))))
        % non-finite x-values will cause problems in z-function
        % warn user in error message which variable(s) cause the problems
        varnames = {stochast.Name};
        nonfinitevars = varnames(any(~isfinite(x(Calc,:))));
        error('FORM:xBecameNonFinite', 'x-values became Inf or NaN for variable(s):%s\n\tReconsider stochastic variable and z-function to solve the problem.', sprintf(' "%s"', nonfinitevars{:}))
    end

    setpref('FORM', 'Calc', Calc)

    % derive z based on x
    z(Calc,1) = prob_zfunctioncall(OPT, stochast, x(Calc,:));
    
    if Converged
        % extra check for convergence
        Converged = abs(z(Calc(end))) < OPT.maxdZ / OPT.Relaxation;
        
        if Converged
            % exit while loop
            break
        else
            if ~isempty(OPT.logconvergence)
                fid = fopen(OPT.logconvergence, 'a');
                fprintf(fid, 'Go back into iteration loop at Iter=%i\n', Iter);
                fclose(fid);
            end
            % remove last calculation and go back into iteration loop
            u(end,:) = [];
            z(end,:) = [];
            Calc = size(z,1);
            Iter = Iter - 1;
            currentU = -alphas(Iter,:).*betas(Iter);
            Relaxation = OPT.Relaxation;
            du = duIter;
            continue
        end
    end
    
    % derive dz/du for each of the active u-values
    dzdu(Iter,active) = (z(id_upp(active)) - z(id_low(active))) ./ sum(u(id_upp(active), active) - u(id_low(active), active), 2);
    
    if any(imag(dzdu(Iter,:)))
        % complex dzdu will cause problems in the next iteration
        % warn user in error message which variable(s) cause the problems
        varnames = {stochast.Name};
        complexvars = varnames(imag(dzdu(Iter,:)) ~= 0);
        error('FORM:complexvariables', 'derivative dz/du becomes complex for variable(s):%s\n\tReconsider stochastic variable and z-function to solve the problem.', sprintf(' "%s"', complexvars{:}))
    end
    
    % linearise z-function in u:
    % z(u) = B + A(1)*u(1) + ... + A(n)*u(n)
    % coefficients A(i) equal to -dz/du(i)
    A = dzdu(Iter,:);
    B = z(Calc(end)) - A*u(Calc(end),:)';
    
    % normalise z-function by dividing by the square root of the sum of the
    % squares of A(i). The normalised z-function looks then like:
    % z_norm(u) = beta + alpha(1)*u(1) + ... + alpha(n)*u(n)
    A_abs = sqrt(A*A');
    alphas(Iter,:) = A/A_abs;
    betas(Iter) = B/A_abs;
    
    % check for convergence
    criteriumZ(Iter) = abs(z(Calc(end)) / A_abs / OPT.epsZ);
    criteriumZ2(Iter) = abs(z(Calc(end)) / OPT.maxdZ);
    if ~FirstIter
        criteriumBeta(Iter) = abs(diff(betas(Iter-1:Iter)) / OPT.epsBeta);
    end
    
    % check whether convergence criteria have been met
    Converged = ~FirstIter &&...
        all([criteriumZ(Iter-1:Iter); criteriumBeta(Iter-1:Iter); criteriumZ2(Iter-1:Iter)] < 1);
    
    % optionally log convergence info to file
    if ~isempty(OPT.logconvergence)
        fid = fopen(OPT.logconvergence, 'a');
        fprintf(fid, '%2i %5.3f %5.3f %5.3f\n', Iter, criteriumZ(Iter), criteriumZ2(Iter), criteriumBeta(Iter));
        fclose(fid);
    end
    
    if maxIterReached && ~Converged
        break
    end
    
    if Converged
        % carry out one more calculation using a relaxation value of 1
        % to make u = -alpha*beta, otherwise the final u solution is
        % not consistent with alpha and beta
        duIter = du;
        du = zeros(1,length(stochast));
        Relaxation = 1;
    else
        if OPT.dudistfactor == 0
            Relaxation = OPT.Relaxation;
        else
            % optionally create different du and relaxation factors for each
            % variable based on the response
            [distr distrinv] = deal(zeros(size(stochast)));
            distr(active) = (abs(dzdu(active))) .^ OPT.dudistfactor;
            distr = distr ./ mean(distr(active));
            distrinv(active) = 1 ./ distr(active);
            distrinv = distrinv ./ mean(distrinv(active));
            Relaxation = distr * OPT.Relaxation;
            du(du~=0) = OPT.du * distrinv(active)';
        end
    end
    
    currentU = -alphas(Iter,:).*betas(Iter);
end

%%
P = P(1:max(Calc),:);
x = x(1:max(Calc),:);
z = z(1:max(Calc),:);

if Converged
    Iter = Iter - 1;
end
dzdu = dzdu(1:Iter,:);
alphas = alphas(1:Iter,:);
alpha = alphas(Iter,:);
betas = betas(1:Iter);
beta = betas(Iter);
criteriumZ = criteriumZ(1:Iter);
criteriumZ2 = criteriumZ2(1:Iter);
criteriumBeta = criteriumBeta(1:Iter);

%% write results to structure
P_f = 1-norm_cdf(beta, 0, 1); % probability of failure
result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
        'Converged', Converged,...
        'P_f', P_f,...
        'Beta', beta,...
        'alpha', alpha,...
        'Iter', Iter,...
        'dzdu', dzdu,...
        'alphas', alphas,...
        'Betas', betas,...
        'criteriumZ1', criteriumZ,...
        'criteriumZ2', criteriumZ2,...
        'criteriumBeta', criteriumBeta,...
        'Calc', size(u,1),...
        'u', u,...
        'P', P,...
        'x', x,...
        'z', z,...
        'info', getpref('FORM', 'info'),...
        'designpoint', [] ...
    ));

if isa(OPT.startU, 'function_handle')
    % save finalU to prefs, in order to be available as startU for another
    % calculation
    setpref('FORM', 'finalU', result.Output.u(end,:))
end

designpoint = cell(1, 2*size(x,2));
designpoint(1:2:length(designpoint)) = {stochast.Name};
designpoint(2:2:length(designpoint)) = num2cell(x(end,:));
result.Output.designpoint = struct(designpoint{:},...
    'finalP', result.Output.P(end,:),...
    'finalU', result.Output.u(end,:),...
    'startU', startU,...
    'distU', sqrt(sum((result.Output.u(end,:)-startU).^2)),...
    'BSS', 1 - sum((result.Output.u(end,:)-startU).^2)/sum(result.Output.u(end,:).^2));

%% subfunction to predefine a series of u-values
function [u id_low id_upp] = prescribeU(currentU, u, du, Relaxation, rel_ids, MaxItStepSize)
Calc = size(u,1); 
if ~isempty(u)
    step = diff([u(end,:); currentU]) .* Relaxation;
    stepsize = sqrt(step*step');
    stepsizeCorrected = min(stepsize,MaxItStepSize);
    currentU = (stepsizeCorrected/stepsize)*step + u(end,:);
%   currentU = diff([u(end,:); currentU]) .* Relaxation + u(end,:);
end
u = [u; repmat(currentU, size(du,1), 1) + du];

if any(any(isnan(u)))
    error('FORM:ubecameNaN', 'One or more u-values became NaN')
end

id_low = Calc + rel_ids{1};
id_upp = Calc + rel_ids{2};