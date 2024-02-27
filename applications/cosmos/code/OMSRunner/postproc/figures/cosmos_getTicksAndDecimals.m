function [tck,dec]=cosmos_getTicksAndDecimals(c1,c2,np)

tcks=[1e-3 2e-3 5e-3 1e-2 2e-2 5e-2 1e-1 2e-1 5e-1 1e-0 2e-0 5e-0 1e+1 2e+1 5e+1 1e+2 2e+2 5e+2 1e+3 2e+3 5e+3 1e+4 2e+4 5e+4];
decs=[3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

cavg=(c2-c1)/np;

ii=find(tcks<cavg,1,'last');

if isempty(ii)
    tck=cavg;
    dec=1;
else
    tck=tcks(ii);
    dec=decs(ii);
end
