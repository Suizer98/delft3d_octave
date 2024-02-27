%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18332 $
%$Date: 2022-08-23 22:45:22 +0800 (Tue, 23 Aug 2022) $
%$Author: chavarri $
%$Id: read_csv_data.m 18332 2022-08-23 14:45:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/read_csv_data.m $
%
%This function reads csv files containing Rijkswaterstaat data and gives as output a structure
%with the data. If adding a new file type, this needs to be arranged in function get_file_data.
%
%INPUT:
%   -fpath: path to the file to read [char]
%
%OUTPUT:
%   -
%
%e.g.: reading with given input
%
% file_structure.file_type=0;
% file_structure.fdelim=';';
% file_structure.headerlines=1;
% file_structure.var_time={'Fecha','Valor'};
% file_structure.idx_time=1;
% file_structure.fmt_time='dd/MM/yyyy hh:mm';
% file_structure.idx_waarheid=2;
% file_structure.var_once={'NombreEstacion','Latitud','Longitud'};
% file_structure.idx_location=1;
% file_structure.idx_y=2;
% file_structure.idx_x=3;
% file_structure.epsg=4326;
% file_structure.grootheid='Q';
% file_structure.eenheid='m3/s';
% file_structure.tzone='-05:00';
% 
% data_station=read_csv_data(fpath_q,'file_structure',file_structure)

function rws_data=read_csv_data(fpath,varargin)

%% PARSE

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);
addOptional(parin,'file_structure',NaN);
addOptional(parin,'convert_coordinates',0);
addOptional(parin,'epsg_convert',28992);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;
file_structure=parin.Results.file_structure;
convert_coordinates=parin.Results.convert_coordinates;
epsg_convert=parin.Results.epsg_convert;

%% 

if ~isstruct(file_structure) %there is no file structure as input
    input_file_structure=false;
else
    input_file_structure=true;
    
    %get empty values
    [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone]=empty_file_structure;
    %substitute the ones that are input
    v2struct(file_structure) %output from get_file_data and file_type=0 or file_type=-1
    %pack again to pass to reading function
    file_structure=v2struct(fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone);
end

%% READ DATA

if ~input_file_structure %there is no file structure as input
    file_type=get_file_type(fpath);
end

switch file_type
    case 0
        vardata=read_data_1(file_type,fpath,'flg_debug',flg_debug,'file_structure',file_structure);
    case {1,2,3,4,6,7,8,9,10,11,12,13,14} %locations in rows
        vardata=read_data_1(file_type,fpath,'flg_debug',flg_debug);
    case {5} %locations in columns
        vardata=read_data_2(file_type,fpath,'flg_debug',flg_debug);       
    otherwise
        error('Specify file type')
end

%% SAVE

nloc=size(vardata,1);

rws_data=struct('location',[],'x',[],'y',[],'raai',[],'grootheid',[],'parameter',[],'eenheid',[],'time',[],'waarde',[],'source',[]);

