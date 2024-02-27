function k=cmglocalk(pd,dep)

% CMGLOCALK: Using Newton-Raphson method to compute local wave number
% from the dispersion relation
% K = CMGLOCALK (pd, dep);
% pd = wave period in seconds
% dep = water depth in M
% 
% jpx @ usgs, 10-12-02


omega=2*pi./pd;
g=9.81;
a=omega.^2 .* dep /g;

l0=1.56 * pd.^2;

x0=2*pi*dep./l0;
eps=1000;
i=0;
while eps>1e-8
	i=i+1;
	fx= x0.*tanh(x0)-a;
	fxd=x0.*(1 - tanh(x0).*tanh(x0)) + tanh(x0);
	
	x=x0 - fx./fxd;
	
	eps=abs(1 - x./x0);
	x0=x;
end;

k=x./dep;
return;