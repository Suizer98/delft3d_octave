function a3l
%a3l - Sets current papersize and position to a3 landscape and fills page

set(gcf,'paperUnits','centimeters','papero','p','papertype','a3','paperpos',[0 0 50*sqrt(1/sqrt(2)) 25*sqrt(sqrt(2))]);
set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize')));