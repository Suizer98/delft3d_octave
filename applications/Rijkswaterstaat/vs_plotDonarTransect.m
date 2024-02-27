function OPT = plotDonarTransect(NFSstruct, varargin)
%plotDonarTransect  plots measured vs. Delft3D modelled substances for each DONAR transect.
%
%    plotDonarTransect(NFSstruct, <keyword,value>)
%
%  where NFSstruct is the NEFIS structure of a trim file
%  (obtained with vs_use)
%  and the following <keyword,value> pairs have been implemented:
%
%   * transect       'all'/'Appelzak'/'Walcheren'/'Schouwen'/'Goeree'/
%                    'Ter Heide'/'Noordwijk'/'Egmond aan Zee'/
%                    'Callantsoog'/'Terschelling'/'Rottumerplaat'
%   * prefix         is the filename prefix for the obs files
%   * save           0/1
%   * substance      'sea_surface_salinity'/'concentration_of_suspended_matter_in_sea_water'
%   * cco            location of cco file for WAQ map files
%   * log            use log10(concentration) for plots
%   * format         'png'/'pdf'
%
% Example:
% plotDonarTransect(NFSstruct, 'substance', 'sea_surface_salinity', ...
%     'transect', 'Goeree', 'save', 1, 'prefix', 'my_transect');
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: rws_waterbase_get_locations, rws_WATERBASE2NC, VS_USE

% $Id: vs_plotDonarTransect.m 8476 2013-04-19 08:43:26Z boer_g $
% $Date: 2013-04-19 16:43:26 +0800 (Fri, 19 Apr 2013) $
% $Author: boer_g $
% $Revision: 8476 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/vs_plotDonarTransect.m $
% $Keywords: $
% 2009 oct 1: allow for use of log10(concentrations) instead of concentrations [Yann Friocourt]
% 2009 oct 7: allow for choice of figure format [Yann Friocourt]

if nargin < 3
   error(['At least 3 input arguments required: ' ...
       'plotDonarTransect(NFStrcut, ''substance'', substanceName'])
end

OPT.refdatenum = datenum(1970,1,1);

%% Definition transect and station names
OPT.listTransect     = {'appzk',   'walcrn',   'schouwn', 'goere', 'terhde',   'noordwk',  'egmaze',        'callog',     'terslg',      'rottmpt'};
OPT.listTransectName = {'Appelzak','Walcheren','Schouwen','Goeree','Ter Heide','Noordwijk','Egmond aan Zee','Callantsoog','Terschelling','Rottumerplaat'};
OPT.stationDist{ 1} = [1,2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 2} = [  2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 3} = [1,   4,  10,   20, 30, 50, 70];
OPT.stationDist{ 4} = [  2, 6,  10,   20, 30, 50, 70];
OPT.stationDist{ 5} = [1,2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 6} = [1,2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 7} = [1,2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 8} = [1,2, 4,  10,   20, 30, 50, 70];
OPT.stationDist{ 9} = [     4,  10,   20, 30, 50, 70, 100, 135, 175, 235];
OPT.stationDist{10} = [    3, 5,10,15,20, 30, 50, 70];

%% Directory of Waterbase data
OPT.ncBaseDir = 'P:\mcdata\opendap\rijkswaterstaat\waterbase\';

%% Season names
OPT.seasName  = {'DJF', 'MAM', 'JJA', 'SON'};

%% Default values: all transects and SPM concentrations
OPT.transect  = 'all';
OPT.substance = 'concentration_of_suspended_matter_in_sea_water';
OPT.save      = 1;
OPT.prefix    = '';
OPT.format    = 'png';
OPT.cco       = '';
OPT.log       = 0;

OPT = setproperty(OPT, varargin{:});

%% Identify specified transect
if (strcmpi(OPT.transect, 'all'))
    OPT.iTransect0 = 1;
    OPT.iTransect1 = length(OPT.listTransectName);
else
    OPT.iTransect0 = find(strcmpi(OPT.listTransectName, OPT.transect));
    OPT.iTransect1 = OPT.iTransect0;
