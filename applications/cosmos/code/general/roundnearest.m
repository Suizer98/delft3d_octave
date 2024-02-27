function val=roundnearest(a,d)

n=round(a/d);
val=n*d;
% 
% n=ceil((a+ceil(a))/d);
% val=ceil(a)+n*d;

