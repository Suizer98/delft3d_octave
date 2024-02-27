function convert_spiderweb_coordinate_system(fnamein,fnameout,csin,csout)

if ~strcmpi(csin.name,csout.name) || ~strcmpi(csin.type,csout.type)
    INFO=asciiwind('open',fnamein);
    wind_speed=asciiwind('read',INFO,'wind_speed');
    wind_from_direction=asciiwind('read',INFO,'wind_from_direction');
    p_drop=asciiwind('read',INFO,'p_drop');
    for it=1:length(INFO.Data)
        x(it)=INFO.Data(it).x_spw_eye;
        y(it)=INFO.Data(it).y_spw_eye;
    end
    [x,y]=convertCoordinates(x,y,'CS1.name',csin.name,'CS1.type',csin.type,'CS2.name',csout.name,'CS2.type',csout.type);
    for it=1:length(INFO.Data)
        tc.track(it).time=INFO.Data(it).time;
        tc.track(it).x=x(it);
        tc.track(it).y=y(it);
        tc.track(it).wind_speed=squeeze(wind_speed(it,2:end,2:end))';
        tc.track(it).wind_from_direction=squeeze(wind_from_direction(it,2:end,2:end))';
        tc.track(it).pressure_drop=squeeze(p_drop(it,2:end,2:end))';        
    end
    switch lower(csout.type)
        case{'projected'}
            gridunit='m';
        otherwise
            gridunit='degree';
    end
    reftime=floor(INFO.Data(1).time);
    radius=INFO.Header.spw_radius;    
    write_spiderweb_file_delft3d(fnameout, tc, gridunit, reftime, radius);    
else
    copyfile(fnamein,fnameout);
end