end
if (isempty(OPT.iTransect0) || isempty(OPT.iTransect1))
    error(['Specified transect does not exist. Choose one of the ' ...
        'following: ''Appelzak'', ''Walcheren'', ''Schouwen'', ' ...
        '''Goeree'', ''Ter Heide'', ''Noordwijk'', ' ...
        '''Egmond aan Zee'', ''Callantsoog'', ''Terschelling'', ' ...
        '''Rottumerplaat''']);
end

if (strcmpi(OPT.substance, 'temperature') || ...
        strcmpi(OPT.substance, 'sea_surface_temperature') || ...
        strcmpi(OPT.substance, 'SST'))
    OPT.substance = 'sea_surface_temperature';
elseif (strcmpi(OPT.substance, 'salinity') || ...
        strcmpi(OPT.substance, 'sea_surface_salinity') || ...
        strcmpi(OPT.substance, 'SSS'))
    OPT.substance = 'sea_surface_salinity';
elseif (strcmpi(OPT.substance, 'waterlevel') || ...
        strcmpi(OPT.substance, 'water_level') || ...
        strcmpi(OPT.substance, 'sea_surface_height') || ...
        strcmpi(OPT.substance, 'SSH'))
    OPT.substance = 'sea_surface_height';
elseif (strcmpi(OPT.substance, 'spm') || ...
        strcmpi(OPT.substance, 'suspended_matter') || ...
        strcmpi(OPT.substance, 'suspended_particles'))
    OPT.substance = 'concentration_of_suspended_matter_in_sea_water';
end

%% Determine Waterbase prefix associated with specified substance
listFiles = dir([OPT.ncBaseDir OPT.substance]);
if (isempty(listFiles))
    error('Specified substance does not exist.');
