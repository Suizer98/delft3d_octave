% this script writes MWTL data to text files in the format of WOS2ACC.txt
% file. The output is per text file: all station per substance.



%% PART 1: set dir's, open netcdf data and additional info for selections

clear all;
close all;
clc;

% define parent-dir and dir for writing .loa files
loaparent= 'd:\GEM-Egmond\meetdata\';
loadir='Loads_Files';
netcdfdir='d:\GEM-Egmond\ncdata\';

cd(netcdfdir);

folders=dir;

% provide list of years
year_start=2009;
year_end=2010;
OBS_year=2009; %to write obsyear instead of observation to output file

% provide list of substance selection
req_sub={'NH4','concentration_of_chlorophyll_in_water','E','PO4','NO3',...
    'sea_water_salinity','SiO2','concentration_of_suspended_matter_in_water',...
    'N','P','O2'};

% list the subdirectories(substances) of the netcdf structure.
substance={'','','NH4','concentration_of_chlorophyll_in_water','E','PO4','NO3',...
    'sea_water_salinity','SiO2','concentration_of_suspended_matter_in_water',...
    'N','P','O2'};

% provide list of selected measuring stations
Stations={'appzk1','appzk2','appzk4','appzk10','appzk20','appzk30','appzk50',...
    'appzk70','blauwsot','blauwswt','callog1','callog2','callog4','callog10',...
    'callog20','callog30','callog50','callog70','dantzgnd','dantzgt','doovbot',...
    'doovbwt','egmaze1','egmaze2','egmaze4','egmaze10','egmaze20','egmaze30',...
    'egmaze50','egmaze70','goere2','goere6','goere10','goere20','goere30','goere50',...
    'goere70','ijmdn1','ijmdn3','ijmdn20','marsdnd','noordwk1','noordwk2','noordwk4','noordwk10',...
    'noordwk20','noordwk30','noordwk50','noordwk70','rottmpt3','rottmpt5','rottmpt10',...
    'rottmpt15','rottmpt20','rottmpt30','rottmpt50','rottmpt70',...
    'schouwn1','schouwn4','schouwn10','schouwn20','schouwn30','schouwn50','schouwn70',...
    'terhde1','terhde2','terhde4','terhde10','terhde20','terhde30','terhde50','terhde70',...
    'terslg4','terslg10','terslg20','terslg30','terslg50','terslg70','terslg100',...
    'terslg135','terslg175','terslg235','vliesm','walcrn1','walcrn2','walcrn4','walcrn10','walcrn20',...
    'walcrn30','walcrn50','walcrn70','zoutkplzgt'};

% Stations={'appzk1','appzk2','appzk4','appzk10','appzk20','appzk30','appzk50',...
%     'appzk70','callog1','callog2','callog4','callog10',...
%     'callog20','callog30','callog50','callog70',...
%     'egmaze1','egmaze2','egmaze4','egmaze10','egmaze20','egmaze30',...
%     'egmaze50','egmaze70','goere2','goere6','goere10','goere20','goere30','goere50',...
%     'goere70','ijmdn1','ijmdn3','ijmdn20','noordwk1','noordwk2','noordwk4','noordwk10',...
%     'noordwk20','noordwk30','noordwk50','noordwk70','rottmpt3','rottmpt5','rottmpt10',...
%     'rottmpt15','rottmpt20','rottmpt30','rottmpt50','rottmpt70',...
%     'schouwn1','schouwn4','schouwn10','schouwn20','schouwn30','schouwn50','schouwn70',...
%     'terhde1','terhde2','terhde4','terhde10','terhde20','terhde30','terhde50','terhde70',...
%     'terslg4','terslg10','terslg20','terslg30','terslg50','terslg70','terslg100',...
%     'terslg135','terslg175','terslg235','walcrn1','walcrn2','walcrn4','walcrn10','walcrn20',...
%     'walcrn30','walcrn50','walcrn70'};

