function varargout = EHY_opendap (varargin)

%% retrieve information availlable on the Deltares opendap server,
%  (a copy of Rijkswaterstaat Waterbase)
%
%  parameters     = EHY_opendap
%                   returns a cell array with the names of the parameters available
%
%  2 <keyword,value> pairs are implemented
%  Stations            = EHY_opendap('Parameter','waterhoogte')
%                        returns a cell array with the names of the stations where this parameter is measured
%  [times,values]      = EHY_opendap('Parameter','waterhoogte','Station','HoekvH')
%                        returns the time series, times and values, of this parameter at this station
%  [times,values,Info] = EHY_opendap('Parameter','waterhoogte','Station','HoekvH')
%                        returns the time series, times and values, of this parameter at this station
%                        in addition, some general Infomation like for instance:
%                        - Full name of the station,
%                        - Location of the station,
%                        - Measurement height, etc
%                        Is returned in the stucture Info
%% Initialisation
OPT.Parameter = '';
OPT.Station   = '';

OPT = setproperty(OPT,varargin);

% interactively retrieving data
if nargout==0 & nargin==0
    EHY_opendap_interactive
end

%% Retreive list of files available on the opendap server
[path,~,~] = fileparts(mfilename('fullpath'));

D = dir([path filesep 'list_opendap.mat']);
if ~isempty(D) && D.datenum < datenum(2022,10,10); delete([path filesep 'list_opendap.mat']); end
if ~exist([path filesep 'list_opendap.mat'],'file')
%    url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml';
    warning('List of OPENDAP waterbase files is out fo date. Rebuiding the list');
    url = '\\dfs-trusted\dfs\openearth-opendap-opendap\thredds\rijkswaterstaat\waterbase\';
    list = opendap_catalog(url,'disp','','maxlevel',4);
    save([path filesep 'list_opendap.mat'],'list');
else
    load([path filesep 'list_opendap.mat']);
end

