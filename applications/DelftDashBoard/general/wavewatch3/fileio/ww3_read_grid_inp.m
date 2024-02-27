function grd=ww3_read_grid_inp(fname,varargin)

if ~isempty(varargin)
    grd=varargin{1};
end

fid=fopen(fname,'r');

% Name of grid
grd.name=nextline(fid);
grd.name=grd.name(2:end-1);

% Spectral data
% $ Frequency increment factor and first frequency (Hz) ---------------- $
% $ number of frequencies (wavenumbers) and directions, relative offset
% $ of first direction in terms of the directional increment [-0.5,0.5].
% $ In versions 1.18 and 2.22 of the model this value was by definiton 0,
% $ it is added to mitigate the GSE for a first order scheme. Note that
% $ this factor is IGNORED in the print plots in ww3_outp.v=str2num(nextline(fid));
v=str2num(nextline(fid));
grd.frequency_increment_factor=v(1);
grd.first_frequency=v(2);
grd.number_of_frequencies=v(3);
grd.number_of_directions=v(4);
grd.relative_offset_of_first_direction=v(5);

% Set model flags
% $ - FLDRY Dry run (input/output only, no calculation).
% $ - FLCX, FLCY Activate X and Y component of propagation.
% $ - FLCTH, FLCK Activate direction and wavenumber shifts.
% $ - FLSOU Activate source terms.
v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
switch lower(v{1})
    case{'f'}
        grd.dry_run=0;
    otherwise
        grd.dry_run=1;
end
switch lower(v{2})
    case{'f'}
        grd.x_component_of_propagation=0;
    otherwise
        grd.x_component_of_propagation=1;
end
switch lower(v{3})
    case{'f'}
        grd.y_component_of_propagation=0;
    otherwise
        grd.y_component_of_propagation=1;
end
switch lower(v{4})
    case{'f'}
        grd.direction_shift=0;
    otherwise
        grd.direction_shift=1;
end
switch lower(v{5})
    case{'f'}
        grd.wavenumber_shift=0;
    otherwise
        grd.wavenumber_shift=1;
end
switch lower(v{6})
    case{'f'}
        grd.source_terms=0;
    otherwise
        grd.source_terms=1;
end

% $ - Time step information (this information is always read)
% $ maximum global time step, maximum CFL time step for x-y and
% $ k-theta, minimum source term time step (all in seconds).
v=str2num(nextline(fid));
grd.maximum_global_timestep=v(1);
grd.maximum_cfl_timestep_x_y=v(2);
grd.maximum_cfl_timestep_k_theta=v(3);
grd.minimum_source_term_timestep=v(4);

% Inputs in name lists (skip these for now)
n=0;
while 1
    v=nextline(fid);
    if strcmpi(v,'end of namelists')
        break
    end
    n=n+1;
    v=textscan(v,'%s','delimiter',',');
    v=v{1};
    for k=1:length(v)
        vv=textscan(v{k},'%s');
        vv=vv{1};
        if k==1
            name=vv{1}(2:end);
            par=vv{2};
            val=str2double(vv{4});
        else
            par=vv{1};
            val=str2double(vv{3});
        end        
        grd.namelist.(name).(par)=val;
    end
end


% $ Define grid -------------------------------------------------------- $
% $ Four records containing :
% $ 1 NX, NY. As the outer grid lines are always defined as land
% $ points, the minimum size is 3x3.
% $ 2 Grid increments SX, SY (degr.or m) and scaling (division) factor.
% $ If NX*SX = 360., latitudinal closure is applied.
% $ 3 Coordinates of (1,1) (degr.) and scaling (division) factor.
% $ 4 Limiting bottom depth (m) to discriminate between land and sea
% $ points, minimum water depth (m) as allowed in model, unit number
% $ of file with bottom depths, scale factor for bottom depths (mult.),
% $ IDLA, IDFM, format for formatted read, FROM and filename.
% $ IDLA : Layout indicator :
% $ 1 : Read line-by-line bottom to top.
% $ 2 : Like 1, single read statement.
% $ 3 : Read line-by-line top to bottom.
% $ 4 : Like 3, single read statement.
% $ IDFM : format indicator :
% $ 1 : Free format.
% $ 2 : Fixed format with above format descriptor.
% $ 3 : Unformatted.
% $ FROM : file type parameter
% $ 'UNIT' : open file by unit number only.
% $ 'NAME' : open file by name and assign to unit.
v=str2num(nextline(fid));
grd.nx=v(1);
grd.ny=v(2);
v=str2num(nextline(fid));
grd.dx=v(1);
grd.dy=v(2);
grd.scaling_factor_dxdy=v(3);
v=str2num(nextline(fid));
grd.x0=v(1);
grd.y0=v(2);
grd.scaling_factor_x0y0=v(3);
v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
grd.limiting_bottom_depth=str2double(v{1});
grd.minimum_water_depth=str2double(v{2});
grd.bottom_depth_unit_number_file=str2double(v{3});
grd.bottom_depth_scaling_factor=str2double(v{4});
grd.bottom_depth_idla=str2double(v{5});
grd.bottom_depth_idfm=str2double(v{6});
grd.bottom_depth_format_for_formatted_read=v{7}(2:end-1);
grd.bottom_depth_from=v{8}(2:end-1);
grd.bottom_depth_filename=v{9}(2:end-1);

