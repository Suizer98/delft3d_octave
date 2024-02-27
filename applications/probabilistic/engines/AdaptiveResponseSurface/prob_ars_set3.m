function ARS = prob_ars_set3(u, z, varargin)
%PROB_ARS_SET2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_set2(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_set2
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
% Created: 24 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_ars_set3.m 8416 2013-04-09 14:22:37Z bieman $
% $Date: 2013-04-09 22:22:37 +0800 (Tue, 09 Apr 2013) $
% $Author: bieman $
% $Revision: 8416 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_set3.m $
% $Keywords: $

%% settings

OPT = struct(...
    'ARS',      prob_ars_struct,    ...
    'maxZ',     Inf,                ...
    'epsZ',     1e-2                ...
);

OPT = setproperty(OPT, varargin{:});

ARS = OPT.ARS;

%% fit data

notinf      = all(isfinite(u),2) & isfinite(z);
notout      = abs(z)<=OPT.maxZ;
nva         = sum(ARS.active);

% derive 2nd degree response surface with all cross terms
if length(ARS.z) >= 1+nva+nva*(nva+1)/2

    ARS.fit     = polyfitn(u(notinf&notout,:), z(notinf&notout), 2);
    ARS.hasfit  = check_fit(ARS.fit);

% derive 2nd degree response surface with no cross terms
elseif length(ARS.z) >= 2*nva+1

    pfmat       = [zeros(1,nva); eye(nva); 2*eye(nva)];
    ARS.fit     = polyfitn(u(notinf&notout,:), z(notinf&notout), pfmat);
    ARS.hasfit  = check_fit(ARS.fit);
    
else
    
    ARS.hasfit  = false;

end

%ARS.hasfit = check_fit(ARS.fit);

% hij werkt vooralsnog alleen als alle variabelen actief zijn. Als niet
% alle variabelen actief zijn moet de procedure m.i. aangepast worden
% zodanig dat de ARS-fit alleen op de actieve variabelen wordt uitgevoerd. 

% in een later stadium kan de procedure nog verbeterd worden door niet in 1
% keer de stap te maken van "geen cross-terms" naar "alle cross-terms". De
% cross-terms kunnen we eventueel wellicht gradueel laten opvoeren door
% eerst alleen de cross-terms te introduceren voor de belangrijkste
% variabelen, d.w.z. de variabelen die de z-functie het sterkst
% beinvloeden. Maar dit is nog even toekomstmuziek.

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FUNCTION: check fit for extreme characteristics
function valid = check_fit(fit)

    valid = false;
    
    maxcoeff = 1e5;
    
    if ~isempty(fit) && ~isempty(fieldnames(fit))
        if ~any(isnan(fit.Coefficients)) && ...
           ~any(isinf(fit.Coefficients)) && ...
           ~any(fit.Coefficients > maxcoeff) && ...
           ~any(isnan(fit.ParameterVar)) && ...
           ~any(isinf(fit.ParameterVar)) && ...
           ~any(fit.ParameterVar > maxcoeff) && ...
           fit.RMSE/max(1,max(abs(fit.Coefficients))) < 1

            valid = true;
            
        else
            
            %fprintf('ARS fit failed: max coef: %3.2f ; max var: %3.2f ; RMSE: %3.2f\n', ...
            %    max(fit.Coefficients), max(fit.ParameterVar), fit.RMSE);

        end
    end
end

