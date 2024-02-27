function varargout = read_values(fname);
%read_values read Datum;Tijd;Parameter;Locatie;Meting;Eenheid from waterinfo csv file
%
%  Manually downloaded csv files can have variable number of columns, e.g.
%  Datum;Tijd;Parameter;Locatie;Meting;Eenheid;Bemonsteringshoogte;Referentievlak;
%  Datum;Tijd;Parameter;Locatie;Meting;Verwachting;Astronomisch getijden;Eenheid;Bemonsteringshoogte;Referentievlak;
%  Datum;Tijd;Parameter;Locatie;Meting;Eenheid;Windrichting;Windrichting eenheid;Bemonsteringshoogte;Referentievlak;
%
% This function reads the positon of the 8 common columns from the header:
% Datum;Tijd;Parameter;Locatie;Meting;Eenheid;Bemonsteringshoogte;Referentievlak;
%
% and parses the associated columns t (time), v (values) and m (metadata).
%
%    t    Datum
%         Tijd
%    v    Parameter
%    m    Locatie
%         Meting
%         Eenheid
%         Bemonsteringshoogte
%         Referentievlak
%
% ! TIMEZONE !
% Do note that accordig to helpdeskwater:
% the timezone for the waterdata altijd is always 
% the Dutch legal time at the moment of downloading
% (e.g.  MEZT ( UTC + 2 ) when downloading between march and 
% october) whereas the historic data download in the website part 
% ( via "Download meer data" ) are always MET ( UTC + 1 ).
%
% https://waterinfo.rws.nl/, waterinfo.read_waterlevel, DATA IN CET TIMEZONE, INCL DST.

warning('DATA IN CET TIMEZONE, INCL DST.')

OPT.delimiter    = ';';
OPT.startRow     = 2;

    fileID = fopen(fname,'r');
        header = fgetl(fileID);
    fclose(fileID);
    cols = split(header,';');

    OPT.column.date     = strmatch('Datum'    , cols);
    OPT.column.time     = strmatch('Tijd'     , cols);
    OPT.column.name     = strmatch('Parameter', cols);
    OPT.column.value    = strmatch('Meting'   , cols);
    OPT.column.unit     = strmatch('Eenheid'  , cols);
    OPT.column.location = strmatch('Locatie'  , cols);
    OPT.column.z        = strmatch('Bemonsteringshoogte', cols);
    OPT.column.zref     = strmatch('Referentievlak'     , cols);
    
    OPT.ncol         = length(cols);

    formatSpec = [repmat('%s ',[1,length(cols)]), '%[^\n\r]'];

    fileID = fopen(fname,'r');
    d = textscan(fileID,formatSpec,...
        'Delimiter',OPT.delimiter,...
        'HeaderLines',OPT.startRow-1,...
        'DateLocale','nl_NL',...
        'ReturnOnError',false);
    fclose(fileID);

    %%
    nt = length(d{1});
    D.t  = repmat(nan,[nt 1]);
    D.v  = repmat(nan,[nt 1]);

    for i=1:nt
        myd = split(d{OPT.column.date}{i},'-');
        hms= split(d{OPT.column.time}{i},':');
        D.t(i) = datenum( str2num(myd{3}),...
                        str2num(myd{2}),...
                        str2num(myd{1}),...
                        str2num(hms{1}),...
                        str2num(hms{2}),...
                        str2num(hms{3}));
        if ~isempty(d{5}{i})
            D.v(i) = str2num(d{OPT.column.value}{i});
        end
    end

    D.m.parameter = unique(d{OPT.column.name});
    D.m.location  = unique(d{OPT.column.unit});
    D.m.units     = unique(d{OPT.column.location});
    D.m.z         = unique(d{OPT.column.z});
    D.m.zref      = unique(d{OPT.column.zref});
    
    
    keys = {'parameter','location','units','z','zref'};
    for i=1:length(keys)
        key = keys{i};
        if iscell(D.m.(key))
            if length(D.m.(key))==1
                D.m.(key) = string(D.m.(key));
            end
        end
    end
    
    varargout = {D};
