function [maximumvalue, maximumtime] = gethighwater(time, value, period)

    %nieuwe methode: zoek lokaal maximum met een zoekwindow van xx dagen.
    %Doe daarna een stap van x dagen vanaf het maximum en ga weer
    %zoeken naar het nieuwe maximum.

    maximumvalue(1:length(value)) = NaN;
    maximumtime (1:length(value)) = NaN;

    if ~isempty(time)

        window      = period / 2; %days
        daten_start = time(1);
        count       = 0;

        while 1

            count               = count + 1;

            if count == 1
                start_tmp           = daten_start;
                stop_tmp            = daten_start + period;
            else
                start_tmp           = max(time(1)  , daten_start) - window;
                stop_tmp            = min(time(end), daten_start) + window;
            end

            % search for high water
            value_tmp           = value(time >= start_tmp & time <= stop_tmp);
            time_tmp            =  time(time >= start_tmp & time <= stop_tmp);

            %determine maximum level
            if sum(isnan(value_tmp))/length(value_tmp) < eps('single')
%             if sum(isnan(value_tmp))/length(value_tmp) < 0.5
                maximumvalue(count) = max(value_tmp);
            else
                maximumvalue(count) = NaN;
            end

            %determine time of maximum level
            if ~isnan(maximumvalue(count))
                maximumtime(count)  = time_tmp(find(abs(value_tmp - maximumvalue(count)) < eps('double'), 1, 'first'));
            else
%                 if count == 1
                    maximumtime(count)  = daten_start;
%                 else
%                     maximumtime(count)  = maximumtime(count-1) + period;
%                 end
            end

    %         figure(1)
    %         plot(time_tmp,value_tmp);
    %         hold on;
    %         scatter(maximumtime(count),maximumvalue(count),'r');
    %         close all

            daten_start = maximumtime(count) + period;

            if daten_start > time(end)
                break
            end

        end

    else

        maximumvalue        = [];
        maximumtime         = [];

    end
