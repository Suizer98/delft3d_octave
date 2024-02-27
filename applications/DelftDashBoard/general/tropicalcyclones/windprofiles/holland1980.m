function [vr,pr]=holland1980(r,pn,pc,varargin)

rhoa=1.15;
iopt=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'rhoa'}
                rhoa=varargin{ii+1};
            case{'ab'}
                iopt=2;
        end
    end
end

if iopt==1
    % Vmax, Pdrop, Rmax given
    vmax  = varargin{1}; % m/s
    rmax  = varargin{2}; % km
else
    a    = varargin{1}; % [-]
    b    = varargin{2}; % [-]
end

% Constants
e=exp(1);  % Base of natural logarithms

dp = pn-pc;

if iopt==1 % Compute a and b from Vmax, dp, and Rmax
    b=rhoa*e*vmax^2/(100*dp);
    a=rmax^b;
else
    rmax=a^(1/b);
end

vr  = sqrt(a*b*(100*dp).*exp(-a./r.^b)./(rhoa*r.^b));
pr  = pn - dp + dp.*exp(-(rmax./r).^b);
