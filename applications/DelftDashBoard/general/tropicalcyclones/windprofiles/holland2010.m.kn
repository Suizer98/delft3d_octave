function [vr,pr,rn,xn,rvms]=holland2010(r,vms,pc,rvms,varargin)
% Holland et al. (2010) formula to determine wind profile
% Function requires Vmax, Pc and Rmax
% and can be used to estimate x

%% 0. Reading parameters
% Holland parameters
pn=1015;        % ambient pressure
rhoa=1.15;      % air density
xn=0.5;         % fitting coefficient    
rn=150;         % 
robs=[];        % radius of observation
vobs=[];        % wind speed of observation -> used to fit xn

% Assumptions for Dvorak
holland2008 = 1;
vt=0; dpdt = 0; lat = 0;

% Oher
estimate_rmax=0;  
e=exp(1);
a=[];

% Read variable inputs
for ii=1:length(varargin)
    if ischar(lower(varargin{ii}))
        switch lower(varargin{ii})
            case{'pn'}
                pn=varargin{ii+1};
            case{'rhoa'}
                rhoa=varargin{ii+1};
            case{'xn'}
                xn=varargin{ii+1};
            case{'rn'}
                rn=varargin{ii+1};
            case{'robs'}
                robs=varargin{ii+1};
            case{'vobs'}
                vobs=varargin{ii+1};
            case('vt')
                vt =varargin{ii+1};
            case('dpdt')
                dpdt =varargin{ii+1};
            case('lat')
                lat =varargin{ii+1};
            case('holland2008')
                holland2008 =varargin{ii+1};
        end
    end
end

% Calculate Holland B parameter based on Holland (2008)
% Assume Dvorak method
dp  = pn-pc;    
if holland2008 == 1
    bs  = -4.4 * 10^-5 * dp.^2 + 0.01 * dp + 0.03 * dpdt - 0.014 * lat + 0.15* vt + 1;
    bs  = min(max(bs, 0.5),2);  % numerical limits
    
    % Determine xn according to Holland, 2008 if Holland, 1980 is used
    if xn == 0.5
        xn  = 0.6*(1-dp/215);
    end
    vms = (100*bs*dp / (1.15*exp(1))).^0.5;
else
    bs  = vms^2*rhoa*e/(100*(pn-pc));
end

%% 1. Determine xn (if needed)
if ~isempty(robs)   
    
    % Try to fit data
    if estimate_rmax
        rrange=0.5*rvms:1:2.0*rvms;
    else
        rrange=rvms;
    end

    % Limits
    xnmin=0.0001;
    xnmax=1.00;
    xnrange=xnmin:0.0001:xnmax;
    
    % Finding minimal
    esqmin=1e12;
    for ii=1:length(xnrange)
        xn=xnrange(ii);
        jj=1;
        for jj=1:length(rrange)
            rtst=rrange(jj);
            [vest,pest]=h2010(robs,pc,dp,rtst,bs,rhoa,xn,rn,a);
            esq=sum((vest-vobs).^2); esq_save(jj) = esq;
            if esq<esqmin
                esqmin=esq;
                iamin=ii;
                irmin=jj;
            else
                break
            end
        end
    end
    xn=xnrange(iamin);
    rvms=rrange(irmin);
end

%% 2. Determine wind structure
% Main
if xn > 0.5
    xn = 0.5;
end
[vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,xn,rn,a);

% Check: needed to overcome instabilities
if length(r)> 1 && (vr(end-1) - vr(end)) < 0
    [vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,0.5,rn,a);
end


%% Private function: Holland et al. (2010)
function [vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,xn,rn,a)
if isempty(a)
    x=0.5+(r-rvms)*(xn-0.5)/(rn-rvms);
else
    x=0.5+(r-rvms)*a;
end
x(r<=rvms)=0.5;
%x=max(x,0.0);
pr=pc+dp*exp(-(rvms./r).^bs);
vr=((100*bs*dp*(rvms./r).^bs)./(rhoa*exp((rvms./r).^bs))).^x;

