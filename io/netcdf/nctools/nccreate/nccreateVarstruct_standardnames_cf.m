function varstruct = nccreateVarstruct_standardnames_cf(standard_name,varargin)
% NCCREATEVARSTRUCT_STANDARDNAMES_CF Creates a varstruct with defaultsd set to those belonging to a specific standardised name 

%% get varstruct structure from nccreateVarstruct
OPT            = nccreateVarstruct();

% set specifics for standard names
OPT.long_name  = ''; 
OPT.units      = ''; 
OPT.definition = ''; 

% parse varargin
OPT            = setproperty(OPT,varargin);

%% define the lists of standard_names, long_names, units and definitions
list = getList;
  
% lookup the standard name in the list
if nargin==0
    varstruct = list.standard_names;
    return
end

n = find(strcmpi(standard_name,list.standard_names),1);
if isempty(n)
    error('standard name not found')
end

if isempty(OPT.long_name);    OPT.long_name    = list.long_names{n};  end
if isempty(OPT.units);        OPT.units        = list.units{n};       end
if isempty(OPT.definition);   OPT.definition   = list.definitions{n}; end



% add attributes belonging to the standard name
OPT.Attributes =  [{...
    'standard_name',standard_name,...
    'long_name',OPT.long_name,...
    'units',OPT.units,...
    'definition',OPT.definition}...
    OPT.Attributes];

OPT = rmfield(OPT,{'long_name','units','definition'});

% finally check is the varstruct is valid
varstruct = nccreateVarstruct(OPT);

function list = getList()
% iput below is auto generated
list.standard_names = {
    'time'
    'altitude'
    'depth'
    'latitude'
    'longitude'
    'projection_x_coordinate'
    'projection_y_coordinate'
    'sea_surface_swell_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_swell_wave_significant_height'
    'sea_surface_swell_wave_to_direction'
    'sea_surface_wave_zero_upcrossing_period'
    'sea_surface_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_wave_mean_period_from_variance_spectral_density_second_frequency_moment'
    'sea_surface_wave_significant_height'
    'sea_surface_wave_to_direction'
    'sea_surface_wind_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_wind_wave_significant_height'
    'sea_surface_wind_wave_to_direction'
    'wind_speed'
    'wind_to_direction'
    'sea_water_x_velocity'
    'sea_water_y_velocity'
    'upward_sea_water_velocity'
    'northward_sea_water_velocity'
    'eastward_sea_water_velocity'
    'direction_of_sea_water_velocity'
    'radial_sea_water_velocity_away_from_instrument'
    'mass_concentration_of_suspended_matter_in_sea_water'
    'water_surface_height_above_reference_datum'
    'water_surface_reference_datum_altitude'
    'sea_water_temperature'
};

list.long_names = {
    'time'
    'altitude'
    'depth'
    'latitude'
    'longitude'
    'x-coordinate'
    'y-coordinate'
    'Mean wave period T-10 (Swell)'
    'Significant wave height (Swell)'
    'Mean wave direction Theta (Swell)'
    'Mean period time Tz'
    'Mean wave period (1st frequency moment)'
    'Mean wave period (2nd frequency moment)'
    'Significant wave height (Sea and Swell)'
    'Mean wave direction Theta (Sea and Swell)'
    'Mean wave period T-10 (Sea)'
    'Significant wave height (Sea)'
    'Mean wave direction Theta (Sea)'
    'Wind speed'
    'Wind direction'
    'Sea water x velocity'
    'Sea water y velocity'
    'Sea water z velocity'
    'Sea water northward velocity'
    'Sea water eastward velocity'
    'Sea water velocity direction'
    'Sea water velocity direction'
    'Mass concentration of suspended matter in sea water'
    'Water surface height above reference datum'
    'Water surface referernce datum altitude'
    'Sea water temperature'
};

list.units = {
    'days since 1970-01-01 00:00:00'
    'm'
    'm'
    'degree_north'
    'degree_east'
    'm'
    'm'
    's'
    'm'
    'degree_true'
    's'
    's'
    's'
    'm'
    'degree_true'
    's'
    'm'
    'degree_true'
    'm/s'
    'degree_true'
    'm/s'
    'm/s'
    'm/s'
    'm/s'
    'm/s'
    'degree_true'
    'm/s'
    'kg/m3'
    'm'
    'm'
    'K'
};

