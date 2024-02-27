function [b z n converged] = find_zero_poly3(un, b, z, varargin)
%FIND_ZERO_POLY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = find_zero_poly(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   find_zero_poly
%
%   See also 

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

% $Id: find_zero_poly3.m 5125 2011-08-29 06:57:15Z dierman $
% $Date: 2011-08-29 14:57:15 +0800 (Mon, 29 Aug 2011) $
% $Author: dierman $
% $Revision: 5125 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/find_zero_poly3.m $
% $Keywords: $
%% settings

OPT = struct(...
    'zFunction',        '',                 ...
    'epsZ',             1e-2,               ...     % precision in stop criterium
    'maxiter',          50,                 ...     % maximum number of iterations
    'maxretry',         3,                  ...     % maximum number of iterations before retry
    'maxorder',         3                   ...     % maximum order of polynom in line search
);

OPT = setproperty(OPT, varargin{:});

%% search zero

converged = true;
fh = findobj('Tag','LSprogress');
close(fh);
l = length(z);
n = 0;  % number of model evaluations


while (b(end)>=0 && abs(z(end))>OPT.epsZ) || length(z) == l
    n   = n+1;

    % set model evaluations in order of absolute z-value
    [zabs, ii] = sort(abs(z));
    ii = ii(1:min(3,length(ii)));
    [zt, bt] = deal(z(ii), b(ii));
    or=min(2, length(z)-1);  % order of the polynome to be fitted
    
    % fit polynome
    p   = polyfit(bt(1:or+1), zt(1:or+1), or);
    
    % find root of polynome
    rts = sort(roots(p));   
    
    % deal with double roots or imaginary roots if order=2
    if or==2
        % real roots, take smallest positive value (if available)
        if isreal(rts(1))
            if rts(1)>=0
                rts = rts(1);
            else
                rts = rts(2);
            end
        else % no real roots, teke line fit
            p   = polyfit(bt(1:2), zt(1:2), 1);
            rts = roots(p);
        end
    end    
    
    % add new beta and z-value
    b   = [b rts];
    z   = [z feval(OPT.zFunction, un, b(end))];
    plot_progress([bt b(end)], [zt z(end)], p);
    
    % retry option 
    if length(z)<=OPT.maxretry
        bl  = b(end-1);
        while ~isfinite(z(end))
            n   = n+1;
            b   = [b(1:end-1) mean([bl b(end)])];
            z   = [z(1:end-1) feval(OPT.zFunction, un, b(end))];

            if length(z)>OPT.maxiter+1
                break;
            end
        end
    end

    if ~isfinite(z(end)) || length(z)>OPT.maxiter+1
        converged = false;
        break;
    end
end

b = b(l+1:end);
z = z(l+1:end);


function plot_progress(b, z, p)


fh = findobj('Tag','LSprogress');

% initialize plot
if isempty(fh)
    fh = figure('Tag','LSprogress');
end
figure(fh);
clf(fh);
hold on; grid on;
xlabel('beta');
ylabel('z');

plot(b,z,'bd','MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',4);
set(gca,'xlim',[min(b)-1 max(b)+1]);

grb         = linspace(min(b),max(b),100);
grz = polyval(p, grb);
plot(grb, grz, 'r-');
    
