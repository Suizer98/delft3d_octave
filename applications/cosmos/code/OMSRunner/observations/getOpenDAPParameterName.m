function par=getOpenDAPParameterName(par,db)

switch db
    case{'ndbc'}
        switch par
            case{'hs'}
                par='wave_height';
            case{'tp'}
                par='dominant_wpd';
            case{'wavdir'}
                par='mean_wave_dir';
            case{'wndspeed'}
                par='wind_spd';
            case{'wnddir'}
                par='wind_dir';
            case{'airp'}
                par='air_pressure';
            case{'surftemp'}
                par='sea_surface_temperature';
        end                
    case{'co-ops'}
        switch par
            case{'wl'}
        end
    case{'matroos'}
        switch par
            case{'wl'}
                par='waterlevel';
            case{'hs'}
                par='wave_height_hm0';
            case{'tp'}
                par='wave_period_tp';
            case{'wnddir'}
                par='wind_direction';
            case{'wndspeed'}
                par='wind_speed';
        end
end