end
OPT.ncPrefix = strtok(listFiles(end).name, '-');
OPT.ncDir    = [OPT.ncBaseDir OPT.substance '\'];

%% Check that filename prefix is specified if user wants to save results
if (OPT.save && isempty(OPT.prefix))
    error('Specify prefix for saving images.')
end

%% Extract time information from NFSstruct file
MODEL = vs_time(NFSstruct);
%% Extract substance information from NFSstruct file
indexSubs = vs_get_constituent_index(NFSstruct);
%% Extract timeseries from NEFIS file
MODEL.NFtype = vs_type(NFSstruct);
%if (strcmpi(MODEL.NFtype, 'Delft3D-trim'))
if (strcmpi(MODEL.NFtype, 'Delft3D-trim'))
    switch (lower(OPT.substance)),
        case 'sea_surface_height'
            MODEL.data = vs_let(NFSstruct, ...
                'map-series', 'ZWL', {0, 0, 1});
        case 'sea_surface_salinity'
            MODEL.data = vs_let(NFSstruct, ...
                indexSubs.salinity.groupname, {0}, ...
                indexSubs.salinity.elementname, ...
                {0, 0, 1, indexSubs.salinity.index});
    end
    MODEL.GRD.cen.x = vs_get(NFSstruct, 'map-const', 'XZ');
    MODEL.GRD.cen.y = vs_get(NFSstruct, 'map-const', 'YZ');
elseif (strcmpi(MODEL.NFtype, 'Delft3D-waq-map'))
    if (isempty(OPT.cco))
        error('You must specify a cco/lga file name.');
    else
        MODEL.GRD = delwaq_meshgrid2dcorcen(OPT.cco);
    end
    switch (lower(OPT.substance)),
        case 'sea_surface_salinity'
            tmp.data = vs_let(NFSstruct, ...
                indexSubs.salinity.groupname, {0}, ...
                indexSubs.salinity.elementname, {0});
        case 'concentration_of_suspended_matter_in_sea_water'
            tmp.data = vs_let(NFSstruct, ...
                indexSubs.TIM.groupname, {0}, ...
                indexSubs.TIM.elementname, {1:MODEL.GRD.NoSegPerLayer});
    end
    MODEL.data = NaN + zeros(size(tmp.data,1), size(MODEL.GRD.cen.x,1), size(MODEL.GRD.cen.x,2));
    for i = 1:size(tmp.data, 1)
        MODEL.data(i,:,:) = waq2flow2d(squeeze(tmp.data(i,:)), MODEL.GRD.Index(:,:,1),'cen');
    end
else
    error('Routine only implemented for FLOW or WAQ map (NEFIS) files.');
end
if OPT.log
    MODEL.data = log10(MODEL.data);
end
MODEL.name = NFSstruct.FileName;
[MODEL.Y, M, D, H, MN, S] = datevec(MODEL.datenum);
for iSeas = 1:4
    SEAS.MODEL.idx{iSeas} = find((mod(M,12) >= (iSeas-1)*3) & ...
        (mod(M, 12) < iSeas*3));
end

for iTransect = OPT.iTransect0:OPT.iTransect1
    for iStation = 1:length(OPT.stationDist{iTransect})
        OPT.listFile = dir([OPT.ncDir OPT.ncPrefix '-' ...
            upper(OPT.listTransect{iTransect}) ...
            sprintf('%d', OPT.stationDist{iTransect}(iStation)) ...
            '-179805240000-*.nc']);
        OPT.ncFile = OPT.listFile(1).name;
        disp(OPT.ncFile)
        OBS.datenum{iStation} = OPT.refdatenum + ...
            nc_varget([OPT.ncDir OPT.ncFile], 'time');
        OBS.data{iStation} = nc_varget([OPT.ncDir OPT.ncFile], ...
            OPT.substance);
        if OPT.log
            OBS.data{iStation} = log10(OBS.data{iStation});
        end
        OBS.lon(iStation) = nc_varget([OPT.ncDir OPT.ncFile], 'lon');
        OBS.lat(iStation) = nc_varget([OPT.ncDir OPT.ncFile], 'lat');
        [OBS.xParis(iStation), OBS.yParis(iStation)] = ...
            lonlat2xy_par(OBS.lon(iStation), OBS.lat(iStation));
        [MODEL.MNSEG{iTransect}.M(iStation), ...
            MODEL.MNSEG{iTransect}.N(iStation)] = ....
            xy2mn(MODEL.GRD.cen.x, MODEL.GRD.cen.y, ...
            OBS.xParis(iStation), OBS.yParis(iStation));
    end
    figure(iTransect);
    clf('reset');
    for iSeas = 1:4
        subplot(2,2,iSeas)
        hold on;
        for iStation = 1:length(OPT.stationDist{iTransect})
            errorbar(OPT.stationDist{iTransect}(iStation), ...
                mean(MODEL.data(SEAS.MODEL.idx{iSeas}, ...
                MODEL.MNSEG{iTransect}.M(iStation), ...
                MODEL.MNSEG{iTransect}.N(iStation))), ...
                std(MODEL.data(SEAS.MODEL.idx{iSeas}, ...
                MODEL.MNSEG{iTransect}.M(iStation), ...
                MODEL.MNSEG{iTransect}.N(iStation))), '*');
            [Y, M, D, H, MN, S] = datevec(OBS.datenum{iStation});
            %% First plot statistics based on all records
            SEAS.OBS.idx = find((mod(M,12) >= (iSeas-1)*3) & ...
                (mod(M,12) < iSeas*3));
            if (~isempty(SEAS.OBS.idx))
                errorbar(OPT.stationDist{iTransect}(iStation), ...
                    mean(OBS.data{iStation}(SEAS.OBS.idx)), ...
                    std(OBS.data{iStation}(SEAS.OBS.idx)), 'ko');
            end
            %% Then only statistics for the modeled year
            SEAS.OBS.idx = find((Y >= min(MODEL.Y)) & ...
                (Y <= max(MODEL.Y)) & (mod(M,12) >= (iSeas-1)*3) & ...
                (mod(M,12) < iSeas*3));
            if (~isempty(SEAS.OBS.idx))
                errorbar(OPT.stationDist{iTransect}(iStation), ...
                    mean(OBS.data{iStation}(SEAS.OBS.idx)), ...
                    std(OBS.data{iStation}(SEAS.OBS.idx)), 'ro');
            end
        end
        title([OPT.listTransectName{iTransect} ' - ' ...
            OPT.prefix ' - ' OPT.seasName{iSeas}]);
        xlabel('Offshore distance (km)');
        ylabel(OPT.substance);
        hold off;
    end
    if (OPT.save)
        orient landscape;
        print([OPT.prefix '_transect_' ...
            OPT.listTransectName{iTransect} '.' OPT.format], ...
            ['-d' OPT.format]);
    end
end %variable loop % for iTransect = OPT.iTransect0:OPT.iTransect1

return;
end %function %
%% EOF