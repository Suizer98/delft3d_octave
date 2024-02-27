function [refdate,tunit,tstart,tstop,hisstart,hisstop,mapstart,mapstop,hisint,mapint] = EHY_getTimeInfoFromMdFile(fileInp,modelType)
%% EHY_getTimeInfoFromMdFile(mdFile,modelType)
% refdate       : Reference date in MATLAB's datenum
% tunit         : Time unit of tstart and tstop (e.g. 'S' , 'M')
% tstart        : Start time of simulation w.r.t. refdate (in tunit)
% tstop         : Stop time of simulation w.r.t. refdate (in tunit)
% hisstart      : Start time of writing history output (in minutes)
% hisstop       : Stop time of writing history output (in minutes)
% mapstart      : Start time of writing map output (in minutes)
% mapstop       : Stop time of writing map output (in minutes)
% hisint        : interval of writing history output (in minutes)
% mapint        : interval of writing history output (in minutes)
% mdFile        : Master definition file (*.mdf, *.mdu, *siminp*)
% modelType	: Model type ('dfm','d3d','simona')
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

fileInp = EHY_getMdFile(fileInp);
if isempty(fileInp)
    error('No .mdu, .mdf or siminp found in this folder')
end
if ~exist('modelType','var')
    modelType = EHY_getModelType(fileInp);
    if isempty(modelType)
        error('Could not determine model type')
    end
end

switch modelType
    case 'dfm'
        mdu = dflowfm_io_mdu('read',fileInp);
        refdate = datenum(num2str(mdu.time.RefDate),'yyyymmdd');
        tunit = mdu.time.Tunit;
        % tstart
        if isfield(mdu.time,'TStart')
            tstart = mdu.time.TStart;
        elseif isfield(mdu.time,'Startdatetime') % yyyymmddHHMMSS
            tstart = (EHY_datenum(num2str(round(mdu.time.Startdatetime))) - refdate) * timeFactor('d',tunit); % Tunit from refDate
        else
            error('Could not find TStart or Startdatetime in .mdu')
        end
        
        % tstop
        if isfield(mdu.time,'TStop')
            tstop = mdu.time.TStop;
        elseif isfield(mdu.time,'Stopdatetime') % yyyymmddHHMMSS
            tstop  = (EHY_datenum(num2str(round(mdu.time.Stopdatetime ))) - refdate) * timeFactor('d',tunit); % Tunit from refDate
        else
            error('Could not find TStop or Stopdatetime in .mdu')
        end
        
        if length(mdu.output.HisInterval) == 0 % no his output
            
        elseif length(mdu.output.HisInterval) == 1 % only interval of his file
            hisint = mdu.output.HisInterval*timeFactor('S','M');
            hisstart = tstart;
            hisstop = tstop;
        else % his start stop, all in seconds
            hisint = mdu.output.HisInterval(1)*timeFactor('S','M');
            hisstart = mdu.output.HisInterval(2)*timeFactor('S','M');
            hisstop = mdu.output.HisInterval(3)*timeFactor('S','M');
        end
        if length(mdu.output.MapInterval) == 0 % no map output
        
        elseif length(mdu.output.MapInterval) == 1 % only interval of map file
            mapint = mdu.output.MapInterval*timeFactor('S','M');
            mapstart = tstart;
            mapstop = tstop;
        else % his start stop, all in seconds
            mapint = mdu.output.MapInterval(1)*timeFactor('S','M');
            mapstart = mdu.output.MapInterval(2)*timeFactor('S','M');
            mapstop = mdu.output.MapInterval(3)*timeFactor('S','M');
        end
    case 'd3d'
        mdf = delft3d_io_mdf('read',fileInp);
        refdate = datenum(mdf.keywords.itdate,'yyyy-mm-dd');
        tunit = mdf.keywords.tunit;
        tstart = mdf.keywords.tstart;
        tstop = mdf.keywords.tstop;
        hisstart = mdf.keywords.flhis(1);
        hisint = mdf.keywords.flhis(2);
        hisstop = mdf.keywords.flhis(3);
        mapstart = mdf.keywords.flmap(1);
        mapint = mdf.keywords.flmap(2);
        mapstop = mdf.keywords.flmap(3);
    case 'simona'
        [pathstr,name,ext] = fileparts(fileInp);
        siminp = readsiminp(pathstr,[name ext]);
        
        tunit = 'M';
        
        for var = {'date','tstart','tstop'}
            ind1 = find(~cellfun(@isempty,strfind(lower(siminp.File),var{1})));
            if length(ind1)>1; ind1 = ind1(1); end
            ind2 = regexp(lower(siminp.File{ind1}),var{1})+length(var{1});
            dmy = regexp(siminp.File{ind1}(ind2:end),'\s+','split');
            if strcmp(var{1},'date')
                refdate = datenum(strtrim(sprintf('%s ',dmy{2:4})));
            else
                eval([var{1} ' = str2double(dmy(2));'])
            end
        end
        
        vars = {'tfhis'   ,'tlhis'  ,'tfmap'   ,'tlmap'; ...
            'hisstart','hisstop','mapstart','mapstop'};
        for iVar = 1:length(vars)
            ind1 = find(~cellfun(@isempty,strfind(lower(siminp.File),vars{1,iVar})));
            if ~isempty(ind1)
                ind2 = regexp(lower(siminp.File{ind1}),vars{1,iVar})+length(vars{1,iVar});
                dmy = regexp(siminp.File{ind1}(ind2:end),'\s+','split');
                eval([vars{2,iVar} ' = str2double(dmy(2));'])
            else
                eval([vars{2,iVar} ' = t' vars{2,iVar}(4:end) ';'])
            end
        end
end



