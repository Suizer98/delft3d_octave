function [surge,vnor,vtan]=compute_normal_surge_along_coast(coast,trackt,phi_rel,varargin)

landdecay=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'landdecay'}
                landdecay=varargin{ii+1};
        end
    end
end
% trackt=interpolate_track_data(track,t);
% 
% [xacc,tacc,phi_rel]=compute_virtual_landfall_coordinates_v02(t,trackt,coast);


[surge,vnor,vtan]=compute_normal_surge(phi_rel,coast.x,coast.y,coast.phi,trackt.x,trackt.y,trackt.vmax,trackt.rmax,trackt.r35,trackt.forward_speed,trackt.heading,trackt.phi_in,coast.w,coast.a,coast.omega,trackt.latitude,landdecay);

function [surge,vnor,vtan]=compute_normal_surge(phi_rel,xc,yc,phi_c,xe,ye,vmax,rmax,r35,vt,phi_t,phi_in,shelf_width,a,iid,lat,landdecay,varargin)

if ~isempty(varargin)
    beta=varargin{1};
    redfac=beta.redfac;
    redext=beta.redext;
    cshift=beta.eyevec1;
    ashift=beta.eyevec2;
    lrfac=beta.offshorefac;
else
%     phi_rel=phi_t-phi_c(ilandfall);
%     phi_rel=min(max(phi_rel,-60),60);
    % Should use phi at landfall here...
%     phi_rel=phi_t;
%     phi_rel=phi_rel*180/pi;
%     redfac=compute_normal_surge_reduction_factor_02(shelf_width,rmax,phi_rel,vt);
%     redext=compute_normal_surge_reduction_extent_02(shelf_width,phi_rel,rmax,r35,a);
% %    cshift=compute_normal_surge_cross_track_shift(shelf_width(ilandfall),vmax,rmax,phi_rel,r35,a(ilandfall),vt);
%     cshift=compute_normal_surge_cross_track_shift_02(shelf_width,vmax,rmax,phi_rel,r35,a);
%     ashift=compute_normal_surge_along_track_shift_02(shelf_width,phi_rel,a);
% %    lrfac=compute_normal_surge_land_reduction_factor(vmax,phi_rel,a,shelf_width,rmax,r35);
%     lrfac=compute_normal_surge_land_reduction_factor_02(vmax,phi_rel,a,shelf_width);

    phi=phi_rel;
    redfac=compute_normal_surge_reduction_factor_02(shelf_width,rmax,phi,vt);
    redext=compute_normal_surge_reduction_extent_02(shelf_width,phi,rmax,r35,a);
    cshift=compute_normal_surge_cross_track_shift_02(shelf_width,phi,a);
    ashift=compute_normal_surge_along_track_shift_02(shelf_width,vmax,rmax,phi,r35,a,vt);
    lrfac=compute_normal_surge_land_reduction_factor_02(vmax,phi,a,shelf_width,rmax,r35);

end

% t in days

% yc    = zeros(size(xc));
% phi_c = zeros(size(xc))+90;

% te    = [-2;2];
% xe    = te*foreward_speed*24*cos((90+phi)*pi/180);
% ye    = te*foreward_speed*24*sin((90+phi)*pi/180);
% vmaxe  = [vmax;vmax];
% rmaxe  = [rmax;rmax];
% r35e   = [r35;r35];
% phi_in= phi_spiral;
% lat   = latitude;


% cshift=0;
% ashift=0;

[vnor,vtan,r,r0]=compute_wind_v03(xc,yc,phi_c,xe,ye,vt,phi_t,vmax,rmax,r35,phi_in,lat,cshift,ashift,'asymfac',0.6,'rhoa',1.20);
                                 

% Land decay
if landdecay
    Fld=land_decay_factor(t,vt,phi,vmax);
else
    Fld=1.0;
end
Fld=repmat(Fld,[1 length(xc)]);
% Fld=1.0;
vnor=vnor.*Fld;
vtan=vtan.*Fld;

[surge,taunor,fnl]=compute_potential_surge(vnor,vtan,iid,a);

fcor=1-(1-redfac).*exp(-((r-rmax)./redext).^1);
fcor(r<rmax)=redfac(r<rmax);

surge=fcor.*surge;

% Land reduction
surge(vnor<0)=surge(vnor<0).*lrfac(vnor<0);

