clear all
%
% Calibration parameter
% ---------------------
gamma=0.8;Cf=0.0027;Acal=0.3;
%
% Constants
% ---------
rho=1000;g=9.81;
D50=200e-6;
D90=300e-6;
por=0.4;
delta=1.65;
nu=1e-6;
kappa=0.4;
z0=0.006;
hmin=0.1;
wetslope=0.15;
dryslope=1;
%
% Definition of grid and water depth
% ----------------------------------
dt=30;
nt=420;
dx=1;
xx=[-100,-30,-20,  0];
zz=[   0,  4,6.5,6.5];
x=[-100:dx:0];
eta=zeros(size(x));
nx=length(x);
for i=1:nx;
    zbt(1,i)=interp1(xx,zz,x(i));
end
eta=5; % offshore water level
%
% Start time loop
% ---------------
for it=2:nt
    %
    % Boundary condition
    % ------------------
    H0=1.2;   % offshore wave height
    T=6;      % wave period
    dir0=0;   % offshore wave direction
    h=max(eta-zbt(it-1,:),hmin);
    % Convert dir0 to radians
    dir0=dir0*pi/180;
    omega=2*pi/T;
    %
    % Compute deep water celerity
    % ---------------------------
    k0=dispersion(h(1),T);
    C0=omega/k0;
    %
    % Compute k,C,Cg for all points
    % -----------------------------
    for i=1:nx
        if h(i)>hmin
            k(i)=dispersion(h(i),T);
            C(i)=omega/k(i);
            n(i)=0.5+k(i)*h(i)/sinh(2*k(i)*h(i));
            Cg(i)=n(i)*C(i);
            dir(i)=asin(sin(dir0)*C(i)/C0);
        else
            k(i)=0;
            C(i)=0;
            n(i)=0;
            Cg(i)=0;
            dir(i)=0;
        end
    end
    %
    % Solve wave energy balance starting at seaward end
    % -------------------------------------------------
    E(1)=1/8*rho*g*H0^2;
    for i=1:nx-1;
        if h(i+1)>hmin
            dx=x(i+1)-x(i);
            % Predictor step
            H(i)=sqrt(8*E(i)/rho/g);
            [Dw(i),Qb(i)]=Baldock2(gamma,k(i),h(i),H(i),T,1);
            E(i+1)=(E(i)*Cg(i)*cos(dir(i))-Dw(i)*dx)/(Cg(i+1)*cos(dir(i+1)));
            % Corrector step
            H(i+1)=sqrt(8*E(i+1)/rho/g);
            [Dw(i+1),Qb(i+1)]=Baldock2(gamma,k(i+1),h(i+1),H(i+1),T,1);
            E(i+1)=(E(i)*Cg(i)*cos(dir(i))-.5*(Dw(i)+Dw(i+1))*dx)...
                /(Cg(i+1)*cos(dir(i+1)));
            E(i+1)=min(E(i+1),1/8*rho*g*h(i+1)^2);
            % Wave forces
            Fx(i)=-((n(i+1)*(cos(dir(i+1)))^2+n(i+1)-.5)*E(i+1)...
                - (n(i  )*(cos(dir(i  )))^2+n(i  )-.5)*E(i  ))/dx;
            Fy(i)=-(n(i+1)*cos(dir(i+1))*sin(dir(i+1))*E(i+1)...
                - n(i  )*cos(dir(i  ))*sin(dir(i  ))*E(i  ))/dx;
        else
            H(i+1)=0;
            Dw(i+1)=0;
            E(i+1)=0;
            Fx(i)=0;
            Fy(i)=0;
        end
    end
    %
    % Solve cross-shore momentum balance
    % ----------------------------------
    for i=1:nx-1;
        if h(i+1)>hmin
            dx=x(i+1)-x(i);
            eta(i+1)=eta(i)+Fx(i)/rho/g*2/(h(i)+h(i+1))*dx;
        else
            eta(i+1)=eta(i);
        end
    end
    %
    % Compute u and v
    % ---------------
    for i=1:nx
        if h(i)>hmin
            i1=max(i-1,1);
            i2=min(i,nx-1);
            % Longshore velocity
            v(i)=sqrt((Fy(i1)+Fy(i2))/2/rho/Cf);
            % Cross-shore velocity (Note enhancement for breaking waves!)
            u(i)=-E(i)/rho/C(i)/h(i)*cos(dir(i))*(1+1*Qb(i));
        else
            v(i)=0;
            u(i)=0;
        end
    end
    %
    % Compute sand transport according to Soulsby - van Rijn
    % ------------------------------------------------------
    Dstar=(g*delta/nu^2)^(1/3)*D50
    for i=1:nx
        if h(i)>hmin
            Urms(i)=1/sqrt(2)*pi*H(i)/T./sinh(k(i).*h(i));
            if D50<=0.5e-3
                Ucr(i)=0.19*D50^0.1*log10(4*h(i)/D90);
            else
                Ucr=8.5*D50^0.6*log10(4*h/D90);
            end
            Cd(i)=(kappa./(log(h(i)/z0)-1)).^2;
            %Cd(i)=0.01;
            umod(i)=sqrt(u(i)^2+v(i)^2+0.018/Cd(i)*Urms(i)^2);
            if umod(i)>Ucr(i)
                ksi(i)=(umod(i)-Ucr(i))^2.4;
            else
                ksi(i)=0;
            end
            Asb(i)=0.05*h(i)*(D50/h(i)/delta/g/D50)^1.2;
            Ass(i)=0.012*D50*Dstar^(-0.6)/(delta*g*D50)^1.2;
            Sbx(i)=Acal*Asb(i)*u(i)*ksi(i);
            Sby(i)=Acal*Asb(i)*v(i)*ksi(i);
            Ssx(i)=Acal*Ass(i)*u(i)*ksi(i);
            Ssy(i)=Acal*Ass(i)*v(i)*ksi(i);
            Stotx(i)=Sbx(i)+Ssx(i);
            Stoty(i)=Sby(i)+Ssy(i);
        else
            Urms(i)=0;
            Ucr(i)=0;
            Cd(i)=0;
            ksi(i)=0;
            Asb(i)=0;
            Ass(i)=0;
            Sbx(i)=0;
            Sby(i)=0;
            Ssx(i)=0;
            Ssy(i)=0;
            Stotx(i)=0;
            Stoty(i)=0;
        end
    end
    %
    % Upwind procedure to obtain transports between grid cells for bottom
    % updating
    % -------------------------------------------------------------------
    for i=1:nx-1
         slopex=0;%(zbt(it-1,i+1)-zbt(it-1,i))/dx;
        if Stotx(i)>0 & Stotx(i+1) > 0
            Sx_upwind(i)=Stotx(i)*(1-1.6*slopex);
        elseif Stotx(i)<0 & Stotx(i+1) < 0
            Sx_upwind(i)=Stotx(i+1)*(1-1.6*slopex);
        else
            Sx_upwind(i)=.5*(Stotx(i)+Stotx(i+1))*(1-1.6*slopex);
        end
    end
    %
    % Now update bed level
    % --------------------
    dz(1)=0.;dz(nx)=0.;
    for i=2:nx-1
        dz(i)=-dt/(1-por)*(Sx_upwind(i)-Sx_upwind(i-1))/dx;
    end
    zbt(it,:)=zbt(it-1,:)+dz;
    %
    % Avalanching
    % -----------
    for i=1:nx-1
        if h(i)>hmin
            critslope=wetslope;
        else
            critslope=dryslope;
        end
        slopex=(zbt(it,i+1)-zbt(it,i))/dx;
        if slopex>critslope
            dzaval=.5*(slopex-critslope)*dx;
            zbt(it,i)=zbt(it,i)+dzaval;
            zbt(it,i+1)=zbt(it,i+1)-dzaval;
        elseif slopex<-critslope
            dzaval=.5*(slopex+critslope)*dx;
            zbt(it,i)=zbt(it,i)+dzaval;
            zbt(it,i+1)=zbt(it,i+1)-dzaval;
        end
    end
    figure(1)
    subplot(421);
    plot(-x,zbt(1,:),-x,zbt(it,:),-x,eta,'linewidth',2);ylabel('-h (m)');
    title('Bed level');
    subplot(423);
    plot(-x,H,'linewidth',2);ylabel('H (m)');
    title('Wave height')
    subplot(425);
    plot(-x,Dw,'linewidth',2);ylabel('Dw (W/m2)');
    title('Dissipation')
    subplot(427);
    plot(-x,v,'linewidth',2);ylabel('v (m/s)');
    title('Longshore vel.')
    xlabel ('X (m)')
    subplot(422);
    plot(-x,dir*180/pi,'linewidth',2);ylabel('Dir (m)');
    title('Direction')
    subplot(424);
    plot(-x,u,'linewidth',2);ylabel('u (m/s)');
    title('Cross-shore vel.')
    subplot(426);
    plot(-x,Stotx,'linewidth',2);ylabel('Stotx (m2/s)');
    title('Transport-x')
    subplot(428);
    plot(-x,zbt(it,:)-zbt(1,:),'linewidth',2);ylabel('sed. (m)');
    title('Sed/ero (m)')
    drawnow;
end
