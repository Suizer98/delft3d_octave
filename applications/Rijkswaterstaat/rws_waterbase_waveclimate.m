function [seriesTime, seriesTimeHeightData, seriesWaveHeight] = rws_waterbase_waveclimate(varargin)
%RWS_WATERBASE_WAVECLIMATE  Creates wave climate from Rijkswaterstaat waterbase data.
%
%   This function takes the netcdf version from the data from the waterbase website from
%   Rijkswaterstaat, and creates a wave climate for certain locations and
%   time period, weighted by wave height. If no timeframe is provided, a GUI will pop up. 
%
%   The required data can be obtained from the Deltares
%   OpenDaP server (default argument). Note however that these data are
%   outdated. To obtain the latest data, create a local netcdf copy using
%   rws_waterbase_all.
%
%   Syntax:
%   varargout = rws_waterbase_waveclimate(varargin)
%
%   Input:
%   varargin  =
%       'baseurl'  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/';
%       'time' = [];                    % Start and end date of wave input data. Format: [yyyymmdd yyyymmdd]
%       'outputrawdata' = 1;            % output raw data to file?
%       'orawfilename' = '';            % filename for output raw data, leave empty if multiple stations
%       'classificationpars' = [];      % Vector with classif. params. Format: [hs0,dhs,nhs,dir0,ddir,ndir]
%       'oclimfilename' = '';           % filename for output climate data, leave empty if multiple stations
%
%
%   Output:
%   varargout =
%       none
%
%   Example
%   rws_waterbase_waveclimate({'outputrawdata',0,'classificationpars',[0 0.5 5 5 10 36]})
%
%   See also
%       rws_waterbase_get_url, rws_waterbase_get_locations,
%       rws_waterbase_all

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 UNESCO-IHE
%       Johan Reyns, Dano Roelvink
%
%       {j.reyns,d.roelvink}@unesco-ihe.org
%
%       P.O. Box 3015
%       2601 DA Delft
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
% Created: 15 Apr 2013
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: rws_waterbase_waveclimate.m 13370 2017-05-24 09:08:04Z vermaas $
% $Date: 2017-05-24 17:08:04 +0800 (Wed, 24 May 2017) $
% $Author: vermaas $
% $Revision: 13370 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_waveclimate.m $
% $Keywords: $

%% Init

OPT.strmatch           = 'exact';
OPT.version            = 2; % 1 is before summer 2009, 2 is after mid dec 2009
OPT.baseurl            = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/';
OPT.time               = [];     % dummy
OPT.outputrawdata      = 1;      % output raw data to file?
OPT.orawfilename       = '';         % filename for output raw data, leave empty if multiple stations
OPT.classificationpars = [];    % hs0,dhs,nhs,dir0,ddir,ndir
OPT.oclimfilename      = '';         % filename for output climate data, leave empty if multiple stations

OPT = setproperty(OPT,varargin{:});

%% Get pre-defined location names

LOC = [];
while isempty(LOC)
    LOC = rws_waterbase_get_locations(22,'22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater');
    if isempty(LOC)
        fprintf(2,[OPT.baseurl,' failed. Trying again to get list of: Stations']);
        pause(5)
    end
end
[indLoc, ok] = listdlg('ListString', LOC.FullName, ...
    'SelectionMode', 'multiple', ...
    'InitialValue' , [1:length(LOC.FullName)], ...
    'PromptString' , 'Select the locations', ....
    'Name'         , 'Selection of locations');
if (ok == 0); return; end

