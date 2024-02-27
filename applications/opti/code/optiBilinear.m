function [sumzi,zi]=optiBilinear(this,x,y,z,lx,ly);

%OPTIBILINEAR - transect bilinear interpolation

d=1e2;
xi=lx(1):diff(lx)/d:lx(2);
yi=ly(1):diff(ly)/d:ly(2);
dxy=sqrt((diff(lx)/d).^2+(diff(ly)/d).^2);

notnan=find(~isnan(x)|~isnan(y)|~isnan(z));
x=x(notnan);
y=y(notnan);
z=z(notnan);

for ii=1:length(xi)

    dists=sqrt((x-xi(ii)).^2+(y-yi(ii)).^2);
    [fac,id]=sort(dists);
    %Use first four
    zi(ii)=sum(fac(1:4)./sum(fac(1:4)).*flipud(z(id(1:4))));
end

sumzi=trapz(pathdistance(xi,yi),zi);
