function [bn zn zn_tot n converged] = find_zero_poly4(un, b, z, varargin)
%find_zero_poly4 
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 27 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: find_zero_poly4.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/find_zero_poly4.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'animate',          false,              ...
    'verbose',          false,              ...
    'zFunction',        '',                 ...
    'aggregateFunction', [],                ...
    'betamax',          norm_inv(1-eps(.9999),0,1), ...    
    'maxorder',         2,                  ...    
    'maxiter',          4,                  ...                             % Maximum iterations for finding z=0
    'maxbisiter',       4,                  ...
    'epsZ',             1e-2                ...                             % precision in stop criterium
);

OPT = setproperty(OPT, varargin{:});

%% Initialise

n           = 0;
iter        = 0;
bisiter     = 0;
b0          = [];
bn          = [];
zn          = [];
zn_tot      = [];
converged   = false;
        
%% Filter NaN's from input

b = b(~isnan(z));
z = z(~isnan(z));

%% Check for origin (b=0)

if ~any(b == 0)
    b       = [0 b];
    z0_tot  = feval(OPT.zFunction, un, b(1));
    zn_tot  = [zn_tot; z0_tot];
    z       = [feval(@prob_aggregate_z, zi, 'aggregateFunction', OPT.aggregateFunction) z];
    
    
    n   = n + 1;
elseif any(b == 0) && z(b == 0) <= 0
    error('Failure at origin.');
end

%% approximate results handling

% check if beta value for which z=0 is already available
if ~converged && any(abs(z)<OPT.epsZ)
    
    id = find(abs(z)<OPT.epsZ,1,'first');
    
    if b(id)>0
        zi_tot  = feval(OPT.zFunction, un, b(id));
        zi      = feval(@prob_aggregate_z, zi_tot, 'aggregateFunction', OPT.aggregateFunction);

        n       = n+1;
        bn      = b(id);
        zn_tot  = zi_tot;
        zn      = zi;

        z(id)   = zi;

        if abs(zn)<OPT.epsZ
            % limit state already available, abort
            converged   = true;
        end
    end
end

%% Line search by fitting polynomial

while iter <= OPT.maxiter && ~converged 
    
    if length(z) == 1
        zi_tot  = feval(OPT.zFunction, un, OPT.betamax);
        zi      = feval(@prob_aggregate_z, zi, 'aggregateFunction', OPT.aggregateFunction)
        
        % Use bisection when zi is NaN
        if isnan(zi)
            iter    = Inf;
            break
        else
            b       = [b OPT.betamax];
            z       = [z zi];
            bn      = [bn OPT.betamax];
            zn      = [zn zi];
            zn_tot  = [zn_tot; zi_tot];
        end
    end
    
    order   = min(OPT.maxorder, length(z)-1);

    for o = order:-1:1
        
        ii  = isort(abs(z));
        zs  = z(ii(1:(o+1)));
        bs  = b(ii(1:(o+1)));
        
        p   = polyfit(bs, zs, o);                                                   % Fit polynomial through points
        
        % continue if fit does not have any singularities
        if all(isfinite(p))
            
            % compute roots
            rts     = sort(roots(p));
            
            % continue of roots are found
            if ~isempty(rts)
                
                % select real and positive roots separately
                oi1     = isreal(rts);
                oi2     = rts > 0;
                
                % continue if a real root is found
                if any(oi1)
                    
                    % select the positive real root closest to the
                    % points with smallest z-values, if available, or
                    % the smallest negative real root otherwise
                    if any(oi1&oi2)
                        ii = find(oi1&oi2);
                        ii = ii(isort(rts(ii)));
                        b0 = rts(ii(1));
                    else
                        b0 = max(rts(oi1));
                    end
                end
            end
        end
        
        % Evaluate zFunction at b0
        if ~isempty(b0)
            n       = n + 1;
            
            z0_tot  = feval(OPT.zFunction, un, b0);
            z0      = feval(@prob_aggregate_z, z0_tot, 'aggregateFunction', OPT.aggregateFunction);
            
            % Use bisection when encountering NaN of Inf
            if isnan(z0) || isinf(z0)
                iter    = Inf;
                break
            end
            
            b       = [b b0];
            z       = [z z0];
            bn      = [bn b0];
            zn      = [zn z0];
            zn_tot  = [zn_tot; z0_tot];
            
            if OPT.animate
                find_zero_plot(OPT,b0,b,z,bs,zs,bn,zn,p);
            end
            
            b0  = [];
        end
            
        iter    = iter + 1;
        
        if abs(z(end))<OPT.epsZ && b(end)>0
            converged = true;
            if OPT.verbose
