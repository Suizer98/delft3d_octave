function result = SubSet(varargin)
% basic implementation of subset simulation
% 
% paper: Estimation of small failure probabilities in high dimensions using
% subset simulation, S. AU and J. Beck, Probabilistic Engineering
% Mechanics, 16 (2001), 263-277
%
% In the current setup, the proposal distribution is uniform on the
% interval [x-delta, x+delta]. dlta can be chosen by the user. Future
% extensions of the procedure should allow a more flexible choice of the
% proposal distribution
%
% syntax:
% result = SubSet(varargin)
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

% Created: 27 Dec 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: SubSet.m 7868 2012-12-28 13:41:42Z dierman $
% $Date: 2012-12-28 21:41:42 +0800 (Fri, 28 Dec 2012) $
% $Author: dierman $
% $Revision: 7868 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/Subset_simulation/SubSet.m $

%% settings

varargin = prob_checkinput(varargin{:});

% defaults
OPT = struct(...
    'stochast', struct(),...  % stochast structure
    'x2zFunction', @x2z,...   % Function to transform x to z    
    'x2zVariables', {{}},...  % additional variables to use in x2zFunction
    'method', 'loop',...      % z-function method 'matrix' (default) or 'loop'
    'delta', 1, ...           % parameter of the uniform proposal distribution of the MCMC procedure
    'Nsamples', 1e3, ...      % number of samples per subset
    'p0', 0.1...              % decrease in excedance probability for subsequent subsets 
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

% Read from "OPT"
[p0, delta, Nsamples, stochast] = deal(OPT.p0, OPT.delta, OPT.Nsamples, OPT.stochast);
ranki = round(p0*Nsamples);  % rankking of sample that determines Z-boundary of each subset

%% evaluation of first subset

% sample P and compute x and z
P = rand(Nsamples,2);
x = P2x(stochast, P);
Z = prob_zfunctioncall(OPT, stochast, x);

% derive Z-value (Zi) with estimated exceedance probability p0
[Z, indexsort] = sort(Z);
x = x(indexsort,:);    % x-values sorted with z-values
Zi = Z(ranki);
PZi = p0;

%% evaluation of subsequent subsets

% define generic function calls
proppdf = @(x,y) multiunifpdf(y-x,-delta,delta);
proprnd = @(x) multiproprnd(x,delta);

while Zi>0
    
    % Markow Chain Monte Carlo sampling
    pdf = @(x) SSpdf(x,Zi, OPT); % function call of the target distribution
    x0 = x(ceil(ranki*rand),:);   % start vector of the Markov chain: random sampled from x-values in subset failure zone
    x = mhsample(x0,Nsamples,'pdf',pdf,'proppdf',proppdf,'proprnd',proprnd); % MCMC sampling of x-values
    Z = prob_zfunctioncall(OPT, stochast, x);  %asociated z-values
    
    % derive Z-value (Zi) with estimated conditional exceedance probability p0 
    [Z, indexsort] = sort(Z);
    x = x(indexsort,:);    % x-values sorted with z-values
    Zi = Z(ranki);
    
    % update total failure probability
    if Zi>0 % if Zi>0, p0 is the probability that Z<Zi | x in current subset
        PZi = PZi*p0;
        
    else  % if Zi<0, procedure is finished  
        p1 = sum(Z<0)/Nsamples;
        PZi=PZi*p1;
    end
end

%% store result
result = struct(...
    'settings', OPT,...
    'Output', struct(...
    'P_f', PZi...
    ));




%% sub-functions
function density = multiunifpdf(x,LB,UB)
% mutivariate uniform pdf
%
% input
%   x:        vector for which density is derived
%   LB, UB:   lower and upper bound of the uniform density function
%
% output
%   density:  pdf-density

y = unifpdf(x,LB,UB);
density = prod(y);


function y = multiproprnd(x, delta) 
% random sampling from a mutivariate uniform density function around a
% vector x
%
% input
%   x:        vector around which the uniform sampling is executed
%   delta:    [x-delta, x+delta] is the sampling range
%
% output
%   y:        sampled vector 

y = x + rand(1, length(x))*2*delta - delta;   


function density = SSpdf(x, Zi, OPT)
% target density function of the Markow Chain Monte Carlo (MCMC) sampling
% procedure
%
% input
%   x:      vector for which density is derived
%   Zi:     Z-value below which the density = 0
%   OPT:    structure with user defined settings
%
% output
%   density:  pdf-density

Z = prob_zfunctioncall(OPT, OPT.stochast, x);
if Z>Zi
    density=0;
else
    density = prod(x2density(OPT.stochast, x));
end


