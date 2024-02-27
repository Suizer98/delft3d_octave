function result = MC(varargin)
%MC  perform Monte Carlo simulation
%
%   This routine executes a Monte Carlo simulation. By default, the crude
%   Monte Carlo method is chosen. The input is parsed by
%   propertyname-propertyvalue pairs. At least the 'stochast' and the
%   'x2zFunction' are required as input. The stochast structure should
%   contain the fields 'Name', 'Distr' and 'Params'. The x2zFunction should
%   have the input arguments 'P', 'samples' (structure) and optionally
%   'Resistance' followed by more optional arguments (varargin).
%
%   Syntax:
%   result = MC(stochast)
%   result = MC(..
%       'stochast', stochast,...
%       'x2zFunction', @x2z,...
%       'NrSamples', 1000);
%
%   Input:
%   varargin  = series of propertyName-propertyValue pairs
%
%   Output:
%   result = structure with 'settings', 'Input' and 'Output'. 'Input'
%            contains all stochastic variable information. Other defaults
%            and input is stored in the 'settings' field. The 'Output'
%            field contains the following information:
%               P_f :    probability of failure
%               Beta :   beta representation of probability of failure
%               Calc :   number of calculations made
%               nFail :  number of calculations leading to failure
%               P_exc :  probability of exceedance for each individual
%                        realisation
%               P_corr : correction factor (only plays a role in importance
%                        sampling applications)
%               idFail : boolean indicating which calculations failed
%               Acy :    accuracy of probability of failure within
%                        requested confidence interval (default: 95%)
%               Acy_rel: relative accuracy with respect to probability of
%                        failure (=Acy/P_f)
%               u :      values in the normally distributed spaces (for each
%                        sample and each variable)
%               P :      probabilities of non-exceedance for each of the
%                        individual variable-sample combinations
%               x :      actual variable values (each row corresponds to one
%                        realisation)
%               z :      result of z-function for each realisation (negative
%                        z-values are considered as failure, corresponding to idFail)
%
%   Example
%   MC
%
%   See also exampleStochastVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
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

% $Id: MC.m 10674 2014-05-11 07:54:57Z ottevan $
% $Date: 2014-05-11 15:54:57 +0800 (Sun, 11 May 2014) $
% $Author: ottevan $
% $Revision: 10674 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/MC.m $

%% settings

varargin = prob_checkinput(varargin{:});

% defaults
OPT = struct(...
    'stochast',     struct(),   ...     % stochast structure
    'meta',         struct(),   ...     % metadata structure
    'CorrMatrix',   [],         ...     % matrix with correlation coefficients (for Gaussian correlation)
    'x2zFunction',  @x2z,       ...     % Function to transform x to z
    'x2zVariables', {{}},       ...     % additional variables to use in x2zFunction
    'method',       'matrix',   ...     % z-function method 'matrix' (default) or 'loop'
    'NrSamples',    1e2,        ...     % number of samples
    'IS',           struct(),   ...     % sampling structure
    'P2xFunction',  @P2x,       ...     % function to transform P to x
    'seed',         NaN,        ...     % seed for random generator
    'confidence',   .95,        ...     % confidence interval for computation of accuracy
    'accuracy',     [],         ...     % required accuracy (negative value indicates relative to Pf)
    'result',       struct(),   ...     % input existing result structure to re-calculate existing samples
    'verbose',      false,      ...     % display convergence
    'timer',        true,       ...     % computation time
    ...
    ... deprecated importance sampling parameters
    ...
    'ISvariable',   '',         ...     % "importance sampling" variable
    'W',            1,          ...     % "(simple) importance sampling" factor
    'f1',           Inf,        ...     % "(advanced) importance sampling" upper frequency boundary
    'f2',           0           ...     % "(advanced) importance sampling" lower frequency boundary
);

OPT = setproperty(OPT, varargin{:});

setpref('FORM', 'info', struct())

% convert old to new IS input format
OPT = prob_is_convert(OPT);

%% parse result as input

result_as_input = ~isempty(fieldnames(OPT.result));

