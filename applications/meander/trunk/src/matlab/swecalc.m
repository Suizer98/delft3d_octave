function [h2,q2,hd,qd] = swecalc(x,b,h,q,Cf,g,Q,H);
% SWECALC - calculation of the shallow water equations
%

% x(1)
%--*----*----*-------*----------*
%

%
% Coded: Willem Ottevanger, 02 October 2009
%
%


dx = diff(x);
M = length(dx);
gq = 1;

%x = x(:);
%b = x(:);
%h = x(:);
%q = x(:);
%Cf = x(:);
%dx = dx(:);

bq1 = b(1:M);   bq2 = b(2:M+1);
hq1 = h(1:M);   hq2 = h(2:M+1);
qq1 = q(1:M);   qq2 = q(2:M+1);
Cfq1 = Cf(1:M); Cfq2 = Cf(2:M+1);

bd  = [0.5*(bq1+bq2)  ,0.5*(-bq1*gq+bq2*gq)];
hd  = [0.5*(hq1+hq2)  ,0.5*(-hq1*gq+hq2*gq)];
qd  = [0.5*(qq1+qq2)  ,0.5*(-qq1*gq+qq2*gq)];
%qd  = [Q*ones(size(hq1)),0*hq1];
Cfd = [0.5*(Cfq1+Cfq2),0*hq1];
%Cfd  = [0.5*(Cfq1+Cfq2)  ,0.5*(-Cfq1*gq+Cfq2*gq)];
[hd,qd] = swe1d2(hd,qd,bd,Cfd,dx,H,Q,g);

hL = [hd(1,:)*[1;-1];hd*[1;1]];
hR = [hd*[1;-1];hd(end,:)*[1;1]];
bL = [bd(1,:)*[1;-1];bd*[1;1]];
bR = [bd*[1;-1];bd(end,:)*[1;1]];
qL = [qd(1,:)*[1;-1];qd*[1;1]];
qR = [qd*[1;-1];qd(end,:)*[1;1]];
%[hL,hR] = getLR(hd);
%[qL,qR] = getLR(qd);

h2 = [hL+hR]*0.5;
q2 = [qL+qR]*0.5;
b2 = [bL+bR]*0.5;
%05-10-2009
% plot(q2);
% hold on; 
% plot(h2,'r');
% pause;
%pause;


%plotdata(x,bd,hd,qd,Cfd);
%pause(0.01)