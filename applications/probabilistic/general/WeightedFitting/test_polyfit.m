 % Testing the weighting procedure for the polyfit and polyfitn functions

f= figure(1)
clf;
x = [1.3 2 3 4 4.5];
y = [1.4 2.2 3.5 4.9 2.3];
p = polyfit(x,y,2)
f = polyval(p,x);
plot(x,y,'k*','MarkerSize',10);
hold on;
plot(x,f,'b-')

hold on;
w = [100 10 100 50 1];
n=3;
p2 = wpolyfit(x,y,n,w)
f2= polyval(p2,x);
plot(x,f2,'r-')
hleg = legend ( 'points','non-weighted','weighted');
title ('Testing the wpolyfit function')
set(hleg, 'Location', 'Best');
xlim([0,5])

print -dpng polyfit

