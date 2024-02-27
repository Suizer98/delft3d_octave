function shl=ww3_read_shell_inp(fname,varargin)

if ~isempty(varargin)
    shl=varargin{1};
end

fid=fopen(fname,'r');

% $ Define input to be used with flag for use and flag for definition
% $ as a homogeneous field (first three only); seven input lines.
% $
%    F F     Water levels
%    F F     Currents
%    T F     Winds
%    F       Ice concentrations
%    F       Assimilation data : Mean parameters
%    F       Assimilation data : 1-D spectra
%    F       Assimilation data : 2-D spectra.

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_water_levels=0;
else
    shl.use_water_levels=1;
end
if strcmpi(v{2},'f')
    shl.uniform_water_levels=0;
else
    shl.uniform_water_levels=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_currents=0;
else
    shl.use_currents=1;
end
if strcmpi(v{2},'f')
    shl.uniform_currents=0;
else
    shl.uniform_currents=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_winds=0;
else
    shl.use_winds=1;
end
if strcmpi(v{2},'f')
    shl.uniform_winds=0;
else
    shl.uniform_winds=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_ice_concentrations=0;
else
    shl.use_ice_concentrations=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_assimilation_data_mean_parameters=0;
else
    shl.use_assimilation_data_mean_parameters=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_assimilation_data_1d_spectra=0;
else
    shl.use_assimilation_data_1d_spectra=1;
end

v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
if strcmpi(v{1},'f')
    shl.use_assimilation_data_2d_spectra=0;
else
    shl.use_assimilation_data_2d_spectra=1;
end

% $ Time frame of calculations ----------------------------------------- $
% $ - Starting time in yyyymmdd hhmmss format.
% $ - Ending time in yyyymmdd hhmmss format.
v=nextline(fid);
shl.start_time=datenum(v,'yyyymmdd HHMMSS');
v=nextline(fid);
shl.stop_time=datenum(v,'yyyymmdd HHMMSS');

% $ Define output data ------------------------------------------------- $
% $ 
% $ Define output server mode. This is used only in the parallel version
% $ of the model. To keep the input file consistent, it is always needed.
% $ IOSTYP = 1 is generally recommended. IOSTYP > 2 may be more efficient
% $ for massively parallel computations. Only IOSTYP = 0 requires a true
% $ parallel file system like GPFS.
% $
% $ IOSTYP = 0 : No data server processes, direct access output from
% $ each process (requirese true parallel file system).
% $ 1 : No data server process. All output for each type
% $ performed by process that performes computations too.
% $ 2 : Last process is reserved for all output, and does no
% $ computing.
% $ 3 : Multiple dedicated output processes.
shl.iostyp=str2double(nextline(fid));

% $ Five output types are available (see below). All output types share
% $ a similar format for the first input line:
% $ - first time in yyyymmdd hhmmss format, output interval (s), and 
% $   last time in yyyymmdd hhmmss format (all integers).
% $ Output is disabled by setting the output interval to 0.
% $
% $ Type 1 : Fields of mean wave parameters
% $          Standard line and line with flags to activate output fields
% $          as defined in section 2.4 of the manual. The second line is
% $          not supplied if no output is requested.
% $                               The raw data file is out_grd.ww3, 
% $                               see w3iogo.ftn for additional doc.
v=textscan(nextline(fid),'%s');
v=v{1};
shl.field_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.field_output.time_step=str2double(v{3});
shl.field_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');
if shl.field_output.time_step>0
    v=textscan(nextline(fid),'%s');
    v=v{1};
    for ii=1:length(v)
        if strcmpi(v{ii},'f')
            shl.field_output.flags(ii)=0;
        else
            shl.field_output.flags(ii)=1;
        end
    end
else
    shl.field_output.flags=zeros(1,31);
end

% $ Type 2 : Point output
% $          Standard line and a number of lines identifying the 
% $          longitude, latitude and name (C*10) of output points.
% $          The list is closed by defining a point with the name
% $          'STOPSTRING'. No point info read if no point output is
% $          requested (i.e., no 'STOPSTRING' needed).
% $          Example for spherical grid.
% $                               The raw data file is out_pnt.ww3, 
% $                               see w3iogo.ftn for additional doc.
% $
% $   NOTE : Spaces may be included in the name, but this is not
% $          advised, because it will break the GrADS utility to 
% $          plots spectra and source terms, and will make it more
% $          diffucult to use point names in data files.
v=textscan(nextline(fid),'%s');
v=v{1};
shl.point_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.point_output.time_step=str2double(v{3});
shl.point_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');
shl.point_output.points=[];
shl.point_output.point_names={''};
if shl.point_output.time_step>0
    n=0;
    while 1
        str=nextline(fid);
