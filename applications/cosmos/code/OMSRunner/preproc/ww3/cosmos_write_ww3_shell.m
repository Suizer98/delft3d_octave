function cosmos_write_ww3_shell(inpfile,tstart,toutstart,tstop,dt,trststart,trststop,dtrst,rid,x,y)

%% Initialize structure

ww3=ww3_initialize_shell_input;

%% Set start and stop times

ww3.start_time=tstart;
ww3.stop_time=tstop;

%% Outputs

% Type 1 : Fields of mean wave parameters
ww3.field_output.start_time=toutstart;
ww3.field_output.time_step=dt;
ww3.field_output.stop_time=ww3.stop_time;

% Type 2 : Point output
ww3.point_output.start_time=ww3.start_time;
ww3.point_output.time_step=dt;
ww3.point_output.stop_time=ww3.stop_time;
ww3.point_output.points=[];
np=0;
for ii=1:length(rid)
    for j=1:length(x{ii})
        np=np+1;
        r=[rid{ii} num2str(j,'%0.3i')];
        ww3.point_output.points(np).name=r;
        ww3.point_output.points(np).x=x{ii}(j);
        ww3.point_output.points(np).y=y{ii}(j);
    end
end
ww3.point_output.nrpoints=np;

% Type 3 : Output along  track.
ww3.track_output.start_time=ww3.start_time;
ww3.track_output.time_step=0;
ww3.track_output.stop_time=ww3.stop_time;

% Type 4 : Restart files (no additional data required).
ww3.restart_file_output.start_time=trststart;
ww3.restart_file_output.time_step=dtrst;
ww3.restart_file_output.stop_time=trststop;

% Type 5 : Boundary data (no additional data required).
ww3.boundary_data_output.start_time=ww3.start_time;
ww3.boundary_data_output.time_step=dt;
ww3.boundary_data_output.stop_time=ww3.stop_time;

% Type 6 : Separated wave field data (dummy for now).
ww3.separated_wave_field_data_output.start_time=ww3.start_time;
ww3.separated_wave_field_data_output.time_step=0;
ww3.separated_wave_field_data_output.stop_time=ww3.stop_time;

%% And write ww3_shel.inp

ww3_write_shell_inp(inpfile,ww3);
