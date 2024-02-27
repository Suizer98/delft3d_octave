function err = getMeteoFromMatroos(meteoname, cycledate, cyclehour, tdummy, xlim, ylim, dirstr)
%GETMETEOFROMMATROOS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   err = getMeteoFromMatroos(meteoname, cycledate, cyclehour, tdummy, xlim, ylim, dirstr)
%
%   Input:
%   meteoname =
%   cycledate =
%   cyclehour =
%   tdummy    =
%   xlim      =
%   ylim      =
%   dirstr    =
%
%   Output:
%   err       =
%
%   Example
%   getMeteoFromMatroos
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

% $Id: getMeteoFromMatroos.m 6234 2012-05-23 10:50:22Z ormondt $
% $Date: 2012-05-23 18:50:22 +0800 (Wed, 23 May 2012) $
% $Author: ormondt $
% $Revision: 6234 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/getMeteoFromMatroos.m $
% $Keywords: $

%%
err=[];

try
    
    url='http://opendap-matroos.deltares.nl/thredds/dodsC/maps/normal/knmi_hirlam_maps/';
    
    ncfile=[datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
    
    urlstr=[url ncfile];
    
    
    err=[];
    ntry=1;
    
    urlstr = getMeteoUrl(meteosource,cycledate,cyclehour);
    switch lower(meteosource)
        case{'gfs1p0','gfs0p5','ncep_gfs_analysis','ncepncar_reanalysis','ncepncar_reanalysis_2','ncep_gfs_analysis_precip'}
            xlim=mod(xlim,360);
    end
    
    mslprs=1;
    switch lower(meteosource)
        case{'ncepncar_reanalysis'}
            mslprs=0;
    end
    
    
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
    timdim=nc_getdiminfo(urlstr,'time');
    nt=timdim.Length;
    
    dt=(tmax-tmin)/(nt-1);
    times=tmin:dt:tmax;
    if ~isempty(t)
        it1=find(abs(times-t(1))<0.01,1,'first');
        it2=find(times<=t(end),1,'last');
    else
        it1=0;
        it2=length(times)-1;
    end
    
    %% Longitude
    lon=nc_varget(urlstr,'lon');
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
    lat=nc_varget(urlstr,'lat');
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
    
    npar = length(parstr);
    
    for i=1:npar
        
        tic
        disp(['Loading ' parstr{i} ' ...']);
        ok=0;
        nok=0;
        while nok<ntry
            try
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
        nanval1=nc_attget(urlstr,parstr{i},'missing_value');
        
        d.(parstr{i})(d.(parstr{i})==nanval1)=NaN;
        
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

                    
                    
                    
                    
                    %     sx=nc_varget([url ncfile],'x');
                    %     sy=nc_varget([url ncfile],'y');
                    %     ny=length(sy);
                    %     nx=length(sx);
                    %
                    %     tdummy=tdummy(1):0.125:tdummy(2);
                    %
                    %     nt = length(tdummy);
                    %
                    %     urlasc=[urlstr '.ascii'];
                    %
                    %     % Available Times
                    %
                    %     url=[urlasc '?time' '[0:1:' num2str(nt-1) ']'];
                    %     s=urlread(url);
                    %
                    %     a = strread(s,'%s','delimiter','\n');
                    %
                    %     b=strread(a{2},'%s','delimiter',',');
                    %     for jj=1:nt
                    %         t0=str2double(b{jj+1});
                    %         t(jj)=datenum(1970,1,1)+t0/1440;
                    %     end
                    %
                    %     % Longitudes
                    %
                    %     url=[urlasc '?x' '[0:1:' num2str(nx-1) ']'];
                    %     s=urlread(url);
                    %
                    %     a = strread(s,'%s','delimiter','\n');
                    %
                    %     b=strread(a{2},'%s','delimiter',',');
                    %     for jj=1:nx
                    %         x(jj)=str2double(b{jj+1});
                    %     end
                    %     dx=(x(end)-x(1))/(nx-1);
                    %     x=x(1):dx:x(end);
                    %
                    %     % Latitudes
                    %
                    %     url=[urlasc '?y' '[0:1:' num2str(ny-1) ']'];
                    %     s=urlread(url);
                    %
                    %     a = strread(s,'%s','delimiter','\n');
                    %
                    %     b=strread(a{2},'%s','delimiter',',');
                    %     for jj=1:ny
                    %         y(jj)=str2double(b{jj+1});
                    %     end
                    %     dy=(y(end)-y(1))/(ny-1);
                    %     y=y(1):dy:y(end);
                    %
                    %
                    %     parstr={'wind_u','wind_v','p'};
                    %     pr={'u','v','p'};
                    %
                    %     npar=3;
                    %
                    %     for ipar=1:npar
                    %
                    %         url=[urlasc '?' parstr{ipar} '[0:1:' num2str(nt-1) '][0:1:' num2str(ny-1) '][0:1:' num2str(nx-1) ']'];
                    %         s=urlread(url);
                    %         a = strread(s,'%s','delimiter','\n');
                    %
                    %         nl=2;
                    %         for it=1:nt
                    %             for ii=1:ny
                    %                 nl=nl+1;
                    %                 b=strread(a{nl},'%s','delimiter',',');
                    %                 for jj=1:nx
                    %                     d.(pr{ipar})(ii,jj,it)=str2double(b{jj+1});
                    %                 end
                    %             end
                    %         end
                    %
                    %     end
                    %
                    %     %% Output
                    %     k=0;
                    %     for ii=1:nt
                    %         k=k+1;
                    %         tstr=datestr(t(ii),'yyyymmddHHMMSS');
                    %         for j=1:npar
                    %             s=[];
                    %             s.t=t(ii);
                    %             s.dLon=x(2)-x(1);
                    %             s.dLat=y(2)-y(1);
                    %             s.lon=x;
                    %             s.lat=y;
                    %             s.(pr{j})=squeeze(d.(pr{j})(:,:,k));
                    %             if ~isnan(max(max(s.(pr{j}))))
                    %                 fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                    %                 disp([dirstr fname]);
                    %                 save([dirstr fname],'-struct','s');
                    %             end
                    %         end
                    %     end
                    %
                    %
                    % catch
                    %     disp('Something went wrong downloading HIRLAM data ...');
                    %     a=lasterror;
                    %     for i=1:length(a.stack)
                    %         disp(a.stack(i));
                    %     end
                end

