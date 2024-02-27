function [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] = criticalbedshearstress(D,rhos,rhow,varargin)
%CRITICALBEDSHEARSTRESS computes the critical Shields parameter for diameter D (m)
%
%   [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] = criticalbedshearstress(D,rhos,rhow)
%
%   Input:
%       D  =  grain diameter (m)
%       rhos = sediment density (kg/m^3)
%       rhow = water density (kg/m^3)
%
%   Optional input:
%       mu = porosity of the sand bed; default is 0.35 (-)
%       gamma = power in cohesive function; default is 1.5 (-)
%       cgel = gelling concentration; default is computed (kg/m^3)
%
%   Output:
%       ThetaCrZanke = nondimensional bed shear stress following Zanke (2003)
%       ThetaCrBrownlie = nondimensional bed shear stress following Brownlie (1981)
%       ThetaCrZanke = nondimensional bed shear stress following Van Rijn (1993)
%       Ddim = Bonnefille dimensionless grain size
%
%   Example
%       D = 0.020;
%       rhos = 2650;
%       rhow = 1000;
%       [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] =  criticalbedshearstress(D,rhos,rhow)
%
%
%   for the dimensional critical shear stress:
%       TauCr = ThetaCr.* (g .* (rhos - rhow) .* D50)
%   
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: criticalbedshearstress.m 2827 2010-07-14 06:02:01Z b.t.grasmeijer@arcadis.nl $
% $Date: 2010-07-14 14:02:01 +0800 (Wed, 14 Jul 2010) $
% $Author: b.t.grasmeijer@arcadis.nl $
% $Revision: 2827 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/criticalbedshearstress.m $
% $Keywords: $

%%

%constants
s = rhos/rhow;                                                                  % relative density
g = 9.81;                                                                       % gravitational acceleration
salinity = 35;
temperature = 10;
nu = kinviscwater(salinity,temperature);                                        % kinematic viscosity of seawater

% default values of optional parameters
gamma = 1.5;                                                                % 1 < gamma < 2 (Van Rijn, 2007)
mu = 0.35;                                                                  % porosity of sand bed
cgel0 = [];

% optional arguments
optvals = varargin;
if 2*round(length(optvals)/2)~=length(optvals),
    error('Invalid option-value pair');
else
    optvals=reshape(optvals,[2 length(optvals)/2]);
end;
OptionUsed=false(1,size(optvals,2));
for i=1:size(optvals,2),
    if ~ischar(optvals{1,i}),
        error('Invalid option'),
    end;
    switch lower(optvals{1,i}),
        case 'gamma',
            gamma = optvals{2,i};
            OptionUsed(i)=1;
        case 'mu',
            mu = optvals{2,i};
            OptionUsed(i)=1;
        case 'cgel',
            cgel0 = optvals{2,i};
            OptionUsed(i)=1;
    end
end;
optvals(:,OptionUsed)=[];                                                   % delete used options

%parameters
Ddim=D.*((s-1).*g./nu.^2).^(1/3);                                           % Bonnefille dimensionless grain size

%computation
%ThetaCrZanke = (0.145.*Ddim.^(-1/2) + 0.045*10.^(-1100.*Ddim.^(-9/4)));
ThetaCrZanke = 0.5.*(0.145.*Ddim.^(-1/2) + 0.045*10.^(-1100.*Ddim.^(-9/4)));
%correction Parker: 0.5, then remove 0.5 in pe.m (Parker-Einstein bedload)

% This is the critical bed shear stress from Brownlie (1981), also referred
% to in 'The Civil Engineering Handbook' from Chen (1995)
ReGrain = sqrt(9.81 .* (s - 1) .* D.^3) ./ nu;
Y = ReGrain.^(-0.6);
ThetaCrBrownlie = 0.22 .* Y + 0.06 .* 10.^(-7.7 .* Y);

% The critical bed shear stress by Van Rijn (1993) looks very much like the
% one from Brownlie (1981)
ThetaCrVanRijn = NaN(size(D));
i = find(Ddim < 4);
ThetaCrVanRijn(i) = 0.115.*Ddim(i).^(-0.5);
i = find(Ddim >= 4 & Ddim <= 10);
ThetaCrVanRijn(i) = 0.14.*Ddim(i).^-0.64;
i = find(Ddim > 10 & Ddim <= 20);
ThetaCrVanRijn(i) = 0.04.*Ddim(i).^-0.1;
i = find(Ddim > 20 & Ddim <= 150);
ThetaCrVanRijn(i) = 0.013.*Ddim(i).^0.29;
i = find(Ddim > 150);
ThetaCrVanRijn(i) = 0.055;

i = find(D<62e-6);
cgels = (1-mu).*rhos;
if isempty(cgel0)
    cgel = max(0.05.*rhos,(D(i)./62e-6).*cgels);
else
    cgel = cgel0.*ones(size(D(i)));
end
phi_cohesive = (62e-6./D(i)).^gamma;
phi_packing = cgel./cgels;
ThetaCrVanRijn(i) = ThetaCrVanRijn(i).*phi_cohesive.*phi_packing;

