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
else
%     phi=0.0;
    aep =compute_ekman_surge_aep(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);    
    bexp=compute_ekman_surge_bexp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cexp=compute_ekman_surge_cexp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cetp=compute_ekman_surge_cetp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    eexp=compute_ekman_surge_eexp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    aen=-compute_ekman_surge_aen(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bexn=compute_ekman_surge_bexn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cexn=compute_ekman_surge_cexn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cetn=compute_ekman_surge_cetn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bet= compute_ekman_surge_bet(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
end
% bet=bet+3;
% cexp=cexp*2;

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
tep=bet-tr;
if iopt==1
    xep=xx + vt.*tr.*sin(phi) - bexp;
else
    % Positions are already relative to the eye
    xep=xx - bexp;
end
sepost=(exp(1)./cetp).*tep.*exp(-tep./cetp);
seposx=exp( - ( abs(xep) ./  ( cexp .* (1+eexp.*sign(xep)).*(1+fexp.*abs(vt.*tep.*cos(phi))) )   )  .^1.5);
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
senegx=exp( - ( abs(xen) ./ ( cexn .* (1+eexn.*xen)   )   )  .^1.5);
v1n=aen.*senegt.*senegx;
v1n(ten<0)=0;

% Total
surge=v1p+v1n;
ok=1;