if result_as_input
    newOPT          = OPT.result.settings;
    newOPT.stochast = OPT.result.Input;
    newOPT.result   = struct();
    
    OPT = newOPT;
end

%% initialize accuracy measures

Acy_abs = Inf;
Acy_rel = Inf;

if ~isempty(OPT.accuracy) && OPT.accuracy~=0
    minAccuracy = abs(OPT.accuracy);
    relAccuracy = OPT.accuracy<0;
    useAccuracy = true;
else
    minAccuracy = Inf;
    relAccuracy = false;
    useAccuracy = false;
end

if (OPT.timer);
    timer = tic;
end
%% start monte carlo routine

stochast    = OPT.stochast;
IS          = OPT.IS;


% determine active stochasts
active      = ~cellfun(@isempty, {stochast.Distr}) &     ...
              ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr}, 'UniformOutput', false));

n = 1;

while (~useAccuracy && n==1) || (useAccuracy && ( ...
        ~isfinite(Acy_abs) || ~isfinite(Acy_rel)    || ...
        (relAccuracy && Acy_rel > minAccuracy)      || ...
        (~relAccuracy && Acy_abs > minAccuracy)))

    idx = [(n-1)*OPT.NrSamples+1:n*OPT.NrSamples]';
          
    if result_as_input
        P(idx,:)        = OPT.result.Output.P;
        P_corr(idx,:)   = OPT.result.Output.P_corr;
        P_exc(idx,1)    = OPT.result.Output.P_exc;
        x(idx,:)        = OPT.result.Output.x;
    else
        if ~isnan(OPT.seed)
            rand('seed', OPT.seed)
%         else
            % store current seed in OPT structure, which will be included
            % in the result.settings
%             OPT.seed = rand('seed');
        end

        % draw random numbers
        P(idx, active)              = rand(OPT.NrSamples, sum(active));
        P(idx,~active)              = .5;

        % perform importance sampling
        [P(idx,:) P_corr(idx,:)]    = prob_is(stochast, IS, P(idx,:));

        % determine probability of exceedance
        P_exc(idx,1)                = prod(1-P(idx,active).*repmat(P_corr(idx,:),1,sum(active)),2);

        % transform P to x
        x(idx,:)                    = feval(OPT.P2xFunction, stochast, P(idx,:), 'CorrMatrix', OPT.CorrMatrix);
       
    end

    setpref('FORM', 'Calc', idx)

    % determine failures
    z(idx,:)    = prob_zfunctioncall(OPT, stochast, x(idx,:));
    idFail(idx,:) = z(idx,:) < 0;
    
    % estimate failure probability and confidence inteval
    EstResult = MCEstimator(idFail,P_corr,OPT.confidence);
    P_f = EstResult.P_f;
    Acy_abs = EstResult.Acy_abs;   % last value of the absoluut error 
    Acy_rel = EstResult.Acy_abs ./ P_f;            
           
    
    if OPT.verbose
        % TODO: make proper printing of multiple P_f values possible
        fprintf('%04d: P_f = %3.2e, Acy = %3.2e (%3.2f%%)\n', n, P_f, Acy_abs, Acy_rel*100);
    end
    
    n = n + 1;

end

if (OPT.timer);
    elapsed_time = toc(timer);
else
    elapsed_time = NaN;
end

%% create result structure

result = struct(...
    'settings',     rmfield(OPT, {'stochast' 'result'}),    ...
    'Input',        stochast,                               ...
    'Output',       struct(                                 ...
                        'P_f',      P_f,                    ...
                        'Beta',     norm_inv(1-P_f, 0, 1),  ...
                        'Calc',     size(z,1),              ...
                        'nFail',    sum(idFail),            ...
                        'P_exc',    P_exc,                  ...
                        'P_corr',   P_corr,                 ...
                        'idFail',   idFail,                 ...
                        'Acy',      Acy_abs,                ...
                        'Acy_rel',  Acy_rel,                ...
                        'u',        norm_inv(P, 0, 1),      ...
                        'P',        P,                      ...
                        'x',        x,                      ...
                        'z',        z,                      ...
                        'info',     getpref('FORM', 'info'),...
                        'elapsed_time', elapsed_time        ...
                    )                                       ...
);