for kloc=1:nloc

    %% get indexes 
    
    if ~input_file_structure
        [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone,var_hog]=get_file_data(file_type,fpath);
    end
    
    switch file_type
        case 5
            idx_waarheid=2; %we have used this index to indicate each of the locations.
        case 13
            [location,epsg,x,y,bemonsteringshoogte,grootheid,eenheid,hoedanigheid]=read_meta_data_01(fpath);
    end
    
    %% convert
    
    %time zone
    if isnan(tzone)
        if isnan(idx_tzone)
            error('Provide a time zone')
        else
            tzone=vardata{kloc,2}{idx_tzone};
        end
    end
    
    switch tzone
        case 'CENT'
            tzone='+01:00';
    end

    %convert time format 
    if isnan(idx_time)
        tim_str=vardata{kloc,1}(:,idx_tijd);
        switch lower(fmt_tijd)
            case 'hh'
                tim_str=cellfun(@(x)sprintf('%s:00',x),tim_str,'UniformOutput',false);
                fmt_tijd='hh:mm';
        end
        time_mea=datetime(vardata{kloc,1}(:,idx_datum),'inputFormat',fmt_datum)+duration(tim_str,'inputFormat',lower(fmt_tijd));
    else
        if contains(fmt_time,{'z','x'})%there is a time zone in the input
            time_mea=datetime(vardata{kloc,1}(:,idx_time),'InputFormat',fmt_time,'TimeZone',tzone);
        else
            time_mea=datetime(vardata{kloc,1}(:,idx_time),'InputFormat',fmt_time);
        end
    end

    time_mea.TimeZone=tzone;

    %convert variable
    mea=cellfun(@(x)undutchify(x),vardata{kloc,1}(:,idx_waarheid),'UniformOutput',false);   
    mea=cell2mat(mea);

    %put in cronological order
    [time_mea,idx_sort]=sort(time_mea);
    mea=mea(idx_sort,:);

    %% variables to save

        %location
    if isnan(location)
        if isnan(idx_location)
            error('No location')
        else
            location=vardata{kloc,2}{idx_location};
        end
    end
        %x
    if isnan(x)    
        if isnan(idx_x)
            x=NaN;
        else
            x=undutchify(vardata{kloc,2}{idx_x});
        end
    end
        %y
    if isnan(y)
        if isnan(idx_y)
            y=NaN;
        else
            y=undutchify(vardata{kloc,2}{idx_y});
        end
    end
        %raai
    if isnan(idx_raai)
        raai=NaN;
    else
        raai=undutchify(vardata{kloc,2}{idx_raai});
    end
        %unit
    if isnan(eenheid)
        if isnan(idx_eenheid)
            error('A unit must be given');
        else
            eenheid=vardata{kloc,2}{idx_eenheid};
        end
    end
        %quantity
    if isnan(grootheid)
        if isnan(idx_grootheid)
            if strcmp(eenheid,'m3/s')
                grootheid='Q';
            elseif strcmp(eenheid,'mg/l')
                grootheid='CONCTTE';
            else
                error('A parameter (grootheid) must be given')
            end
        else
            grootheid=vardata{kloc,2}{idx_grootheid};
            if strcmp(grootheid,'Debiet') %in some file types the code is not given and we assing the omschrijving to grotheid
                grootheid='Q';
            end
        end
    else
        switch grootheid
            case 'H10'
                grootheid='WATHTE';
        end
    end
        %parameter
   if isnan(parameter)
        if isnan(idx_parameter)
            if strcmp(grootheid,'CONCTTE')
                parameter='Cl'; %ASSUMPTION: if nothing is said, it is salt. 
            else
                parameter='';
            end
        else
            parameter=vardata{kloc,2}{idx_parameter};
        end
    end
        %epsg
    if isnan(epsg)
        if isnan(idx_epsg)
    %         epsg=NaN;
        else
            epsg=vardata{kloc,2}{idx_epsg};
            if strcmp(epsg,'RD')
                epsg=28992;
            else
                epsg=str2double(epsg);
            end
            
        end
    end
        %reference
    if isempty(hoedanigheid)
        if isnan(idx_hoedanigheid)
            hoedanigheid='';
        else
            hoedanigheid=vardata{kloc,2}{idx_hoedanigheid};
    %         hoedanigheid=hoedanigheid(~isspace(ref));
        end
    end
        %elevation
    if isnan(bemonsteringshoogte)
        if isnan(idx_bemonsteringshoogte)
            bemonsteringshoogte=NaN;
        else
            bemonsteringshoogte=undutchify(vardata{kloc,2}{idx_bemonsteringshoogte})./100;
        end
    end


    %% convert output

    %convert all coordinates to RD New
    if convert_coordinates
        if ~isnan(epsg)
            if abs(epsg-epsg_convert)>0.5 
                [x,y]=convertCoordinates(x,y,'CS1.code',epsg,'CS2.code',epsg_convert);
                epsg=epsg_convert;   
            end
        end
    end
    
    %units
    switch eenheid
        case 'm'

        case 'cm'
            mea=mea./100;
            eenheid='m';
        case 'dm/s'
            mea=mea*0.1;
            eenheid='m/s';
    end

    %quantity
    switch grootheid
        case {'CONCTTE'}
            switch eenheid
                case {'ppm'}
                    eenheid='mg/l';
            end
        case {'WATHTE','Q'}

    end

    %reference
    switch grootheid
        case {'CONCTTE','Q'}
            if strcmp(hoedanigheid,'NVT')
                hoedanigheid='';
            end
        case {'WATHTE'}
            if strcmp(hoedanigheid,'NVT')
                hoedanigheid='NAP'; %ASSUMPTION
            end        
    end
    if contains(eenheid,hoedanigheid)
        hoedanigheid='';
    end
    if strcmp(parameter,hoedanigheid)
        hoedanigheid='';
    end
    eenheid=strcat(eenheid,hoedanigheid);

    %filter
    %It may be possible to do this for at least waterinfo data (type 6) by making use of flag 'KWALITEITSOORDEEL_CODE' (Normale waarde vs. nothing)
    if exist('limsf','var')==0
        switch grootheid        
            case {'Q','WATHTE'}
                limsf=[-1e6,1e6];
            otherwise
                limsf=[-inf,inf];
        end
    end
    mea(mea<limsf(1)|mea>limsf(2))=NaN;

    %% create structure

    rws_data(kloc).raai=raai;
    rws_data(kloc).x=x;
    rws_data(kloc).y=y;
    rws_data(kloc).epsg=epsg;
    rws_data(kloc).location=location;
    rws_data(kloc).eenheid=eenheid;
    rws_data(kloc).parameter=parameter;
    rws_data(kloc).grootheid=grootheid;
    rws_data(kloc).source=fpath;
    rws_data(kloc).time=time_mea;
    rws_data(kloc).waarde=mea;
    rws_data(kloc).bemonsteringshoogte=bemonsteringshoogte;

end %kloc

end %read_csv_data

%%
%% FUNCTIONS
%%

function vardata=read_data_2(file_type,fpath,varargin)

%% parse

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;

%% header
fid=fopen(fpath,'r');
fline=fgetl(fid); %first line

%% file type data

[fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid]=get_file_data(file_type);
tok_header=regexp(fline,fdelim,'split');
idx_var_once=find_str_in_cell(tok_header,var_once);
idx_var_time=find_str_in_cell(tok_header,var_time);    
% idx_var_loc =find_str_in_cell(tok_header,var_loc );

nv=2;
nloc=numel(idx_waarheid);

%% read

