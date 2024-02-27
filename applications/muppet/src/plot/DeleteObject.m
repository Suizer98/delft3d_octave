function DeleteObject(i,j,k)

h=findobj(gcf,'UserData',[i,j,k]);
delete(h);
