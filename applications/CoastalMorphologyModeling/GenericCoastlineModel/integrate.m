function F=integrate(x1,x2,xin,yin)
dx=xin(2)-xin(1);
x=[xin(1)-dx/2:dx:xin(end)+dx/2];
y=[0 yin 0];
f(1)=0;
for i=2:length(x)
    f(i)=f(i-1)+y(i);
end
if x1<x(1)
    f1=f(1);
else
    f1=interp1(x,f,x1);
end
if x2>x(end)
    f2=f(end);
else
    f2=interp1(x,f,x2);
end
F=f2-f1;