%preallocate
npreall=10000;
vardata=cell(nloc,2); 
    %{kloc,1}=info changing with time; 
    %{kloc,2}=info constant per location; 
for kloc=1:nloc
    vardata{kloc,1}=cell(npreall,nv);
end
keep_going=true;

%first line outside loop to get location
kl=1; %line counter
ks=kl; %time counter

while ~feof(fid) && keep_going
    %get info
    fline=fgetl(fid); 
    tok=regexp(fline,fdelim,'split');
    
    %save
    for kloc=1:nloc
        vardata{kloc,1}(ks,:)=tok([idx_var_time(1),idx_var_time(idx_waarheid(kloc))]); %first index is time
    end
    
    %update
    kl=kl+1;
    ks=kl;
    
    %check if needed to preallocate more
    if ks==size(vardata{kloc,1},1)
        for kloc=1:nloc
            vardata{kloc,1}=cat(1,vardata{kloc,1},cell(npreall,nv));
        end
    end

    %debug
    if flg_debug && kl==10
        keep_going=false;
    end
    
    %display
%     fprintf('line %d \n',kl)
end
fclose(fid);

for kloc=1:nloc
    vardata{kloc,1}=vardata{kloc,1}(1:ks-1,:);
    vardata{kloc,2}=tok_header(idx_var_once(idx_location(kloc)));
end

vardata=cellfun(@(X)strrep(X,'"',''),vardata,'UniformOutput',false);

end %function

%%

function vardata=read_data_1(file_type,fpath,varargin)

%% parse

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);
addOptional(parin,'file_structure',NaN);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;
file_structure=parin.Results.file_structure;
v2struct(file_structure) %output from get_file_data and file_type=0 or file_type=-1

%% file type data

if file_type~=0 
[fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone,var_hog]=get_file_data(file_type,fpath);
end

%cycle header
fid=fopen(fpath,'r');
for kl=1:headerlines
    fline=fgetl(fid); 
end

tok_header=regexp(fline,fdelim,'split');
tok_header=strtrim(tok_header);
if isempty(var_once)
    idx_var_once=NaN;
else
    idx_var_once=find_str_in_cell(tok_header,var_once);
end
if isnan(idx_var_time)
    idx_var_time=find_str_in_cell(tok_header,var_time);    
end
% idx_var_loc =find_str_in_cell(tok_header,var_loc );
% idx_var_hog =find_str_in_cell(tok_header,var_hog );

nv=numel(idx_var_time);

%% read

%preallocate
npreall=10000;
nlocpreall=10;
vardata=cell(nlocpreall,2); 
    %{kloc,1}=info changing with time; 
    %{kloc,2}=info constant per location; 
vardata{1,1}=cell(npreall,nv);
keep_going=true;

%first line outside loop to get location
kl=1; %line counter
kloc=1; %location counter
nloc=1; %number of locations
ks=1; %time counter
ks_vec=1; %vector of time counters

    %get info
    tok=get_clean_line(fid,fdelim);

    %save time
    vardata{kloc,1}(ks,:)=tok(idx_var_time);
    
    %save constant
    if ~isnan(idx_var_once)
        vardata{kloc,2}=tok(idx_var_once);
    else
        vardata{kloc,2}='';
    end
    
    %update
    kl=kl+1;

while ~feof(fid) && keep_going
    %get info
    tok=get_clean_line(fid,fdelim);
    
    %check if new elevation or existing
    if ~isnan(idx_var_once)
        var_once_loc=tok(idx_var_once); %save local data to be read once
        bol_cmp=false(nloc,numel(var_once_loc));
        for kkloc=1:nloc 
            [~,bol_cmp(kkloc,:)]=find_str_in_cell(vardata{kkloc,2},var_once_loc); 

            %filter empty ones
            bol_empty=cellfun(@(X)isempty(X),var_once_loc); 
            bol_cmp(kkloc,bol_empty)=true;
        end
        idx_same=find(all(bol_cmp,2)); %index of vardata with same varonce
    else
        idx_same=1;
    end
    
    if isempty(idx_same) %new elevation
        %update
        nloc=nloc+1;
        kloc=nloc;
        ks=1;
        ks_vec=cat(1,ks_vec,ks);
        
        %preallocate
        vardata{kloc,1}=cell(npreall,nv);

        %new constants
%         if ~isnan(idx_var_once)
            vardata{kloc,2}=var_once_loc; %there is always a constant if there is elevation?
%         else
%             vardata{kloc,2}='';
%         end
    elseif numel(idx_same)>1
        error('something is not working')
    else
        kloc=idx_same;
        ks_vec(kloc)=ks_vec(kloc)+1;
        ks=ks_vec(kloc);
%         ks=find(~cellfun(@(X)isempty(X),(vardata{kloc,1}(:,1))),1,'last')+1; %exremely expensive
    end      
    
    %save
    vardata{kloc,1}(ks,:)=tok(idx_var_time);
    
    %update
    kl=kl+1;
    
    %check if needed to preallocate more
    if kloc==size(vardata,1)
        vardata=cat(1,vardata,cell(nlocpreall,2));
    end
    if ks==size(vardata{kloc,1},1)
        vardata{kloc,1}=cat(1,vardata{kloc,1},cell(npreall,nv));
    end

    %debug
    if flg_debug && kl==100
        keep_going=false;
    end
    
    %display
