function [bn zn n converged] = find_zero_poly2(un, b, z, varargin)
%FIND_ZERO_POLY2  Line search algorithm for roots
%
%   Searches for a root aling a specified direction in the solution space
%   described by a customizable function. This function is based on the
%   polyfit and roots function. These functions are embedded in a series of
%   additional functionalities to minimize the number of (unnecessary)
%   model evaluations and thus increase efficiency.
%
%   The additional measures to increase efficiency are described in the
%   memo Extending the OpenEarth probabilistic toolbox, which is part of
%   the SBW2011 project at Deltares. The headers in this function
%   correspond to this memo.
%
%   This function is still in development. Different functions with similar
%   purpose exist as well.
%
%   Hoonhout, B.M. (2011). Extending the OpenEarth probabilistic toolbox.
%   Memo to Diermanse, F.L.M.. Deltares. Project 1204206.004.
%
%   Syntax:
%   [bn zn n converged] = find_zero_poly2(un, b, z, varargin)
%
%   Input:
%   un        = unit vector (direction)
%   b         = beforehand evaluated positions along direction
%   z         = beforehand evaluated results corresponding to b
%   varargin  = zFunction:      Function handle for model evaluation which
%                               takes two parameters: unit vector and
%                               length
%               epsZ:           Precision in stop criterium
%               maxiter:        Maximum number of iterations
%               maxretry:       Maximum number of iterations before retry
%               maxorder:       Maximum order of polynom in line search
%               maxratio:       Maximum ratio between interval boundaries
%               maxinfpow:      Maximum power of z0 which is assumed to be
%                               infinite 
%               animate:        Boolean indicating wheter process should be
%                               animated 
%
%   Output:
%   bn          = newly evaluated positions along direction
%   zn          = newly evaluated results corresponding to bn
%   n           = number of model evaluations made
%   converged   = flag indicating if result has converged
%
%   Example
%   [bn zn n converged] = find_zero_poly2(un, b, z, 'zFunction', @(x,y)beta2z(OPT,x,y))
%
%   See also DS

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
% Created: 25 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: find_zero_poly2.m 7452 2012-10-11 15:10:55Z hoonhout $
% $Date: 2012-10-11 23:10:55 +0800 (Thu, 11 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7452 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/find_zero_poly2.m $
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

%   b*                  beta values
%   z*                  z-values
%   u*                  vectors in standard normal space
%   n*                  counter
%   i*                  index

%   *e                  exact values
%   *a                  approximated values
%   *n                  unit vectors
%   *l                  vector magintudes

%% principle

%   origin handling
%
%   approximate results handling
%
%   START LINE SEARCH
%
%       infinity approximation
%
%       LOOP until root is found
%
%           finite interval preservation
%
%           outlier detection
%
%           point selection
%
%           LOOP while lowering order of polynome until root is found
%
%               estimate root
%
%           END LOOP
%
%           evaluate new root estimate
%
%           initial retry in case of infinite results
%
%           maximalisation
%
%       END LOOP
%
%       check convergence
%
%   STOP LINE SEARCH

%% settings

OPT = struct(...
    'zFunction',        '',                 ...
    'epsZ',             1e-2,               ...     % precision in stop criterium
    'maxiter',          50,                 ...     % maximum number of iterations
    'maxretry',         1,                  ...     % maximum number of iterations before retry
    'maxorder',         3,                  ...     % maximum order of polynom in line search
    'maxratio',         10,                 ...     % maximum ratio between interval boundaries
    'maxinfpow',        10,                 ...     % maximum power of z0 which is assumed to be infinite
    'animate',          false,              ...     % animate progress
    'verbose',          false               ...     % display verbose messages
);

OPT = setproperty(OPT, varargin{:});

%% initialise

global history

history = {};

verbose(OPT,'Initializing line search...');

n               = 0;
z0              = 0;
bn              = [];
zn              = [];

converged       = false;
startsearch     = true;

%% origin handling

% check if z-evaluation at origin (beta=0) is available, 
% assume z-evaluation is exact, so not from ARS aproximation
if ~converged && any(b==0)
    
    verbose(OPT,'Origin handling...');
    
    % store origin as scaling factor
    i0 = find(b==0,1,'first');
    z0 = z(i0);
    
    if z(i0)<-OPT.epsZ
        % origin in failure area, abort
        startsearch = false;
        
        verbose(OPT,'    Origin in failure area. Abort.');
    end
    
    if abs(z(i0))<OPT.epsZ
        
        % origin is limit state, abort
        bn          = b(i0);
        zn          = z(i0);
        converged   = true;
        startsearch = false;
        
        verbose(OPT,'    Origin is limit state. Abort.');
    end
end

%% approximate results handling

% check if beta value for which z=0 is already available
if ~converged && any(abs(z)<OPT.epsZ)
    
    verbose(OPT,'Approximate results handling...');
    
    id = find(abs(z)<OPT.epsZ,1,'first');
    zi = feval(OPT.zFunction, un, b(id));
    
    n  = n+1;
    bn = b(id);
    zn = zi;
    
    if abs(zn)<OPT.epsZ
        % limit state already available, abort
        converged   = true;
        startsearch = false;
        
        verbose(OPT,'    Limit state already available. Abort.');
    end
end

%% line search

% remove nan's from initial results
b = b(~isnan(z));
z = z(~isnan(z));

if startsearch && length(z)>1
    
    %% infinity approximation
    
    % delete beta-z combinations for which z is extremely large or
    % imaginary
    while any(abs(z)>abs(z0^OPT.maxinfpow)|~isreal(z))&&n<OPT.maxiter
        
        verbose(OPT,'Infinity approximation...');
        
        % select largest value
        ii        = abs(z)==max(abs(z))|~isreal(z);

        % only delete if more than 2 evaluations are available
        if length(z)>sum(ii)+1
            b(ii) = [];
            z(ii) = [];
            
            verbose(OPT,'    Removed %d values',sum(ii));
            
        % otherwise, instead add another evaluation half way
        else
            n     = n+1;
            
            bn    = mean(b);
            zn    = feval(OPT.zFunction, un, bn(end));
            
            b(ii) = bn;
            z(ii) = zn;
            
            verbose(OPT,'    Sampled intermediate value at \beta=%3.2f',bn);
        end
    end
    
    %% line search loop
        
    % start loop, in each iteration a new beta-z value is added
    % until [a] the beta-value is found for which z=0 or [b] the search
    % procedure is terminated because this direction does not have
    % a (relevant)crossing with the limit state.
    while isempty(zn) || abs(zn(end))>OPT.epsZ
        
        verbose(OPT,'Line search...');
        
        % add new samples from infinity approximation to initial
        % evaluations
        ii          = ~ismember(b,bn);
        
        b           = real([b(ii) bn]);
        z           = real([z(ii) zn]);

        % set model evaluations in order of absolute z-value
        order       = min(OPT.maxorder, length(z)-1);
        ii          = isort(abs(z));
        
        %% finite interval preservation
        
        % check if both positive and negative z-values are available. If
        % so, define finite search boundaries
        if any(z>0) && any(z<0)
            
            verbose(OPT,'    Preserved finite interval');
            
            il      = ii(z(ii)>=0);
            iu      = ii(z(ii)<0);
            
            ni      = ceil((order+1)/2);
            nl      = min(ni,length(il));
            nu      = min(ni,length(iu));
            
            ii      = [il(1:nl) iu(1:nu)];
            ii      = ii(isort(abs(z(ii))));
        end
        
        %% outlier detection
        
        % remove outliers, to make sure they don't have a bad infleunce on
        % the fit of the polynome that is used to estimate for which beta z
        % is equal to zero
        while max(abs(z(ii)))/min(abs(z(ii)))>OPT.maxratio
            
            % only delete outlier if more than 2 evaluations are available
            if length(ii)>2
                ii(end) = [];
                
                verbose(OPT,'    Removed outlier');
                
            % otherwise, instead add another evaluation half way
            else
                n       = n+1;

                bn      = [bn mean(b(ii))];
                zn      = [zn feval(OPT.zFunction, un, bn(end))];

                im      = ~ismember(b,bn);

                b       = [b(im) bn];
                z       = [z(im) zn];

                ii      = [ii length(z)];
                ii      = ii(isort(abs(z(ii))));
                
                verbose(OPT,'    Sampled intermediate value at \beta=%3.2f',bn(end));

                break;
            end
        end
        
        %% point selection
        
        % define the order of the polynome
        order       = min(OPT.maxorder, length(ii)-1);
        
        verbose(OPT,'    Set order to %d',order);
        
        % select same number of evaluations closest to z=0 as the order
        ii          = ii(1:order+1);
        [zs bs]     = deal(z(ii), b(ii));
        
        %% line search algorithm
        
        % fit polynome to selected points and decrease order until a real
        % root (z=0) is found
        b0          = -Inf;
        for o = order:-1:1
            
            verbose(OPT,'    Create polynome fit of order %d',o);
            
            % fit polynome
            p       = polyfit(bs(1:o+1),zs(1:o+1),o);
            
            [x ii]  = unique(zs);
            if length(x)>1
                b0a = interp1(x,bs(ii),0,'linear','extrap');
            else
                b0a = 0;
            end
            
            % continue if fit does not have any singularities
            if all(isfinite(p))
                
                % compute roots
                rts     = sort(roots(p));
                
                % continue of roots are found
                if ~isempty(rts)
                    
                    % select real and positive roots separately
                    oi1     = isreal(rts);
                    oi2     = rts>0;

                    % continue if a real root is found
                    if any(oi1)

                        % select the positive real root closest to the
                        % points with smallest z-values, if available, or
                        % the smallest negative real root otherwise
                        if any(oi1&oi2)
                            ii = find(oi1&oi2);
                            ii = ii(isort(abs(rts(ii)-b0a)));
                            b0 = rts(ii(1));
                        else
                            b0 = max(rts(oi1));
                        end

                        % a root is found, stop decreasing the order of the
                        % polynome
                        break;
                    end
                end
            end
        end
    
        % stop procedure if z=0 is found for negative beta value
        if b0<0
            verbose(OPT,'    Found negative beta value. Abort.');
            
            break;
        else
            
            n   = n+1;
            
            % add new beta and z-value at the location of the new root
            % estimate
            bn  = real([bn b0]);
            zn  = real([zn feval(OPT.zFunction, un, bn(end))]);
            
            % set z-value to infinity if z-value exceeds maximum allowed
            % value
            if abs(zn(end))>abs(z0^OPT.maxinfpow)
                zn(end) = zn(end)*Inf;
                
                verbose(OPT,'    Set approximate infinite to Inf');
            end
            
        end

        % plot progress of search
        if OPT.animate
            find_zero_plot(OPT,b0,b,z,bs,zs,bn,zn,p);
        end
        
        %% initial retry
        
        % if maximum number of evaluations is not yet reached, check if
        % last z-value is "infinitely" large. If so, start procedure to
        % search for finite z-values numbers
        if length(zn)<=OPT.maxretry
            
            % loop while last z-value is still infinite
            while ~isfinite(zn(end))&&n<OPT.maxiter
                
                verbose(OPT,'Intial retry...');

                bt  = [b bn];
                zt  = [z zn];

                % overwrite infinite values with new approximates by
                % evaluating a point halfway the last known finite point
                % and the last evaluated infinite point
                if length(bt)>1
                    n           = n+1;
                    bn(end)     = mean(bt(end-1:end));
                    zn(end)     = feval(OPT.zFunction, un, bn(end));
                    
                    verbose(OPT,'    Sampled intermediate value at \beta=%3.2f',bn(end));
                    
                    % set z-value to infinity if z-value exceeds maximum
                    % allowed value
                    if abs(zn(end))>abs(z0^OPT.maxinfpow)
                        zn(end) = zn(end)*Inf;
                        
                        verbose(OPT,'    Set approximate infinite to Inf');
                    end
                else
                    verbose(OPT,'    Didn''t found enough points. Abort.');
                    
                    break;
                end

                if length(zn)>=OPT.maxiter
                    verbose(OPT,'    Reached maximum number of iterations. Abort.');
                    
                    break;
                end
            end
        end
        
        %% maximalisation

        % give up in case infinity or maximum number of iterations is
        % reached
        if ~isfinite(zn(end)) || length(zn)>=OPT.maxiter
            verbose(OPT,'Maximum number of iterations reached or infinite values found. Abort.');
            
            break;
        end
        
        % give up in case new value is not closer to zero
        if any(abs(zn(end))>=abs(zs)) && length(z)>length(zs)
            verbose(OPT,'Solution does not converge. Abort.');
            
            break;
        end
    end

    % check for convergence
    if ~isempty(zn) && abs(zn(end))<OPT.epsZ
        verbose(OPT,'Solution converged');
        
        converged = true;
    end
    
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function verbose(OPT,varargin)
    global history
    
    if OPT.verbose
        
        message = sprintf(varargin{:});

        if message(1)~=' '
            if ismember(message,history)
                return;
            else
                history = [history{:} {message}];
            end
        end
    
        disp(message);
    end