%% Nothing specified, return list of possible parameters
if isempty(OPT.Parameter) & nargout==1
    i_par = 1;
    for i_data = 1: length(list)
        i_sep = strfind(list{i_data},filesep);
        name_tmp = list{i_data}(i_sep(end-2) + 1:i_sep(end-1) - 1);
        if i_data == 1
            name_par{i_par} = name_tmp;
        else
            if ~strcmp(name_tmp,name_par{i_par})
                i_par = i_par + 1;
                name_par{i_par} = name_tmp;
            end
        end
    end
    varargout = {sort(name_par)'};
end

%% Parameter name specified
if ~isempty(OPT.Parameter)
    i_stat = find(~cellfun(@isempty,strfind(lower(list),lower(OPT.Parameter))));
    list_stat = list(i_stat);
    if isempty(OPT.Station)
        %% No station name specified, return list of stations
        i_stat = 1;
        for i_data = 1: length(list_stat)
            i_sep = strfind(list_stat{i_data},'\');
            name_tmp = list_stat{i_data}(i_sep(end) + 1:end-3);
            i_id     = strfind(name_tmp,'-');
            name_tmp = name_tmp(i_id+1:end);
            
            if i_data == 1
                name_stat{i_stat} = name_tmp;
            else
                if ~strcmp(name_tmp,name_stat{i_stat})
                    i_stat            = i_stat + 1;
                    name_stat{i_stat} = name_tmp;
                end
            end
        end
        varargout = {sort(name_stat)'};
    else
        %% Station name specified, return time series of the parameter at this station
        %  First find the station
        try
            i_stat = find(~cellfun(@isempty,strfind(lower(list_stat),lower(OPT.Station))));
            %tk            i_stat = find(~cellfun(@isempty,regexp(lower(list_stat),strjoin(lower(OPT.Station),'|'))));
            % Get information on the parameter name on the file
            date_tmp  = [];
            value_tmp = [];
            if ~isempty(i_stat)
                for i_par = 1: length(i_stat)
                    Info       = ncinfo(list_stat{i_stat(i_par)});
                    param_name = Info.Variables(end).Name;
                    
                    %% Retrieve data
                    D           = nc_cf_timeseries(list_stat{i_stat(i_par)},param_name,'plot',0);
                    date_tmp    = [date_tmp;  reshape(D.datenum,[],1)];
                    value_tmp   = [value_tmp; reshape(D.(param_name),[],1)];
                end
                [dates,index]   = sort(date_tmp);
                values          = value_tmp(index);
                varargout{1} = dates;
                varargout{2} = values;
                
                %% Retrieve general information (if requested)
                if nargout == 3
                    for i_var = 1: length(Info.Variables) - 2
                        if i_var <= 2
                            geninf.(Info.Variables(i_var).Name) = ncread(list_stat{i_stat(i_par)},Info.Variables(i_var).Name)';
                        else
                            geninf.(Info.Variables(i_var).Name) = ncread(list_stat{i_stat(i_par)},Info.Variables(i_var).Name);
                        end
                    end
                    varargout{3} = geninf;
                end
            else
                varargout{1} = [datenum(1900,1,1); datenum(now)];
                varargout{2} = [NaN              ; NaN         ];
                if nargout == 3
                    varargout{3} = 'Station not found on Deltares OPENDAP server';
                end
                
            end
            
        catch
            disp(['Problems retrieving OPENDAP data for station : ' OPT.Station]);
            if nargout == 2
                [dates,values]        = EHY_opendap (varargin{1:end});
            elseif nargout == 3
                [dates,values,geninf] = EHY_opendap (varargin{1:end});
                varargout{3}          = geninf;
            end
            varargout{1} = dates;
            varargout{2} = values;
        end
    end
    
end

end

function EHY_opendap_interactive
parameters=EHY_opendap;
for iP=1:length(parameters)
    parameters2{iP,1}=strrep(parameters{iP}(4:end),'_',' ');
end
[selection,~]=  listdlg('PromptString','Select a parameter',...
    'SelectionMode','single',...
    'ListString',parameters2,...
    'ListSize',[500 500]); if isempty(selection); return; end
selectedParameter=parameters{selection};

Stations            = EHY_opendap('Parameter',selectedParameter);
[selection,~]=  listdlg('PromptString',['Select a station for variable '''  parameters2{selection}  ''''],...
    'SelectionMode','single',...
    'ListString',Stations,...
    'ListSize',[500 500]); if isempty(selection); return; end
selectedStation=Stations{selection};
[selection,~]=  listdlg('PromptString','Choose between:',...
    'SelectionMode','single',...
    'ListString',{'Download times and values','Download times, values and additional information (e.g. location of station)'},...
    'ListSize',[500 100]); if isempty(selection); return; end

disp(['start downloading data... Station: ' selectedStation ' - Parameter: ' selectedParameter])
if selection==1
    [times,values]=EHY_opendap('Parameter',selectedParameter,'Station',selectedStation);
    disp([char(10) 'Note that next time you want to download this data, you can also use:'])
    disp(['[times,values]=EHY_opendap(''Parameter'',''' selectedParameter ''',''Station'',''' selectedStation ''');' char(10)])
elseif selection==2
    [times,values,info]=EHY_opendap('Parameter',selectedParameter,'Station',selectedStation);
    disp([char(10) 'Note that next time you want to download this data, you can also use:'])
    disp(['[times,values,info]=EHY_opendap(''Parameter'',''' selectedParameter ''',''Station'',''' selectedStation ''');' char(10)])
end

assignin('base','times',times);
assignin('base','values',values);

[selection,~]=  listdlg('PromptString','Do you want to plot the download data?',...
    'SelectionMode','single',...
    'ListString',{'Yes','No'},...
    'ListSize',[500 100]); if isempty(selection); return; end
if selection==1
    figure('units','normalized','outerposition',[0 0 1 1])
    plot(times,values);
    xlabel('time')
    datetick('x','dd-mmm-yyyy')
    ylabel(selectedParameter,'interpreter','none')
    title(['Station: ' selectedStation])
end
[selection,~]=  listdlg('PromptString','Do you want to save the downloaded data to a .tek-file?',...
    'SelectionMode','single',...
    'ListString',{'Yes','No'},...
    'ListSize',[500 100]); if isempty(selection); return; end
if selection==1
    option=inputdlg({['Want to specifiy a certain output period? (Default: all data)' char(10) char(10) 'Start date [dd-mmm-yyyy HH:MM]'],'End date   [dd-mmm-yyyy HH:MM]'},'Specify output period',1,...
        {datestr(times(1)),datestr(times(end))});
    if ~isempty(option)
        timeIndex=times>=datenum(option(1)) & times<=datenum(option(2));
        times=times(timeIndex);
        values=values(timeIndex);
    end
    disp('Save file as ..')
    [file,path] = uiputfile([ selectedStation '_' selectedParameter(4:end) '.tek']);
    outputFile=[path file];
    fid = fopen(outputFile,'w+');
    fprintf (fid,'* Column  1 : Date \n');
    fprintf (fid,'* Column  2 : Time \n');
    fprintf (fid,'%s \n',['* Column  3 : ' selectedParameter(4:end)] );
    fprintf(fid,[selectedStation ' \n']);
    fprintf(fid,'%5i %5i \n',length(times),3);
    format = ['%16s %12.6f \n'];
    for i_time = 1: length(times)
        fprintf(fid,format,datestr(times(i_time),'yyyymmdd  HHMMSS'), values(i_time));
    end
    fclose (fid);
    disp(['EHY_opendap created file:' char(10) outputFile])
end

end