%                 fprintf('Found Z=0 with polynomial fit! \n')
            end
            break
        end
    end
end

%% Line search by bisection

if ~converged

    while ~converged && bisiter <= OPT.maxbisiter
        ii  = isort(abs(z));
        
        if bisiter == 0
            if any(z<0)
                ii  = isort(b);
                iu  = ii(find(z(ii)<0 ,1 ,'first'));

                il  = ii(find(b(ii)<b(iu),1,'last'));
            elseif ~any(z<0) && ~any(b == OPT.betamax)
                b       = [b OPT.betamax];
                bn      = [bn OPT.betamax];
                zu_tot  = feval(OPT.zFunction, un, bn(end));
                zu      = feval(@prob_aggregate_z, zu_tot, 'aggregateFunction', OPT.aggregateFunction);
                n       = n + 1;
                
                z       = [z zu];
                zn      = [zn zu];
                zn_tot  = [zn_tot; zu_tot];
                
                ii      = isort(b);
                iu      = ii(b(ii)==OPT.betamax);
                if zu < 0
                    il  = ii(find(b(ii)<b(iu),1,'last'));
                else
                    il  = ii(b(ii)==0);
                end
            else
                il  = ii(b(ii)==0);
                iu  = ii(2);
            end
        elseif bisiter > 0 && z(end) < 0
            iu  = ii(z(ii)==z(end));
        elseif bisiter > 0 && z(end) > 0
            if abs(z(end)) > abs(zs(1)) && abs(z(end)) <= abs(zs(2))
                iu  = ii(z(ii)==z(end));
            elseif abs(z(end)) <= abs(zs(1)) && abs(z(end)) > abs(zs(2)) 
                il  = ii(z(ii)==z(end));
            elseif abs(z(end)) > abs(zs(1)) && abs(z(end)) > abs(zs(2))
                if abs(zs(1)) > abs(zs(2))
                    il  = ii(z(ii)==z(end));
                elseif abs(zs(1)) <= abs(zs(2))
                    iu  = ii(z(ii)==z(end));
                end
            elseif abs(z(end)) <= abs(zs(1)) && abs(z(end)) <= abs(zs(2))
                if abs(zs(1)) > abs(zs(2))
                    il  = ii(z(ii)==z(end));
                elseif abs(zs(1)) <= abs(zs(2))
                    iu  = ii(z(ii)==z(end));
                end
            end
        elseif bisiter > 0 && isnan(z(end))
            iu  = ii(b(ii)==b0);
        elseif bisiter > 0 && ~isnan(z(end)) && any(isnan(zs))
            if bs(~isnan(zs)) <= b(end)
                iu  = ii(b(ii)==b(end));
            elseif bs(~isnan(zs)) > b(end)
                il  = ii(b(ii)==b(end));
            end
        end
        
        bs  = [b(il) b(iu)];
        zs  = [z(il) z(iu)];
        
        if all(bs<0)                                                        % Abort if the interval is completely located in negative beta area
            break
        elseif any(bs<0) && any(bs>=0)                                      % If one beta of the interval is negative, set that one to b=0
            in      = ii(b(ii)==0);
            bs(bs<0)= b(in);
            zs(bs<0)= z(in);
        end
        
        b0      = mean(bs);
        z0_tot  = feval(OPT.zFunction, un, b0);
        z0      = feval(@prob_aggregate_z, z0, 'aggregateFunction', OPT.aggregateFunction);
        b       = [b b0];
        z       = [z z0];
        bn      = [bn b0];
        zn      = [zn z0];
        zn_tot  = [zn_tot; z0_tot];
        
        if OPT.animate && exist('p','var')
            find_zero_plot(OPT,b0,b,z,bs,zs,bn,zn,p);
        end
        
        n   = n + 1;
        bisiter     = bisiter + 1;
        
        if isnan(z0)
            OPT.maxbisiter  = 10;                                           % Use more iterations when encountering NaN's
        end

        if abs(z(end))<OPT.epsZ && b(end)>0
            converged = true;
            if OPT.verbose
%                 fprintf('Found Z=0 with bisection! \n')
            end
        end
    end
end

%% Filter NaN's from output

bn      = bn(~isnan(zn));
zn      = zn(~isnan(zn));