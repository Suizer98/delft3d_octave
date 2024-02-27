function surge=compute_ekman_surge_07(x,t,vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat,iopt,varargin)

if ~isempty(varargin)
    beta=varargin{1};
    aep=beta.aep;
    bexp=beta.bexp;
    cexp=beta.cexp;
    cetp=beta.cetp;
    eexp=beta.eexp;
    aen=beta.aen;
    bexn=beta.bexn;
    cexn=beta.cexn;
    cetn=beta.cetn;
    bet=beta.bet;
    ggg=beta.ggg;
else
%     phi=0.0;
    aep =compute_ekman_surge_aep_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);    
    bexp=compute_ekman_surge_bexp_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cexp=compute_ekman_surge_cexp_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cetp=compute_ekman_surge_cetp_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    eexp=compute_ekman_surge_eexp_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    aen=-compute_ekman_surge_aen_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bexn=compute_ekman_surge_bexn_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cexn=compute_ekman_surge_cexn_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cetn=compute_ekman_surge_cetn_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bet= compute_ekman_surge_bet_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    ggg= compute_ekman_surge_ggg_10(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
end
% bet=bet-0;
% aep=aep*0.9;
% % cexp=cexp*2;
% cexp=cexp*0.75;

fexp = 0.007;
eexn = 0.0;

nt=length(t);
nx=length(x);

t=t*24; % t was in days, convert to hours

if iopt==1
    xx=repmat(x,[nt 1]);
    tr=repmat(t,[1 nx]);
else
    xx=x;
    tr=t;
end

phi=phi*pi/180;

% Positive
tep=bet - tr - ggg*min(xx,0);
if iopt==1
    xep=xx + vt.*tr.*sin(phi) - bexp;
else
    % Positions are already relative to the eye
    xep=xx - bexp;
end
sepost=(exp(1)./cetp).*tep.*exp(-tep./cetp);
seposx=exp( - ( abs(xep) ./  max( cexp .* (1+eexp.*sign(xep)).*(1+fexp.*abs(vt.*tep.*cos(phi))) , 10)   )  .^1.25);

v1p=aep.*sepost.*seposx;
v1p(tep<0)=0;

% Negative
ten=tr-bet;
if iopt==1
    xen=xx + vt.*tr.*sin(phi) - bexn;
else
    % Positions are already relative to the eye
    xen=xx - bexn;
end
senegt=(exp(1)./cetn).*ten.*exp(-ten./cetn);
senegx=exp( - ( abs(xen) ./ ( cexn .* (1+eexn.*xen)   )   )  .^2);
v1n=aen.*senegt.*senegx;
v1n(ten<0)=0;

% Total
surge=v1p+v1n;
ok=1;

