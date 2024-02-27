function Ws = sediment_settling_velocity(D,varargin)
% sediment_settling_velocity computes the settling velocity Ws [m/s] using
% a formulation for both the cohesive- (D <= 0.000065 m) and non-cohesive
% regime (D > 0.000065 m = 0.065 mm = 65 micrometer/microns)
% 
% By default, Ws is computed using v. Rijn (1993) for the non-cohesive
% regime based on the sediment particle diameter D (commonly D50) [microns]
% For particles smaller than (or equal to) 0.000065 m (cohesive regime),
% the basic Stokes' formula (which is identical to v. Rijn (1993) as well)
% for a single, stationary falling spherical particle is used (not incl. 
% e.g. hindred setting, (de-)flocculation, shape effects, turbulence, etc.)
% 
% So far only v. Rijn (1993) is implemented for the non-cohesive regime
% (<Form_nc> = 1) and Stokes for the cohesive regime (<Form_c> = 1).
% Feel free to implement any formulation yourself, the script is setup for
% this, inclusion of e.g. hindred setting, flocculation, shape effects and
% turbulence for the cohesive regime would be interesting
% 
% Syntax:
% 
%  <Ws> = sediment_settling_velocity(D,<RhoS>,<Sal>,<Temp>,<Form_nc>,<Form_c>)
% 
%  Input:
%
%    D            Median sediment diameter in meter (D50)
%                 (e.g. 0.0002 or 0.000001:0.000001:0.0001)
%    <RhoS>       Optional, sediment density RhoS (kg/m3), default is 2650
%    <Sal>        Optional, salinity (PSU), default is 35 (sea), fresh = 0
%    <Temp>       Optional, Water temperature (Degrees Celcius), default is 10
%    <Form_nc>    Optional, indice of formulation used for the non-cohesive
%                 regime (D > 0.000065 m), default is 1 (v. Rijn 1993)
%    <Form_c>     Optional, indice of formulation used for the cohesive
%                 regime (D <= 0.000065 m), default is 1 (Stokes)
%
%  Output:
%
%     <Ws>         Optional, output argument in which settling
%                  velocity (m/s) is stored (else an ans is shown)
%
%  Example:
% 
%     Ws_200_micron = sediment_settling_velocity(0.0002);
%
%     OR
%
%     D  = 1:1:1100;
%     Ws = sediment_settling_velocity(D*10^-6,2600,30,15,1,1);
%     plot(D,Ws,'k');
%     xlabel('D_{50} [\mum]'); ylabel('Ws [m/s]'); title('D_{50} v.s. Ws');
%     grid on; box on; axis tight;
%
%  Hard coded variable:
%
%     Gravitational constant g   9.81  [m/s2]
%
%  References:
%
%    Rijn, L.C. van (1993) Principles of sediment transport in rivers,
%    estuaries and coastal seas, page 3.13
%
%  See also kinviscwater waterdensity0

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       <freek.scheel@deltares.nl>;
%
%       Deltares
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

% Input container:
if nargin == 0
    error('No input specified')
elseif nargin == 1
    RhoS = 2650;
    Sal = 35;
    Temp = 10;
    Form_nc = 1;
    Form_c  = 1;
elseif nargin == 2
    RhoS = varargin{1};
    Sal = 35;
    Temp = 10;
    Form_nc = 1;
    Form_c  = 1;
elseif nargin == 3
    RhoS = varargin{1};
    Sal = varargin{2};
    Temp = 10;
    Form_nc = 1;
    Form_c  = 1;
elseif nargin == 4
    RhoS = varargin{1};
    Sal = varargin{2};
    Temp = varargin{3};
    Form_nc = 1;
    Form_c  = 1;
elseif nargin == 5
    RhoS = varargin{1};
    Sal = varargin{2};
    Temp = varargin{3};
    Form_nc = varargin{4};
    Form_c  = 1;
elseif nargin == 6
    RhoS = varargin{1};
    Sal = varargin{2};
    Temp = varargin{3};
    Form_nc = varargin{4};
    Form_c  = varargin{5};
elseif nargin > 6
    old_warn_state = warning;
    warning on;
    warning(['Too many (' num2str(nargin) ') input arguments specified, ignoring all input arguments after the 6th...']);
    RhoS = varargin{1};
    Sal = varargin{2};
    Temp = varargin{3};
    Form_nc = varargin{4};
    Form_c  = varargin{5};
end

% Check input variables for type consistency
if ~isnumeric(D) | ~isnumeric(RhoS) | ~isnumeric(Sal) | ~isnumeric(Temp) | ~isnumeric(Form_nc) | ~isnumeric(Form_c)
    error('Only numeric values are allowed for any of the input arguments');
elseif min(size(D))>1
    error('D should be a single value or vector, not a matrix...');
elseif (max(size(RhoS))>1) | (max(size(Sal))>1) | (max(size(Temp))>1) | (max(size(Form_nc))>1) | (max(size(Form_c))>1)
    error('Numeric values of optional input arguments should only contain 1 number/value');
end

% Check input variables for some physical limits (can be extended of course)
if Sal<0
    error('Salinity too small');
elseif Sal>350
    error('Salinity physically too high');
elseif Temp<-132
    error('Temperature too small');
elseif Temp>100
    error('Temperature too large for liquid water...');
end

%Specify and compute some additional parameters
g        = 9.81;

kin_visc = kinviscwater(Sal,Temp);
RhoW     = waterdensity0(Sal,Temp);

if RhoS<RhoW
    error('RhoS smaller than RhoW, particles will float...');
end

S        = RhoS/RhoW;

% Note that each value for D (if D is a vector) is computed separately, one
% could add an indice trigger using find 'D<=65' &  '~' for efficiency
% gains, though that often this is not required anyway (an extremely fine
% vector of 1.000.000 points runs in a few secs anyway...)

for ii=1:length(D)
    if D(ii)<=0 % Useless data (D <= 0) gets a NaN
        Ws(ii,1) = NaN;
        if ~exist(['old_warn_state'])
            old_warn_state = warning;
        end
        warning on;
        warning(['Negative or zero sediment diameter found for indice ' num2str(ii)]);
    elseif D(ii)<=0.000065 % Entering the cohesive regime:
        if Form_c == 1 % Stokes
            Ws(ii,1) = ((S-1)*g*(D(ii)^2))/(18*kin_visc);
        elseif Form_c == 2
            % 2nd cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        elseif Form_c == 3
            % 3rd cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        elseif Form_c == 4
            % 4th cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        else
            error(['Cohesive formulation ' num2str(Form_c) ' is not implemented (yet)']);
        end 
    else % Entering the non-cohesive regime:
        if Form_nc == 1 % v. Rijn (1993)
            if D(ii)<=0.0001
                Ws(ii,1) = ((S-1)*g*(D(ii)^2))/(18*kin_visc);
            elseif D(ii)<=0.001
                Ws(ii,1) = ((10*kin_visc)/D(ii))*(sqrt(1+((0.01*(S-1)*g*(D(ii)^3))/(kin_visc^2)))-1);
            else
                Ws(ii,1) = 1.1*sqrt((S-1)*g*D(ii));
            end
        elseif Form_nc == 2
            % 2nd non-cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        elseif Form_nc == 3
            % 3rd non-cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        elseif Form_nc == 4
            % 4th non-cohesive formulation here, if statements can be added (see e.g. v. Rijn 1993 Form_nc == 1)...
        else
            error(['Non-cohesive formulation ' num2str(Form_nc) ' is not implemented (yet)']);
        end
    end
end

% Reset you warning state if used
if exist(['old_warn_state'])
    eval(['warning ' old_warn_state.state]);
end

end