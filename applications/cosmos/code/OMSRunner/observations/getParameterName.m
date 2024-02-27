function par=getParameterName(par,db)

switch db
    case{'ndbc'}
    case{'co-ops'}
        switch par
            case{'wl'}
                par='water level';
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
