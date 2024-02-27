function [zg1,varargout]=radial2regular(xg1,yg1,xp,yp,dx,dphi,val,varargin)

mergefrac=[];
projection = 'spherical';

convention='cartesian';
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'nautical'}
                convention='nautical';
            case{'mergefrac'}
                mergefrac=varargin{ii+1};
            case{'projection'}
                projection=varargin{ii+1};
        end
    end
end                

ndir=size(val,2);
nrad=size(val,1);
radius=nrad*dx;

if strcmp(projection,'spherical') % Compute deg2m scaling factors
    cfacx=cos(pi*yp/180)/111111;
    cfacy=1/111111;
elseif strcmp(projection,'projected')
    cfacx=1;
    cfacy=1;    
end
% Compute distances (in metres) and angles for each point in local grid
dst=sqrt(((xg1-xp)/cfacx).^2+((yg1-yp)/cfacy).^2);
ang=atan2((yg1-yp)/cfacy,(xg1-xp)/cfacx);
if strcmpi(convention,'nautical')
    ang=pi/2-ang;
end
ang=mod(ang,2*pi);
ang=ang*180/pi;

% Spatial merge function
if ~isempty(mergefrac)
    merge_frac=0.5;
    fm0=1.0/(1.0-merge_frac);
    fm=fm0*dst/radius-fm0+1.0;
    frac=max(0.0, min(1.0,fm));
    frac=1-frac;
    varargout{1}=frac;
end

% Take average value of surrounding spiderweb points

%         i     i
%         d     d
%         i     i
%         r     r
%         2     1
%
%  ^    3 o-----o 4  irad2
%  |      |     |
%  r      |     |
%  a      |     |
%  d    2 o-----o 1  irad1
%
%         <- idir

% Radial index
irad1=max(1,floor(dst./dx)+1);
% Relative distance (0-1) between radial points
drad=1+dst./dx-irad1;
irad2=irad1+1;
irad1(irad1>nrad)=1;
irad2(irad2>nrad)=1;
% Directional index
idir1=min(ndir,max(1,floor(ang./dphi)+1));
% Relative distance (0-1) between directional points
ddir=1+ang./dphi-idir1;
idir2=idir1+1;
idir1(idir1>ndir)=1;
idir2(idir2>ndir)=1;

% Vector index
ind1=sub2ind(size(val),irad1,idir1);
ind2=sub2ind(size(val),irad1,idir2);
ind3=sub2ind(size(val),irad2,idir2);
ind4=sub2ind(size(val),irad2,idir1);

% Compute weights of surrounding spiderweb points
f1 = (1.0-ddir).*(1.0-drad);
f2 = (    ddir).*(1.0-drad);
f3 = (    ddir).*(    drad);
f4 = (1.0-ddir).*(    drad);

zg1=    f1.*val(ind1);
zg1=zg1+f2.*val(ind2);
zg1=zg1+f3.*val(ind3);
zg1=zg1+f4.*val(ind4);

zg1(idir2==1)=NaN;
zg1(irad2==1)=NaN;
