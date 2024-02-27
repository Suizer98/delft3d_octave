function [h,q] = swe1d2(h,q,b,Cf,dx,H0,Q0,g)
%

% 1D shallow water equation solver
%
% Coded: Willem Ottevanger, 02 October 2009


%initilisation;
%[physpar] = getphyspar();
[numpar] = getnumpar();
%t  = 0;
%Te = 1000;
CFL = numpar.sweCFL;
gq = numpar.gq;
%g = physpar.g;

%[bq1,bq2]   = getqp(b);%[b(:,1)*0,b(:,2)]);
%[Cfq1,Cfq2] = getqp(Cf);
bq1  = b*[1;-gq];
bq2  = b*[1; gq];
Cfq1 = Cf*[1;-gq];
Cfq2 = Cf*[1; gq];
x = [0;cumsum(dx)];
%heq1 = SWE_test1exactsol(bq1,sqrt(1/g));
%heq2 = SWE_test1exactsol(bq2,sqrt(1/g));
diffh = 1;
%%
k = 0;
while diffh/Q0 > numpar.sweacc;
    k = k+1;
    %Get face values
    %xL = x(1:end-1);
    %xR = x(2:end);
hL = [h(1,:)*[1;-1];h*[1;1]];
hR = [h*[1;-1];h(end,:)*[1;1]];
qL = [q(1,:)*[1;-1];q*[1;1]];
qR = [q*[1;-1];q(end,:)*[1;1]];
bL = [b(1,:)*[1;-1];b*[1;1]];
bR = [b*[1;-1];b(end,:)*[1;1]];
CfL = [Cf(1,:)*[1;-1];Cf*[1;1]];
CfR = [Cf*[1;-1];Cf(end,:)*[1;1]];
%    bL = [b(1,:)*[1;1];b*[1;1]];
%    bR = [b*[1;-1];b(end,:)*[1;-1]];
%    hL = [h(1,:)*[1;1];h*[1;1]];
%    hR = [h*[1;-1];h(end,:)*[1;-1]];
%    qL = [q(1,:)*[1;1];q*[1;1]];
%    qR = [q*[1;-1];q(end,:)*[1;-1]];
%    CfL = [Cf(1,:)*[1;1];Cf*[1;1]];
%    CfR = [Cf*[1;-1];Cf(end,:)*[1;-1]];
    %[bL,bR] = getLR(b);
    %[hL,hR] = getLR(h);
    %[qL,qR] = getLR(q);
    %[CfL,CfR] = getLR(Cf);

    hprev = q(:,1);%%g*h(:,1).^2/2+q(:,1).^2./h(:,1); %h(:,1);%
    %    q = [Q0*ones(size(bq1)),0*bq1];
    %boundary conditions
    hL(1)   = hR(1);%max(1+1-hR(1),0.5);%1;%hR(1);
    hR(end) = H0;%hR(1);%max(1+1-hL(end),0.5);
    qL(1)   = Q0;
    qR(end) = Q0;%qL(end);
    %pause
    Fdh = max(abs(hL(1:end-1)-hR(1:end-1)),abs(hL(2:end)-hR(2:end)));%For dissipation op.
    Fdq = max(abs(qL(1:end-1)-qR(1:end-1)),abs(qL(2:end)-qR(2:end)));%For dissipation op.

    %% Calcflux;
    %[Fhst,Fqst,sc] = calcHLL(hL,hR,qL,qR,g);

    sR = max(qL./hL+sqrt(g*hL),qR./hR+sqrt(g*hR));
    sL = min(qL./hL-sqrt(g*hL),qR./hR-sqrt(g*hR));
    sc = max([sR(:);sL(:)]);  %[max([abs(sR(2:M)),abs(sL(1:M-1))]')]';
    %  SL  !  SR
    %   \  !  /
    %    \ ! /
    %     \!/
    %****xL!xR*****

    FhL = qL;
    FqL = qL.^2./hL + 0.5*g*hL.^2;
    FhR = qR;
    FqR = qR.^2./hR + 0.5*g*hR.^2;

    %[sL(31),sR(31)]
    %pause(1)
    %HLL flux
    %Fhst = (sR.*FhL - sL.*FhR + sL.*sR.*(hR - hL))./(sR-sL);
    %Fqst = (sR.*FqL - sL.*FqR + sL.*sR.*(qR - qL))./(sR-sL);
    %sLt = sL>0;
    %sRt = sR<0;
    %Fhst(sLt) = FhL(sLt);
    %Fqst(sLt) = FqL(sLt);
    %Fhst(sRt) = FhR(sRt);
    %Fqst(sRt) = FqR(sRt);

    t1 = (min(sR,0)-min(sL,0))./(sR-sL);
    t2 = 1-t1;
    t3 = 0.5*(sR.*abs(sL)-sL.*abs(sR))./(sR-sL);
    Fhst = t1.*FhR + t2.*FhL - t3.*(hR-hL);
    Fqst = t1.*FqR + t2.*FqL - t3.*(qR-qL);

    dt = min(abs(CFL*dx(:)./sc(:)));
    %    disp(dt);

    hq1 = h*[1;-gq];
    hq2 = h*[1; gq];
    qq1 = q*[1;-gq];
    qq2 = q*[1; gq];

    %[hq1,hq2] = getqp(h);
    %[qq1,qq2] = getqp(q);

    % plot(x,heq1);pause

    %    linf = max([abs(hq1-heq1');abs(hq2-heq2')]);
    %    l2   = mean(sqrt([(hq1-heq1').^2;(hq2-heq2').^2]));
    %    disp([linf,l2]);
    Sm =   -g*hq1.*b(:,2).*2./dx     -g*hq2.*b(:,2).*2./dx -    Cfq1.*qq1.*abs(qq1./hq1.^2) -    Cfq2.*qq2.*abs(qq2./hq2.^2);%.*dx;
    Ss = gq*g*hq1.*b(:,2).*2./dx - gq*g*hq2.*b(:,2).*2./dx + gq*Cfq1.*qq1.*abs(qq1./hq1.^2) - gq*Cfq2.*qq2.*abs(qq2./hq2.^2);

    Fh = qq1 + qq2;
    Fq = qq1.^2./hq1 + qq2.^2./hq2 + 0.5*g*(hq1.^2+hq2.^2);

    %    plot(S); pause
    %    plot(0:M-1,- 1.5*dt*Ss,0:M-1,-3*dtx.*(Fqst(1:end-1)+Fqst(2:end)) +3*dtx.*Fq)
    %    plot(0:M-1,-3*dtx.*(Fqst(1:end-1)+Fqst(2:end)))
    %    pause

    %update means, slopes.
    dtx = dt./dx;
    h(:,1) = h(:,1)+  dtx.*(Fhst(1:end-1)-Fhst(2:end));
    h(:,2) = h(:,2)-3*dtx.*(Fhst(1:end-1)+Fhst(2:end)) +3*dtx.*Fh             - 12*0.01./dx.^2.*Fdh.*h(:,2);
    q(:,1) = q(:,1)+  dtx.*(Fqst(1:end-1)-Fqst(2:end))            + 0.5*dt*Sm;%+dt.*Sq;
    q(:,2) = q(:,2)-3*dtx.*(Fqst(1:end-1)+Fqst(2:end)) +3*dtx.*Fq + 1.5*dt*Ss - 12*0.01./dx.^2.*Fdq.*q(:,2);%+dt.*Sq;

%            figure(1)
%            plot(h(:,1));

%    plotdata(x,b,h,q,Cf);
%    pause(0.01);
    hnew = q(:,1);%g*h(:,1).^2/2+q(:,1).^2./h(:,1); %h(:,1);%
    diffh = max(abs(hnew-hprev));

    %   dhex = (-g*h(:,1)*iS-Cf(:,1).*q(:,1).^2./h(:,1).^2)./(-q(:,1).^2./h(:,1).^2+g.*h(:,1));

    %   linf = max(abs(dhex-(h(:,2).*2./dx)));
    %   l2   = mean(sqrt((dhex-(h(:,2).*2./dx)).^2));
    %   disp([linf,l2])
    %   pause(0.01);
    %    plotdata(x,b,flipud(h),-flipud(q),Cf);
    %    plot(0.5:1:M,q(:,2),0.5:1:M,flipud(q(:,2)))
    %    figure(2)
    %    plot(0:M-1,q(:,1))
    %    t = t+dt;
    %plotdata(x,b,h,q,Cf);
    %pause(0.01);
end
    disp(['SWE: ',num2str(k),': ',num2str(diffh/Q0)]);

% disp([k,diffh])
%%
%A 20  1.9258e-004  1.6742e-004
%A 40  1.9640e-004  1.7093e-004
%A 80  1.9826e-004  1.7266e-004
%A 160 1.9918e-004  1.7351e-004

%B 20  1.1070e-004  2.4470e-005
%B 40  1.5771e-004  3.1496e-005
%B 80  1.7991e-004  3.4754e-005
%B 160 1.9035e-004  3.6286e-005

%C 20  8.4930e-005  1.3310e-005  - -
%C 40  4.2184e-005  6.2935e-006 1.01  1.08
%C 80  2.1089e-005  3.0023e-006 1.00  1.07
%C 160 1.0443e-005  1.4553e-006 1.01  1.04

%%
