function OBS = ncTimeseries2obs(GRD, iYear, varargin)
%NCTIMESERIES2OBS ...  
%
% list all NETCDF Excel tables and builds Delft3d-FLOW and
% Delft3d-WAQ observation files. The choice of observation points to include
% is based on a check to the year, in order to limit the size of the list of
% observation files, and hence of the model output.
% The D3D-FLOW OBS file can be included as is in the MDF file, the D3D-WAQ 
% OBS file needs to be imported through the GUI.
%
%    OBS = ncTimeseries2obs(GRD, iYear, <keyword,value>)
%
%  where GRD is the grid structure (obtained with delft3d_io_grd or 
%  with delwaq 
%  and iYear is the year to be modeled
%  and the following <keyword,value> pairs have been implemented:
%
%   * source         'all'/'waterbase'/'cefas'
%   * prefix         is the filename prefix for the obs files
%   * refdatenum     default (datenum(1970,1,1))
%   * ncdir          locations of the Excel overview files
%   * output         'all'/'waq'/'flow'
%   * coord          'PARIJS'
%
% Example:
%  ncTimeseries2obs(GRD, iYear, 'prefix', 'zuno', 'ncdir', ...
%                   {'P:\mcdata\opendap\rijkswaterstaat\waterbase\', ...
%                   'F:\checkouts\OpenEarthRawData\cefas\nc\'});
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: SNCTOOLS
%          NC_CF_STATIONTIMESERIES2META, NC_CF_STATIONTIMESERIES

% $Id: ncTimeseries2obs.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/ncTimeseries2obs.m $
% $Keywords: $

%% Default values

OPT.source     = 'all';
OPT.output     = 'all';
OPT.prefix     = 'zunogrof';
OPT.coord      = 'PARIJS';
OPT.refdatenum = datenum(1970,1,1); 
OPT.ncdir      = { ...
    'P:\mcdata\opendap\rijkswaterstaat\waterbase\', ... % Donar data
    'F:\checkouts\OpenEarthRawData\cefas\nc\'};         % Cefas data

OPT = setproperty(OPT, varargin{:});

if (strcmpi(OPT.source, 'all'))
    OPT.dir_index = 1:length(OPT.ncdir);
elseif (strcmpi(OPT.source, 'waterbase'))
    OPT.dir_index = 1;
elseif (strcmpi(OPT.source, 'cefas'))
    OPT.dir_index = 2;
end

%% Build mask for grid in order to identify the outer edge of the domain

GRD.ind            = find(isfinite(GRD.cor.x));
GRD.tmask          = zeros(size(GRD.cor.x));
GRD.tmask(GRD.ind) = 1;
[GRD.tm, GRD.tc] = boundary(GRD.tmask);
GRD.ind = find(GRD.tc < 0);
j = 1;
for i = 2:GRD.ind(2)
    if (isfinite(GRD.tm(i,1)) && isfinite(GRD.tm(i,2)))
        GRD.xypos{j} = sprintf('%f %f', ...
            [GRD.cor.x(GRD.tm(i,1), GRD.tm(i,2)), ...
             GRD.cor.y(GRD.tm(i,1), GRD.tm(i,2))]);
        j = j + 1;
    end
end
for i = 1:length(GRD.xypos)
    a = str2num(GRD.xypos{i});
    GRD.xv(i) = a(1);
    GRD.yv(i) = a(2);
end

%% Reading all xls files in order to list all the stations

iStation = 1;
DATA = struct;
for iDir = OPT.dir_index
    OPT.xlsFiles = dir([OPT.ncdir{iDir} '*.xls']);
    for iFile = 1:length(OPT.xlsFiles)
        overview.file = [OPT.ncdir{iDir} OPT.xlsFiles(iFile).name];
        [overview.num, overview.text, overview.raw] = ...
            xlsread(overview.file, 'sheet1');
        overview.offset = 4;
        idColumn.Station = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'station_id'));
        idColumn.FileName = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'filename'));
        idColumn.Latitude = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'latitude'));
        idColumn.Longitude = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'longitude'));
        idColumn.DateMin = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'datenummin'));
        idColumn.DateMax = ...
            find(strcmpi(overview.text(overview.offset-1,:), 'datenummax'));
        for iSta = overview.offset+1:size(overview.raw, 1)
            DATA.namst{iStation}  = strtrim(overview.raw{iSta,idColumn.Station});
            DATA.lat(iStation)     = overview.raw{iSta,idColumn.Latitude};
            DATA.lon(iStation)     = overview.raw{iSta,idColumn.Longitude};
            DATA.datemin(iStation) = OPT.refdatenum + ...
                overview.raw{iSta,idColumn.DateMin};
            DATA.datemax(iStation) = OPT.refdatenum + ...
                overview.raw{iSta,idColumn.DateMax};
            [DATA.x(iStation), DATA.y(iStation)] = ...
                ctransdv(DATA.lon(iStation), DATA.lat(iStation), ...
                'LONLAT', OPT.coord);
            DATA.inDomain(iStation) = ...
                inpolygon(DATA.x(iStation), DATA.y(iStation), GRD.xv, GRD.yv);
            iStation = iStation + 1;
        end
    end
