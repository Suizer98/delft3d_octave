function [datStruc, datStruc2] = nwi_usgs_read2(SiteNo,tstart,tend,ParCode,Dir)
% Read data from USGS NWI data system
% SiteNo is parameter
% tstart en tend is time
% ParCode is stationcode
% Dir is output dir

%% Make sure time is defined as string
if ~isnumeric(tstart)
    tstart = num2str(tstart);
end

if isnumeric(tend)
    tend = num2str(tend);
end

if isnumeric(SiteNo)
    SiteNo = num2str(SiteNo);
end

if iscell(ParCode)
    Pars = [ParCode{1}];
    for i = 2:length(ParCode)
        Pars = [Pars '&' ParCode{i}];
    end
else
    Pars = [ParCode];
end

%% Download data
prepart = 'https://nwis.waterdata.usgs.gov/ca/nwis/uv/?cb_';
urlwant = [prepart, Pars, '=on&format=rdb&site_no=', SiteNo, '&period=&begin_date=', tstart, '&end_date=', tend];
urlout  = [Dir 'nwi_usgs_data_' SiteNo, '_', Pars, '_', tstart '_' tend '.txt'];
if exist(urlout) ~= 2
    tmp     = urlwrite(urlwant,[Dir 'nwi_usgs_data_' SiteNo, '_', Pars, '_', tstart '_' tend '.txt']);
else
    tmp     = urlout;
end

%% Read in the data
cmnt = 1;
lno = 0;
fid = fopen(tmp);
while cmnt == 1
    lno = lno + 1;
    if lno == 16
    end
    str{lno} = fgetl(fid);
    if isempty(strfind(str{lno},'#') == 1)
        cmnt = 0;
    end
end

if strcmp(str,'No sites/data found using the selection criteria specified ')
    
    % NO DATA
    datStruc            = [];
    datStruc2.values    = [];
    
else
    % Read it and put it in a structure
    
    % NO DATA
    datStruc            = [];
    datStruc2.values    = [];
    
    try
        tmp2       = regexp(str(lno), '([^ \t][^\t]*)', 'match');
        str{lno+1} = regexp(fgetl(fid), '([^ \t][^\t]*)', 'match');
        form       = [];
        for i = 1:length(tmp2{1})
            form = [form ' %s'];
            if i > 3
                pars{i} = ['par_' tmp2{1}{i}];
            else
                pars{i} = tmp2{1}{i};
            end
        end
        data       = textscan(fid,form,'delimiter','\t');
        fclose(fid);
        
        %% Create the first data structure
        % First create a datenum from the date
        for i = 5:2:length(pars)
            tmp3 = zeros(size(data{i}));
            for j = 1:length(data{i})
                if ~isempty(data{i}{j})
                    tmp3(j) = str2num(data{i}{j});
                else
                    tmp3(j) = NaN;
                end
            end
            data{i} = tmp3;
            clearvars tmp3
        end
        
        % Now make the data numeric, so it can be plotted
        for i = 1:length(data)
            if strmatch(pars{i},'datetime')
                ind = i;
            end
        end
        for i = 1:size(data{ind})
            mtime(i) = datenum(data{ind}(i));
        end
        
        datStruc = struct(pars{1},char(data{1}));
        datStruc = setfield(datStruc,'datenum',mtime);
        try
            for i = 2:8
                if i < 4
                    datStruc = setfield(datStruc,pars{i},char(data{i}));
                else
                    datStruc = setfield(datStruc,pars{i},data{i});
                end
            end
        catch
        end
        
    catch
    end
    
    try
        %% Create the second data structure
        datStruc2.number            = SiteNo;
        datStruc2.agency            = datStruc.agency_cd(1,:);
        datStruc2.parcode           = ParCode;
        datStruc2.period.start      = tstart;
        datStruc2.period.end        = tend;
        datStruc2.datenum           = datStruc.datenum;
        datStruc2.values            = data{1,5};
    catch
    end
end