%        v=textscan(str,'%f%f%s');
        v=textscan(str,'%s','delimiter','''');
        v=v{1};
        vxy=textscan(v{1},'%s');
        vxy=vxy{1};
        x=str2double(vxy{1});
        y=str2double(vxy{2});
        name=v{2};
        if x==0 && y==0 && strcmpi(name,'stopstring')
            break
        end
        n=n+1;
        shl.point_output.points(n).name=name;
        shl.point_output.points(n).x=x;
        shl.point_output.points(n).y=y;
    end
end
shl.point_output.nrpoints=length(shl.point_output.points);
for ii=1:shl.point_output.nrpoints
    shl.point_output.point_names{ii}=shl.point_output.points(ii).name;
end

% $ Type 3 : Output along  track.
% $          Flag for formatted input file.
% $                         The data files are track_i.ww3 and
% $                         track_o.ww3, see w3iotr.ftn for ad. doc.
% $
v=textscan(nextline(fid),'%s');
v=v{1};
shl.track_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.track_output.time_step=str2double(v{3});
shl.track_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');

% $ Type 4 : Restart files (no additional data required).
% $                               The data file is restartN.ww3, see
% $                               w3iors.ftn for additional doc.
v=textscan(nextline(fid),'%s');
v=v{1};
shl.restart_file_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.restart_file_output.time_step=str2double(v{3});
shl.restart_file_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');

% $ Type 5 : Boundary data (no additional data required).
% $                               The data file is nestN.ww3, see
% $                               w3iobp.ftn for additional doc.
v=textscan(nextline(fid),'%s');
v=v{1};
shl.boundary_data_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.boundary_data_output.time_step=str2double(v{3});
shl.boundary_data_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');

% $ Type 6 : Separated wave field data (dummy for now).
% $          First, last step IX and IY, flag for formatted file
v=textscan(nextline(fid),'%s');
v=v{1};
shl.separated_wave_field_data_output.start_time=datenum([v{1} ' ' v{2}],'yyyymmdd HHMMSS');
shl.separated_wave_field_data_output.time_step=str2double(v{3});
shl.separated_wave_field_data_output.stop_time=datenum([v{4} ' ' v{5}],'yyyymmdd HHMMSS');
v=textscan(nextline(fid),'%s');
v=v{1};
shl.separated_wave_field_data_output.first_x=str2double(v{1});
shl.separated_wave_field_data_output.last_x=str2double(v{2});
shl.separated_wave_field_data_output.step_x=str2double(v{3});
shl.separated_wave_field_data_output.first_y=str2double(v{4});
shl.separated_wave_field_data_output.last_y=str2double(v{5});
shl.separated_wave_field_data_output.step_y=str2double(v{6});
if strcmpi(v{7},'f')
    shl.separated_wave_field_data_output.flag=0;
else
    shl.separated_wave_field_data_output.flag=1;
end

% $ Homogeneous field data --------------------------------------------- $
% $ Homogeneous fields can be defined by a list of lines containing an ID
% $ string 'LEV' 'CUR' 'WND', date and time information (yyyymmdd
% $ hhmmss), value (S.I. units), direction (current and wind, oceanographic
% $ convention degrees)) and air-sea temparature difference (degrees C).
% $ 'STP' is mandatory stop string.
% $
% $   'WND' 19680606 000000    10.0    20.0    20.0
% $   'LEV' 19680606 000000    0.0
% $   'CUR' 19680606 000000    0.0    0.0

% Set defaults
shl.homogeneous_field_data.wnd.use=0;
shl.homogeneous_field_data.wnd.time=floor(now);
shl.homogeneous_field_data.wnd.value=0;
shl.homogeneous_field_data.wnd.direction=0;
shl.homogeneous_field_data.wnd.air_sea_temperature_difference=0;

shl.homogeneous_field_data.lev.use=0;
shl.homogeneous_field_data.lev.time=floor(now);
shl.homogeneous_field_data.lev.value=0;

shl.homogeneous_field_data.cur.use=0;
shl.homogeneous_field_data.cur.time=floor(now);
shl.homogeneous_field_data.cur.value=0;
shl.homogeneous_field_data.cur.direction=0;

while 1
    v=textscan(nextline(fid),'%s');
    v=v{1};
    par=v{1}(2:end-1);
    if strcmpi(par,'stp')
        break
    end
    switch lower(par)
        case{'wnd'}
            shl.homogeneous_field_data.wnd.use=1;
            shl.homogeneous_field_data.wnd.time=datenum([v{2} ' ' v{3}],'yyyymmdd HHMMSS');
            shl.homogeneous_field_data.wnd.value=str2double(v{4});
            shl.homogeneous_field_data.wnd.direction=str2double(v{5});
            shl.homogeneous_field_data.wnd.air_sea_temperature_difference=str2double(v{6});
        case{'lev'}
            shl.homogeneous_field_data.lev.use=1;
            shl.homogeneous_field_data.lev.time=datenum([v{2} ' ' v{3}],'yyyymmdd HHMMSS');
            shl.homogeneous_field_data.lev.value=str2double(v{4});
        case{'cur'}
            shl.homogeneous_field_data.cur.use=1;
            shl.homogeneous_field_data.cur.time=datenum([v{2} ' ' v{3}],'yyyymmdd HHMMSS');
            shl.homogeneous_field_data.cur.value=str2double(v{4});
            shl.homogeneous_field_data.cur.direction=str2double(v{5});
    end
end

fclose(fid);

%%
function s=nextline(fid)

while 1
    s=fgetl(fid);
    s=deblank2(s);
    if isempty(s)
        % Skip empty line
        continue
    end
    if s(1)=='$'
        % Skip comment line
        continue
    end
    break
end
