function [datenums,varargout] = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile,displ,varargin)

%%
OPT.SDS_his_or_map = 'his'; % When requesting times from a SIMONA SDS, we need to take format (his/map) into account
OPT = setproperty(OPT,varargin);

%%
modelType = EHY_getModelType(inputFile);

if ~exist('displ','var')
    if EHY_isSFINCS(inputFile)
        displ = 0;
    else
        displ = 1;
    end
end

switch modelType
    case {'dfm','SFINCS','nc'}
        
        % First, reconstruct the time series
        if nc_isvar(inputFile,'time')
            timeVar = 'time';
        elseif nc_isvar(inputFile,'TIME')
            timeVar = 'TIME';
        elseif nc_isvar(inputFile,'nmesh2d_dlwq_time')
            timeVar = 'nmesh2d_dlwq_time';
        end
        infonc = ncinfo(inputFile, timeVar);
        no_times = infonc.Size;
        
        if no_times < 4 
            time = ncread(inputFile, timeVar); 
        else % - to enhance speed, reconstruct time array from start time, numel and interval
            time_begin = ncread(inputFile, timeVar, 1, 3);
            time_end = ncread(inputFile, timeVar, no_times-2, 3);
            
            interval = diff(time_begin(2:3));
            if ~strcmp(infonc.Datatype,'double')
                time_begin = double(time_begin);
                time_end   = double(time_end);
                interval   = double(interval);
            end
            time = [time_begin(1) time_begin(2) + interval*[0:no_times-2] ]';
            time(end) = time_end(end); % overwrite, end time could be different when interval is specified
            
            % For netCDF-files with random interval and Delft3D FM output with
            % e.g. MapOutputTimeVector = 1 or output times not being a multiple
            % of DtUser, it is not possible to reconstruct the timeseries.
            %
            % Check if reconstructed timeseries matches with original data,
            % otherwise just read from file
            if abs(time(end-2)-time_end(1)) > eps
                if displ
                    disp('Time could not be reconstructed, so it''s read from file')
                end
                time = ncread(inputFile, timeVar);
            end
        end
        
        % read time unit and reference date (itdate) from netCDF
        time = double(time);
        AttrInd       = strmatch('units',{infonc.Attributes.Name},'exact');
        [tUnit,since] = strtok(infonc.Attributes(AttrInd).Value,' ');
        days          = time * timeFactor(tUnit,'days'); % from tUnit to days
        itdate        = EHY_datenum(strtrim(strrep(since,'since','')));
        datenums      = itdate + days;
        varargout{1}  = itdate; % in MATLABs datenum
        
    case 'd3d'
        if ~isempty(strfind(inputFile,'mdf'))
            % mdf file
            mdFile=EHY_getMdFile(inputFile);
            [~,name] = fileparts(inputFile);
            [refdate,tunit,tstart,tstop,hisstart,hisstop,mapstart,mapstop,hisint,mapint]=EHY_getTimeInfoFromMdFile(mdFile,modelType);
            if strcmp(name(1:4),'trih')
                datenums = refdate+(hisstart:hisint:hisstop)/1440;
            elseif strcmp(name(1:4),'trim')
                datenums = refdate+(mapstart:mapint:mapstop)/1440;
            end
        elseif ~isempty(strfind(inputFile,'trih'))
            % history output file from simulation
            trih         = qpfopen(inputFile);
            datenums     = qpread(trih,'water level','times');
            datenums     = datenums([true;diff(datenums)>0]); %JV: delete invalid time steps in unfinished D3D simulation
            itdate       = vs_let(trih,'his-const','ITDATE','quiet');
            varargout{1} = datenum([num2str(itdate(1),'%8.8i') '  ' num2str(itdate(2),'%6.6i')], 'yyyymmdd  HHMMSS');   
        elseif ~isempty(strfind(inputFile,'trim'))
            % history output file from simulation
            trim     = qpfopen(inputFile);
            datenums = qpread(trim,'water level','times');
        end
        
    case 'simona'
        sds = qpfopen(inputFile); 
        if strcmpi(OPT.SDS_his_or_map,'his')
            fields     = qpread   (sds    ,1    ); 
            fieldnames = transpose({fields.Name});

            datenums_wl = []; datenums_vel = [];
            if find(contains(fieldnames,'water level (station)')) datenums_wl  = qpread(sds,1,'water level (station)','times'); end
            if find(contains(fieldnames,'velocity (station)'   )) datenums_vel = qpread(sds,1,'velocity (station)'   ,'times'); end
            
            if length(datenums_wl) < length(datenums_vel)
                datenums = datenums_vel;
            else
                datenums = datenums_wl;
            end
        else
            datenums = qpread(sds,1,'water level','times');
        end
        varargout{1} = waquaio(sds,'','refdate');
        
    case 'sobek3' 
        D        = read_sobeknc(inputFile);
        refdate  = ncreadatt(inputFile, 'time','units');
        datenums = D.time/1000./1440./60. + datenum(refdate(20:end),'yyyy-mm-dd');
    case 'sobek3_new'
        D        = read_sobeknc(inputFile);
        refdate  = ncreadatt(inputFile, 'time','units');
        datenums = D.time/1440./60. + datenum(refdate(15:end),'yyyy-mm-dd  HH:MM:SS');
        
    case 'implic'
        if exist([inputFile filesep 'implic.mat'],'file')
            load([inputFile filesep 'implic.mat']);
            datenums = tmp.times;
        else
            months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
            fileName = [inputFile filesep 'BDSL.dat'];
            fid      = fopen(fileName,'r');
            line     = fgetl(fid);
            line     = fgetl(fid);
            line     = fgetl(fid);
            i_time   = 0;
            while ~feof(fid)
                i_time             = i_time + 1;
                line               = fgetl(fid);
                i_day              = str2num(line(1:2));
                i_month            = find(~cellfun(@isempty,strfind(months,line(4:6))));
                i_year             = str2num(line( 8:11));
                i_hour             = str2num(line(13:14));
                i_min              = str2num(line(16:17));
                datenums (i_time)  = datenum(i_year,i_month,i_day,i_hour,i_min,0);
            end
            
            fclose(fid);
            
        end
        
    case 'waqua_scaloost'      
        months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
        fileName = [strrep(inputFile,'**stationName**','BDSL') '.dat'];
        fid      = fopen(fileName,'r');
        line     = fgetl(fid);
        line     = fgetl(fid);
        line     = fgetl(fid);
        i_time   = 0;
        while ~feof(fid)
            i_time             = i_time + 1;
            line               = fgetl(fid);
            i_day              = str2num(line(1:2));
            i_month            = find(~cellfun(@isempty,strfind(months,line(4:6))));
            i_year             = str2num(line( 8:11));
            i_hour             = str2num(line(13:14));
            i_min              = str2num(line(16:17));
            datenums (i_time)  = datenum(i_year,i_month,i_day,i_hour,i_min,0);
        end
        fclose(fid);
        
    case 'delwaq'
        dw = delwaq('open',inputFile);
        datenums = delwaq('read',dw,dw.SubsName{1},1,0);
end
