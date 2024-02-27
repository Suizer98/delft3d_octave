function [lon,lat,err] = getMeteoFromNomads4(meteosource, meteoname, cycledate, cyclehour, t, xlim, ylim, dirstr, parstr, pr, varargin)
%GETMETEOFROMNOMADS3  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   err = getMeteoFromNomads3(meteosource, meteoname, cycledate, cyclehour, t, xlim, ylim, dirstr, parstr, pr, varargin)
%
%   Input:
%   meteosource =
%   meteoname   =
%   cycledate   =
%   cyclehour   =
%   t           =
%   xlim        =
%   ylim        =
%   dirstr      =
%   parstr      =
%   pr          =
%   varargin    =
%
%   Output:
%   err         =
%
%   Example
%   getMeteoFromNomads3
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getMeteoFromNomads3.m 11439 2014-11-25 22:38:40Z ormondt $
% $Date: 2014-11-25 23:38:40 +0100 (Tue, 25 Nov 2014) $
% $Author: ormondt $
% $Revision: 11439 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/getMeteoFromNomads3.m $
% $Keywords: $

%%

err=[];
ntry=1;
lon=[];
lat=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'lon'}
                lon=varargin{ii+1};
            case{'lat'}
                lat=varargin{ii+1};
        end
    end
end

forecasthour=(t-cycledate)*24;
urlstr = getMeteoUrl(meteosource,cycledate,cyclehour,'forecasthour',forecasthour);

switch lower(meteosource)
    case{'gfs1p0','gfs0p5','gfs0p25','ncep_gfs_analysis','ncepncar_reanalysis','ncepncar_reanalysis_2','ncep_gfs_analysis_precip','nam_hawaiinest', ...
            'gfs_anl4'}
        xlim=mod(xlim,360);
end

mslprs=1;
switch lower(meteosource)
    case{'ncepncar_reanalysis'}
        mslprs=0;
end

