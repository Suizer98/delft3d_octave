function [longname, cf_name, sdn_uom_urn] = resolve_ehd(code,varargin)
%RESOLVE_EHD convert donar units code to english long_name, CF UDUNITS units,...
%
%   [longname,cf_udunits] = resolve_ehd(code)
%
% resolves DONAR units longname "ehdoms" + CF UDunits units from DONAR datamodel "ehdcod"
% published as web service here (we use csv format as it is smaller and extendable compared to RDF xml):
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=ehd&order=code
% manually extended with CF compliant UDunits units. Loading the cache the 1st
% time is slow, but the internal DB is persistent, so any 2nd time is faster.
%
% Example: resolve_ehd('doC') = 'decidegree_Celsius'
%
% To be applied to field EHD{2} from donar.read_header().
%
%See also: resolve_wns, convert_units, 
% http://www.unidata.ucar.edu/software/udunits/udunits-2/udunits2.html#Introduction
% http://coastwatch.pfeg.noaa.gov/erddap/convert/units.html
% https://data.overheid.nl/data/dataset/rws-donar-metis-service-rijkswaterstaat
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en

%% source (mind lang=nl or lang=en)
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=ehd
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=ehd&order=code&format=xml
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=ehd&order=code&format=txt

% TO DO: add BODC SeaDataNet P06
% TO DO: vectorize

%%

if isnumeric(code)
   code = num2str(code);
end

%% load cache

persistent EHD  % cache this as it takes too long to load many times
if isempty(EHD)
   disp('Loading persistent cache of DONAR units ...')
   EHD = csv2struct([fileparts(mfilename('fullpath')),filesep,'ehd_en.csv'],'delimiter',';');
end

%%

index = find(strcmpi(EHD.ehdcod,code));
if isempty(index)
    disp(['DONAR ehdcod units not in database cache: ',code])
    disp(['http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=ehd&order=code'])
    error('.')
else
    
    longname = EHD.ehdoms{index};
    
    if isfield(EHD,'units')
    cf_name  = EHD.units{index}; % not always present
    else
    cf_name  = '';
    end
    
    if isfield(EHD,'P06')
    sdn_uom_urn  = EHD.P06{index}; % not always present
    else
    sdn_uom_urn  = '';
    disp([code,' not mapped to SDN P06 urn yet.'])
    end
    
    if isempty(cf_name)
        disp([code,' not mapped to CF UDunits yet.'])
    end
    
end

