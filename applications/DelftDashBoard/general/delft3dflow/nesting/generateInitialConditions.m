function varargout = generateInitialConditions(flow, opt, par, ii, dplayer, fname)
%GENERATEINITIALCONDITIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   generateInitialConditions(flow, opt, par, ii, dplayer, fname)
%
%   Input:
%   flow    =
%   opt     =
%   par     =
%   ii      =
%   dplayer =
%   fname   =
%
%
%
%
%   Example
%   generateInitialConditions
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateInitialConditions.m 15017 2019-01-03 14:11:20Z nederhof $
% $Date: 2019-01-03 22:11:20 +0800 (Thu, 03 Jan 2019) $
% $Author: nederhof $
% $Revision: 15017 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateInitialConditions.m $
% $Keywords: $

%%
mmax=size(flow.gridXZ,1)+1;
nmax=size(flow.gridYZ,2)+1;
data=zeros(mmax,nmax,flow.KMax);


if isfield(opt,par)
    
    switch opt.(par)(ii).IC.source
        case 4
            pars=[0 1000;opt.(par)(ii).IC.constant opt.(par)(ii).IC.constant];
        case 5
            pars=opt.(par)(ii).IC.profile';
    end
    
    switch opt.(par)(ii).IC.source
        
        case{4,5}
            
            % Constant or profile
            depths=pars(1,:); % Depths must be defined positive up! I.e. at a level 1000 below the surface, depth must be -1000
            vals=pars(2,:);
            if depths(2)>depths(1)
                % Make sure we start at highest point
                depths=fliplr(depths);
                vals=fliplr(vals);
            end
            depths=[10000 depths -10000];
            depths=depths*-1;
            vals =[vals(1) vals vals(end)];            
            data=interp1(depths,vals,dplayer);
            u=data;
            v=data;
            
        case{2,3}
            
            % File
            xz=flow.gridXZ;
            xz=mod(xz,360);
            yz=flow.gridYZ;
            nans=zeros(mmax,nmax);
            nans(nans==0)=NaN;
            xxz=nans;
            xxz(1:end-1,1:end-1)=xz;
            xz=xxz;
            yyz=nans;
            yyz(1:end-1,1:end-1)=yz;
            yz=yyz;
            
            
            % Find available times
            switch lower(par)
                case{'current'}
                    flist=dir([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.*.mat']);
                otherwise
                    flist=dir([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.*.mat']);
            end
            for i=1:length(flist)
                tstr=flist(i).name(end-17:end-4);
                times(i)=datenum(tstr,'yyyymmddHHMMSS');
            end
            ts=flow.startTime;
            it1=find(times<=ts, 1, 'last' );
            it2=find(times>ts, 1, 'first' );
            if isempty(it2)
                it2=length(times);
            end
            t0=times(it1);
            t1=times(it2);
            if it1==it2
                m1=1;
                m2=0;
            else
                m1=(t1-ts)/(t1-t0);
                m2=(ts-t0)/(t1-t0);
            end
            
            %             % Find available times
            %             switch lower(par)
            %                 case{'current'}
            %                     flist=dir([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.*.mat']);
            %                     dataname=opt.(par)(ii).IC.file_u;
            %                     s=load(dataname);
            %                     dataname=opt.(par)(ii).IC.file_v;
            %                     sv=load(dataname);
            %                     s.lon=mod(s.lon,360);
            %                     sv.lon=mod(sv.lon,360);
            %                 otherwise
            %                     flist=dir([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.*.mat']);
            %                     dataname=opt.(par)(ii).IC.file;
            %                     s=load(dataname);
            %                     s.lon=mod(s.lon,360);
            %             end
            
            
            
            
            switch lower(par)
                case{'current'}
                    
                    % Load data
                    su1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    su2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
                    sv1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_v.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    sv2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_v.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
                    su1.lon=mod(su1.lon,360);
                    su2.lon=mod(su2.lon,360);
                    sv1.lon=mod(sv1.lon,360);
                    sv2.lon=mod(sv2.lon,360);
                    
                    xu=zeros(size(xz));
                    yu=xu;
                    xv=xu;
                    yv=xu;
                    dxu=xu;
                    dyu=xu;
                    dxv=xu;
                    dyv=xu;
                    alphau=xu;
                    alphav=xu;
                    
                    % Get xu,yu,xv,yv and alpha
                    
                    xu=zeros(size(xz));
                    yu=xu;
                    xv=xu;
                    yv=xu;
                    alphau=xu;
                    alphav=xu;
                    
                    xg=flow.gridX;
                    yg=flow.gridY;
                    
                    xg=mod(xg,360);
                    
                    % U Points
                    xu(1:end-1,2:end-1)=0.5*(xg(:,1:end-1)+xg(:,2:end));
                    yu(1:end-1,2:end-1)=0.5*(yg(:,1:end-1)+yg(:,2:end));
                    dx=xg(:,2:end)-xg(:,1:end-1);
                    dy=yg(:,2:end)-yg(:,1:end-1);
                    
                    for k=1:flow.KMax
                        alphau(1:end-1,2:end-1,k)=atan2(dy,dx)-0.5*pi;
                    end
                    
                    velu1=interpolate3D(xu,yu,dplayer,su1,'u');
                    velu2=interpolate3D(xu,yu,dplayer,su2,'u');
                    velv1=interpolate3D(xu,yu,dplayer,sv1,'v');
                    velv2=interpolate3D(xu,yu,dplayer,sv2,'v');
                    
                    uvelu=m1*velu1+m2*velu2;
                    vvelu=m1*velv1+m2*velv2;
                    
                    u = uvelu.*cos(alphau) + vvelu.*sin(alphau);
                    
                    u(xu==0)=0;
                    
                    % V Points
                    xv(2:end-1,1:end-1)=0.5*(xg(1:end-1,:)+xg(2:end,:));
                    yv(2:end-1,1:end-1)=0.5*(yg(1:end-1,:)+yg(2:end,:));
                    dx=xg(2:end,:)-xg(1:end-1,:);
                    dy=yg(2:end,:)-yg(1:end-1,:);
                    for k=1:flow.KMax
                        alphav(2:end-1,1:end-1,k)=atan2(dy,dx)+0.5*pi;
                    end
                    
                    velu1=interpolate3D(xv,yv,dplayer,su1,'u');
                    velu2=interpolate3D(xv,yv,dplayer,su2,'u');
                    velv1=interpolate3D(xv,yv,dplayer,sv1,'v');
                    velv2=interpolate3D(xv,yv,dplayer,sv2,'v');
                    
                    uvelv=m1*velu1+m2*velu2;
                    vvelv=m1*velv1+m2*velv2;
                    
                    v = uvelv.*cos(alphav) + vvelv.*sin(alphav);
%%%%%%%%%%%%%%%%%%%%% Added by j.lencart@gmail.com %%%%%%%%%%%%%%%%%%%%%%%%
                case {'waterlevel'}
                    s1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    s2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
                    s1.lon=mod(s1.lon,360);
                    s2.lon=mod(s2.lon,360);
                    s1=interpolate3D(xz,yz,dplayer,s1, 'wl');
                    s2=interpolate3D(xz,yz,dplayer,s2, 'wl');
                    data=m1*s1+m2*s2;
                otherwise
                    % Load data
                    s1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    s2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
                    s1.lon=mod(s1.lon,360);
                    s2.lon=mod(s2.lon,360);
                    s1=interpolate3D(xz,yz,dplayer,s1);
                    s2=interpolate3D(xz,yz,dplayer,s2);
                    data=m1*s1+m2*s2;
            end
    end
        
    % Overwrite initial conditions in polygons with user-specified data  
    if isfield(opt.(par)(ii).IC,'polygons')
        xz=flow.gridXZOri;
        yz=flow.gridYZOri;
        for ip=1:length(opt.(par)(ii).IC.polygons)
            [xp,yp] = landboundary('read',opt.(par)(ii).IC.polygons(ip).filename);
            inpol=inpolygon(xz,yz,xp,yp);
            for k=1:flow.KMax
                dd0=squeeze(data(1:end-1,1:end-1,k));
                dd0(inpol)=opt.(par)(ii).IC.polygons(ip).value;
                data(1:end-1,1:end-1,k)=dd0;
            end            
        end        
    end
    
end

if strcmpi(flow.vertCoord,'z')
    k1=flow.KMax;
    k2=1;
    dk=-1;
else
    k1=1;
    k2=flow.KMax;
    dk=1;
end

% C
switch lower(par)
    case{'waterlevel'}
        
        % If -999 we compute geoid to local msl based on HYCOM
        if opt.waterLevel.IC.constant == -999
            
            % goes from -180 to +180
            fnc             = 'p:\11201739-usgs-coop-20172018\CoralReefs\Maui\03_data\DTU\DTU10MDT_1min.nc';
            lat             = nc_varget(fnc, 'lat');
            lon             = nc_varget(fnc, 'lon');
            idlat           = find(lat >= nanmin(nanmin(yz)) & lat <= nanmax(nanmax(yz)));
            idlon           = find(lon >= nanmin(nanmin(xz)) & lon <= nanmax(nanmax(xz)));
            mdt             = nc_varget(fnc, 'mdt', [idlat(1)-1 idlon(1)-1], [length(idlat) length(idlon)]);
            lat             = nc_varget(fnc, 'lat', [idlat(1)-1], [length(idlat)]);
            lon             = nc_varget(fnc, 'lon', [idlon(1)-1], [length(idlon)]);
            [lon_TMP, lat_TMP]  = meshgrid(lon, lat);
            geoid_msl           = internaldiffusion(griddata(lon_TMP, lat_TMP, mdt, xz, yz), 'nst', 5);
            dd                  = internaldiffusion(data,'nst',5) - geoid_msl;
            
        else
            dd=internaldiffusion(data,'nst',5);
            dd(dd==-999)=0;
        end
        ddb_wldep('write',fname,dd,'negate','n','bndopt','n');
    case{'current'}
        for k=k1:dk:k2
            dd=squeeze(u(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
        for k=k1:dk:k2
            dd=squeeze(v(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
    otherwise
        for k=k1:dk:k2
            dd=squeeze(data(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
end
varargout{1} = dd;