try

    usenetcdfjava=getpref('SNCTOOLS','USE_NETCDF_JAVA');

    switch lower(meteosource)
        case{'hirlam'}
            setpref( 'SNCTOOLS','USE_NETCDF_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
            tms=ncread(urlstr,'time');
            tmin=datenum(1970,1,1)+tms(1)/1440;
            tmax=datenum(1970,1,1)+tms(end)/1440;
            if tms(end)<0
                % Sometimes the last (?) time in HIRLAM contains weird
                % values
                tmax=tmin+2;
            end
            lonstr='x';
            latstr='y';
            missvalstr=[];
        otherwise
%            setpref( 'SNCTOOLS','USE_NETCDF_JAVA'   , 0); 
%            tminstr=ncreadatt(urlstr,'time','minimum');
%            tmaxstr=ncreadatt(urlstr,'time','maximum');
            tminstr=nc_attget(urlstr,'time','minimum');
            tmaxstr=nc_attget(urlstr,'time','maximum');
            tminstr=deblank(strrep(tminstr,'z',''));
            tmaxstr=deblank(strrep(tmaxstr,'z',''));
            for i=1:10
                try
                    tmin=datenum(tminstr(3:end),'ddmmmyyyy')+str2double(tminstr(1:2))/24;
                    tmax=datenum(tmaxstr(3:end),'ddmmmyyyy')+str2double(tmaxstr(1:2))/24;
                    break
                catch
                    pause(0.1);
                end
            end
            lonstr='lon';
            latstr='lat';
            missvalstr='missing_value';
    end
    
%    timdim=nc_info(urlstr,'time');
    tim=nc_varget(urlstr,'time');
    nt=length(tim);
%    try
%        nt=timdim.Length;
%    catch
%        nt=timdim.Size;
%    end
    
    if nt==1
        it1=1;
        it2=1;        
    else
        dt=(tmax-tmin)/(nt-1);
        times=tmin:dt:tmax;
        if ~isempty(t)
            it1=find(abs(times-t(1))<0.01,1,'first');
            it2=find(times<=t(end),1,'last');
        else
            it1=0;
            it2=length(times)-1;
        end
    end
    
    if isempty(it1)
        it1=1;
    end
    
    %% Longitude
%    lon=ncread(urlstr,lonstr);
    if isempty(lon)
        lon=nc_varget(urlstr,lonstr);
    end
    if ~isempty(xlim)
        ilon1=find(lon<=xlim(1), 1, 'last' );
        ilon2=find(lon>=xlim(2), 1 );
        if isempty(ilon1)
            ilon1=1;
        end
        if isempty(ilon2)
            ilon2=length(lon);
        end
    else
        ilon1=1;
        ilon2=length(lon);
    end
    
    %% Latitude
%    lat=ncread(urlstr,latstr);
    if isempty(lat)
        lat=nc_varget(urlstr,latstr);
    end
%     flipvert=0;
%     if lat(1)>lat(end)
%         lat=flipud(lat);
%         flipvert=1;
%     end
    if ~isempty(ylim)
        ilat1=find(lat<=ylim(1), 1, 'last' );
        ilat2=find(lat>=ylim(2), 1 );
        if isempty(ilat1)
            ilat1=1;
        end
        if isempty(ilat2)
            ilat2=length(lat);
        end
    else
        ilat1=1;
        ilat2=length(lat);
    end
%     if flipvert
%         ilat1a=ilat1;
%         ilat1=length(lat)-ilat2;
%         ilat2=length(lat)-ilat1a;
%     end    
    
    npar = length(parstr);
    
    for i=1:npar
        
        tic
        disp(['Loading ' parstr{i} ' ...']);
        ok=0;
        nok=0;
        while nok<ntry
            try
%                data=ncread(urlstr,parstr{i},[it1-1 ilat1-1 ilon1-1],[it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1]);
                data=nc_varget(urlstr,parstr{i},[it1-1 ilat1-1 ilon1-1],[it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1]);
                nok=ntry;
                ok=1;
            catch
                disp(['Failed loading ' parstr{i} ' - trying again ...']);
                nok=nok+1;
                pause(5);
            end
        end
        toc
        if ~ok
            err=['could not download ' parstr{i}];
            return
        end
        
        d.(parstr{i})=data;
        
        if ~isempty(missvalstr)
%            nanval1=ncreadatt(urlstr,parstr{i},'missing_value');
            nanval1=nc_attget(urlstr,parstr{i},'missing_value');
            d.(parstr{i})(d.(parstr{i})==nanval1)=NaN;
        end
        
        switch lower(parstr{i})
            case{'tmp2m'}
                tmpmax=max(max(max(d.(parstr{i}))));
                if tmpmax>200
                    % Probably Kelvin i.s.o. Celsius
                    d.(parstr{i})=d.(parstr{i})-273.15;
                end
        end

        if ~mslprs
            switch lower(parstr{i})
                case{'pressfc'}
%                    lnd=ncread(urlstr,'landsfc',[it1-1 ilat1-1 ilon1-1],[it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1]);
                    lnd=nc_varget(urlstr,'landsfc',[it1-1 ilat1-1 ilon1-1],[it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1]);
                    d.(parstr{i})(lnd==1)=NaN;
            end
        end
        
        nlon=(ilon2-ilon1);
        nlat=(ilat2-ilat1);
        dlon=(lon(ilon2)-lon(ilon1))/nlon;
        dlat=(lat(ilat2)-lat(ilat1))/nlat;
        x=lon(ilon1):dlon:lon(ilon2);
        y=lat(ilat1):dlat:lat(ilat2);
        
    end
    
    %% Output
    k=0;
    for ii=it1:it2
        k=k+1;
        for j=1:npar
            tstr=datestr(times(ii),'yyyymmddHHMMSS');
            s=[];
            s.t=times(ii);
            s.dLon=dlon;
            s.dLat=dlat;
            s.lon=x;
            s.lat=y;
            if ndims(d.(parstr{j}))==2
                s.(pr{j})=squeeze(d.(parstr{j}));
            else
                s.(pr{j})=squeeze(d.(parstr{j})(k,:,:));
            end
%             if flipvert
%                 s.(pr{j})=flipud(s.(pr{j}));
%             end
            if ~isnan(max(max(s.(pr{j}))))
                fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                disp([dirstr filesep fname]);
                save([dirstr filesep fname],'-struct','s');
            else
                % Only NaNs found, skip this file...
                %                 sz=size(s.(pr{j}));
                %                 s.(pr{j})=zeros(sz);
                %                 fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                %                 disp([dirstr filesep fname]);
                %                 save([dirstr filesep fname],'-struct','s');
            end
        end
    end
    
catch
    
    disp('Something went wrong downloading meteo data');
    a=lasterror;
    disp(a.stack(1));
    
end

%switch lower(meteosource)
%    case{'hirlam'}
        setpref ( 'SNCTOOLS','USE_NETCDF_JAVA'   , usenetcdfjava);
%end
    
%%
function tmin=GetDatenum(tmin)
tmin=strread(tmin,'%s','delimiter','"','whitespace','');
tmin=tmin{2};
tminHH=tmin(1:2);
tmindd=tmin(4:5);
tminmmm=tmin(6:8);
tminyyyy=tmin(9:12);
tmin=[tmindd '-' tminmmm '-' tminyyyy ' ' tminHH ':00'];
tmin=datenum(tmin);

%%
function y=year(t)
dv=datevec(t);
y=dv(1);

%%
function m=month(t)
dv=datevec(t);
m=dv(2);

%%
function i=fieldNr(s,fld,val)
for i=1:length(s)
    if strcmpi(s(i).(fld),val)
        break
    end
end

