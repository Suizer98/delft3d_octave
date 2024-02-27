function ww3_write_grid_inp(fname,grd)


fid=fopen(fname,'wt');



fprintf(fid,'%s\n','$ WAVEWATCH III Grid preprocessor input file');
fprintf(fid,'%s\n','$ -------------------------------------------');
fprintf(fid,'%s\n',['  ''' grd.name '''']);
fprintf(fid,'%s\n','$');
v=[grd.frequency_increment_factor grd.first_frequency grd.number_of_frequencies grd.number_of_directions grd.relative_offset_of_first_direction];
v=num2str(v);
fprintf(fid,'%s\n',v);
fprintf(fid,'%s\n','$');

str=' ';
if grd.dry_run
    str=[str ' T'];
else
    str=[str ' F'];
end
if grd.x_component_of_propagation
    str=[str ' T'];
else
    str=[str ' F'];
end
if grd.y_component_of_propagation
    str=[str ' T'];
else
    str=[str ' F'];
end
if grd.direction_shift
    str=[str ' T'];
else
    str=[str ' F'];
end
if grd.wavenumber_shift
    str=[str ' T'];
else
    str=[str ' F'];
end
if grd.source_terms
    str=[str ' T'];
else
    str=[str ' F'];
end
fprintf(fid,'%s\n',str); 
fprintf(fid,'%s\n','$');

v=[grd.maximum_global_timestep grd.maximum_cfl_timestep_x_y grd.maximum_cfl_timestep_k_theta grd.minimum_source_term_timestep];
v=num2str(v);

fprintf(fid,'%s\n',[' ' v]);
fprintf(fid,'%s\n','$');

fldnames1=fieldnames(grd.namelist);
for ii=1:length(fldnames1)
    fldname1=fldnames1{ii};
    str=['  &' fldname1];
    fldnames2=fieldnames(grd.namelist.(fldname1));    
    for jj=1:length(fldnames2)
        fldname2=fldnames2{jj};
        str=[str ' ' fldname2 ' = ' num2str(grd.namelist.(fldname1).(fldname2))];
        if jj==length(fldnames2)
            str=[str ' /'];
        else
            str=[str ','];
        end
    end
    fprintf(fid,'%s\n',str); 
end

fprintf(fid,'%s\n','END OF NAMELISTS');
fprintf(fid,'%s\n','$');

% Grid
v=[grd.nx grd.ny ];
v=num2str(v);
fprintf(fid,'%s\n',['  ' v]);

v=[grd.dx grd.dy grd.scaling_factor_dxdy];
v=num2str(v);
fprintf(fid,'%s\n',['  ' v]);

v=[grd.x0 grd.y0 grd.scaling_factor_x0y0];
v=num2str(v);
fprintf(fid,'%s\n',['  ' v]);

fprintf(fid,'%s\n','$');

% Bottom depth
v=['  ' num2str(grd.limiting_bottom_depth)];
v=[v '  ' num2str(grd.minimum_water_depth)];
v=[v '  ' num2str(grd.bottom_depth_unit_number_file)];
v=[v '  ' num2str(grd.bottom_depth_scaling_factor)];
v=[v '  ' num2str(grd.bottom_depth_idla)];
v=[v '  ' num2str(grd.bottom_depth_idfm)];
v=[v '  ''' grd.bottom_depth_format_for_formatted_read ''''];
v=[v '  ''' grd.bottom_depth_from ''''];
v=[v '  ''' grd.bottom_depth_filename ''''];
fprintf(fid,'%s\n',v);

% Obstructions
if  ~isempty(grd.obstructions_filename) && grd.namelist.MISC.FLAGTR>0
    v=['                ' num2str(grd.obstructions_unit_number_file)];
    v=[v '  ' num2str(grd.obstructions_scaling_factor)];
    v=[v '  ' num2str(grd.obstructions_idla)];
    v=[v '  ' num2str(grd.obstructions_idfm)];
    v=[v '  ''' grd.obstructions_format_for_formatted_read ''''];
    v=[v '  ''' grd.obstructions_from ''''];
    v=[v '  ''' grd.obstructions_filename ''''];
    fprintf(fid,'%s\n',v);
end

% Status map
v=['   ' num2str(grd.status_map_unit_number_file)];
v=[v '  ' num2str(grd.status_map_idla)];
v=[v '  ' num2str(grd.status_map_idfm)];
v=[v '  ''' grd.status_map_format_for_formatted_read ''''];
v=[v '  ''' grd.status_map_from ''''];
v=[v '  ''' grd.status_map_filename ''''];
fprintf(fid,'%s\n',v);

fprintf(fid,'%s\n','$');

% Boundary points
for ii=1:length(grd.boundary_points)
    if grd.boundary_points(ii).flag
        flag='T';
    else
        flag='F';
    end
    v=['      ' num2str(grd.boundary_points(ii).ix) '   ' num2str(grd.boundary_points(ii).iy) '   ' flag];
    fprintf(fid,'%s\n',v);    
end
fprintf(fid,'%s\n','      0   0   F');

% Excluded points
for ii=1:length(grd.excluded_points)
    if grd.excluded_points(ii).flag
        flag='T';
    else
        flag='F';
    end
    v=['      ' num2str(grd.excluded_points(ii).ix) '   ' num2str(grd.excluded_points(ii).iy) '   ' flag];
    fprintf(fid,'%s\n',v);    
end
fprintf(fid,'%s\n','      0   0   F');

% Excluded closed bodies
for ii=1:length(grd.excluded_closed_bodies)
    v=['      ' num2str(grd.excluded_closed_bodies(ii).ix) '   ' num2str(excluded_closed_bodies(ii).iy)];
    fprintf(fid,'%s\n',v);    
end
fprintf(fid,'%s\n','      0   0');

fprintf(fid,'%s\n','$');

% Output boundary points for nesting
for ii=1:length(grd.output_boundary_points)
    fprintf(fid,'%s\n',['$ Model boundary conditions - grid ' num2str(ii)]);
    for jj=1:length(grd.output_boundary_points(ii).line)
        x0=grd.output_boundary_points(ii).line(jj).x0;
        y0=grd.output_boundary_points(ii).line(jj).y0;
        dx=grd.output_boundary_points(ii).line(jj).dx;
        dy=grd.output_boundary_points(ii).line(jj).dy;
        np=grd.output_boundary_points(ii).line(jj).np;
        if jj==1 && ii~=1
            np=np*-1;
        end
        fprintf(fid,'%f %f %f %f %i\n',x0,y0,dx,dy,np);
    end
    fprintf(fid,'%s\n','$');
end
fprintf(fid,'%f %f %f %f %i\n',0,0,0,0,0);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ End of input file');

fclose(fid);

