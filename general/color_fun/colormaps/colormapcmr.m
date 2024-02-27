function col = colormapcmr(m)
%COLORMAPCMR based on CMRMAP, but with optional input for no of steps

map=[0.    0.    0.  ;...
         .15   .15   .5 ;...
         .3    .15   .75;...
         .6    .2    .50;...
        1.     .25   .15;...
         .9    .5   0.  ;...
         .9    .75   .1 ;...
         .9    .9    .5 ;...
        1.    1.    1.];


r = map(:,1);
g = map(:,2);
b = map(:,3);    
x = linspace(0,1,size(map,1));
if nargin < 1
   ncol = 9;
else
   ncol=m;
end

for j=1:ncol

    i=(j-1)/(ncol-1);

    for k=1:(size(x,2)-1);
        in=and( i>=x(k), i<=x(k+1) );
        if in
            col(j,1)=r(k) + ((r(k+1)-r(k))/(x(k+1)-x(k)))*(i-x(k));
            col(j,2)=g(k) + ((g(k+1)-g(k))/(x(k+1)-x(k)))*(i-x(k));
            col(j,3)=b(k) + ((b(k+1)-b(k))/(x(k+1)-x(k)))*(i-x(k));
        end
    end
end