end

%% Only stations for which there is data during the modeled year are used
%% (in order to limit the size of the model files)

[listUniqueStation, idx] = unique(DATA.namst);
ind = find(DATA.inDomain(idx) & ...
    (DATA.datemin(idx) <= datenum(iYear+1,1,1)) & ...
    (DATA.datemax(idx) >= datenum(iYear,1,1)));
uniqueStruct = struct;
for iStation = 1:length(ind)
    uniqueStruct(iStation).namst = DATA.namst{idx(ind(iStation))};
    uniqueStruct(iStation).lat   = DATA.lat(idx(ind(iStation)));
    uniqueStruct(iStation).lon   = DATA.lon(idx(ind(iStation)));
    uniqueStruct(iStation).x     = DATA.x(idx(ind(iStation)));
    uniqueStruct(iStation).y     = DATA.y(idx(ind(iStation)));
    [uniqueStruct(iStation).n, uniqueStruct(iStation).m, mn] = ...
        xy2mn(GRD.cen.x, GRD.cen.y, ...
        uniqueStruct(iStation).x, uniqueStruct(iStation).y);
    uniqueStruct(iStation).k     = 0;
end

%% Build OBS structs used for output

for iSta = 1:length(uniqueStruct)
    OBS.flow.namst{iSta} = uniqueStruct(iSta).namst;
    OBS.flow.m(iSta)     = uniqueStruct(iSta).m;
    OBS.flow.n(iSta)     = uniqueStruct(iSta).n;
    OBS.waq.namst{iSta}  = uniqueStruct(iSta).namst;
    OBS.waq.x(iSta)      = uniqueStruct(iSta).x;
    OBS.waq.y(iSta)      = uniqueStruct(iSta).y;
    OBS.waq.k(iSta)      = 0;
end

%% Write .obs files

if (strcmpi(OPT.output, 'all') || strcmpi(OPT.output, 'flow'))
    delft3d_io_obs('write', [OPT.prefix '_flow' ...
        sprintf('%d', iYear) '.obs'], OBS.flow);
    fclose all;
end
if (strcmpi(OPT.output, 'all') || strcmpi(OPT.output, 'waq'))
    fid = fopen([OPT.prefix '_waq' sprintf('%d', iYear) '.obs'], 'w+');
    for i = 1:length(OBS.waq.x)
        fprintf(fid, '%f,\t'  , OBS.waq.x(i));
        fprintf(fid, '%f,\t'  , OBS.waq.y(i));
        fprintf(fid, '%d,\t'  , OBS.waq.k(i));
        fprintf(fid, '%-20s\n', OBS.waq.namst{i});
    end
    fclose(fid);
end

end %function %
%% EOF
