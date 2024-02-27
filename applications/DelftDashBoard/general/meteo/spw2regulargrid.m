function [t,ug,vg,pg,frac,prcpg]=spw2regulargrid(spwfile,xg,yg,dt,varargin)
% Interpolates data from spiderweb file onto rectangular grid
% 
% e.g.
% gavprs=101200.0         % background pressure (Pa) - function returns absolute pressure
% interpolation='linear'; % determines locations of intermediate track points, can be either linear or spline
% dt=60;                  % time step in minutes, if left empty, only wind and pressure fields of the original track will be created 
% mergefrac=0.5;          % merge fraction 
% projection='projected'  % if spiderweb coordinated are specified in projected coordinates specify as 'projected' in meters, default is spherical (lat-lon)
% [xg,yg]=meshgrid(-70:0.1:-50,20:0.1:30);
% [t,ug,vg,pg,frac]=spw2regulargrid('ike.spw',xg,yg,dt,'interpolation',interpolation,'backgroundpressure',gavprs,'mergefrac',mergefrac);
%
mergefrac=[];
interpmethod='spline';
backgroundpressure=101500;
precipitation = 0; % by default don't read in rainfall
projection = 'spherical';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'mergefrac'}
                mergefrac=varargin{ii+1};
            case{'interpolation'}
                interpmethod=varargin{ii+1};
            case{'backgroundpressure'}
                backgroundpressure=varargin{ii+1};
            case{'precipitation'}
                precipitation=varargin{ii+1};     
            case{'projection'}
                projection=varargin{ii+1};                
        end
    end
end                

% Read data
info=asciiwind('open',spwfile);
if precipitation == 1
    quantity={'wind_speed'  'wind_from_direction'  'p_drop'  'precipitation'};    
else
    quantity={'wind_speed'  'wind_from_direction'  'p_drop'};
end
rows=1:info.Header.n_rows;
cols=1:info.Header.n_cols;
dx=info.Header.spw_radius/info.Header.n_rows;
dphi=360/info.Header.n_cols;
nt0=length(info.Data);
for it=1:nt0
    t0(it)=info.Data(it).time;
end

% Data
wvel0=asciiwind('read',info,quantity{1},1:nt0,rows,cols);
wdir0=asciiwind('read',info,quantity{2},1:nt0,rows,cols);
pdrp0=asciiwind('read',info,quantity{3},1:nt0,rows,cols);
if precipitation == 1
    prcp0=asciiwind('read',info,quantity{4},1:nt0,rows,cols);
end
for it=1:nt0
    xeye(it)=info.Data(it).x_spw_eye;
    yeye(it)=info.Data(it).y_spw_eye;
end

if ~isempty(dt)
    t=t0(1):dt/1440:t0(end);
    nt=length(t);
    switch lower(interpmethod)
        case{'spline'}
            xeye=spline(t0,xeye,t);
            yeye=spline(t0,yeye,t);
        case{'linear'}
            xeye=interp1(t0,xeye,t);
            yeye=interp1(t0,yeye,t);
    end
else
    t=t0;
    nt=nt0;
end

% Allocate array
ug=zeros(nt,size(xg,1),size(xg,2));
ug(ug==0)=NaN;
vg=ug;
pg=ug;
frac=ug;
prcpg=ug;

for it=1:nt

    if ~isempty(dt)
        [it1,it2,tfrac1,tfrac2]=find_time_indices_and_factors(t0,t(it));
    else
        it1=it;
        it2=0;
    end
        
    if it2==0
        % Just read one time
        wvel=squeeze(wvel0(it1,:,:));
        wdir=0.5*pi-pi*squeeze(wdir0(it1,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp=squeeze(pdrp0(it1,:,:));
        u=-wvel.*cos(wdir);
        v=-wvel.*sin(wdir);
        if precipitation == 1
            prcp=squeeze(prcp0(it1,:,:));        
        end
    else
        
        wvel1=squeeze(wvel0(it1,:,:));
        wdir1=0.5*pi-pi*squeeze(wdir0(it1,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp1=squeeze(pdrp0(it1,:,:));
        % Convert to coming from
        u1=-wvel1.*cos(wdir1);
        v1=-wvel1.*sin(wdir1);
        
        wvel2=squeeze(wvel0(it2,:,:));
        wdir2=0.5*pi-pi*squeeze(wdir0(it2,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp2=squeeze(pdrp0(it2,:,:));
        % Convert to coming from
        u2=-wvel2.*cos(wdir2);
        v2=-wvel2.*sin(wdir2);
        
        u=tfrac1*u1+tfrac2*u2;
        v=tfrac1*v1+tfrac2*v2;
        pdrp=tfrac1*pdrp1+tfrac2*pdrp2;
        
        if precipitation == 1
            prcp1=squeeze(prcp0(it1,:,:));    
            prcp2=squeeze(prcp0(it2,:,:));        
            prcp=tfrac1*pdrp1+tfrac2*pdrp2;
        end        

    end
    
    u(:,end+1)=u(:,1);
    v(:,end+1)=v(:,1);
    pdrp(:,end+1)=pdrp(:,1);
    if precipitation == 1
        prcp(:,end+1)=prcp(:,1);
    end
    
    % Interpolate
    if isempty(mergefrac)
        ug(it,:,:)=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,u,'nautical','projection',projection);
        vg(it,:,:)=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,v,'nautical','projection',projection);
    else
        [ug(it,:,:),frac0]=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,u,'nautical','mergefrac',mergefrac,'projection',projection);
        [vg(it,:,:),frac0]=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,v,'nautical','mergefrac',mergefrac,'projection',projection);
        frac(it,:,:)=frac0;
    end
    pg(it,:,:)=backgroundpressure-radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,pdrp,'nautical','projection',projection);
    
    if precipitation == 1
        prcpg(it,:,:)=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,prcp,'nautical','projection',projection);
    end
end

% varargout{1}=frac;
% if precipitation == 1
%     varargout{2}=prcpg;
% end

