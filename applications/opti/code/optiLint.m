function [sumzi,zi]=optiLint(this,x,y,z,lx,ly,dataGroup);

%OPTIBILINEAR - transect bilinear interpolation

d=20;
xi=lx(1):diff(lx)/d:lx(2);
yi=ly(1):diff(ly)/d:ly(2);
dxy=sqrt((diff(lx)/d).^2+(diff(ly)/d).^2);

if ~isfield(this.input(dataGroup),'dataGridInfo')|isempty(this.input(dataGroup).dataGridInfo)
    error('optiLint needs gridsize information in optiStruct.input.dataGridInfo!');
end

xg=reshape(x,this.input(dataGroup).dataGridInfo);
yg=reshape(y,this.input(dataGroup).dataGridInfo);
zg=reshape(z,this.input(dataGroup).dataGridInfo);

zi=lint2(xg,yg,zg,xi,yi);
xi(isnan(zi))=[];
yi(isnan(zi))=[];
zi(isnan(zi))=[];
sumzi=trapz(pathdistance(xi,yi),zi);
