function density = eckart_1958(varargin)
%ECKART_1958 equation of state according to Eckart [1958]
%
%  density = eckart_1958(varargin)
%
% Calculates density from salinity and temperature.
%
%   - density     [kg/m3]    
%   - temperature [deg C]
%   - salinity    [ppt]  
%
%   EXAMPLE
% 
%   density  = eckart_1958('salinity'  ,30,'temperature',15 )
%   density  = eckart_1958('salinity'  , 0,'temperature',4)
%
% Eckart, C., 1958: Properties of water: II. The equation of state of
% water and sea water at low temperatures and pressures. Amer.
% J. Sci., 256, 225-240.
%
% Wright, Daniel G., 1997: An Equation of State for Use in 
% Ocean Models: Eckart’s Formula Revisited. J. Atmos. Oceanic 
% Technol., 14, 735-740.
%
%See also: waterdensity0, waterdensityp, saco_ui

density     = NaN;
temperature = NaN;
salinity    = NaN;

if nargin ~= 4
   error('EquationOfState requires 4 inputs')
end

i=1;
while i<=nargin,
    switch lower(varargin{i})
    case 'density'
      i=i+1;
      density      = varargin{i};
    case 'temperature'
      i=i+1;
       temperature = varargin{i};
    case 'salinity'
      i=i+1;
      salinity     = varargin{i};
    otherwise
      error(sprintf('Error in function EquationOfStateInvalid invalid option: %s.',varargin{i}));
    end
  i=i+1;
end;

if isnan(density)
   labda   =    + 1779.5 ...
                + 11.250          .* temperature ...
                - 0.0745          .* temperature  .^ 2 ...
             - (+ 3.8000 + 0.0100 .* temperature) .* salinity;
   alpha0  =      0.6980;
   P0      =    + 5890.0 ...
                + 38.000          .* temperature ...
                - 0.3750          .* temperature  .^ 2 ...
                + 3.0000          .* salinity;
   density =      1000.0          .* P0 ./ (labda + alpha0*P0); % source: Delft3D-FLOW manual
end

density(temperature < 0 | temperature > 40 | salinity < 0 | salinity > 40) = nan;

% EOF