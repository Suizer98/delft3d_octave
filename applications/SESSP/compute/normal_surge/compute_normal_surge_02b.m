function [surge,vnor,vtan]=compute_normal_surge(xc,t,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,iid,latitude,varargin)

if ~isempty(varargin)
    beta=varargin{1};
    redfac=beta.redfac;
    redext=beta.redext;
    cshift=beta.cshift;
    ashift=beta.ashift;
    lrfac=beta.offshorefac;
else
    redfac=compute_normal_surge_reduction_factor_02(shelf_width,rmax,phi,foreward_speed);
    redext=compute_normal_surge_reduction_extent_02(shelf_width,phi,rmax,r35,a);
    cshift=compute_normal_surge_cross_track_shift_02(shelf_width,phi,a);
    ashift=compute_normal_surge_along_track_shift_02(shelf_width,vmax,rmax,phi,r35,a,foreward_speed);
    lrfac=compute_normal_surge_land_reduction_factor_02(vmax,phi,a,shelf_width,rmax,r35);
end

% t in days

yc    = zeros(size(xc));
phi_c = zeros(size(xc))+90;

te    = [-2;2];
xe    = te*foreward_speed*24*cos((90+phi)*pi/180);
ye    = te*foreward_speed*24*sin((90+phi)*pi/180);
vmaxe  = [vmax;vmax];
rmaxe  = [rmax;rmax];
r35e   = [r35;r35];
phi_in= phi_spiral;
lat   = latitude;


% cshift=0;
% ashift=0;

[vnor,vtan,r,r0]=compute_wind(t,xc,yc,phi_c,te,xe,ye,vmaxe,rmaxe,r35e,phi_in,lat,cshift,ashift,'asymangle',0);

% Land decay
Fld=land_decay_factor(t,foreward_speed,phi,vmax);
Fld=repmat(Fld,[1 length(xc)]);
% Fld=1.0;
vnor=vnor.*Fld;
vtan=vtan.*Fld;

% figure(500)
% plot(xc,vnor(73,:))
% hold on
% wl=load('e:\work\empirical_surge_formula\runs\runs06_old\run00024\n\wl.mat');
% vnorm=double(wl.vy(217,:));
% xm=wl.x/1000;
% plot(xm,vnorm)

[surge,taunor,fnl]=compute_potential_surge(vnor,vtan,iid,a);

fcor=1-(1-redfac)*exp(-((r-rmax)/redext).^1);
% finp=exp(r.*log(redfac)./rmax);
%fcor(r<rmax)=finp(r<rmax);
fcor(r<rmax)=redfac;

surge=fcor.*surge;

% Land reduction
% lrfac=1-4*(1-lrfac);
% lrfac=max(lrfac,0);
%lrfac=lrfac;

surge(vnor<0)=surge(vnor<0)*lrfac;

