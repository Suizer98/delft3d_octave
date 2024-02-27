function a3p
%a3p - Sets current papersize and position to a3 portrait and fills page

set(gcf,'paperUnits','centimeters','papero','p','papertype','a3','paperpos',[0 0 25*sqrt(sqrt(2)) 50*sqrt(1/sqrt(2))]);