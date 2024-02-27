function urlstr = getMeteoUrl(meteosource,cycledate,cyclehour,varargin)
%GETMETEOURL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getMeteoUrl(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getMeteoUrl
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
%       Wiebe de Boer
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Oct 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getMeteoUrl.m 18433 2022-10-12 16:05:49Z ormondt $
% $Date: 2022-10-13 00:05:49 +0800 (Thu, 13 Oct 2022) $
% $Author: ormondt $
% $Revision: 18433 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/getMeteoUrl.m $
% $Keywords: $

%%
% OPT.keyword=value;
% OPT = setproperty(OPT,varargin{:});
% 
% if nargin==0;
%     varargout = OPT;
%     return;
% end

forecasthour=0;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'forecasthour'}
                forecasthour=varargin{ii+1};
        end
    end
end

%% code
switch lower(meteosource)
    case{'hirlam'}
        if floor(now)>cycledate+31
            ystr=num2str(year(cycledate));
            mstr=num2str(month(cycledate),'%0.2i');
            urlstr=['http://opendap-matroos.deltares.nl/thredds/dodsC/archive/maps2d/' ystr '/knmi_hirlam_maps/' ystr mstr '/' datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
        else
            urlstr=['http://opendap-matroos.deltares.nl/thredds/dodsC/maps2d/knmi_hirlam_maps/' datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
        end
    case{'ncep_gfs_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/analysis_complete';
    case{'ncep_gfs'}
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_GFS/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfs_3_' datestr(cycledate,'yyyymmdd')  '_' num2str(cyclehour,'%0.2i') '00_fff'];
    case{'gfs1p0'}
%        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs/gfs' datestr(cycledate,'yyyymmdd') '/gfs_' num2str(cyclehour,'%0.2i') 'z'];
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_1p00/gfs' datestr(cycledate,'yyyymmdd') '/gfs_1p00_' num2str(cyclehour,'%0.2i') 'z'];    
    case{'gfs0p5'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_0p50/gfs' datestr(cycledate,'yyyymmdd') '/gfs_0p50_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gfs0p25'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs' datestr(cycledate,'yyyymmdd') '/gfs_0p25_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gfs0p25_1hr'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25_1hr/gfs' datestr(cycledate,'yyyymmdd') '/gfs_0p25_1hr_' num2str(cyclehour,'%0.2i') 'z'];
    case{'nam'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/nam/nam' datestr(cycledate,'yyyymmdd') '/nam_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gdas'}
        if year(now)~=year(cycledate)
            ystr=num2str(year(cycledate));
            mstr=num2str(month(cycledate),'%0.2i');
            dr=[ystr mstr '/'];
            extstr='';
        else
            dr='';
            extstr='.grib2';
        end
        urlstr=['http://nomad3.ncep.noaa.gov:9090/dods/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
%        urlstr=['http://nomad3.ncep.noaa.gov:9090/pub/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
    case{'ncep_nam'}
        ystr=num2str(year(cycledate));
        mstr=num2str(month(cycledate),'%0.2i');
        dr=[ystr mstr '/'];
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_NAM/' dr datestr(cycledate,'yyyymmdd') '/nam_218_' datestr(cycledate,'yyyymmdd') '_' num2str(cyclehour,'%0.2i') '00_fff'];
    case{'ncepncar_reanalysis'}
        urlstr='http://nomad3.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-1/6hr/grb2d/grb2d';
    case{'ncepncar_reanalysis_2'}
        urlstr='http://nomad3.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-2/6hr/pgb/pgb';
    case{'ncep_nam_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/Anl_Complete';
    case{'ncep_nam_analysis_precip'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/3hr_Pcp';
    case{'ncep_gfs_analysis_precip'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/3hrPrecip';
%     case{'hirlam'}
%         url='http://matroos.deltares.nl:8080/opendap/maps/normal/knmi_hirlam_maps/';
%         ncfile=[datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
%         urlstr=[url ncfile];
    case{'ncep_narr'}
        ystr=num2str(year(cycledate));
        mstr=num2str(month(cycledate),'%0.2i');
        dr=[ystr mstr '/'];
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_NARR_DAILY/' dr datestr(cycledate,'yyyymmdd') '/narr-a_221_' datestr(cycledate,'yyyymmdd') '_' num2str(cyclehour,'%0.2i') '00_000'];
    case{'nam_hawaiinest'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/nam/nam' datestr(cycledate,'yyyymmdd') '/nam_hawaiinest_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gfs_anl4'}
        urlstr=['http://nomads.ncdc.noaa.gov/thredds/dodsC/gfs-004-anl/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfsanl_4_' datestr(cycledate,'yyyymmdd') '_' datestr(cycledate,'HHMM') '_' num2str(forecasthour,'%0.3i') '.grb2'];
    case{'gfs_anl3'}
        urlstr=['http://nomads.ncdc.noaa.gov/thredds/dodsC/gfs-003-anl/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfsanl_3_' datestr(cycledate,'yyyymmdd') '_' datestr(cycledate,'HHMM') '_' num2str(forecasthour(1),'%0.3i') '.grb'];
    case{'gfs_anl_0p50'}
        urlstr=['https://www.ncei.noaa.gov/thredds/dodsC/model-gfs-g4-anl-files/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfs_4_' datestr(cycledate,'yyyymmdd') '_' datestr(cycledate,'HHMM') '_' num2str(forecasthour(1),'%0.3i') '.grb2'];
end