list.definitions = {
    'Variables representing time must always explicitly include the units attribute; there is no default value. The units attribute takes a string value formatted as per the recommendations in the Udunits package.'
    'Altitude is the (geometric) height above the geoid, which is the reference geopotential surface. The geoid is similar to mean sea level.'
    'Depth is the vertical distance below the surface. Depth is positive downward.'
    'Latitude is positive northward; its units of degree_north (or equivalent) indicate this explicitly. '
    'Longitude is positive eastward; its units of degree_east (or equivalent) indicate this explicitly. '
    ''
    ''
    'A period is an interval of time, or the time-period of an oscillation.'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'A period is an interval of time, or the time-period of an oscillation. The zero upcrossing period is defined as the time interval between consecutive occasions on which the surface height passes upward above the mean level.'
    'The swell wave directional spectrum can be written as a five dimensional function S(t,x,y,f,theta) where t is time, x and y are horizontal coordinates (such as longitude and latitude), f is frequency and theta is direction. S can be integrated over direction to give S1= integral(S dtheta). Frequency moments, M(n) of S1 can then be calculated as follows: M(n) = integral(S1 f^n df), where f^n is f to the power of n. The first wave period, T(m1), is calculated as the square root of the ratio M(0)/M(1).'
    'The swell wave directional spectrum can be written as a five dimensional function S(t,x,y,f,theta) where t is time, x and y are horizontal coordinates (such as longitude and latitude), f is frequency and theta is direction. S can be integrated over direction to give S1= integral(S dtheta). Frequency moments, M(n) of S1 can then be calculated as follows: M(n) = integral(S1 f^n df), where f^n is f to the power of n. The second wave period, T(m2), is calculated as the square root of the ratio M(0)/M(2).'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'A period is an interval of time, or the time-period of an oscillation.'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'The wind speed is the magnitude of the wind velocity. Wind is defined as a two-dimensional (horizontal) air velocity vector, with no vertical component.'
    'Wind is defined as a two-dimensional (horizontal) air velocity vector, with no vertical component. In meteorological reports, the direction of the wind vector is usually (but not always) given as the direction from which it is blowing (wind_from_direction) (westerly, northerly, etc.).'
    'A velocity is a vector quantity. "x" indicates a vector component along the grid x-axis, when this is not true longitude, positive with increasing x.'
    'A velocity is a vector quantity. "y" indicates a vector component along the grid y-axis, when this is not true latitude, positive with increasing y.'
    'A velocity is a vector quantity. "Upward" indicates a vector component which is positive when directed upward (negative downward).'
    'A velocity is a vector quantity. "Northward" indicates a vector component which is positive when directed northward (negative southward).'
    'A velocity is a vector quantity. "Eastward" indicates a vector component which is positive when directed eastward (negative westward).'
    '"direction_of_X" means direction of a vector, a bearing. A velocity is a vector quantity.'
    'A velocity is a vector quantity. Radial velocity away from instrument means the component of the velocity along the line of sight of the instrument where positive implies movement away from the instrument (i.e. outward). The "instrument" (examples are radar and lidar) is the device used to make an observation.'
    'Mass concentration means mass per unit volume and is used in the construction mass_concentration_of_X_in_Y, where X is a material constituent of Y. A chemical species denoted by X may be described by a single term such as ''nitrogen'' or a phrase such as ''nox_expressed_as_nitrogen''.'
    'water_surface_height_above_reference_datum ''Water surface height above reference datum'' means the height of the upper surface of a body of liquid water, such as sea, lake or river, above an arbitrary reference datum. The altitude of the datum should be provided in a variable with standard name water_surface_reference_datum_altitude. The surface called "surface" means the lower boundary of the atmosphere.'
    'Altitude is the (geometric) height above the geoid, which is the reference geopotential surface. The geoid is similar to mean sea level. ''Water surface reference datum altitude'' means the altitude of the arbitrary datum referred to by a quantity with standard name ''water_surface_height_above_reference_datum''. The surface called "surface" means the lower boundary of the atmosphere.'
    'Sea water temperature is the in situ temperature of the sea water. To specify the depth at which the temperature applies use a vertical coordinate variable or scalar coordinate variable. There are standard names for sea_surface_temperature, sea_surface_skin_temperature, sea_surface_subskin_temperature and sea_surface_foundation_temperature which can be used to describe data located at the specified surfaces. For observed data, depending on the period during which the observation was made, the measured in situ temperature was recorded against standard "scales". These historical scales include the International Practical Temperature Scale of 1948 (IPTS-48; 1948-1967), the International Practical Temperature Scale of 1968 (IPTS-68, Barber, 1969; 1968-1989) and the International Temperature Scale of 1990 (ITS-90, Saunders 1990; 1990 onwards). Conversion of data between these scales follows t68 = t48 - (4.4 x 10e-6) * t48(100 - t - 48); t90 = 0.99976 * t68. Observations made prior to 1948 (IPTS-48) have not been documented and therefore a conversion cannot be certain. Differences between t90 and t68 can be up to 0.01 at temperatures of 40 C and above; differences of 0.002-0.007 occur across the standard range of ocean temperatures (-10 - 30 C). The International Equation of State of Seawater 1980 (EOS-80, UNESCO, 1981) and the Practical Salinity Scale (PSS-78) were both based on IPTS-68, while the Thermodynamic Equation of Seawater 2010 (TEOS-10) is based on ITS-90. References: Barber, 1969, doi: 10.1088/0026-1394/5/2/001; UNESCO, 1981; Saunders, 1990, WOCE Newsletter, 10, September 1990.'
};
    