function hFig = A4fig()

Y = 29.7/2;   X = 21.0;                       
xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
hFig = figure; hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[X Y]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');