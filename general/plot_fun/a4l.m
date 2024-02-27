function a4l
%a4l - Sets current papersize and position to a4 landscape and fills page

set(gcf,'paperUnits','centimeters','papero','p','papertype','a4','paperpos',[0 0 25*sqrt(sqrt(2)) 25*sqrt(1/sqrt(2))]);
set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize')));