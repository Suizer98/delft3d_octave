function ww3=ww3_initialize_grid_input(varargin)

if ~isempty(varargin)
    ww3=varargin{1};
end

% Name
ww3.name='';

% Spectral data
ww3.frequency_increment_factor=1.1;
ww3.first_frequency=0.04177;
ww3.number_of_frequencies=25;
ww3.number_of_directions=24;
ww3.relative_offset_of_first_direction=0;

% Set model flags
ww3.dry_run=0;
ww3.x_component_of_propagation=1;
ww3.y_component_of_propagation=1;
ww3.direction_shift=1;
ww3.wavenumber_shift=0;
ww3.source_terms=1;

% $ - Time step information (this information is always read)
ww3.maximum_global_timestep=3600;
ww3.maximum_cfl_timestep_x_y=1300;
ww3.maximum_cfl_timestep_k_theta=3600;
ww3.minimum_source_term_timestep=300;

% Inputs in name lists
ww3.namelist.SBT1.GAMMA=-0.038;
ww3.namelist.MISC.FLAGTR=0;
ww3.namelist.MISC.CICE0=0.33;
ww3.namelist.MISC.CICEN=0.67;

% Define grid
ww3.nx=288;
ww3.ny=157;
ww3.dx=1.25;
ww3.dy=1;
ww3.scaling_factor_dxdy=1;
ww3.x0=0;
ww3.y0=-78;
ww3.scaling_factor_x0y0=1;

% Bottom depth
ww3.limiting_bottom_depth=-0.05;
ww3.minimum_water_depth=25;
ww3.bottom_depth_unit_number_file=11;
ww3.bottom_depth_scaling_factor=-0.1;
ww3.bottom_depth_idla=1;
ww3.bottom_depth_idfm=1;
ww3.bottom_depth_format_for_formatted_read='(...)';
ww3.bottom_depth_from='NAME';
ww3.bottom_depth_filename='';

% Obstructions
ww3.obstructions_unit_number_file=12;
ww3.obstructions_scaling_factor=0.001;
ww3.obstructions_idla=1;
ww3.obstructions_idfm=1;
ww3.obstructions_format_for_formatted_read='(...)';
ww3.obstructions_from='NAME';
ww3.obstructions_filename='';

% Input boundary points
ww3.status_map_unit_number_file=10;
ww3.status_map_idla=3;
ww3.status_map_idfm=1;
ww3.status_map_format_for_formatted_read='(....)';
ww3.status_map_from='PART';
ww3.status_map_filename='mapsta.inp';

% Input boundary points
ww3.boundary_points=[];

% Excluded grid points
ww3.excluded_points=[];

% Points in a closed body of sea points to remove
% the entire body of sea points. Also close by point (0,0)
ww3.excluded_closed_bodies=[];

% Output boundary points
ww3.output_boundary_points=[];
