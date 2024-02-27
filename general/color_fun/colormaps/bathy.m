function col = bathy(m)

% BATHY

x(1)=0.0;
r(1)=10;
%g(1)=103;
g(1)=10;
%b(1)=238;
b(1)=170;

x(2)=0.70;
r(2)=170;
g(2)=230;
b(2)=254;

x(3)=0.8;
r(3)=255;
g(3)=255;
b(3)=220;

x(4)=0.93;
r(4)=255;
g(4)=255;
b(4)=0;

x(5)=1.0;
r(5)=0.0;
g(5)=187;
b(5)=94;


if nargin < 1
   ncol = 16;
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

col=col/255;
