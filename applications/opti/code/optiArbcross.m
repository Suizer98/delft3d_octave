function [sumzi,zi]=optiArbcross(this,x,y,z,lx,ly,dataGroup);

%OPTIARBCROSS - transect interpolation based on arbcross
% This function needs gridded data information in optiStruct.dataGridInfo.size

if ~isfield(this.input(dataGroup),'dataGridInfo')|isempty(this.input(dataGroup).dataGridInfo)
    error('optiArbcross needs gridsize information in optiStruct.input.dataGridInfo!');
end

xg=reshape(x,this.input(dataGroup).dataGridInfo);
yg=reshape(y,this.input(dataGroup).dataGridInfo);
zg=reshape(z,this.input(dataGroup).dataGridInfo);

%Specify nans in x,y as middle of grid, to enable triangulation
% idnan=(isnan(xg)|isnan(yg));
% xg(idnan)=mean(mean(xg(~idnan)));
% yg(idnan)=mean(mean(yg(~idnan)));

[xi,yi,zi]=arbcross(xg,yg,zg,lx,ly);
idnanzi=isnan(zi); %Only not nans
xi=xi(~idnanzi);
yi=yi(~idnanzi);
zi=zi(~idnanzi);
% pd=diff(pathdistance(xi,yi));%section lengths
% pd=[pd(1)*.5; .5*(pd(1:end-1)+pd(2:end)); .5*pd(end)]; %Redivide nicely over datapoints
% 
% sumzi=sum(zi.*pd);

sumzi=trapz(pathdistance(xi,yi),zi);