if length(indLoc)>1
    disp(['message: rws_waterbase_waveclimate: Location    ',num2str(length(indLoc),'%0.3d'),'x: #',num2str(indLoc(:)','%0.3d,')])
else
    disp(['message: rws_waterbase_waveclimate: Location  # ',num2str(indLoc,'%0.3d'),': ',LOC.ID{indLoc},' "',LOC.FullName{indLoc},'"'])
end

%% Times

if ~isempty(OPT.time)
    indDate   = OPT.time;
    startdate = [datestr(indDate(1),'yyyymmddHHMM')]; %,'01010000'];
    enddate   = [datestr(indDate(2),'yyyymmddHHMM')]; %,'12312359'];
    ok        = 1;
else
    ListYear  = '1961';
    for iYear = 1962:str2num(datestr(date,'yyyy'))
        ListYear = strvcat(ListYear, sprintf('%d', iYear));
    end
    ListYear  = cellstr(ListYear);
    
    [indDate, ok] = listdlg('ListString', ListYear, ...
        'SelectionMode', 'multiple', ...
        'InitialValue' , [length(ListYear)], ...
        'PromptString' , 'Select the year', ....
        'Name'         , 'Selection of year');
    
    if (ok == 0)
        return;
    end
    startdate = [ListYear{min(indDate)} '01010000'];
    enddate   = [ListYear{max(indDate)} '12312359'];
end

disp(['message: rws_waterbase_waveclimate: startdate        ',startdate]);
disp(['message: rws_waterbase_waveclimate: enddate          ',enddate]);

h = waitbar(0,'Downloading data...');

for iLoc=1:length(indLoc)
    
    urlNameWaveHeight    = [OPT.baseurl,'17_Significante_golfhoogte_uit_energiespectrum_van_30-500_mhz_in_cm_in_oppervlaktewater/nc/','id22-',LOC.ID{indLoc(iLoc)},'.nc'];
    urlNameWaveDirection = [OPT.baseurl,'08_Gemiddelde_richting_uit_golfrichtingsspectrum_van_30-500_mhz_in_graad_t.o.v._kaart_noorden_in_oppervlaktewater/nc/'    ,'id23-',LOC.ID{indLoc(iLoc)},'.nc'];
    urlNameWavePeriod    = [OPT.baseurl,'07_Gem._golfperiode_uit_spectrale_momenten_m0+m2_van_30-500_mhz_in_s_in_oppervlaktewater/nc/'         ,'id24-',LOC.ID{indLoc(iLoc)},'.nc'];
    
    %% Perform operation on three separate time series, as they are not
    %% necessarily synchronous
    seriesTimeHeight = nc_varget(urlNameWaveHeight,'time');
    seriesTimePeriod = nc_varget(urlNameWavePeriod,'time');
    seriesTimeDirection = nc_varget(urlNameWaveDirection,'time');
    
    seriesTimeHeightStart = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimeHeight   >=datenum(startdate,'yyyymmddHHMM'),1,'first');
    seriesTimeHeightEnd   = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimeHeight   <=datenum(enddate  ,'yyyymmddHHMM'),1,'last');
    seriesTimePeriodStart = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimePeriod   >=datenum(startdate,'yyyymmddHHMM'),1,'first');
    seriesTimePeriodEnd   = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimePeriod   <=datenum(enddate  ,'yyyymmddHHMM'),1,'last');
    seriesTimeDirStart    = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimeDirection>=datenum(startdate,'yyyymmddHHMM'),1,'first');
    seriesTimeDirEnd      = find(datenum('010119700100','ddmmyyyyHHMM')+seriesTimeDirection<=datenum(enddate  ,'yyyymmddHHMM'),1,'last');
    
    if numel(seriesTimeHeightStart)==0 || numel(seriesTimeHeightEnd)==0
        disp(['Time limits outside period of available data.. Data limits are ', datestr(datenum('01011970','ddmmyyyy')+seriesTimeHeight(1)), ' and ',datestr(datenum('01011970','ddmmyyyy')+seriesTimeHeight(end)),'. Aborting.']);
        close(h);
        return;
    end
    seriesTimeHeightData    = datenum('010119700100','ddmmyyyyHHMM')+ seriesTimeHeight(seriesTimeHeightStart:seriesTimeHeightEnd)';
    seriesTimePeriodData    = datenum('010119700100','ddmmyyyyHHMM')+ seriesTimePeriod(seriesTimePeriodStart:seriesTimePeriodEnd)';
    seriesTimeDirectionData = datenum('010119700100','ddmmyyyyHHMM')+ seriesTimeDirection(seriesTimeDirStart:seriesTimeDirEnd   )';
    seriesWaveHeight = nc_varget(urlNameWaveHeight   ,'sea_surface_wave_significant_height',[0 seriesTimeHeightStart-1],[1 seriesTimeHeightEnd-seriesTimeHeightStart+1]);
    seriesWaveDir    = nc_varget(urlNameWaveDirection,'sea_surface_wave_from_direction'    ,[0 seriesTimeDirStart-1],[1 seriesTimeDirEnd-seriesTimeDirStart+1]);
    seriesWavePeriod = nc_varget(urlNameWavePeriod   ,'sea_surface_wind_wave_tm02'         ,[0 seriesTimePeriodStart-1],[1 seriesTimePeriodEnd-seriesTimePeriodStart+1]); % Tm02
    resolution       = seriesTimeHeightData(3)-seriesTimeHeightData(2);
    resolution       = (ceil(resolution*24*60))/24/60;
    
    %% Plot raw data
    figure(iLoc*2-1);
    subplot(3,1,1);
    plot(seriesTimeHeightData,seriesWaveHeight,'-r');
    ylabel('Wave height [m]')
    datetick('x')
    subplot(3,1,2);
    plot(seriesTimePeriodData,seriesWavePeriod,'-g');
    ylabel('Wave period [s]')
    datetick('x')
    subplot(3,1,3);
    ylim([0 360]);
    plot(seriesTimeDirectionData,seriesWaveDir,'-b');
    datetick('x');
    ylabel('Wave direction [deg from N]')
    xlabel('time')
    
    %% Generate synchronous time series
    seriesTime = (floor(datenum(startdate,'yyyymmddHHMM')):resolution:ceil(datenum(enddate,'yyyymmddHHMM'))-1/24)';
    seriesWaveHeightC = NaN(length(seriesTime),1);
    seriesWavePeriodC = NaN(length(seriesTime),1); 
    seriesWaveDirC    = NaN(length(seriesTime),1); 
    
    %% Fill series with data
    [dummy,iWHa,iWHb] = intersect(round(seriesTime*10000)/10000,round(seriesTimeHeightData(:)*10000)/10000);    % to counter rounding error related to ismember implementation
    [dummy,iWPa,iWPb] = intersect(round(seriesTime*10000)/10000,round(seriesTimePeriodData(:)*10000)/10000);
    [dummy,iWDa,iWDb] = intersect(round(seriesTime*10000)/10000,round(seriesTimeDirectionData(:)*10000)/10000);
    seriesWaveHeightC(iWHa) = seriesWaveHeight(iWHb);
    seriesWavePeriodC(iWPa) = seriesWavePeriod(iWPb);
    seriesWaveDirC(iWDa)    = seriesWaveDir   (iWDb);
    clear dummy;
    
    %% Write raw data to file
    if OPT.outputrawdata
        if isempty(OPT.orawfilename)
            OPT.orawfilename = ['wavedata_',LOC.ID{indLoc(iLoc)},'_',startdate,'_',enddate,'.txt'];
        end
        clear ii;
        ofid = fopen(OPT.orawfilename,'w');
        fprintf(ofid,'%s\t%s\t%s\t%s\n','Time [yyyymmddHHMM]','Hs [m]','Tp [s]','Dir [deg]');
        for ii = 1:length(seriesTime)
            fprintf(ofid,'%s\t%.2f\t%.2f\t%.2f\n',datestr(seriesTime(ii),'yyyymmddHHMM'),seriesWaveHeightC(ii),seriesWavePeriodC(ii),seriesWaveDirC(ii));
        end
        fclose(ofid); clear ofid;
        OPT.orawfilename='';
    end
    
    %% Convert timeseries of wave height, direction and period into
    % - 2D table of percentage occurrence of wave height classes perc
    % - 2D table of weighted mean waveheight per class meanhs
    % - 2D table of weighted mean direction per class meandir
    % - 2D table of weighted mean wave period per class meantp
    % wave heights are weighted with power 2.5
    
    
    hs  = seriesWaveHeightC(:);
    dir = seriesWaveDirC(:);
    tp  = 1.2859*seriesWavePeriodC(:);      % assuming JONSWAP, gamma=3.3
    
    hs1 =  hs(find(~isnan(hs)&~isnan(dir)&~isnan(tp)));
    tp1 =  tp(find(~isnan(hs)&~isnan(dir)&~isnan(tp)));
    dir = dir(find(~isnan(hs)&~isnan(dir)&~isnan(tp)));
    hs  = hs1;
    tp  = tp1;
    
    power=2.5;
    
    if isempty(OPT.classificationpars)
        hs0  = 0;
        dhs  = 0.5;
        nhs  = 5;
        dir0 = 5;
        ddir = 10;
        ndir = 36;
    else
        if length(OPT.classificationpars)~=6
            disp('Wrong number of arguments for wave climate classification. Aborting..');
            clear all; fclose all;
            return;
        end
        hs0  = OPT.classificationpars(1);
        dhs  = OPT.classificationpars(2);
        nhs  = OPT.classificationpars(3);
        dir0 = OPT.classificationpars(4);
        ddir = OPT.classificationpars(5);
        ndir = OPT.classificationpars(6);
    end
    
    
    ind_hs =max(min(ceil((hs-hs0)/dhs),nhs),1);
    ind_dir=max(min(ceil((dir-dir0)/ddir),ndir),1);
    n     = zeros(nhs,ndir);
    s_hs  = zeros(nhs,ndir);
    s_dir = zeros(nhs,ndir);
    s_tp  = zeros(nhs,ndir);
    
    for i=1:length(hs);
        ih=ind_hs(i);
        id=ind_dir(i);
        n    (ih,id) = n(ih,id)+1;
        s_hs (ih,id) = s_hs (ih,id)+hs(i).^power;
        s_dir(ih,id) = s_dir(ih,id)+dir(i);
        s_tp (ih,id) = s_tp (ih,id)+tp(i);
        
    end;
    n(n==0)= NaN;
    perc    = n/length(hs)*100;
    meanhs  = (s_hs./n).^(1/power);
    meandir = s_dir./n;
    meantp  = s_tp./n;
    
    %% Write output p,Hs,Tp,Dir
    if isempty(OPT.oclimfilename)
        OPT.oclimfilename = ['waveclimate_',LOC.ID{indLoc(iLoc)},'_',startdate,'_',enddate,'.txt'];
    end
    
    ofid = fopen(OPT.oclimfilename,'w');
    clear ii;
    for ii = 1:size(perc,2)
        for ij = 1:size(perc,1)
            fprintf(ofid,'%.2f\t%.2f\t%.2f\t%.0f\n',perc(ij,ii),meanhs(ij,ii),meantp(ij,ii),meandir(ij,ii));
        end
    end
    fclose(ofid); clear ofid;
    OPT.oclimfilename='';
    
    %% Plot output in spiderplot
    figure(iLoc*2);
    xhs=[hs0:dhs:nhs*dhs];
    xdir=[dir0:ddir:ndir*ddir];
    perc_ext=zeros([size(perc,1)+1,size(perc,2)+1]);
    perc_ext(1:end-1,1:end-1)=perc;
    meanhs_ext=zeros([size(meanhs,1)+1,size(meanhs,2)+1]);
    meanhs_ext(1:end-1,1:end-1)=meanhs;
    meantp_ext=zeros([size(meantp,1)+1,size(meantp,2)+1]);
    meantp_ext(1:end-1,1:end-1)=meantp;
    
    for i=1:ndir+1;
        theta=(i-1)*ddir*pi/180;
        for j=1:length(xhs);
            xpol(j,i)=xhs(j)*sin(theta);
            ypol(j,i)=xhs(j)*cos(theta);
        end;
    end
    
    ticks=[-xhs(end) 0 xhs(end)];
    ticklabels=[xhs(end) 0 xhs(end)];
    
    subplot(131);
    pcolor(xpol,ypol,perc_ext);
    axis equal tight
    colorbar;
    set(gca,'fontweight','bold');
    title('percentage occurrence');
    set(gca,'ytick',ticks,'yticklabel',ticklabels,'xticklabel',[]);
    ylabel('Hs (m)')
    
    subplot(132);
    pcolor(xpol,ypol,meanhs_ext);
    axis equal tight
    colorbar;
    set(gca,'fontweight','bold');
    title('mean Hs [m]');
    set(gca,'xticklabel',[],'yticklabel',[]);
    
    subplot(133);
    pcolor(xpol,ypol,meantp_ext);
    axis equal tight
    colorbar;
    set(gca,'fontweight','bold');
    title('mean T_p [s]');
    set(gca,'xtick',ticks,'xticklabel',ticklabels,'ytick',ticks,'yticklabel',ticklabels);
    xlabel('Hs [m]');
    ylabel('Hs [m]');
    
    waitbar(iLoc/length(indLoc),h);
end
close(h);
varargout = {};
end

