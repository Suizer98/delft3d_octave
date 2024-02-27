function [vr,pr]=fujita(r,pfar,pc,r0,lat,c1,varargin)

rho_air=1.15;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'rhoa'}
                rho_air=varargin{ii+1};
        end
    end
end

f = 2*(2*pi/86400)*sin(lat*pi/180) ; % Coriolis parameter

% Convert to SI
pfar=pfar*100; % hPa to Pa
pc=pc*100;     % hPa to Pa
r0=r0*1000;    % km to m
r=r*1000;      % km to m

cf = 4.0 / rho_air / ( r0 * f )^2;
dp = pfar - pc;

rr = 1.0 + ( r/r0 ).^2;
xx = dp ./ sqrt( rr );
pr = pfar - xx;     % Surface pressure
vr = c1 * 0.5 * f * r .* ( -1.0 + sqrt( 1.0 + cf * dp./ rr.^1.5 ) ); % Gradient winds
pr=0.01*pr;
