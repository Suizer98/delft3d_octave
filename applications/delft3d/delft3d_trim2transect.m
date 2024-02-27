function dataOut=trim2transect(transect,nfs,varargin)
%MAP2TRANSECT Create transect (cross-section and along transect) using data
%in trim file.
%
%Syntax:
%  dataOut=trim2transect(transect,NFStruct,GroupName,GroupIndex,...
%  ElementName,ElementIndex,<keyword>,<value>)
%
%Input:
%
%Output:
%
%Example:

%   --------------------------------------------------------------------
%   Copyright (C) 2003-2007 Arcadis
%
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis Zwolle
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: delft3d_trim2transect.m 8163 2013-02-22 16:48:45Z ivo.pasmans.x $
% $Date: 2013-02-23 00:48:45 +0800 (Sat, 23 Feb 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8163 $
% $HeadURL:
% https:$

%% Preprocessing

%Optional arguments
nfsOpt=4; 
OPT.step_d=[]; %step size between nodes horizontal direction [m]
OPT.step_z=[]; %step size between nodes vertical direction[m]
OPT.nstep_d=200; %number of steps in horizontal direction
OPT.nstep_z=50; %number of steps in vertical direction
OPT.d=[]; %interpolation points along transect in horizontal direction
OPT.z=[]; %interpolation points along transect in vertical direction
OPT.morfSim=sum(strcmpi('map-sed-series',{nfs.CelDef(:).Name}))>0; 
OPT.zOrientation=-1; %positive direction of z-axis
OPT.unique=true; %if true each index point is used by maximal 1 horizontal interpolation point. 

if length(varargin)>nfsOpt
    [OPT OPTset OPTdefault]=setproperty(OPT,varargin(nfsOpt+1:end)); 
end

%Read transect
if ~exist(transect,'file')
    error(sprintf('Matlab cannot find %s',transect)); 
else
    trans=landboundary('read',transect); 
end %end if

%Open D3D-grid
grd=vs_meshgrid2dcorcen(nfs); 
t=vs_time(nfs); t=t.datenum;
sigma=[1;d3d_sigma(grd.sigma_dz);0]-1; 
sizegrd=[length(sigma),size(grd.cen.x)]; 
sizedim=length(varargin{4})+1; 

%timesteps
it=varargin{2}{1}; 
if it==0
    it=[1:length(t)];
end

%% Find transect-coordinates

%Only one way of specifying interpolation points can be provided
if sum(OPTset.step_d+OPTset.nstep_d+OPTset.d)>1
    error('Only 1 one way of specifying horizontal interpolation points can be used.'); 
end
if sum(OPTset.step_z+OPTset.nstep_z+OPTset.z)>1
    error('Only 1 one way of specifying vertical interpolation points can be used.'); 
end

%check if nstep is positive integer
if OPTset.nstep_d && (OPT.nstep_d<1 || OPT.nstep_d~=round(nstep_d))
    error('Number of horizontal interpolation points must be greater or equal than 2.'); 
end
if OPTset.nstep_z && (OPT.nstep_z<1 || OPT.nstep_z~=round(nstep_z))
    error('Number of vertical interpolation points must be greater or equal than 2.'); 
end

%check if step is positive 
if OPTset.step_d && (OPT.step_d<0 )
    error('Stepsize horizontal interpolation must be positive.'); 
end
if OPTset.nstep_z && (OPT.nstep_z<1 )
    error('Stepsize vertical interpolation must be positive.'); 
end

%Create horizontal interpolation points
if isempty(OPT.d)
    [xi yi di]=local_interpPath(trans(1:end-1,1),trans(1:end-1,2),[]);
    if ~isempty(OPT.step_d)
        %step_d is provided
    elseif ~isempty(OPT.nstep_d)
        %nstep_d is provided
        OPT.step_d=di(end)/OPT.nstep_d;
    else
        error('Horizontal interpolation points are not defined.'); 
    end %end if OPT.step_d
    [xi yi di]=local_interpPath(trans(1:end-1,1),trans(1:end-1,2),OPT.step_d);
end %end if OPT.d

%Find data points closest to horizontal interpolation points
[m n w]=local_findDataPoints(grd.cen.x,grd.cen.y,xi,yi); 


if OPT.unique
    %Eliminate horizontal interpolation points which use the same grid cell
    
    %Get unique index points
    mn=[m,n]; mn(isnan(mn))=0; 
    [mnunique iunique junique]=unique(mn,'rows'); 
    
    %eliminate horizontal interpolation points
    dunique=nan(1,length(iunique)); 
    wunique=nan(length(iunique),size(w,2)); 
    for k1=1:length(iunique)
       dunique(k1)=nanmean(di(k1==junique)); 
       wunique(k1,:)=nanmean(w(k1==junique,:),1); 
    end
    m=mnunique(:,1:size(m,2)); n=mnunique(:,size(m,2)+1:end);     
    di=dunique;  

    %create new horizontal interpolation points
    [xi yi di]=local_interpPath(trans(1:end-1,1),trans(1:end-1,2),di);
end %end if OPT.unique

%Reduce size grid
mnblock={[min(m):max(m)],[min(n):max(n)]}; 
xblock=grd.cen.x(mnblock{1},mnblock{2});
yblock=grd.cen.y(mnblock{1},mnblock{2});
m=m-min(m)+1; n=n-min(n)+1; 
mnblock{1}=mnblock{1}+1; mnblock{2}=mnblock{2}+1;

%limit input to block
varargin{4}{1}=mnblock{1};
varargin{4}{2}=mnblock{2}; 
varargin{4}{3}=0;

%Find coordinates nodes z-direction
dep0=OPT.zOrientation*vs_let(nfs,'map-const',{1},'DPS0',mnblock,'quiet'); 
dep0=squeeze(dep0); 
if isempty(OPT.z)
    mindep=min(dep0(:)); maxdep=max(dep0(:)); 
    if ~isempty(OPT.step_z)
        %OPT.step_z specified
        mindep=floor(mindep/OPT.step_z)*OPT.step_z; 
        maxdep=ceil(maxdep/OPT.step_z)*OPT.step_z; 
        OPT.z=[mindep:OPT.step_z:maxdep];        
    elseif ~isempty(OPT.nstep_z)
        OPT.z=[mindep:(maxdep-mindep)/OPT.nstep_z:maxdep]; 
    else
        error('Vertical interpolation points are not defined.');
    end %end OPT.step_z
else
    if OPT.z(end)>OPT.z(1)
        OPT.z=flipdim(OPT.z,2);
    end
end %end OPT.z

%create block vertical interpolation points
ziblock=vector2grid(OPT.z,[length(OPT.z),length(mnblock{1}),length(mnblock{2})],1); 

%create output
dataOut.x=xi; dataOut.y=yi; dataOut.d=di; dataOut.z=OPT.z'; 
dataOut.datenum=t(it); 
dataOut.along=nan([length(it),length(OPT.z),length(di)]);
dataOut.cross=nan([length(it),length(OPT.z),length(di)]);
dataOut.filename={nfs.DatExt,nfs.DefExt};

%% Interpolate 

%creat waitbar
hWB=waitbar(0,'Reading data');

%read quantity
if ~iscell(varargin{3})
    %scalar
    val{1}=vs_let(nfs,varargin{1},varargin{2},varargin{3},varargin{4},'quiet');
else
    %vector
    [val{1} val{2}]=vs_let_vector_cen(nfs,varargin{1},varargin{2},varargin{3},varargin{4},'quiet'); 
end 
    
%water level
zwl=vs_let(nfs,'map-series',varargin{2},'S1',mnblock,'quiet');

%bottom level
if OPT.morfSim
    dep=OPT.zOrientation*vs_let(nfs,'map-sed-series',varargin{2},'DPS',mnblock,'quiet'); 
else
    dep=OPT.zOrientation*vs_let(nfs,'map-const',{1},'DPS0',mnblock,'quiet');
end

waitbar(0,hWB,'Interpolating data'); 

if ~iscell(varargin{3})==1
    %interpolate scalar
    
    for k1=1:length(it)
        %loop over all timesteps
        
        %convert zi->sigma
        si=local_z2sigma(ziblock,zwl(k1,:,:),dep(k1,:,:));

        %read 1 time
        val1=local_val1time(val{1},k1);

        %interpolate to block grid
        vali=nan(size(si)); 
        for k2=1:size(vali,2)
            for k3=1:size(vali,3)
                vali(:,k2,k3)=interp1(sigma,val1(:,k2,k3),si(:,k2,k3),'linear',NaN);
            end %end for k3
        end %end for k2

        %interpolate to transect
        for k2=1:length(di)
            if ~isnan(m(k2)) & ~isnan(n(k2))
                out1=[];
                for k3=1:size(m,2)
                    out1=[out1,w(k2,k3)*vali(:,m(k2,k3),n(k2,k3))];
                end
                dataOut.along(k1,:,k2)=nansum(out1,2);
            end %end if ~isnan
        end %end for k2
         dataOut.cross=dataOut.along; 
         dataOut.type='scalar';
         waitbar(k1/length(it),hWB); 
    end %end for k1
    
else
    %vector interpolation
    
    %calculate tangent to path in every point
    [tanxi tanyi tantheta]=local_tangent(xi,yi); 
    
    for k1=1:length(it)
        %loop over all timesteps

        %convert zi->sigma
        si=local_z2sigma(ziblock,zwl(k1,:,:),dep(k1,:,:));

        %read 1 time
        val1=local_val1time(val{1},k1);
        val2=local_val1time(val{2},k1); 

        %interpolate to block grid
        %interpolate to block grid
        vali=nan(size(si)); 
        for k2=1:size(vali,2)
            for k3=1:size(vali,3)
                vali1(:,k2,k3)=interp1(sigma,val1(:,k2,k3),si(:,k2,k3),'linear',NaN);
                vali2(:,k2,k3)=interp1(sigma,val2(:,k2,k3),si(:,k2,k3),'linear',NaN);
            end %end for k3
        end %end for k2

        %interpolate to transect
        for k2=1:length(di)
            if ~isnan(m(k2)) & ~isnan(n(k2))
                out1=[]; out2=[];
                for k3=1:size(m,2)
                    out1=[out1,w(k2,k3)*vali1(:,m(k2,k3),n(k2,k3))];
                    out2=[out2,w(k2,k3)*vali2(:,m(k2,k3),n(k2,k3))];
                end
                dataOut1=nansum(out1,2);
                dataOut2=nansum(out1,2);
                
                %get component cross and component along
                theta=tantheta(k2); 
                dataOut.along(k1,:,k2)=dataOut1*cos(theta)+dataOut2*sin(theta); 
                dataOut.cross(k1,:,k2)=dataOut1*sin(theta)-dataOut2*cos(theta);
                
            end %end if ~isnan
        end %end for k2
        dataOut.type='vector';
        waitbar(k1/length(it),hWB); 
    end %end for k1
    
end %end if ~iscell

%close waitbar
close(hWB); 

%% Postprocessing



end %end function map2transect


function [m n w]=local_findDataPoints2(x,y,xi,yi)

[mindex nindex]=meshgrid([1:size(x,2)],[1:size(x,1)]); 

inan=~isnan(x) & ~isinf(x) & ~isnan(y) & ~isinf(y); 
inan=inan(:); 

im=griddata(x(inan),y(inan),mindex(inan),xi,yi); 
in=griddata(x(inan),y(inan),nindex(inan),xi,yi); 

m=nan(numel(im),4);
m(:,1)=max(floor(im),1); 
m(:,2)=max(floor(im),1); 
m(:,3)=min(ceil(im),max(mindex(:)));
m(:,4)=min(ceil(im),max(mindex(:)));

n=nan(numel(im),4);
n(:,1)=max(floor(in),1); 
m(:,3)=max(floor(in),1); 
m(:,2)=min(ceil(in),max(nindex(:)));
m(:,4)=min(ceil(in),max(nindex(:)));

w=zeros(size(m)); 
for k=1:size(m,1)
    for l=size(m,2)
        w(k,l)=1/hypot(x(m(k,l),n(k,l))-xi(k),y(m(k,l),n(k,l))-yi(k))^2;   
    end
end
w(isnan(w))=0; 
sumw=sum(w,2); sumw=repmat(sumw,[1 size(m,2)]); 
w=w./sumw; 

end %end function local_findDataPoints2

function [tanx tany tantheta]=local_tangent(x,y)
%LOCAL_TANGENT Calculate tangent vector along the path given by x and y
%using central differences.

if sum(size(x)~=size(y))>0
    error('local_tangent: x and y must have equal dimensions.'); 
else
    sizexy=size(x); 
end

if size(x,1)<size(x,2)
    x=x'; y=y';
end

dd=hypot( diff(x),diff(y) ); 

%calculate differential
tanx=(dd(2:end).*x(3:end)-dd(1:end-1).*x(1:end-2)-(dd(2:end)-dd(1:end-1)).*x(2:end-1))./...
    (2*dd(1:end-1).*dd(2:end));
tany=(dd(2:end).*y(3:end)-dd(1:end-1).*y(1:end-2)-(dd(2:end)-dd(1:end-1)).*y(2:end-1))./...
    (2*dd(1:end-1).*dd(2:end));

%calculate angle
tantheta=atan2(tany,tanx);

%normalize
tannorm=hypot(tanx,tany);
tanx=tanx./tannorm; tany=tany./tannorm; 

%patch NaN
tanx=[NaN; tanx; NaN]; tany=[NaN; tany; NaN]; tantheta=[NaN; tantheta; NaN]; 
tanx=reshape(tanx,sizexy); tany=reshape(tany,sizexy); tantheta=reshape(tantheta,sizexy); 

end 

function [xi yi di]=local_interpPath(x,y,step)
%LOCAL_INTERPPATH Create points along a given path with distance step
%between the points

%convert to column vectors
x=reshape(x,[],1); 
y=reshape(y,[],1); 

%check input
if length(x)~=length(y)
    error('local_interpPath: the number of x-coordinates must match number of y-coordinates'); 
end
if sum( isnan(x)+isnan(y)+isinf(x)+isinf(y))>0
    error('local_interpPath: Non numerial values detected in path coordinates'); 
end

%distance between to input points of path
dd=hypot(diff(x),diff(y)); 

%distance along path
d=[0;cumsum(dd)]; 

if isempty(step)
        di=d; xi=x; yi=y;
elseif length(step)==1
    %interpolate
    di=[0:step:d(end)];
    xi=interp1(d,x,di);
    yi=interp1(d,y,di);
else
    di=step; 
    xi=interp1(d,x,di); 
    yi=interp1(d,y,di); 
end %end if

end %end function local_interpTrans

function [m n w]=local_findDataPoints(x,y,xi,yi)
%LOCAL_FINDDATAPOINTS Find for every node of the path the relevant grid
%points and the weight with which the data in these points should be
%averaged to get the interpolated value at the node of the path

%convert to column vectors
xi=reshape(xi,[],1); 
yi=reshape(yi,[],1);

%Use OpenEarth xy2mn
[m n]=xy2mn(x,y,xi,yi); 

%No weighting
w=ones(size(m)); 
end %end function local_findDataPoints

function sigma=local_z2sigma(z,zwl,dep)
%LOCAL_Z2SIGMA Convert z-coordinates to sigma-coordinates

if sum(size(dep)==size(zwl))~=length(size(zwl))
    error('dep and zwl must have the same dimensions'); 
end

zwl=repmat(zwl,[size(z,1) 1 1]);
dep=repmat(dep,[size(z,1) 1 1]); 
sigma= (z-zwl)./(zwl-dep); 

end %end function local_z2sigma

function valOut=local_val1time(valIn,timestep)
%LOCAL_VAL1TIME Convert matrix as found by vs_let_... to matrix ready for
%interpolation

sizeval=size(valIn);
if length(sizeval)>4
    error('Too many non-singleton dimensions in valIn'); 
end 
sizeval1=sizeval(2:end); 

valIn=reshape(valIn(timestep,:),sizeval1); 
valIn=permute(valIn,[3 1 2]); 

valOut=nan([size(valIn,1)+2,size(valIn,2),size(valIn,3)]); 
valOut(2:end-1,:,:)=valIn; 
valOut(1,:,:)=valIn(1,:,:); 
valOut(end,:,:)=valIn(end,:,:); 

end %end function local_val1time
