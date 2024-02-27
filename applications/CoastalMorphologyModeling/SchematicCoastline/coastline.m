clear all;close all;
%% Input
phi0=pi/12;
Bd=200;B=50;L=2000;x0=5000
dt=0.01;
dx=100;
sx=500000;
d=10;
nt=50/dt
x=0:dx:25000
nx=length(x);
%% Initialise white figure
figure(1);
set(gcf,'color','w')
hold on
%% Run three different cases
for j=1:3
    %% Define initial disturbance: gaussian hump
    for i=1:nx
        y(i)=-.2*B+B*exp(-(x(i)-x0)^2/L^2);
    end
    y0=y;
    subplot(3,1,j)
    %% Start time loop
    for it=2:nt
        for i=1:nx-1
            %% Compute coast angle
            phic(i)=atan((y(i+1)-y(i))/dx);
            %% Compute influence factor coastline position
            if j==1
                fac(i)=1;
            elseif j==2
                fac(i)=y(i)/Bd+1;
            else
                fac(i)=max(min(y(i)/Bd+1,1),0);
            end
            %% Compute transport rate
            Sx(i)=sx*sin(2*(phi0-phic(i)))*fac(i);
        end
        Sx(nx)=Sx(nx-1);
        %% Compute rate of change of coastline position and new coastline
        for i=2:nx
            dydt(i)=-1/d*(Sx(i)-Sx(i-1))/dx;
            y(i)=y(i)+dydt(i)*dt;
        end
        if mod(it,500)==0
            fill(x/1000,y0,'r');hold on;fill(x/1000,y,'y');hold off %axis equal
            ylabel('y (m)')
            if j==1
                title('S_x independent of y')
            elseif j==2
                title('S_x=S_{x0}(y/B_d+1)')
            else
                title('S_x=S_{x0}[min(y/B_d+1,1)]')
                xlabel('longshore distance (km)')
            end
            drawnow;
            print('-dpng',[num2str(j*100+it/500),'.png'])
        end
    end
    fill(x/1000,y0,'r');hold on;fill(x/1000,y,'y'); %axis equal
    plot(x/1000,y,'k','linewidth',2);hold off
            ylabel('y (m)')
            if j==1
                title('S_x independent of y')
            elseif j==2
                title('S_x=S_{x0}(y/B_{d}+1)')
            else
                title('S_x=S_{x0}[min(y/B_d+1,1)]')
                xlabel('longshore distance (km)')
            end
    print('-dpng',[num2str(j*100+it/500+1),'.png'])
end