%     fprintf('line %d \n',kl)
end
fclose(fid);

%squeeze data
vardata=vardata(1:nloc,:);
for kkloc=1:nloc
%     ks=find(~cellfun(@(X)isempty(X),(vardata{kkloc,1}(:,1))),1,'last')+1;   
    ks=ks_vec(kkloc);
    vardata{kkloc,1}=vardata{kkloc,1}(1:ks-1,:);
end

vardata=cellfun(@(X)strrep(X,'"',''),vardata,'UniformOutput',false);

end %function

%%
%% get_file_data
%%

function [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone,var_hog]=get_file_data(file_type,fpath)

         [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone,var_hog]=empty_file_structure;

switch file_type
    case 1
        %"Meetpunt.identificatie" ;"geometriepunt.x_rd";"geometriepunt.y_rd";"Grootheid.code";"Typering.code";"Parameter.groep";"Parameter.code";"Parameter.omschrijving";"Eenheid.code";"Hoedanigheid.code";"Compartiment.code";"Begindatum";"Begintijd";"Numeriekewaarde";"NumeriekeWaarde.nl";"Kwaliteitsoordeel.code";"kwaliteitsoordeel.omschrijving"
        %"433-036-00021_kwaliteit";107520              ;445821              ;"CONCTTE"       ;""             ;"ChemischeStof"  ;"Cl"            ;"Chloride"              ;"mg/l"        ;"NVT"              ;"OW"               ;2018-01-01  ;00:00:00   ;183              ;183                 ;0                       ;""
        %"MPN-527"                ;105872.22           ;444168.82           ;"WATHTE"        ;""             ;"Grootheid"      ;""              ;"Waterhoogte"           ;"mNAP"        ;"NAP"              ;"OW"               ;2018-01-01  ;00:00:00   ;0.193            ;0,193               ;0                       ;""
        %variables to save once
%         var_once={'"Meetpunt.identificatie"','"geometriepunt.x_rd"','"geometriepunt.y_rd"','"Grootheid.code"','"Typering.code"','"Parameter.groep"','"Parameter.code"','"Parameter.omschrijving"','"Eenheid.code"','"Hoedanigheid.code"','"Compartiment.code"'};
        var_once={'"Meetpunt.identificatie"','"geometriepunt.x_rd"','"geometriepunt.y_rd"','"Parameter.code"','"Eenheid.code"','"Grootheid.code"','"Hoedanigheid.code"'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        epsg=28992; %assumption
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_hoedanigheid=7;
        
        %variables to save with time
        var_time={'"Begindatum"','"Begintijd"','"Numeriekewaarde"'};
        idx_datum=1;
        fmt_datum='yyyy-MM-dd';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'"Meetpunt.identificatie"'};
        
        fdelim=';';
        tzone='+0000'; %File <"Overzicht data Hollandsche IJssel_v18-01-2021.xlsx" > specifies that this set is in UTC.
        headerlines=1;
    case 2
        % Datum              ,Serie                                                                                               ,Waarde   ,Eenheid,
        % "1-1-2018 00:00:00","GOUDA ADCP_3237-K_GOUDA ADCP-debietmeter - KW323711 - Q[m3/s][NVT][OW] - Debiet CAW [m3/s] - 15min","15.5958","m3/s"
        
        %variables to save once
        var_once={'Serie','Eenheid'};
        idx_location=1;
        idx_eenheid=2;
        
        %variables to save with time
        var_time={'Datum','Waarde'};
        idx_time=1;
        fmt_time='dd-MM-yyyy HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'Serie'};
        
        fdelim=',';
        tzone='Europe/Amsterdam'; %File <"Overzicht data Hollandsche IJssel_v18-01-2021.xlsx" > specifies that this set is in local time.
        headerlines=1;
    case 3
