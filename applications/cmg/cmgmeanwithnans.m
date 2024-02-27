function y=cmgmeanwithnans(x,varargin);
pct=0.25;
if nargin>1
	pct=varargin{1};
end;

if isempty(x)
	y=nan;
	return;
end;

if size(x,1)==1
	x=x(:);
end;
x=cmgdataclean(x);
nans=isnan(x);
indx=find(nans);
x(indx)=0;

ncount=size(x,1)-sum(nans);

indx=find(ncount==0);
ncount(indx)=1;

y=sum(x)./ncount;
y(indx)=indx+nan;

dum=ncount./size(x,1);
indx=find(dum<pct);
y(indx)=indx+nan;

return;