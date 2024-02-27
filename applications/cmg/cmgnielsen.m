function klocal=cmgnielsen(pd,dep)

%Nielsen (1982)'s empirical function to compute local wave number.
% 
% klocal=cmgnielsen(period,depth)
% 
% 	pd = vector of wave period in SECONDS;
% 	dep = vector of water depth in METERS
% 	klocal = output local wave number
% 
% jpx @ usgs, 12-14-00
% 
if nargin<1
	help(mfilename);
	return;
end;

grav=9.81; % M/S^2

period=pd(:) * ones(1,length(dep));
depth=ones(length(pd),1) * dep(:)';

l0=1.56*period.^2;
eps=depth./l0;

if any(eps>0.21)
	fprintf('\nThe value of D/L0 is greater than 0.21.\nPlease use CMGLOCALK instead.\n');
	error('...');
end;

k0=(4*pi^2)./(grav*period.^2);


term1=sqrt(k0.*depth);
term2=1+(1/6)*k0.*depth+(11/360)*(k0.*depth).^2;
klocal=term1 .* term2 ./ depth;