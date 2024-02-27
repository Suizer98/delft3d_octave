% This program plots the output information as a movie for review

% This code is from Xbeach tests (Boerrs)
% Modified by JLE 9/24/09 to read xbeach output specific to SoCal model

fid=fopen('dims.dat','r');
nt=fread(fid,[1],'double')
nx=fread(fid,[1],'double')
ny=fread(fid,[1],'double')
fclose(fid)
fixy=fopen('xy.dat','r');
x=fread(fid,[nx+1,ny+1],'double');
y=fread(fid,[nx+1,ny+1],'double');
fclose(fixy)
dr ='M:\Coastal_Hazards\Xbeach\Tests_Sep09\VE4_3401\';
XBdims=getdimensions(dr);
r = readpoint('rugau001.dat',XBdims,3);

figure(1);
fid=fopen('H.dat','r');
fiz=fopen('zs.dat','r');
fib=fopen('zb.dat','r');
for i=1:nt;
    f=fread(fid,[nx+1,ny+1],'double');
    z=fread(fiz,[nx+1,ny+1],'double');
    b=fread(fib,[nx+1,ny+1],'double');

    figure(1)
    clf
    plot(x(:,2),z(:,2),'b')
    hold on
    plot(x(:,2),f(:,2),'r');
    plot(x(:,2),b(:,2),'k');
    plot([x(1,2),x(end/2,2)],[r(i,2),r(i,2)],'-m');
    a=axis;
    axis([a(1) x(end/2,2) a(3) a(4)]);
    
    title(i)
    hold on
    grid on
    %vv=axis;
     %axis([vv(1:2) -0.7 0.15]);

    drawnow
    grid on
    xlabel('x (m)');
    ylabel('z (m)');
    title('wave height (red), surface elevation (blue), depth (black)'); 
    
    
 
end;
fclose(fid)
fclose(fiz)
fclose(fib)
