function ww3_write_shell_inp(fname,shl)

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ WAVEWATCH III shell input file                                       $');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ Define input to be used with flag for use and flag for definition');
fprintf(fid,'%s\n','$ as a homogeneous field (first three only); seven input lines.');
fprintf(fid,'%s\n','$');

if shl.use_water_levels
    f1='T';
else
    f1='F';
end
if shl.uniform_water_levels
    f2='T';
else
    f2='F';
end
fprintf(fid,'%s\n',['  ' f1 ' ' f2 '     Water levels']);

if shl.use_currents
    f1='T';
else
    f1='F';
end
if shl.uniform_currents
    f2='T';
else
    f2='F';
end
fprintf(fid,'%s\n',['  ' f1 ' ' f2 '     Currents']);

if shl.use_winds
    f1='T';
else
    f1='F';
end
if shl.uniform_winds
    f2='T';
else
    f2='F';
end
fprintf(fid,'%s\n',['  ' f1 ' ' f2 '     Winds']);

if shl.use_ice_concentrations
    f1='T';
else
    f1='F';
end
fprintf(fid,'%s\n',['   ' f1 '       Ice concentrations']);

if shl.use_assimilation_data_mean_parameters
    f1='T';
else
    f1='F';
end
fprintf(fid,'%s\n',['   ' f1 '       Assimilation data : Mean parameters']);

if shl.use_assimilation_data_1d_spectra
    f1='T';
else
    f1='F';
end
fprintf(fid,'%s\n',['   ' f1 '       Assimilation data : 1-D spectra']);

if shl.use_assimilation_data_2d_spectra
    f1='T';
else
    f1='F';
end
fprintf(fid,'%s\n',['   ' f1 '       Assimilation data : 2-D spectra.']);
fprintf(fid,'%s\n','$');


