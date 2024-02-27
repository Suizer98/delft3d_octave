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

% $Id: generateInitialConditions.m 12103 2015-07-16 07:46:07Z ormondt $
% $Date: 2015-07-16 09:46:07 +0200 (Thu, 16 Jul 2015) $
% $Author: ormondt $
% $Revision: 12103 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateInitialConditions.m $
% $Keywords: $

%%
% mmax=size(flow.gridXZ,1)+1;
% nmax=size(flow.gridYZ,2)+1;
% data=zeros(mmax,nmax,flow.KMax);

np=length(flow.gridX);
data=zeros(np,flow.KMax);
xg=flow.gridX;
yg=flow.gridY;

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
            
%             x=flow.gridX;
%             y=flow.gridY;

%             nans=zeros(np,1);
%             nans(nans==0)=NaN;           
            
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
            
            switch lower(par)
                case{'current'}
                    
                    % Load data
                    su1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    su2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_u.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
                    sv1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_v.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    sv2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.current_v.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
%                     su1.lon=mod(su1.lon,360);
%                     su2.lon=mod(su2.lon,360);
%                     sv1.lon=mod(sv1.lon,360);
%                     sv2.lon=mod(sv2.lon,360);
                    
%                     xu=zeros(size(xz));
%                     yu=xu;
%                     xv=xu;
%                     yv=xu;
%                     dxu=xu;
%                     dyu=xu;
%                     dxv=xu;
%                     dyv=xu;
%                     alphau=xu;
%                     alphav=xu;
                    
                    % Get xu,yu,xv,yv and alpha
                    
%                     xu=zeros(size(xz));
%                     yu=xu;
%                     xv=xu;
%                     yv=xu;
%                     alphau=xu;
%                     alphav=xu;
                    
                    
%                     xg=mod(xg,360);
                    
%                     % U Points
%                     xu(1:end-1,2:end-1)=0.5*(xg(:,1:end-1)+xg(:,2:end));
%                     yu(1:end-1,2:end-1)=0.5*(yg(:,1:end-1)+yg(:,2:end));
%                     dx=xg(:,2:end)-xg(:,1:end-1);
%                     dy=yg(:,2:end)-yg(:,1:end-1);
%                     
%                     for k=1:flow.KMax
%                         alphau(1:end-1,2:end-1,k)=atan2(dy,dx)-0.5*pi;
%                     end
                    
                    velu1=interpolate_ocean_data(xg,yg,dplayer,su1);
                    velu2=interpolate_ocean_data(xg,yg,dplayer,su2);
                    velv1=interpolate_ocean_data(xg,yg,dplayer,sv1);
                    velv2=interpolate_ocean_data(xg,yg,dplayer,sv2);
                    
                    u=m1*velu1+m2*velu2;
                    v=m1*velv1+m2*velv2;
                    
%                     u = uvelu.*cos(alphau) + vvelu.*sin(alphau);
                    
%                     u(xu==0)=0;
                    
%                     % V Points
%                     xv(2:end-1,1:end-1)=0.5*(xg(1:end-1,:)+xg(2:end,:));
%                     yv(2:end-1,1:end-1)=0.5*(yg(1:end-1,:)+yg(2:end,:));
%                     dx=xg(2:end,:)-xg(1:end-1,:);
%                     dy=yg(2:end,:)-yg(1:end-1,:);
%                     for k=1:flow.KMax
%                         alphav(2:end-1,1:end-1,k)=atan2(dy,dx)+0.5*pi;
%                     end
%                     
%                     velu1=interpolate3D(xv,yv,dplayer,su1,'u');
%                     velu2=interpolate3D(xv,yv,dplayer,su2,'u');
%                     velv1=interpolate3D(xv,yv,dplayer,sv1,'v');
%                     velv2=interpolate3D(xv,yv,dplayer,sv2,'v');
%                     
%                     uvelv=m1*velu1+m2*velu2;
%                     vvelv=m1*velv1+m2*velv2;
%                     
%                     v = uvelv.*cos(alphav) + vvelv.*sin(alphav);
%%%%%%%%%%%%%%%%%%%%% Added by j.lencart@gmail.com %%%%%%%%%%%%%%%%%%%%%%%%
                case {'waterlevel'}
                    s1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    s2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
%                     s1.lon=mod(s1.lon,360);
%                     s2.lon=mod(s2.lon,360);
%                     s1=interpolate_ocean_data(xg,yg,dplayer,s1, 'wl');
%                     s2=interpolate_ocean_data(xg,yg,dplayer,s2, 'wl');
                    [xd,yd]=meshgrid(s1.lon,s1.lat);
                    s1=double(s1.data);
                    s2=double(s2.data);
                    s1=interp2(xd,yd,s1,xg,yg);
                    s2=interp2(xd,yd,s2,xg,yg);                    
                    data=m1*s1+m2*s2;
                otherwise
                    % Load data
                    s1=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it1),'yyyymmddHHMMSS') '.mat']);
                    s2=load([opt.(par)(ii).IC.datafolder filesep opt.(par)(ii).IC.dataname '.' par '.' datestr(times(it2),'yyyymmddHHMMSS') '.mat']);
%                     s1.lon=mod(s1.lon,360);
%                     s2.lon=mod(s2.lon,360);
                    s1=interpolate_ocean_data(xg,yg,dplayer,s1);
                    s2=interpolate_ocean_data(xg,yg,dplayer,s2);
                    data=m1*s1+m2*s2;
            end
    end
        
%     % Overwrite initial conditions in polygons with user-specified data  
%     if isfield(opt.(par)(ii).IC,'polygons')
%         xz=flow.gridXZOri;
%         yz=flow.gridYZOri;
%         for ip=1:length(opt.(par)(ii).IC.polygons)
%             [xp,yp] = landboundary('read',opt.(par)(ii).IC.polygons(ip).filename);
%             inpol=inpolygon(xz,yz,xp,yp);
%             for k=1:flow.KMax
%                 dd0=squeeze(data(1:end-1,1:end-1,k));
%                 dd0(inpol)=opt.(par)(ii).IC.polygons(ip).value;
%                 data(1:end-1,1:end-1,k)=dd0;
%             end            
%         end        
%     end
    
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

dd=[];

switch lower(par)
    case{'waterlevel'}
        dd=data;
        varargout{1} = data;
%         dd=internaldiffusion(data,'nst',5);
%         dd(dd==-999)=0;
%         ddb_wldep('write',fname,dd,'negate','n','bndopt','n');
    case{'current'}
        varargout{1}=u;
        varargout{2}=v;
        for k=k1:dk:k2
%             dd=squeeze(u(:,:,k));
%             dd=internaldiffusion(dd,'nst',5);
%             ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
        for k=k1:dk:k2
%             dd=squeeze(v(:,:,k));
%             dd=internaldiffusion(dd,'nst',5);
%             ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
    otherwise
        varargout{1} = data;
        for k=k1:dk:k2
%             dd=squeeze(data(:,:,k));
%             dd=internaldiffusion(dd,'nst',5);
%             ddb_wldep('append',fname,dd,'negate','n','bndopt','n');
        end
end