%        "";"Date"    ;"Time"  ;"P"    ;"T"  ;"EGV";"G";"loc"                         ;"K_18_t"        ;"cl"            ;"D_T"              ;"raai";"zomertijd"
%       "1";2020-05-26;12:10:00;1607,31;18,08;0,636;636;" LEK_981_200713102930_V8523 ";634,897163168224;110,867149947533;2020-05-26 12:10:00;"981" ;2020-05-26 11:10:00

        %variables to save once
        var_once={'"loc"','"raai"'};
        idx_location=1;
        idx_raai=2;
        
        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
        
        %variables to save with time
        var_time={'"zomertijd"','"cl"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'"loc"'};
        
        fdelim=';';
        tzone='+02:00'; %we get the summertime and add the UTC shift to be sure. 
        headerlines=1;
        
    case 4
        % "";"Date";"Time";"P";"T";"EGV";"G";"loc";"K_18_t";"cl";"D_T";"wintertijd"
        % "1";2020-07-24;09:10:00;1568,883;21,58;0,668;668;"GROEN-18";618,991985292716;106,745759214351;2020-07-24 09:10:00;2020-07-24 08:10:00

        %variables to save once
        var_once={'"loc"'};
        idx_location=1;

        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
            
        %variables to save with time
        var_time={'"wintertijd"','"cl"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'"loc"'};
        
        fdelim=';';
        tzone='+01:00'; %we get the wintertime and add the UTC shift to be sure. 
        headerlines=1;
    case 5
    %     "";"D_T";"972";"977";"979";"982";"983.5";"985";"986";"989";"GROEN-18";"GROEN-26";"ROOD-12";"ROOD-6";"ROOD-9"
    %     "1";2020-09-04 09:00:00;NA;NA;NA;NA;NA;119,369608158169;NA;236,661232888235;200,15535414911;NA;199,37711013335;164,142701624404;173,556143951793
        %variables to save once
        var_once={'"972"','"977"','"979"','"982"','"983.5"','"985"','"986"','"989"','"GROEN-18"','"GROEN-26"','"ROOD-12"','"ROOD-6"','"ROOD-9"'}; 
        idx_location=1:1:numel(var_once);

        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
        
        %variables to save with time
        var_time={'"D_T"','"972"','"977"','"979"','"982"','"983.5"','"985"','"986"','"989"','"GROEN-18"','"GROEN-26"','"ROOD-12"','"ROOD-6"','"ROOD-9"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2:1:14;
        
        %variable with location, to check for different places in same file.
        var_loc={''};
        
        fdelim=';';
        tzone='+02:00'; %we assume it is local time
        headerlines=1;
        
    case 6
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
        %variables to save once
        var_once={'MEETPUNT_IDENTIFICATIE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_epsg=7;
        idx_hoedanigheid=8;
        
        %variables to save with time
        var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD','NUMERIEKEWAARDE'};
        idx_datum=1;
        fmt_datum='dd-MM-yyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        fdelim=';';
        tzone='+01:00'; %waterinfo in CET
        headerlines=1;    
    case 7
        %%
% Parameter                    : Cl               chloride
% Eenheid                      : mg/l
% Gebied                       : OUDMS            Oude Maas
% Locatie                      : BEERPLKOVR       Beerenplaat linker oever (kilometer 996.1)
% Referentievlak               : NAP
% Bemonsteringshoogte          : -200
% X-coordinaat RD in m         :  88407
% Y-coordinaat RD in m         : 428330

        %read from file
        if exist('fpath','var') %if not, we are calling this function without second argument
        fid=fopen(fpath,'r');
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(\w*)','tokens');
        parameter=tok2{1,1}{1,1};
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(\w*(/?\w*))','tokens');
        eenheid=tok2{1,1}{1,1};
        
        lin=fgetl(fid);
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(\w*)','tokens');
        location=tok2{1,1}{1,1};
        
        lin=fgetl(fid);
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(-?\d*)','tokens');
        bemonsteringshoogte=str2double(tok2{1,1}{1,1})./1000; %assume it is mm
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(\d*)','tokens');
        x=str2double(tok2{1,1}{1,1});
        
        lin=fgetl(fid);
        tok=regexp(lin,':','split');
        tok2=regexp(tok{1,2},'(\d*)','tokens');
        y=str2double(tok2{1,1}{1,1});
        
        if contains(tok{1,1},' RD ')
            epsg=28992;
        else
            error('no idea what coordinates are')
        end
        
        lin=fgetl(fid);
        
        lin=fgetl(fid);
        if contains(lin,' MET')
            tzone='+01:00';
        else
            error('no idea about time zone')
        end
        
        fclose(fid);
        
        %other
        if strcmp(parameter,'Cl')
            grootheid='CONCTTE'; %assing, as they are not in head
        end
        
        idx_var_time=[1,2,3];
        idx_datum=1;
        fmt_datum='dd-MM-yyyy';
        idx_tijd=2;
        fmt_tijd='hh:mm';
        idx_waarheid=3;
        fdelim=' ';
        headerlines=12;
        

        end
    case 8
        %%
%         locatie.code;locatie.naam   ;coordinatenstelsel;geometriepunt.x ;geometriepunt.y ;tijdstip            ;eenheid.code;grootheid.omschrijving;hoedanigheid.code;numeriekewaarde
%         HAGSBVN     ;Hagestein boven;25831             ;646656.911653319;5762067.30484693;2000-12-04T07:00:00Z;m3/s        ;Debiet                ;NVT              ;477
        var_once={'locatie.code','coordinatenstelsel','geometriepunt.x','geometriepunt.y','eenheid.code','grootheid.omschrijving','hoedanigheid.code'};
        idx_location=1;
        idx_epsg=2;
        idx_x=3;
        idx_y=4;
        idx_eenheid=5;
        idx_grootheid=6; %should be the code, but it is not present and we assing omschrijving for later changing it 
        idx_hoedanigheid=7;
        
        %variables to save with time
        var_time={'tijdstip','numeriekewaarde'};
        idx_time=1;
        fmt_time='yyyy-MM-dd''T''HH:mm:ssz';
        idx_waarheid=2;
        
        tzone='+01:00'; %as there is a time zone in the input, this is the timezone in which is will be saved
        
        %variable with location, to check for different places in same file.
        var_loc={'locatie.code'};
        
        fdelim=';';
        headerlines=1;
    case 9
        %%
% kannum;wnsnum;parcod;paroms  ;casnum    ;staind;cpmcod;cpmoms          ;domein;ehdcod;hdhcod;hdhoms                ;orgcod;orgoms             ;sgkcod;1.klscod;1.klsoms;2.klscod;2.klsoms;3.klscod;3.klsoms;muxcod;muxoms;btccod;btlcod;btxoms             ;btnnam             ;ivscod;ivsoms             ;anicod     ;anioms                                   ;bhicod     ;bhioms                                       ;bmicod     ;bmioms                                       ;ogicod      ;ogioms                                   ;gbdcod   ;gbdoms            ;loccod      ;locoms                                          ;locsrt;crdtyp;loc_xcrdgs;loc_ycrdgs;ghoekg    ;rhoekg    ;metrng    ;straal    ;xcrdmp    ;ycrdmp    ;omloop;anacod;anaoms                                               ;bemcod ;bemoms                                  ;bewcod;bewoms             ;vatcod;vatoms             ;rkstyp;refvlk;bemhgt;rks_xcrdgs;rks_ycrdgs;vakstp    ;tydehd;tydstp;rks_begdat;rks_begtyd;rks_enddat;rks_endtyd;syscod;beginv;endinv;vzmcod;vzmoms;svzcod;svzoms;ssvcod;ssvoms;ssscod;sssoms;xcrdwb    ;ycrdzb    ;xcrdob    ;ycrdnb    ;xcrdmn    ;ycrdmn    ;xcrdmx    ;ycrdmx    ;datum     ;tijd ;bpgcod;waarde    ;kwlcod;rkssta
% 0     ;46    ;Cl    ;chloride;16887-00-6;J     ;10    ;Oppervlaktewater;E     ;mg/l  ;Cl    ;Uitgedrukt in Chloride;NVT   ;Niet van toepassing;NVT   ;        ;        ;        ;        ;        ;        ;      ;      ;NVT   ;NVT   ;Niet van toepassing;Niet van toepassing;NVT   ;Niet van toepassing;ZLXXWVMMDBG;Dir. Zeeland - afdeling WVM te Middelburg;ZHXXZXMRTDM;Dir. Zuid-Holland - afdeling ZXM te Rotterdam;ZHXXZXMRTDM;Dir. Zuid-Holland - afdeling ZXM te Rotterdam;ZHXXREG_ZOUT;Dir. Zuid-Holland - Regionaal zoutmeetnet;HOLLSIJSL;Hollandsche IJssel;KRIMPADIJSLK;Krimpen a/d IJssel linker oever (kilometer 18.0);P     ;RD    ;9946325   ;43679456  ;-999999999;-999999999;-999999999;-999999999;-999999999;-999999999;      ;F072  ;Berekende chloride concentratie - methode NDB '80-'81;VELDMTG;Veldmeting, directe bepaling in het veld;NVT   ;Niet van toepassing;NVT   ;Niet van toepassing;TE    ;NAP   ;-550  ;9946325   ;43679456  ;-999999999;min   ;10    ;01 01 2017;00:00     ;21 11 2017;23:50     ;CENT  ;      ;      ;      ;      ;      ;      ;      ;      ;      ;      ;-999999999;-999999999;-999999999;-999999999;-999999999;-999999999;-999999999;-999999999;01 01 2017;00:00;      ;194,000000;0     ;G
        
        %variables to be read once
        var_once={'parcod','ehdcod','crdtyp','loc_xcrdgs','loc_ycrdgs','bemhgt','syscod','loccod'};
        idx_parameter=1;
        idx_eenheid=2;
        idx_epsg=3;
        idx_x=4;
        idx_y=5;
        idx_bemonsteringshoogte=6;
        idx_tzone=7;
        idx_location=8;
        
        %variables to save with time
        var_time={'datum','tijd','waarde'};
        idx_datum=1;
        fmt_datum='dd MM yyyy';
        idx_tijd=2;
        fmt_tijd='HH:mm';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'loccod'};
        
        
        fdelim=';';
        headerlines=1;
    case 10 %same as 11 with time zone and getting location from locatie code, needs to be before for getting it prior to the other one
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
%
%MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE                           ;LOCATIE_CODE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;CAS_NR    ;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                  ;WAARDEBEPALINGSMETHODE_CODE;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;REFERENTIE;WAARNEMINGTIJD (MET/CET);LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME;GROEPERING_OMSCHRIJVING;GROEPERING_CODE;GROEPERING_KANAAL;GROEPERING_TYPE
%                     ;Hoek van Holland rechter oever (kilometer 1030.1);HOEKVHLRTOVR;                     ;             ;(massa)Concentratie   ;CONCTTE        ;chloride              ;Cl             ;16887-00-6;mg/l        ;uitgedrukt in chloor     ;Cl               ;Oppervlaktewater         ;OW               ;                                    ;                            ;Berekende chloride concentratie - methode NDB '80-'81;other:F072                 ;Steekbemonstering              ;SB                     ;31-12-2017     ;00:00:00  ;                        ;             ;11089          ;                   ;Normale waarde        ;Gecontroleerd;ZHXXREG_ZOUT             ;                         ;                 ;                                  ;                          ;                                    ;                            ;-250               ;NAP           ;25831;576915,135917929;5759061,05599413;;;;;;;

        %variables to save once
        var_once={'LOCATIE_CODE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE','BEMONSTERINGSHOOGTE'};
%         var_once={'LOCATIE_CODE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE','BEMONSTERINGSHOOGTE','WAARNEMINGTIJD (MET/CET)'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_epsg=7;
        idx_hoedanigheid=8;
        idx_bemonsteringshoogte=9;
        
        %variables to save with time
        var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD (MET/CET)','NUMERIEKEWAARDE'};
%         var_time={'WAARNEMINGDATUM','REFERENTIE','NUMERIEKEWAARDE'};
        idx_datum=1;
        fmt_datum='dd-MM-yyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file. !! not needed anymore
        var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        %variable with elevation, to check and save in existing variable !!not needed anymore
        var_hog={'BEMONSTERINGSHOOGTE'};
        
        fdelim=';';
        tzone='+01:00'; %waterinfo in CET
        headerlines=1;    
        
    case 11 %same as 12 with bemonsteringhoogte, needs to be before for getting it prior to the other one
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
%
%MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE                           ;LOCATIE_CODE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;CAS_NR    ;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                  ;WAARDEBEPALINGSMETHODE_CODE;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;REFERENTIE;WAARNEMINGTIJD (MET/CET);LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME;GROEPERING_OMSCHRIJVING;GROEPERING_CODE;GROEPERING_KANAAL;GROEPERING_TYPE
%                     ;Hoek van Holland rechter oever (kilometer 1030.1);HOEKVHLRTOVR;                     ;             ;(massa)Concentratie   ;CONCTTE        ;chloride              ;Cl             ;16887-00-6;mg/l        ;uitgedrukt in chloor     ;Cl               ;Oppervlaktewater         ;OW               ;                                    ;                            ;Berekende chloride concentratie - methode NDB '80-'81;other:F072                 ;Steekbemonstering              ;SB                     ;31-12-2017     ;00:00:00  ;                        ;             ;11089          ;                   ;Normale waarde        ;Gecontroleerd;ZHXXREG_ZOUT             ;                         ;                 ;                                  ;                          ;                                    ;                            ;-250               ;NAP           ;25831;576915,135917929;5759061,05599413;;;;;;;

        %variables to save once
        var_once={'MEETPUNT_IDENTIFICATIE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE','BEMONSTERINGSHOOGTE'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_epsg=7;
        idx_hoedanigheid=8;
        idx_bemonsteringshoogte=9;
        
        %variables to save with time
%         var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD (MET/CET)','NUMERIEKEWAARDE'};
        var_time={'WAARNEMINGDATUM','REFERENTIE','NUMERIEKEWAARDE'};
        idx_datum=1;
        fmt_datum='dd-MM-yyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file. !! not needed anymore
        var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        %variable with elevation, to check and save in existing variable !!not needed anymore
        var_hog={'BEMONSTERINGSHOOGTE'};
        
        fdelim=';';
        tzone='+01:00'; %waterinfo in CET
        headerlines=1;    
    case 12 %same as 6 but timezone is actually specified but data is in referentie!
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
        %variables to save once
        var_once={'MEETPUNT_IDENTIFICATIE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_epsg=7;
        idx_hoedanigheid=8;
        
        %variables to save with time
%         var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD (MET/CET)','NUMERIEKEWAARDE'};
        var_time={'WAARNEMINGDATUM','REFERENTIE','NUMERIEKEWAARDE'};
        idx_datum=1;
        fmt_datum='dd-MM-yyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        fdelim=';';
        tzone='+01:00'; %waterinfo in CET
        headerlines=1;    
    case 13 %HbR
        if exist('fpath','var')
        [fdir,~,~]=fileparts(fpath);
        
        %features
        fpath_md_feat=fullfile(fdir,'Meta_Data_Features.csv');
        if exist(fpath_md_feat,'file')~=2
            error('features metadata file does not exist')
        end
        feat=readcell(fpath_md_feat);
        idx_l=find_str_in_cell(feat(1,:),{'FEATURE_NAME'});
        loc=feat{2,idx_l};
        
        %properties
        fpath_md_prop=fullfile(fdir,'Meta_Data_Properties.csv');
        if exist(fpath_md_prop,'file')~=2
            error('features metadata file does not exist')
        end
        prop=readcell(fpath_md_prop);
        idx_p=find_str_in_cell(prop(1,:),{'PROPERTY_NAME'});
        gro=prop{2,idx_p};
        
        str_val=sprintf('"%s_%s"',gro,loc);
        
%         var_once={''};
%         idx_location=NaN;
%         idx_x=NaN;
%         idx_y=NaN;
%         idx_parameter=NaN;
%         idx_eenheid=NaN;
%         idx_grootheid=NaN;
%         idx_epsg=NaN;
%         idx_hoedanigheid=NaN;
        
        %variables to save with time
%         var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD (MET/CET)','NUMERIEKEWAARDE'};
        var_time={'"PHENOMENON_TIME_UTC"',str_val};
        
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
%         var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        fdelim=';';
        tzone='+00:00'; 
        headerlines=1;    
        end
    case 14
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
        %variables to save once
        var_once={'Parameter','Eenheid'};
        idx_location=1;
        idx_eenheid=2;
%         idx_x=2;
%         idx_y=3;
%         idx_parameter=4;
%         
%         idx_grootheid=6;
%         idx_epsg=7;
%         idx_hoedanigheid=8;
        
        %variables to save with time
%         var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD (MET/CET)','NUMERIEKEWAARDE'};
        var_time={'Datum','Tijd','Waarde'};
        idx_datum=1;
        fmt_datum='dd-MM-yyyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'Parameter'};
        
        fdelim=',';
        tzone='+01:00'; %?
        headerlines=1;    
    otherwise
        error('You are asking for an inexisteng file type')

end %file_type

end %get_vars

%%

function file_type=get_file_type(fpath)

%% open and header

fid=fopen(fpath,'r');
fline=fgetl(fid); %first line
fclose(fid);

keep_searching=true;

%% ad-hoc filetypes

%check for header with several lines of info
%very ad-hoc. This is not the nicest.

if numel(fline)>8 && strcmp(fline(1:9),'Parameter')
    file_type=7;
    keep_searching=false;
end

%HbR data
[~,fname,~]=fileparts(fpath);
if strcmp(fname,'Observations') && numel(fline)>10 && strcmp(fline(1:11),'"PHENOMENON')
    file_type=12;
    keep_searching=false;
end

%% loop 
if keep_searching
    
    file_type=1;

    while keep_searching
        [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_param,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg]=get_file_data(file_type);
        tok_header=regexp(fline,fdelim,'split');
        idx_var_once=find_str_in_cell(tok_header,var_once);
        idx_var_time=find_str_in_cell(tok_header,var_time);    
    %     idx_var_loc =find_str_in_cell(tok_header,var_loc );
        %it is possible to make it in one expression, but it gets unreadable
        if ~isempty(var_once{1,1}) 
            if any(isnan(idx_var_once))  || numel(var_once)~=numel(idx_var_once) || any(isnan(idx_var_time)) || numel(var_time)~=numel(idx_var_time)
                file_type=file_type+1;
            else
                keep_searching=false;
            end
        else
            if any(isnan(idx_var_time)) || numel(var_time)~=numel(idx_var_time)
                file_type=file_type+1;
            else
                keep_searching=false;
            end
        end
    end %keep_searching
end %keep searching

end %get_file_type

%%

function tok=get_clean_line(fid,fdelim)

tok{1,1}='';
kc=1;
klim=10; %number of emtpy lines to allow
while all(cellfun(@(X)isempty(X),tok))
fline=fgetl(fid); 
tok=regexp(fline,fdelim,'split');
if strcmp(fdelim,' ') %this is only an issue if separator is space, although it could be passed to all cases
    bol_val=~cellfun(@(X)isempty(X),(tok(:)));
    tok=tok(bol_val);
end %strcmp
kc=kc+1;
if kc==klim
    error('too many empty lines.')
end %kc
end %while
end %function

%%

function [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid,location,parameter,x,y,bemonsteringshoogte,headerlines,idx_var_time,idx_bemonsteringshoogte,idx_tzone,var_hog]=empty_file_structure

idx_location=NaN;
var_once={''};
idx_var_time=NaN;
var_time={''};
var_loc={''};
var_hog={''};
parameter=NaN;
location=NaN;
idx_grootheid=NaN;
grootheid=NaN;
idx_eenheid=NaN;
eenheid=NaN;
idx_epsg=NaN;
idx_raai=NaN;
idx_x=NaN;
x=NaN;
idx_y=NaN;
y=NaN;
idx_parameter=NaN;
idx_time=NaN; %date+time
fmt_time='';
idx_datum=NaN; %date
fmt_datum='';
idx_tijd=NaN; %time
fmt_tijd='';
epsg=NaN;
idx_hoedanigheid=NaN;
hoedanigheid='';
idx_bemonsteringshoogte=NaN;
bemonsteringshoogte=NaN;
headerlines=NaN;
fdelim=',';
idx_waarheid=NaN;
idx_tzone=NaN;
tzone=NaN;

end 

%%
%% read_meta_data_01
%%

function [location,epsg,x,y,bemonsteringshoogte,grootheid,eenheid,hoedanigheid]=read_meta_data_01(fpath)

[fdir,~,~]=fileparts(fpath);

%features
fpath_md_feat=fullfile(fdir,'Meta_Data_Features.csv');
if exist(fpath_md_feat,'file')~=2
    error('features metadata file does not exist')
end
feat=readcell(fpath_md_feat);

idx_l=find_str_in_cell(feat(1,:),{'FEATURE_NAME'});
location=feat{2,idx_l};

idx_l=find_str_in_cell(feat(1,:),{'WKID'});
epsg=feat{2,idx_l};

idx_l=find_str_in_cell(feat(1,:),{'X'});
x=feat{2,idx_l};

idx_l=find_str_in_cell(feat(1,:),{'Y'});
y=feat{2,idx_l};

idx_l=find_str_in_cell(feat(1,:),{'Z (m to NAP)'});
bemonsteringshoogte=undutchify(feat{2,idx_l});

%properties
fpath_md_prop=fullfile(fdir,'Meta_Data_Properties.csv');
if exist(fpath_md_prop,'file')~=2
    error('features metadata file does not exist')
end
prop=readcell(fpath_md_prop);

idx_p=find_str_in_cell(prop(1,:),{'PROPERTY_NAME'});
grootheid=prop{2,idx_p};
        
idx_p=find_str_in_cell(prop(1,:),{'UNIT_OF_MEASUREMENT'});
eenheid=prop{2,idx_p};

idx_p=find_str_in_cell(prop(1,:),{'DATUM'});
hoedanigheid=prop{2,idx_p};

end %read_meta_data_01