fprintf(fid,'%s\n','$ Time frame of calculations ----------------------------------------- $');
fprintf(fid,'%s\n','$ - Starting time in yyyymmdd hhmmss format.');
fprintf(fid,'%s\n','$ - Ending time in yyyymmdd hhmmss format.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.start_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n',['   ' datestr(shl.stop_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Define output data ------------------------------------------------- $');
fprintf(fid,'%s\n','$ ');
fprintf(fid,'%s\n','$ Define output server mode. This is used only in the parallel version');
fprintf(fid,'%s\n','$ of the model. To keep the input file consistent, it is always needed.');
fprintf(fid,'%s\n','$ IOSTYP = 1 is generally recommended. IOSTYP > 2 may be more efficient');
fprintf(fid,'%s\n','$ for massively parallel computations. Only IOSTYP = 0 requires a true');
fprintf(fid,'%s\n','$ parallel file system like GPFS.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ IOSTYP = 0 : No data server processes, direct access output from');
fprintf(fid,'%s\n','$ each process (requirese true parallel file system).');
fprintf(fid,'%s\n','$ 1 : No data server process. All output for each type');
fprintf(fid,'%s\n','$ performed by process that performes computations too.');
fprintf(fid,'%s\n','$ 2 : Last process is reserved for all output, and does no');
fprintf(fid,'%s\n','$ computing.');
fprintf(fid,'%s\n','$ 3 : Multiple dedicated output processes.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' num2str(shl.iostyp)]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Five output types are available (see below). All output types share');
fprintf(fid,'%s\n','$ a similar format for the first input line:');
fprintf(fid,'%s\n','$ - first time in yyyymmdd hhmmss format, output interval (s), and ');
fprintf(fid,'%s\n','$   last time in yyyymmdd hhmmss format (all integers).');
fprintf(fid,'%s\n','$ Output is disabled by setting the output interval to 0.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 1 : Fields of mean wave parameters');
fprintf(fid,'%s\n','$          Standard line and line with flags to activate output fields');
fprintf(fid,'%s\n','$          as defined in section 2.4 of the manual. The second line is');
fprintf(fid,'%s\n','$          not supplied if no output is requested.');
fprintf(fid,'%s\n','$                               The raw data file is out_grd.ww3, ');
fprintf(fid,'%s\n','$                               see w3iogo.ftn for additional doc.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.field_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.field_output.time_step) '  ' datestr(shl.field_output.stop_time,'yyyymmdd HHMMSS')]);
str='    ';
for ii=1:length(shl.field_output.flags)
    if shl.field_output.flags(ii)
        str=[str ' T'];
    else
        str=[str ' F'];
    end        
end
fprintf(fid,'%s\n',str);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 2 : Point output');
fprintf(fid,'%s\n','$          Standard line and a number of lines identifying the ');
fprintf(fid,'%s\n','$          longitude, latitude and name (C*10) of output points.');
fprintf(fid,'%s\n','$          The list is closed by defining a point with the name');
fprintf(fid,'%s\n','$          ''STOPSTRING''. No point info read if no point output is');
fprintf(fid,'%s\n','$          requested (i.e., no ''STOPSTRING'' needed).');
fprintf(fid,'%s\n','$          Example for spherical grid.');
fprintf(fid,'%s\n','$                               The raw data file is out_pnt.ww3, ');
fprintf(fid,'%s\n','$                               see w3iogo.ftn for additional doc.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$   NOTE : Spaces may be included in the name, but this is not');
fprintf(fid,'%s\n','$          advised, because it will break the GrADS utility to ');
fprintf(fid,'%s\n','$          plots spectra and source terms, and will make it more');
fprintf(fid,'%s\n','$          diffucult to use point names in data files.');
fprintf(fid,'%s\n','$');
if shl.point_output.nrpoints==0
    shl.point_output.time_step=0;
else
    if shl.point_output.time_step==0
        shl.point_output.time_step=3600;
        disp('Point output time step set to 3600!');
    end
end
fprintf(fid,'%s\n',['   ' datestr(shl.point_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.point_output.time_step) '  ' datestr(shl.point_output.stop_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$');
for ii=1:shl.point_output.nrpoints
    x=shl.point_output.points(ii).x;
    y=shl.point_output.points(ii).y;
    name=shl.point_output.points(ii).name;
    r=['''' name ''''];
    fprintf(fid,'%s\n',['     ' num2str(x,'%12.5f') ' ' num2str(y,'%12.5f') ' ' r]);
end
if shl.point_output.nrpoints>0
    fprintf(fid,'%s\n','     0.0   0.0  ''STOPSTRING'' ');
end
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 3 : Output along  track.');
fprintf(fid,'%s\n','$          Flag for formatted input file.');
fprintf(fid,'%s\n','$                         The data files are track_i.ww3 and');
fprintf(fid,'%s\n','$                         track_o.ww3, see w3iotr.ftn for ad. doc.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.track_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.track_output.time_step) '  ' datestr(shl.track_output.stop_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n','$     F');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 4 : Restart files (no additional data required).');
fprintf(fid,'%s\n','$                               The data file is restartN.ww3, see');
fprintf(fid,'%s\n','$                               w3iors.ftn for additional doc.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.restart_file_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.restart_file_output.time_step) '  ' datestr(shl.restart_file_output.stop_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 5 : Boundary data (no additional data required).');
fprintf(fid,'%s\n','$                               The data file is nestN.ww3, see');
fprintf(fid,'%s\n','$                               w3iobp.ftn for additional doc.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.boundary_data_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.boundary_data_output.time_step) '  ' datestr(shl.boundary_data_output.stop_time,'yyyymmdd HHMMSS')]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Type 6 : Separated wave field data (dummy for now).');
fprintf(fid,'%s\n','$          First, last step IX and IY, flag for formatted file');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['   ' datestr(shl.separated_wave_field_data_output.start_time,'yyyymmdd HHMMSS') '   ' num2str(shl.separated_wave_field_data_output.time_step) '  ' datestr(shl.separated_wave_field_data_output.stop_time,'yyyymmdd HHMMSS')]);

if shl.separated_wave_field_data_output.flag
    flag='T';
else
    flag='F';
end
str=['      ' num2str(shl.separated_wave_field_data_output.first_x) ' ' num2str(shl.separated_wave_field_data_output.last_x) ' ' num2str(shl.separated_wave_field_data_output.step_x) ... 
          ' ' num2str(shl.separated_wave_field_data_output.first_y) ' ' num2str(shl.separated_wave_field_data_output.last_y) ' ' num2str(shl.separated_wave_field_data_output.step_y) ... 
          ' ' flag];
      
fprintf(fid,'%s\n',str);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Testing of output through parameter list (C/TPAR) ------------------ $');
fprintf(fid,'%s\n','$    Time for output and field flags as in above output type 1.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$  19680606 014500');
fprintf(fid,'%s\n','$    T T T T T  T T T T T  T T T T T  T');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Homogeneous field data --------------------------------------------- $');
fprintf(fid,'%s\n','$ Homogeneous fields can be defined by a list of lines containing an ID');
fprintf(fid,'%s\n','$ string ''LEV'' ''CUR'' ''WND'', date and time information (yyyymmdd');
fprintf(fid,'%s\n','$ hhmmss), value (S.I. units), direction (current and wind, oceanographic');
fprintf(fid,'%s\n','$ convention degrees)) and air-sea temparature difference (degrees C).');
fprintf(fid,'%s\n','$ ''STP'' is mandatory stop string.');
fprintf(fid,'%s\n','$');

if shl.homogeneous_field_data.wnd.use
    tstr=datestr(shl.homogeneous_field_data.wnd.time,'yyyymmdd HHMMSS');
    vstr=num2str(shl.homogeneous_field_data.wnd.value);
    dstr=num2str(shl.homogeneous_field_data.wnd.direction);
    atstr=num2str(shl.homogeneous_field_data.wnd.air_sea_temperature_difference);
    str=['$   ''WND'' ' tstr vstr dstr atstr];
    fprintf(fid,'%s\n',str);
end

if shl.homogeneous_field_data.lev.use
    tstr=datestr(shl.homogeneous_field_data.lev.time,'yyyymmdd HHMMSS');
    vstr=num2str(shl.homogeneous_field_data.lev.value);
    str=['$   ''LEV'' ' tstr vstr];
    fprintf(fid,'%s\n',str);
end

if shl.homogeneous_field_data.cur.use
    tstr=datestr(shl.homogeneous_field_data.cur.time,'yyyymmdd HHMMSS');
    vstr=num2str(shl.homogeneous_field_data.cur.value);
    dstr=num2str(shl.homogeneous_field_data.cur.direction);
    str=['$   ''CUR'' ' tstr vstr dstr];
    fprintf(fid,'%s\n',str);
end

fprintf(fid,'%s\n','   ''STP''');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ End of input file                                                    $');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');

fclose(fid);

