function output=wpr_holland2008(varargin)
% Holland 2008 Wind-Pressure relation
% Returns either Vmax or Pc

vmax=[];    % Maximum winds (m/s) - absolute value!
pc=[];      % Central pressure (hPa)
pn=1015;    % Environment pressure (hPa)
phi=20;     % Latitude (degrees)
vt=5;       % Cyclone translation speed (in m/s)
dpcdt=0;    % Intensity change in hPa/h
rhoa=[];    % Air density
SST=[];     % Sea surface temperature

for ii=1:length(varargin)
    if ischar(lower(varargin{ii}))
        switch lower(varargin{ii})
            case{'vmax'}
                vmax=varargin{ii+1};
            case{'pc'}
                pc=varargin{ii+1};
            case{'pn'}
                pn=varargin{ii+1};
            case{'lat','latitude'}
                phi=abs(varargin{ii+1});
            case{'vt'}
                vt=varargin{ii+1};
            case{'dpcdt'}
                dpcdt=varargin{ii+1};
            case{'rhoa'}
                rhoa=varargin{ii+1};
            case{'sst'}
                SST=varargin{ii+1};
        end
    end
end

% Constants
e=exp(1);  % Base of natural logarithms

if isempty(rhoa)
    % Used when Pc needs to be determined
    if ~isempty(vmax)
        dp1=1:150;
        pc1=pn-dp1;
    else
        dp1=pn-pc;
        pc1=pc;
    end    
    if isempty(SST)
        Ts=28.0-3*(phi-10)/20; % Surface temperature
    else
        Ts=SST-1;              % Surface temperature
    end
    prmw=pc1+dp1/3.7;
    qm=0.9*(3.802./prmw)*exp(17.67*Ts/(243.5+Ts)); % Vapor pressure
    Tvs=(Ts+273.15)*(1.0+0.81*qm);                % Virtual surface air temperature
    Rspecific=287.058;
    rhoa=100.*pc1./(Rspecific*Tvs);
end

if isempty(vmax)
    % Vmax to be determined
    dp=pn-pc;  % Pressure drop (in hPa)
    x=0.6*(1+dp/215);
    bs = -4.4e-5*dp.^2 + 0.01*dp + 0.03*dpcdt - 0.014*phi + 0.15*vt^x + 1.0;
    vmax=sqrt(100*bs.*dp./(rhoa*e));
    output=vmax;
else
    % Pc to be determined
    dpall = 1:5:151;
    x       = 0.6*(1+dpall/215);
    bs      = -4.4e-5*dpall.^2 + 0.01*dpall + 0.03*dpcdt - 0.014*phi + 0.15*vt.^x + 1.0;
    vmaxall = sqrt(100*bs.*dpall./(rhoa*e));
    dp      = interp1(vmaxall,dpall,vmax);
    output  = pn-dp;    
end