% Stations={'noordwk1','noordwk2','noordwk4','noordwk10',...
%         'noordwk20','noordwk30','noordwk50','noordwk70',...
%         'walcrn1','walcrn2','walcrn4','walcrn10','walcrn20',...
%         'walcrn30','walcrn50','walcrn70'};
%% PART 2: select data for rivers, substances

disp('Part 2: selecting data from Netcdf')
disp('This may take a few minutes')

for l=6%1:length(req_sub) % substance selection
    a=l+2;
    for v=3:length(substance)
        if strcmpi(substance(v),req_sub(l)) % select only required substances
            
            datadirectory=[netcdfdir,folders(v).name,'\'];
            cd (folders(v).name);
            fileinfo = dir([datadirectory,'*.nc']);
            
            for m=1:length(Stations) % river selection
                for k=1:length(fileinfo)
                    stat_name=nc_varget([fileinfo(k).name],'station_id');
                    station_name=stat_name';
                    if strcmpi(Stations(m),station_name) % select only required rivers
                        
                        data=nc_varget([fileinfo(k).name],[substance{v}]);
                        stat_name=nc_varget([fileinfo(k).name],'station_id');
                        station_name=stat_name';
                        lat=nc_varget([fileinfo(k).name],'lat');
                        long=nc_varget([fileinfo(k).name],'lon');
                        
                        %get the julday from the dates (in the NetCDF they refer to
                        %1-1-1970)
                        Struct.datenum.data = nc_varget ([fileinfo(k).name],'time');
                        Struct.datenum.units = nc_attget([fileinfo(k).name],'time','units');
                        [datenumbers]=udunits2datenum(Struct.datenum.data,Struct.datenum.units);
                        
                        % Put the data needed in a structure
                        Data.(station_name).name=station_name;
                        Data.(station_name).lat=lat;
                        Data.(station_name).lon=long;
                        Data.(station_name).([substance{v}])=data(:);
                        Data.(station_name).datenum=datenumbers(:);
                        
                    end %selected measurement station
                end %search all station names
            end
            
            cd ..\ % one dir up for the next substance
            clear('data','datenumbers','station_name','long','lat')
            
        end
    end
    
    clear('Struct','fileinfo','k','m')
    
    %% PART 3: perform data conversions
    disp('Part 3: Performing data conversions')
    disp('This may take a few minutes')
  
    river=fieldnames(Data);
    
    %new_chloro (*1000 too small in netcdf file)
    if strcmpi(substance{a},'concentration_of_chlorophyll_in_water')
        
        for i=1:length(river) %ospar rivers only
            if isfield(Data.(river{i}),'concentration_of_chlorophyll_in_water')
                Data.(river{i}).new_chlfa= zeros(size(Data.(river{i}).concentration_of_chlorophyll_in_water));
                for j=1:size(Data.(river{i}).datenum,1)
                    if isnan(Data.(river{i}).concentration_of_chlorophyll_in_water(j))
                        Data.(river{i}).chlfa(j,:) = -999;
                    else Data.(river{i}).chlfa(j,:) = 1000.*Data.(river{i}).concentration_of_chlorophyll_in_water(j);
                    end
                end
            end
        end
        
    end
    
    %new_spm (*1000 too small in netcdf file)
    if strcmpi(substance{a},'concentration_of_suspended_matter_in_water')
        
        for i=1:length(river) %ospar rivers only
            if isfield(Data.(river{i}),'concentration_of_suspended_matter_in_water')
                Data.(river{i}).new_spm= zeros(size(Data.(river{i}).concentration_of_suspended_matter_in_water));
                for j=1:size(Data.(river{i}).datenum,1)
                    if isnan(Data.(river{i}).concentration_of_suspended_matter_in_water(j))
                        Data.(river{i}).new_spm(j,:) = -999;
                    else Data.(river{i}).new_spm(j,:) = 1000.*Data.(river{i}).concentration_of_suspended_matter_in_water(j);
                    end
                end
            end
        end
        
    end
    
    clear('i','j')
    
    
    %% PART 4: select years and save converted data to .loa file in required format
    disp('Part 4: writing .loa file')
    disp('This may take a few minutes')
    
    cd(loaparent)
    mkdir(loadir)
    cd(loadir)
    
    filename = [char(req_sub(l)),'_','monitor','.txt'];
    fid = fopen(filename,'w+');
    
    for z=year_start:year_end
        for i=1:length(river)
            mask=(Data.(river{i}).datenum)>=datenum(z,1,1)& (Data.(river{i}).datenum)<=datenum(z,12,31);
            new_datestr=Data.(river{i}).datenum(mask);
            
             for dd=1:length(new_datestr)
                Data.(river{i}).new_datestr(dd,:)=new_datestr(dd);
                xyear(dd)=datenum(year(new_datestr(dd)),1,1);
                Data.(river{i}).daynumber(dd,:)=ceil(new_datestr(dd)-xyear(dd));
                
                if strcmpi('NH4',substance(a))
                    if isfield(Data.(river{i}),'NH4')
                    Data.(river{i}).stof_new=Data.(river{i}).NH4(mask);
                    end
                    
                elseif strcmpi('concentration_of_chlorophyll_in_water',substance(a))
                    Data.(river{i}).stof_new=Data.(river{i}).chlfa(mask);
                
                elseif strcmpi('PO4',substance(a))
                    if isfield(Data.(river{i}),'PO4')
                    Data.(river{i}).stof_new=Data.(river{i}).PO4(mask);
                    end
                elseif strcmpi('NO3',substance(a))
                    if isfield(Data.(river{i}),'NO3')
                    Data.(river{i}).stof_new=Data.(river{i}).NO3(mask);
                    end
                elseif strcmpi('sea_water_salinity',substance(a))
                    if isfield(Data.(river{i}),'sea_water_salinity')
                    Data.(river{i}).stof_new=Data.(river{i}).sea_water_salinity(mask);
                    end
                elseif strcmpi('SiO2',substance(a))
                    if isfield(Data.(river{i}),'SiO2')
                    Data.(river{i}).stof_new=Data.(river{i}).SiO2(mask);
                    end
                elseif strcmpi('concentration_of_suspended_matter_in_water',substance(a))
                    Data.(river{i}).stof_new=Data.(river{i}).new_spm(mask);
                
                elseif strcmpi('N',substance(a))
                    if isfield(Data.(river{i}),'N')
                    Data.(river{i}).stof_new=Data.(river{i}).N(mask);
                    end
                elseif strcmpi('P',substance(a))
                    if isfield(Data.(river{i}),'P')
                    Data.(river{i}).stof_new=Data.(river{i}).P(mask);
                    end
                elseif strcmpi('O2',substance(a))
                    if isfield(Data.(river{i}),'O2')
                    Data.(river{i}).stof_new=Data.(river{i}).O2(mask);
                    end
               elseif strcmpi('E',substance(a))
                    if isfield(Data.(river{i}),'E')
                    Data.(river{i}).stof_new=Data.(river{i}).E(mask);
                    end
                else
                    continue
                end
                                
            end
            
            if z==OBS_year
                label = ['OBS',num2str(OBS_year)];
            else
                label = 'Observation';
                
            end
            
            for j=1:length(new_datestr)
                fprintf(fid,'%s\t%c%d\t%c%s\t%c%s\t%c%s\t%c%d\t%c%s\t%c%d \n',label,';',Data.(river{i}).daynumber(j,:),';',[river{i}],...
                    ';',char(req_sub(l)),';',datestr(Data.(river{i}).new_datestr(j,:),'yyyy-mm-dd'),';',...
                    Data.(river{i}).stof_new(j),';',datestr(Data.(river{i}).new_datestr(j,:),'mm/dd'),';',Data.(river{i}).daynumber(j,:));
            end
            
            
            clear ('mask')
        end
    end
    
    cd(netcdfdir)
    fclose ('all');
    %clear ('z','mask');
    
end

cd ../

save 'Data'

%% OEF
