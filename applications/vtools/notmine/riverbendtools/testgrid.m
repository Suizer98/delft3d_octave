%wlsettings; 
grd = wlgrid('read','Booij.grd');
m = 155;
n = 6;
p1 = [grd.X(m+1,n+1),grd.Y(m+1,n+1)];
p2 = [grd.X(m+2,n+1),grd.Y(m+2,n+1)];
p3 = [grd.X(m+2,n+2),grd.Y(m+2,n+2)];
plot(grd.X',grd.Y','b',grd.X,grd.Y,'b');
axis equal
hold on;
plot([p1(1),p2(1),p3(1)],[p1(2),p2(2),p3(2)],'r',p1(1),p1(2),'ro')
d2 = p2-p1;
d3 = p3-p1;

ang2=atan2(d2(1),d2(2))+3*pi;
ang3=atan2(d3(1),d3(2))+3*pi;

dang = ang2-ang3;
if dang<0
   title('Clockwise grid orientation')
elseif dang > 0 
   title('Anti-clockwise grid orientation')
else
   title('Try again')
end