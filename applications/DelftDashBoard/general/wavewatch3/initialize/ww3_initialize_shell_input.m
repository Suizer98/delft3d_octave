function ww3=ww3_initialize_shell_input(varargin)

if ~isempty(varargin)
    ww3=varargin{1};
end

% Flags
ww3.use_water_levels=0;
ww3.uniform_water_levels=0;
ww3.use_currents=0;
ww3.uniform_currents=0;
ww3.use_winds=1;
ww3.uniform_winds=0;
ww3.use_ice_concentrations=0;
ww3.use_assimilation_data_mean_parameters=0;
ww3.use_assimilation_data_1d_spectra=0;
ww3.use_assimilation_data_2d_spectra=0;

% Time frame of calculations
ww3.start_time=floor(now);
ww3.stop_time=floor(now)+3;

% Define output data
ww3.iostyp=1;

% Five output types are available

% Type 1 : Fields of mean wave parameters
ww3.field_output.start_time=ww3.start_time;
ww3.field_output.time_step=3600;
ww3.field_output.stop_time=ww3.stop_time;
ww3.field_output.flags=[0 0 1 0 0 1 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

% Type 2 : Point output
ww3.point_output.start_time=ww3.start_time;
ww3.point_output.time_step=3600;
ww3.point_output.stop_time=ww3.stop_time;
ww3.point_output.points=[];

% Type 3 : Output along  track.
ww3.track_output.start_time=ww3.start_time;
ww3.track_output.time_step=0;
ww3.track_output.stop_time=ww3.stop_time;

% Type 4 : Restart files (no additional data required).
ww3.restart_file_output.start_time=ww3.stop_time;
ww3.restart_file_output.time_step=86400;
ww3.restart_file_output.stop_time=ww3.stop_time;

% Type 5 : Boundary data (no additional data required).
ww3.boundary_data_output.start_time=ww3.start_time;
ww3.boundary_data_output.time_step=3600;
ww3.boundary_data_output.stop_time=ww3.stop_time;

% Type 6 : Separated wave field data (dummy for now).
ww3.separated_wave_field_data_output.start_time=ww3.start_time;
ww3.separated_wave_field_data_output.time_step=0;
ww3.separated_wave_field_data_output.stop_time=ww3.stop_time;
ww3.separated_wave_field_data_output.first_x=0;
ww3.separated_wave_field_data_output.last_x=999;
ww3.separated_wave_field_data_output.step_x=1;
ww3.separated_wave_field_data_output.first_y=0;
ww3.separated_wave_field_data_output.last_y=999;
ww3.separated_wave_field_data_output.step_y=1;
ww3.separated_wave_field_data_output.flag=1;

% Homogeneous field data
ww3.homogeneous_field_data.wnd.use=0;
ww3.homogeneous_field_data.wnd.time=floor(now);
ww3.homogeneous_field_data.wnd.value=0;
ww3.homogeneous_field_data.wnd.direction=0;
ww3.homogeneous_field_data.wnd.air_sea_temperature_difference=0;
ww3.homogeneous_field_data.lev.use=0;
ww3.homogeneous_field_data.lev.time=floor(now);
ww3.homogeneous_field_data.lev.value=0;
ww3.homogeneous_field_data.cur.use=0;
ww3.homogeneous_field_data.cur.time=floor(now);
ww3.homogeneous_field_data.cur.value=0;
ww3.homogeneous_field_data.cur.direction=0;
