function z = Pf2z(samples, Pf, varargin)
%PF2Z  Converts failure probabilities to z-values based on Monte Carlo result
%
%   Returns z-values corresponding to one or more failure probabilites
%   based on a set of Monte Carlo samples.
%
%   Syntax:
%   z = Pf2z(samples, Pf, varargin)
%
%   Input:
%   samples   = list of z-values from Monte Carlo routine or result
%               structure from MC routine
%   Pf        = list of failure probabilities
%   varargin  = increment:  initial increment used in search routine
%               resistance: original resistance used in computation of
%                           z-values
%               correction: list of correction factors corresponding to
%                           z-values, for example returned by importance
%                           sampling routine
%
%   Output:
%   z         = list of z-values corresponding to failure probabilities
%
%   Example
%   z = Pf2z(samples, Pf)
%
%   See also MC

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
% Created: 03 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: Pf2z.m 5014 2011-08-09 11:34:07Z hoonhout $
% $Date: 2011-08-09 19:34:07 +0800 (Tue, 09 Aug 2011) $
% $Author: hoonhout $
% $Revision: 5014 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/Pf2z.m $
% $Keywords: $

%% settings

OPT = struct(...
    'increment',    10,         ...
    'resistance',   0,          ...
    'correction',   [],         ...
    'interpolate',  true        ...
);

OPT = setproperty(OPT, varargin{:});

%% read MC structure

if isstruct(samples)
    S = samples;
    
    if isfield(S, 'settings') && isstruct(S.settings)
        if isfield(S.settings, 'Resistance')
            OPT.resistance = S.settings.Resistance;
        end
        if isfield(S.settings, 'variables')
            idx = find(strcmpi(S.settings.variables, 'resistance'));
            if ~isempty(idx) && length(S.settings.variables)>idx
                OPT.resistance = S.settings.variables{idx+1};
            end
        end
    end
    if isfield(S, 'Output') && isstruct(S.Output)
        if isfield(S.Output, 'P_corr')
            OPT.correction = S.Output.P_corr;
        end
        if isfield(S.Output, 'z')
            samples = S.Output.z;
        end
    end
end

%% initialisation

samples = OPT.resistance - samples;

if isempty(OPT.correction)
    OPT.correction = ones(size(samples));
end

N = length(samples);

%% search z value

z  = nan(size(Pf));

for i = 1:length(Pf)
    
    ll = -Inf;
    ul = Inf;
    
    R   = [];
    Pfc = [];
    
    while true
        
        if ~isinf(ll)
            if ~isinf(ul)
                R = [R mean([ll ul])];
            else
                R = [R ll + OPT.increment];
            end
        else
            if ~isinf(ul)
                R = [R ul - OPT.increment];
            else
                R = [R 0];
            end
        end
        
        Pfc = [Pfc sum((R(end)-samples<0).*OPT.correction)./N];
               
        if length(Pfc) > 1 && ~isinf(ll) && ~isinf(ul) && Pfc(end) == Pfc(end-1)
            
            if OPT.interpolate
                [Pfc ii] = unique(Pfc);
                R        = R(ii);
                
                R        = [R interp1(Pfc, R, Pf(i))];
                Pfc      = [Pfc Pf(i)];
            end
            
            z(i) = R(end); break;
        elseif sum(OPT.correction)./N < Pf(i)
        	z(i) = -Inf; break;
        elseif Pfc(end) >= Pf(i)
            ll = R(end);
        elseif Pfc(end) <= Pf(i)
            ul = R(end);
        end
    end
end
