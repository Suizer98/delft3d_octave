%% Preliminaries
softwaredir  = '../../../src/matlab/';
addpath(softwaredir)
clc;
lastchangedate(softwaredir)
displayfile('case.txt')

load validationdata

a = getphyspar();

teta_0 = 110/180*pi;    lambda = 10;    Js = 1/32;    Jf = 1/192;    
ds     = 0.1;
scal   = 0.1834;
s0     = [0:ds:lambda*3]-scal;   
teta0  = teta_0*sin(2*pi*s0/lambda)  +  teta_0^3*(Js*cos(6*pi*s0/lambda)-Jf*sin(6*pi*s0/lambda));    
iR0    = -teta_0*2*pi/lambda*cos(2*pi*s0/lambda)   +   6*pi/lambda*teta_0^3*(Js*sin(6*pi*s0/lambda)+Jf*cos(6*pi*s0/lambda));    

uiR = iR0; 
diR = -iR0;
ds = -s0;
s  = s0;
ds = ds+30;
uiR(s<0) = [];
s(s<0)   = [];
uiR(s>30) = [];
s(s>30)   = [];
diR(ds<0) = [];
ds(ds<0)   = [];
diR(ds>30) = [];
ds(ds>30)   = [];
%s   = s(1:2:end);
%ds  = ds(1:2:end);
ds  = fliplr(ds);
%uiR = uiR(1:2:end);
%diR = diR(1:2:end);
diR = fliplr(diR);
dx  = s(2)-s(1);
s   = [-2:dx:-dx, s, 30+dx:dx:32];
ds  = [-2:dx:-dx, ds, 30+dx:dx:32];
uiR = [0*(-2:dx:-dx), uiR, 0*(-2:dx:-dx)];
diR = [0*(-2:dx:-dx), diR, 0*(-2:dx:-dx)];

ul.q   = a.Q0 *ones(size(s));
ul.h   = a.H0 *ones(size(s));
ul.W   = a.W  *ones(size(s));
Cf0 = a.Cf0*ones(size(s));
ul.asR = zeros(size(s));
zb     = zeros(size(s));
ul.AR  = zeros(size(s));

%%
tic
for k = 1:10
[ul]  = meander_model(s,uiR,ul.AR,ul.q,ul.h,ul.W,Cf0,   zb,ul.asR,0.01,     0,    0);
[ul.h,ul.q] = swecalc(ul.s,zb',ul.h,ul.q,ul.Cf3,a.g,a.Q0,a.H0);
%plot(ul.s,ul.h)
%hold on;
end
%%
unl = ul;
dl = ul;
dnl = ul;
toc
tic
for k = 1:10
[unl]  = meander_model(s,uiR,unl.AR,unl.q,unl.h,unl.W,Cf0,zb,unl.asR,0.01,     1,    0);
[unl.h,unl.q] = swecalc(unl.s,zb',unl.h,unl.q,unl.Cf3,a.g,a.Q0,a.H0);
%plot(unl.s,unl.h)
%hold on;
end

%%
for k = 1:10
[dl]  = meander_model(ds,diR,dl.AR,dl.q,dl.h,dl.W,Cf0,   zb,dl.asR,0.01,     0,    0);
[dl.h,dl.q] = swecalc(dl.s,zb',dl.h,dl.q,dl.Cf3,a.g,a.Q0,a.H0);
end
for k = 1:10
[dnl] = meander_model(ds,diR,dnl.AR,dnl.q,dnl.h,dnl.W,Cf0,zb,dnl.asR,0.01,     1,    0);
[dnl.h,dnl.q] = swecalc(dnl.s,zb',dnl.h,dnl.q,dnl.Cf3,a.g,a.Q0,a.H0);
end
%% Rounding off;
rmpath(softwaredir)