% $ If sub-grid information is available as indicated by FLAGTR above,
% $ additional input to define this is needed below. In such cases a
% $ field of fractional obstructions at or between grid points needs to
% $ be supplied. First the location and format of the data is defined
% $ by (as above) :
% $ - Unit number of file (can be 10, and/or identical to bottem depth
% $ unit), scale factor for fractional obstruction, IDLA, IDFM,
% $ format for formatted read, FROM and filename

iok=0;
% Check if obstructions need to be read
if isfield(grd.namelist,'MISC')
    if isfield(grd.namelist.MISC,'FLAGTR')
        if grd.namelist.MISC.FLAGTR>0
            iok=1;
        end
    end
end
if iok
    v=nextline(fid);
    v=textscan(v,'%s');
    v=v{1};
    grd.obstructions_unit_number_file=str2double(v{1});
    grd.obstructions_scaling_factor=str2double(v{2});
    grd.obstructions_idla=str2double(v{3});
    grd.obstructions_idfm=str2double(v{4});
    grd.obstructions_format_for_formatted_read=v{5}(2:end-1);
    grd.obstructions_from=v{6}(2:end-1);
    grd.obstructions_filename=v{7}(2:end-1);
end

% $ Input boundary points and excluded points -------------------------- $
% $ The first line identifies where to get the map data, by unit number
% $ IDLA and IDFM, format for formatted read, FROM and filename
% $ if FROM = 'PART', then segmented data is read from below, else
% $ the data is read from file as with the other inputs (as INTEGER)
v=nextline(fid);
v=textscan(v,'%s');
v=v{1};
grd.status_map_unit_number_file=str2double(v{1});
grd.status_map_idla=str2double(v{2});
grd.status_map_idfm=str2double(v{3});
grd.status_map_format_for_formatted_read=v{4}(2:end-1);
grd.status_map_from=v{5}(2:end-1);
grd.status_map_filename=v{6}(2:end-1);

% $ Input boundary points from segment data ( FROM = PART ) ------------ $
% $ An unlimited number of lines identifying points at which input
% $ boundary conditions are to be defined. If the actual input data is
% $ not defined in the actual wave model run, the initial conditions
% $ will be applied as constant boundary conditions. Each line contains:
% $ Discrete grid counters (IX,IY) of the active point and a
% $ connect flag. If this flag is true, and the present and previous
% $ point are on a grid line or diagonal, all intermediate points
% $ are also defined as boundary points.
n=0;
grd.boundary_points=[];
while 1
    v=nextline(fid);
    v=textscan(v,'%f%f%s');
    ix=v{1};
    iy=v{2};
    flag=v{3};
    if ix==0 && iy==0 && strcmpi(flag,'f')
        break
    end
    n=n+1;
    grd.boundary_points(n).ix=ix;
    grd.boundary_points(n).iy=iy;
    switch lower(flag{1})
        case{'f'}
            grd.boundary_points(n).flag=0;
        otherwise
            grd.boundary_points(n).flag=1;
    end
end

% $ Excluded grid points from segment data ( FROM != PART )
% $ First defined as lines, identical to the definition of the input
% $ boundary points, and closed the same way.
n=0;
grd.excluded_points=[];
while 1
    v=nextline(fid);
    v=textscan(v,'%f%f%s');
    ix=v{1};
    iy=v{2};
    flag=v{3};
    if ix==0 && iy==0 && strcmpi(flag,'f')
        break
    end
    n=n+1;
    grd.excluded_points(n).ix=ix;
    grd.excluded_points(n).iy=iy;
    grd.excluded_points(n).flag=flag;
end

% $ Second, define a point in a closed body of sea points to remove
% $ the entire body of sea points. Also close by point (0,0)
n=0;
grd.excluded_closed_bodies=[];
while 1
    v=nextline(fid);
    v=textscan(v,'%f%f');
    ix=v{1};
    iy=v{2};
    if ix==0 && iy==0
        break
    end
    n=n+1;
    grd.excluded_closed_bodies(n).ix=ix;
    grd.excluded_closed_bodies(n).iy=iy;
end

% $ Output boundary points --------------------------------------------- $
% $ Output boundary points are defined as a number of straight lines,
% $ defined by its starting point (X0,Y0), increments (DX,DY) and number
% $ of points. A negative number of points starts a new output file.
% $ Note that this data is only generated if requested by the actual
% $ program. Example again for spherical grid in degrees. Note, these do
% $ not need to be defined for data transfer between grids in te multi
% $ grid driver.
nf=1;
n=0;
grd.output_boundary_points=[];
while 1
    v=nextline(fid);
    v=str2num(v);
    x0=v(1);
    y0=v(2);
    dx=v(3);
    dy=v(4);
    np=v(5);
    if sum(v)==0
        break
    end
    if np<0
        % New file
        nf=nf+1;
        n=0;
        np=np*-1;
    end    
    n=n+1;
    grd.output_boundary_points(nf).line(n).x0=x0;
    grd.output_boundary_points(nf).line(n).y0=y0;
    grd.output_boundary_points(nf).line(n).dx=dx;
    grd.output_boundary_points(nf).line(n).dy=dy;
    grd.output_boundary_points(nf).line(n).np=np;
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
