function varargout = resolve_wns(code,varargin)
%resolve_wns   convert donar code to english long_name, CF standard name, ...
%
%  [longname,cf_name, netcdf_name, <sdn_parameter_urn>] = donar.resolve_wns(code)
%
% resolves DONAR longname "wnsoms" + CF standard name from DONAR datamodel "wnsnum"
% published as web service here (we use csv format as it is smaller and extendable compared to RDF xml):
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=wns&order=code
% manually extended with CF compliant standared_names. Loading the cache the 1st
% time is slow, but the internal DB is persistent, so any 2nd time is faster.
%
% To be applied to field WNS from donar.read_header().
%
% One output argument can be chosen to be a struct with all columns from csv database or
% just one specific column with keyword request is 'struct' or the column csv name respectively.
%  [] = donar.resolve_wns(code)
%
%See also: resolve_ehd, CF standard_names: http://cf-pcmdi.llnl.gov/documents/cf-standard-names/
% https://data.overheid.nl/data/dataset/rws-donar-metis-service-rijkswaterstaat
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en

%% source (mind lang=nl or lang=en)
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns&order=code&format=xml
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns&order=code&format=txt

% TO DO: add BODC SeaDataNet P01
% TO DO: vectorize

OPT.request = 'auto';

OPT = setproperty(OPT,varargin);

%%

if ischar(code)
   codestr = code;
   code    = str2num(code);
else
   codestr = num2str(code);
end

%% load cache

persistent WNS  % cache this as it takes too long to load many times
if isempty(WNS)
   disp('Loading persistent cache of DONAR variable names ...')
   WNS = csv2struct([fileparts(mfilename('fullpath')),filesep,'wns_en.csv'],'delimiter',';');
end

if ischar(WNS.wnsnum)% csv2struct is not always consistent
   WNS.wnsnum = str2num(WNS.wnsnum);
end

%%

index = find(WNS.wnsnum==code);
if isempty(index)
    disp(['DONAR wns code not in database cache: ',code])
    disp(['http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=wns&order=code'])
    error('.')
elseif strcmpi(OPT.request,'struct')
    varargout = {structsubs(WNS,index)};
elseif ~strcmpi(OPT.request,'auto')
    WNS1 = structsubs(WNS,index);
    varargout = {WNS1.(OPT.request)};
else
    longname      = WNS.wnsoms{index};
    
    if isfield(WNS,'standard_name')
    cf_name       = WNS.standard_name{index}; % often still empty
    else
    cf_name       = '';
    disp([codestr,' not mapped to CF standard_name yet.'])
    end
    if isempty(cf_name)
        disp([codestr,' not mapped to CF standard_name yet.'])
    end     

    
    if isfield(WNS,'deltares_name')
    deltares_name = WNS.deltares_name{index}; % not always present
    else
    deltares_name = '';
    disp([codestr,' not mapped to Deltares netCDF name yet.'])
    end
    if isempty(deltares_name)
        disp([codestr,' not mapped to Deltares netCDF name yet.'])
    end    

    
    if isfield(WNS,'P01')
    sdn_parameter_urn = WNS.P01{index}; % not always present
    else
    sdn_parameter_urn = '';
    disp([codestr,' not mapped to SDN P01 code yet.'])
    end
    if isempty(sdn_parameter_urn)
        disp([codestr,' not mapped to SDN P01 code yet.'])
    end    
    
    varargout = {longname, cf_name, deltares_name, sdn_parameter_urn};
    
end
