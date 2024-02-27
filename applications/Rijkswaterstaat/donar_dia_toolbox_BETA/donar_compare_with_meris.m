function compare_donar_meris(the_donar_files,the_meris_files,the_grid_file,variable)
%donar_compare_with_meris    compare DONAR dia data and MERIS

    thefontsize = 8;
    thegrid = delwaq('open',the_grid_file);
    

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Do it for every file %
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 1:1:length(the_donar_files)
        
        if strfind(lower(the_donar_files{i}),'ctd'),          sensor_name = 'CTD'; 
        elseif strfind(lower(the_donar_files{i}),'ferry'),    sensor_name = 'Ferrybox';
        elseif strfind(lower(the_donar_files{i}),'meetvis'),  sensor_name = 'Meetvis';
        end

%->
        disp(['Loading: ',the_donar_files{i}]);
        thecompend = importdata(the_donar_files{i});
             
        % Check if the variable of interest is in the file
        allfields = fields(thecompend);
        thefield = allfields(strcmpi(allfields,variable));
        if isempty(thefield)
            disp('Parameter not found in file.')
            return;    
        end
        disp(['Looking for values of ',variable]);




%->     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get the segment numbers for the donar data %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Getting the segment numbers')
        [the_segnr,x,y] = delwaq_xy2segnr(thegrid,thecompend.(variable).data(:,1),thecompend.(variable).data(:,2),'ll');            
        unique_segnrs = unique(the_segnr);

        
        
        
% ->    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Organize the information by day and segment number %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        the_day = fix(thecompend.(variable).data(:,4));
        [unique_days,~,days_index] = unique(the_day);
        numdays = length(unique_days);

        
        current_year = -1;
        
        % Number of measured days in the sensor.
        for iday = 1:1:numdays
            disp(['Analyzing day: ',num2str(iday),' of ',num2str(numdays)]);
            
            [unique_segnrs,~,segnrs_index] = unique(the_segnr( days_index == iday ));
            
            % Open the MERIS file for the corresponding year, only open
            % another meris file if the year changed no?
            if year(unique_days(iday) + thecompend.(variable).referenceDate) ~= current_year
                current_year = year(unique_days(iday) + thecompend.(variable).referenceDate);
                disp(['Opening meris file for year: ', num2str(current_year)]);
                struct = delwaq('open',the_meris_files{~cellfun('isempty',strfind(the_meris_files,num2str(current_year)))});
            end

            
            cont = 1;
            % Check segment by segment.
            for iseg = unique_segnrs',              
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Gather the meris information %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [time data] = delwaq('read',struct,delwaq_subsname2index(struct,'TIM'),iseg,0);
                
                
                time = fix(time(~isnan(data)));
                data = data(~isnan(data));
                
                if ~isempty(find(   time == (unique_days(iday) + thecompend.(variable).referenceDate)    ))
                    
                    % The form of daySegObs = {day_datenum segnr mean(obs)]}
                    donar_daySegObs(cont,1) = unique_days(iday) + thecompend.(variable).referenceDate;
                    donar_daySegObs(cont,2) = iseg;
                    
                    la_informacion          = thecompend.(variable).data(the_day == unique_days(iday) & the_segnr == iseg,:);
                    donar_daySegObs(cont,3) = mean(la_informacion(la_informacion(:,3)<400,5));
                    donar_daySegObs(cont,4) = mean(  data(time == donar_daySegObs(cont,1))  );
                    
                    
                    cont = cont + 1;
                else
                    disp(['No MERIS-information available for day: ', datestr(unique_days(iday) + thecompend.(variable).referenceDate) ,' on segment: ',num2str(iseg)])
                end
            end
            
            if iday == numdays
                disp('now')
            end
        end
        disp(['donar_meris_',sensor_name,'_',num2str(current_year),'_',variable,'.mat']);
        save(['donar_meris_',sensor_name,'_',num2str(current_year),'_',variable,'.mat'],'donar_daySegObs');
        
        clear donar_daySegObs
    end
end