function [surge,semin]=compute_ekman_surge_03(x,t,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,manning,latitude,varargin)

if ~isempty(varargin)
    
    beta=varargin{1};
    
    semax=beta.semax;
    xmaxt=beta.xmaxt;
    cpx=beta.cpx;
    a1p=beta.a1p;
%     a2p=beta.a2p;
    epx=beta.epx;
    
    semin=beta.semin;
%     t0n=beta.t0n;
    xmint=beta.xmint;
    cnx=beta.cnx;
    a1n=beta.a1n;
    enx=beta.enx;
%     a2n=beta.a2n;

    t0=beta.t0;
     fpx=beta.fpx;
    
else
    
    % Positive
    semax=compute_ekman_surge_semax(a,vmax,shelf_width,foreward_speed,phi,r35,latitude,manning);    
%     t0p=-compute_ekman_surge_t0p(a,r35,shelf_width,foreward_speed,phi,vmax);
    xmaxt=compute_ekman_surge_xmax(shelf_width,phi,foreward_speed,phi_spiral);
    cpx=compute_ekman_surge_cpx(a,vmax,shelf_width,foreward_speed,phi,r35,manning,latitude);
    a1p=compute_ekman_surge_a1p(vmax,foreward_speed,phi,r35);
%     a2p=compute_ekman_surge_a2p(shelf_width,foreward_speed,phi,a);
    epx=compute_ekman_surge_epx(shelf_width,a,foreward_speed,latitude,r35,phi_spiral);
    
    semin=-compute_ekman_surge_semin(a,shelf_width,phi,vmax,r35,latitude,manning);

%     t0n=compute_ekman_surge_t0n(a,vmax,shelf_width,foreward_speed,phi,r35);
    xmint=compute_ekman_surge_xmin(shelf_width,foreward_speed,phi,phi_spiral);
    cnx=compute_ekman_surge_cnx(shelf_width,phi);
    a1n=compute_ekman_surge_a1n(latitude,r35,foreward_speed,phi,a,shelf_width);
%     a2n=compute_ekman_surge_a2n(vmax,shelf_width,foreward_speed,phi,r35);
    enx=compute_ekman_surge_enx(shelf_width,a,vmax,phi);

    fpx=compute_ekman_surge_fpx(shelf_width,phi);
    t0=compute_ekman_surge_t0(a,vmax,shelf_width,foreward_speed,phi,manning);

end

% fpx=0.004;

% x in km
% t in hours

nt=length(t);
nx=length(x);

t=t*24;
x=repmat(x,[nt 1]);
t=repmat(t,[1 nx]);

% t0=compute_ekman_surge_t0(a,vmax,shelf_width,foreward_speed,phi);


%a1n=a1p;
%a2n=a2p;

phi=phi*pi/180;

%e=exp(1);
% dpx=1.6;
% dnx=1.6;
%epx=0.007;
% enx=0;
% cpt=t0-t0p;

% semaxt1=semax*exp(-((t-t0p)./a1p).^2);
% semaxt2=semax*exp(-((t-t0p)./a2p).^2);
% semaxt=semaxt1;
% semaxt(t>=t0p)=semaxt2(t>=t0p);
% 
% semint1=semin*exp(-((t-t0n)./a1n).^2);
% semint2=semin*exp(-((t-t0n)./a2n).^2);
% semint=semint1;
% semint(t<=t0n)=semint2(t<=t0n);


tacc=t-t0;
semaxt=-(exp(1)/a1p)*semax.*tacc.*exp(-abs(tacc)/a1p);
semint= (exp(1)/a1n)*semin.*tacc.*exp(-abs(tacc)/a1n);
semaxt(t>t0)=0;
semint(t<t0)=0;

xp=x + foreward_speed*t*sin(phi) - xmaxt;
xn=x + foreward_speed*t*sin(phi) - xmint;

% Positive
%v1p=semaxt.*exp(-(abs(x + foreward_speed*t*sin(phi) - xmaxt)./(cpx.*(1-epx*foreward_speed*min(t,0).*cos(phi)))).^(dpx));
%v1p=semaxt.*exp( - ( (xx + vt*tt*sin(phi) - xmaxt) ./ ( cpx .* (1+epx*(xx + vt*tt*sin(phi) - xmaxt)).*(1-fpx*foreward_speed*min(t,0).*cos(phi))   )   )  .^2);
%v1p=semaxt.*exp(-(abs(xp) ./ ( cpx .* (1+epx*xp).*(1-fpx*foreward_speed*min(t,0).*cos(phi))   )   )  .^2);


% Negative
%v1n=semint.*exp(-(abs(xn) ./ ( cnx )).^2);

v1p=semaxt.*exp( - ( xp ./ ( cpx .* (1+epx*xp).*(1-fpx*foreward_speed*min(t,0).*cos(phi))   )   )  .^2);
v1n=semint.*exp( - ( xn ./ ( cnx .* (1+enx*xn)    ) ).^2);

% Total
surge=v1p+v1n;
