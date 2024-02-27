clear
clc
close all

% max difference in flow depth between energy-Euler and energy-RK4 = 3.353101e-05 m 
% max difference in flow depth between energy-RK4 and depth-RK4 = 3.355792e-05 m 
% max difference in flow depth between depth-euler and depth-RK4 = 1.200612e-05 m 
% RK4 cost: 
% energy-RK4 is 59.99 % slower than energy-Euler 
% depth-RK4 is 260.54 % slower than depth-Euler 
% energy vs. depth: 
% energy-euler is 442.71 % slower than depth-euler 
% depth-RK4 is -58.48 % slower than energy-RK4 
% full function cost: 
% full function is 1.84 % slower than separate function 

%% INPUT

nt=1;

L=70000;
dx=1;

qwup=5;
Hdown=9;
Cf=0.01;
slopeb=1e-4;
B=1;

g=9.81;

%% CALC

%rename
nx=round(L/dx);
input.mdv.nx=nx;
input.grd.dx=dx;
input.grd.B=B*ones(1,nx);
input.mdv.g=g;
input.mdv.flowtype=1;

in.s=0; %streamwise position with known flow depth, positive downstream [m]
in.s2=-L; %streamwise position in which we want to know the flow depth, positive downstream [m]
in.ib=slopeb; %bed slope [-]
in.Cf=Cf; %dimensionless friction coefficient [-]
in.h=Hdown; %flow depth at 's' [m]
in.H=(Cf*qwup^2/g/slopeb)^(1/3); %normal flow depth [m]

Cf=Cf*ones(1,nx);
etab=fliplr(linspace(0,L*slopeb,input.mdv.nx));

xp=-fliplr(linspace(0,nx*dx,nx));

%call
[~,H1]=flow_steady_energy_euler(qwup,Hdown,Cf,etab,input); %energy Euler
[~,H2]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input); %energy RK4
[~,H3]=flow_update_backwatersolver_3(qwup,Hdown,Cf,etab,input); %energy Euler (full)
[~,H4]=flow_steady_depth_euler(qwup,Hdown,Cf,etab,input); %depth Euler
[~,H5]=flow_steady_depth_RK4(qwup,Hdown,Cf,etab,input); %depth RK4
H6=Hdown*ones(1,nx);
for kp=1:nx-1
    in.s2=xp(kp);
    out=Bresse(in);
    H6(kp)=out.h2;
end

%% CHECK
tol=1e-8;

h_err1=max(abs(H1-H2));
fprintf('max difference in flow depth between energy-Euler and energy-RK4 = %e m \n',h_err1)

h_err3=max(abs(H2-H4));
fprintf('max difference in flow depth between energy-RK4 and depth-RK4 = %e m \n',h_err3)

h_err4=max(abs(H5-H4));
fprintf('max difference in flow depth between depth-euler and depth-RK4 = %e m \n',h_err4)

h_err2=max(abs(H1-H3));
if h_err2>tol
    fprintf('error! \n')
else
%     fprintf('same \n')
end

%% TIME

tic;
for kt=1:nt
    [U1,H1]=flow_steady_energy_euler(qwup,Hdown,Cf,etab,input);
end
time1=toc;

tic;
for kt=1:nt
    [U2,H2]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input);
end
time2=toc;

tic;
for kt=1:nt
    [U3,H3]=flow_update_backwatersolver_3(qwup,Hdown,Cf,etab,input);
end
time3=toc;

tic;
for kt=1:nt
    [U4,H4]=flow_steady_depth_euler(qwup,Hdown,Cf,etab,input);
end
time4=toc;

tic;
for kt=1:nt
    [U4,H5]=flow_steady_depth_RK4(qwup,Hdown,Cf,etab,input);
end
time5=toc;

% H1 energy Euler
% H2 energy RK4
% H3 energy Euler (full)
% H4 depth Euler
% H5 depth RK4

fprintf('RK4 cost: \n')
rel_t1=(time2-time1)/time1*100;
fprintf('energy-RK4 is %4.2f %% slower than energy-Euler \n',rel_t1)
rel_t1=(time5-time4)/time4*100;
fprintf('depth-RK4 is %4.2f %% slower than depth-Euler \n',rel_t1)

fprintf('energy vs. depth: \n')
rel_t3=(time1-time4)/time4*100;
fprintf('energy-euler is %4.2f %% slower than depth-euler \n',rel_t3)
rel_t3=(time5-time2)/time2*100;
fprintf('depth-RK4 is %4.2f %% slower than energy-RK4 \n',rel_t3)

fprintf('full function cost: \n')
rel_t2=(time3-time1)/time1*100;
fprintf('full function is %4.2f %% slower than separate function \n',rel_t2)

%% PLOT

figure
subplot(2,1,1)
hold on
han.p(1)=plot(xp,H1-H6);
han.p(2)=plot(xp,H2-H6);
han.p(3)=plot(xp,H4-H6);
han.p(4)=plot(xp,H5-H6);
legend(han.p,{'E-Euler','E-RK4','h-Euler','h-RK4'})
ylabel('difference to Bresse [m]')

subplot(2,1,2)
hold on
plot(xp,etab,'k')
plot(xp,etab+H1)
plot(xp,etab+H2)
plot(xp,etab+H4)
plot(xp,etab+H5)
plot(xp,etab+H6)
ylabel('elevation [m]')