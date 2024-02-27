% Function to extract tidal harmonic constants out of a tidal model
% for given locations
% USAGE
% [amp,Gph,Depth,conList]=extract_HC(Model,lat,lon,type,Cid);
%
% PARAMETERS
% Input:
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
%             lat(L),lon(L) - coordinates in degrees;
%             type - char*1 - one of
%                    'z' - elvation (m)
%                    'u','v' - velocities (cm/s)
%                    'U','V' - transports (m^2/s);
% Cid - indices of consituents to include (<=nc); if given
%             then included constituents are: ConList(Cid,:),
%             if Cid=[] (or not given), ALL model constituents
%
% Ouput:     amp(nc,L) - amplitude
%            Gph(nc,L) - Greenvich phase (o)
%            Depth(L)  - model depth at lat,lon
%            conList(nc,4) - constituent list
%
% Sample call:
% [amp,Gph,Depth,conList]=extract_HC('DATA/Model_Ross_prior',lat,lon,'z');
%
% Dependencies:  h_in,u_in,grd_in,XY,rd_con,BLinterp,checkTypeName
%
function [amp,Gph,D,conList]=extract_HC(Model,lat,lon,type,Cid)

if type=='z'
    k=1;
else
    k=2;
end

[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
km=1;

if isempty(Fxy_ll)>0
    km=0;
end

[Flag]=checkTypeName(ModName,GridName,type);

if Flag>0
    return;
end

ik=findstr(GridName,'km');

if isempty(ik)==0 & km==0,
 fprintf('STOPPING...\n');
 fprintf('Grid is in km, BUT function to convert lat,lon to x,y is NOT given\n');
 conList='stop';
 amp=NaN;Gph=NaN;D=NaN;
 return
end
if km==1,
 eval(['[xt,yt]=' Fxy_ll '(lon,lat,''F'');']);
else
 xt=lon;yt=lat;
end
[ll_lims,H,mz,iob]=grd_in(GridName);

if type ~='z',
 [mz,mu,mv]=Muv(H);[hu,hv]=Huv(H);
end
[n,m]=size(H);

[x,y]=XY(ll_lims,n,m);

% n=n+1;
% 
% x0=zeros(1,length(x)+1);
% x0(2:end)=x;
% x0(1)=0.0;
% 
% H0=zeros(size(H,1)+1,size(H,2));
% H0(2:end,:)=H;
% H0(1,:)=H(end,:);
% 
% mz0=zeros(size(mz,1)+1,size(mz,2));
% mz0(2:end,:)=mz;
% mz0(1,:)=mz(end,:);
% 
% x=x0;
% H=H0;
% mz=mz0;

dx=x(2)-x(1);dy=y(2)-y(1); 
conList=rd_con(ModName);
[nc,dum]=size(conList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xu=x-dx/2;yv=y-dy/2;

[X,Y]=meshgrid(x,y);[Xu,Yu]=meshgrid(xu,y);[Xv,Yv]=meshgrid(x,yv);

H(find(H==0))=NaN;
if type ~='z',
 hu(find(hu==0))=NaN;hv(find(hv==0))=NaN;
end
D=interp2(X,Y,H',xt,yt);
mz1=interp2(X,Y,mz',xt,yt);
% Correct near coast NaNs if possible
i1=find(isnan(D)>0 & mz1>0);
if isempty(i1)==0,
  D(i1)=BLinterp(x,y,H,xt(i1),yt(i1));
end
%
cind=[1:nc];
if nargin>4,cind=Cid;end
fprintf('\n');
for ic0=1:length(cind),
 ic=cind(ic0); 
 fprintf('Interpolating constituent %s...',conList(ic,:));
 if type=='z',
  [z,th_lim,ph_lim]=h_in(ModName,ic);
  [nn,mm]=size(z);if nn~=n | mm~=m,TMDcrash(n,m,nn,mm);break;end
  z(find(z==0))=NaN;
 else
  [u,v,th_lim,ph_lim]=u_in(ModName,ic);
  [nn,mm]=size(u);if nn~=n | mm~=m,TMDcrash(n,m,nn,mm);break;end
   u(find(u==0))=NaN;v(find(v==0))=NaN;
  if type=='u',u=u./hu*100;end
  if type=='v',v=v./hv*100;end
 end
 if type=='z',
       z1=interp2(X,Y,z',xt,yt);z1=conj(z1);
% Correct near coast NaNs if possible
       i1=find(isnan(z1)>0 & mz1>0);
       if isempty(i1)==0,
         z1(i1)=BLinterp(x,y,z,xt(i1),yt(i1));
       end
       amp(ic0,:,:)=abs(z1);
       Gph(ic0,:,:)=atan2(-imag(z1),real(z1));
 elseif type=='u' | type=='U',
       u1=interp2(Xu,Yu,u',xt,yt);u1=conj(u1);
       mu1=interp2(Xu,Yu,mu',xt,yt);
% Correct near coast NaNs if possible
       i1=find(isnan(u1)>0 & mu1>0);
       if isempty(i1)==0,
         u1(i1)=BLinterp(xu,y,u,xt(i1),yt(i1));
       end
       amp(ic0,:,:)=abs(u1);
       Gph(ic0,:,:)=atan2(-imag(u1),real(u1));
 elseif type=='v' | type=='V',
       v1=interp2(Xv,Yv,v',xt,yt);v1=conj(v1);
       mv1=interp2(Xv,Yv,mv',xt,yt);
% Correct near coast NaNs if possible      
       i1=find(isnan(v1)>0 & mv1>0);
       if isempty(i1)==0,
         v1(i1)=BLinterp(x,yv,v,xt(i1),yt(i1));
       end
       amp(ic0,:,:)=abs(v1);
       Gph(ic0,:,:)=atan2(-imag(v1),real(v1));
 else
      fprintf(['Wrong Type %s, should be one ',...
               'of:''z'',''u'',''v'',''U'',''V''\n'],type);
      amp=NaN;Gph=NaN;
      return 
 end
 fprintf('done\n');
end
Gph=Gph*180/pi;Gph(find(Gph<0))=Gph(find(Gph<0))+360;
Gph=squeeze(Gph);amp=squeeze(amp);
if nargin>4,conList=conList(cind,:);end
return
