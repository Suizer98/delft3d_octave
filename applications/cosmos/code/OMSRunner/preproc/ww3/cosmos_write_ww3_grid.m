function cosmos_write_ww3_grid(inpfile,model,boundary_points_file,output_boundary_points_files,includeobstructions)

%% Initialize structure

ww3=ww3_initialize_grid_input;

% Name
ww3.name=model.longName;

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
ww3.maximum_cfl_timestep_x_y=model.timeStep;
ww3.maximum_cfl_timestep_k_theta=3600;
ww3.minimum_source_term_timestep=300;

% Inputs in name lists
ww3.namelist.SBT1.GAMMA=-0.038;
ww3.namelist.MISC.FLAGTR=0;
ww3.namelist.MISC.CICE0=0.33;
ww3.namelist.MISC.CICEN=0.67;

% Define grid
ww3.nx=model.nX;
ww3.ny=model.nY;
ww3.dx=model.dX;
ww3.dy=model.dY;
ww3.scaling_factor_dxdy=1;
ww3.x0=model.xOri;
ww3.y0=model.yOri;
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
if includeobstructions
    ww3.bottom_depth_filename=[model.name '.bot'];
    ww3.namelist.MISC.FLAGTR=4;
end

% Obstructions
ww3.obstructions_unit_number_file=12;
ww3.obstructions_scaling_factor=0.001;
ww3.obstructions_idla=1;
ww3.obstructions_idfm=1;
ww3.obstructions_format_for_formatted_read='(...)';
ww3.obstructions_from='NAME';
ww3.obstructions_filename=[model.name '.obs'];

% Input boundary points
ww3.status_map_unit_number_file=10;
ww3.status_map_idla=3;
ww3.status_map_idfm=1;
ww3.status_map_format_for_formatted_read='(....)';
ww3.status_map_from='PART';
ww3.status_map_filename='mapsta.inp';

% Input boundary points
ww3.boundary_points=[];
if exist(boundary_points_file,'file')
    n=0;
    fid=fopen(boundary_points_file,'r');
    while 1
        v=fgetl(fid);
        if v==-1
            break
        end
        v=textscan(v,'%f%f%s');
        ix=v{1};
        iy=v{2};
        flag=v{3};
        if ix==0 && iy==0 && strcmpi(flag,'f')
            break
        end
        n=n+1;
        ww3.boundary_points(n).ix=ix;
        ww3.boundary_points(n).iy=iy;
        switch lower(flag{1})
            case{'f'}
                ww3.boundary_points(n).flag=0;
            otherwise
                ww3.boundary_points(n).flag=1;
        end
    end
    fclose(fid);
end

% Excluded grid points
ww3.excluded_points=[];

% Points in a closed body of sea points to remove
% the entire body of sea points. Also close by point (0,0)
ww3.excluded_closed_bodies=[];

% Output boundary points
ww3.output_boundary_points=[];
for nf=1:length(output_boundary_points_files)
    s=load(output_boundary_points_files{nf});
    for n=1:size(s,1)
        ww3.output_boundary_points(nf).line(n).x0=s(n,1);
        ww3.output_boundary_points(nf).line(n).y0=s(n,2);
        ww3.output_boundary_points(nf).line(n).dx=s(n,3);
        ww3.output_boundary_points(nf).line(n).dy=s(n,4);
        ww3.output_boundary_points(nf).line(n).np=s(n,5);
    end
end

%% And write ww3_shel.inp

ww3_write_grid_inp(inpfile,ww3);
