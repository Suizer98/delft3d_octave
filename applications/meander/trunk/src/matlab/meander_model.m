
function [output] = meander_model(s,iR,AR,q,h,W,Cfe,zb,asR,dt,modtyp,FasRb)
% Meander model based on
%
% 1) Model for the spatial development of alpha_s/R
% 2) Parametrisation from 1DV model (<fsfn>,<Cf>).
% 3) Model for the spatial development of A/R
% 4) Bank erosion formulation based on B/2*alpha_s/R*U.
%
% Coded: Willem Ottevanger, 6 October 2009
%
% -------------------------------------------



%% User settings
[physpar] = getphyspar();
g         = physpar.g;       % Gravity
karman    = physpar.karman;  % von Karman constant
Sn        = physpar.Sn;      % Transverse slope
chi       = physpar.chi;     % ??
Eu        = physpar.Eu;
iS        = physpar.iS;      % Valley slope
%Cf0       = physpar.Cf0;
z0        = physpar.ks/30;
L         = physpar.L;
H0        = physpar.H0;
Q0        = physpar.Q0;      %Unit discharge
Fr        = Q0/H0/sqrt(g*H0);
%Gthet     = physpar.Gthet;
[numpar]  = getnumpar();
CFL       = numpar.asRCFL;
smoothrad = numpar.smoothrad;
streamcurv= numpar.streamcurv;
bedtype   = numpar.bedtype;
asRacc    = numpar.asRacc;
routyp    = numpar.routyp;
%ds        = numpar.ds;
rn        = numpar.rn;
maxK      = numpar.maxK;
sweacc    = numpar.sweacc;              % accuracy cutoff for SWE calculation

%% Initialisation

%Make vertical input.
q   = q(:);
h   = h(:);
W   = W(:);
Cfe = Cfe(:);
%zb  = zb(:);
asR = asR(:);
AR  = AR(:);
while (dt > 0)
    s = s(:);
    iR = iR(:);
    sn = sign(iR);
    N  = length(s);
    iR0 = iR;
    s2 = s(end)+diff(s(end-1:end));%sqrt((y(end)-y(end-1))^2+(x(end)-x(end-1))^2);

    B1b = ones(N,1);            %Identity matrix diagonal
    ds  = diff([s;s2]);
    B2b = [0;1./ds(2:N)];       %First derivative matrix diagonal
    B2a = -B2b;                 %First derivative matrix offleft diagonal
    B2c = zeros(N,1);
    B4a = zeros(N,1);
    B4b = zeros(N,1);
    B4c = zeros(N,1);
    for k = 2:N-1;
       B4a(k)= 1./(0.5*(ds(k+1)+ds(k)))*1/ds(k);               %Second derivative matrix off-left diagonal
       B4b(k)=-1./(0.5*(ds(k+1)+ds(k)))*(1/ds(k)+1/ds(k+1));   %Second derivative matrix diagonal
       B4c(k)= 1./(0.5*(ds(k+1)+ds(k)))*1/ds(k+1);             %Second derivative matrix off-right diagonal
    end
    switch(smoothrad)
        case(1)
            difval = 0.0025;                 %                
            for t = 0:difval:0.0125;          %diffusion solver
                iR2 = matprodsol(B4a,B4b,B4c,iR);
                iR = (1-difval)*iR + difval*iR2;
            end
             tend = 0.0125;
             difval = min(0.25*min(ds).^2,tend)                 %                
             for t = difval:difval:tend;          %diffusion solver
                 iR2 = matprodsol(B4a,B4b,B4c,iR);
                 iR = (1-difval)*iR + difval*iR2;
                 difval = min(difval,tend-t);                 %                
             end
        case(2)
            l1  = 2*h;
            %L1   = 2*diag(h./ones(size(s))).*B2+B1;                       
            [iR] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,iR0);          %iR = (inv(L1)*iR0);
        otherwise
    end
    
    %Initial streamline curvature:
    iRs = iR;
    switch(bedtype)
        case(0)
            AR = 0*iR; %=flat bed;
        case(1)
            AR = 3*iR;  %=river bed.
        case(2)
            load sA_m89
            s_m89 = s_m89+3;
            s_m89(1)= s(1);
            s_m89(end)= s(end);
            AR = interp1(s_m89,A_m89,s,'cubic');
        case(3)
            %From input;
    end
    AR0   = AR;
    %Calculate first derivatives (d/ds)
    dsiR  = matprodsol(B2a,B2b,B2c,iR);
    dsiRs = matprodsol(B2a,B2b,B2c,iRs);
    dsAR  = matprodsol(B2a,B2b,B2c,AR);
    psias = ones(length(s),1);
    psitur = ones(length(s),1);
    psitot0 = ones(length(s),1);
    atau  = zeros(length(s),1);
    fsfnd = zeros(length(s),1);
    beta  = zeros(length(s),1);
    fnfnd = zeros(length(s),1);
    
    %% Linear & non-linear solution for curved channel flow.
    asRdiff = 1;
    k = 0;
    Cfg = ((log(h./z0) - (h-z0)./h)/karman).^(-2);  %grain friction;
    Cf3 = routyp*Cfg + (1-routyp)*Cfe;
    Cf2 = Cf3;

    while (asRdiff > asRacc && k < maxK);
        clc;
        disp([num2str(k),': ',num2str(asRdiff)])
        k = k+1;
        for j = 1:length(s);
            af         = min(sqrt(Cf2(j))/karman,0.5);
            bt         = max(Cf3(j)^(-1.1)*h(j)^2*abs(iR(j))*abs(sn(j)*asR(j)+abs(iR(j))),0)^0.25;
            btp        = max(Cf3(j)^(-1.1)*h(j)^2*(iR(j))*abs(asR(j)+iR(j)),0)^0.25;
            btm        = max(Cf3(j)^(-1.1)*h(j)^2*(-iR(j))*abs(-asR(j)-iR(j)),0)^0.25;
            psi(j)     = (1+modtyp*0.52*(bt*Cf3(j).^0.15)*exp(-(2.6*bt*Cf3(j).^0.15)^(-1.5))).^2;  %(W. Ottevanger, 2009)
            atau0(j)   = 2/karman^2*(1-af)*sn(j); 
            fac(j)     = 1-modtyp.*exp(-0.4./(bt.*(bt.^3+0.25)));                                  %(W. Ottevanger, 2009)
            fac2(j)    = 1-modtyp.*exp(-1./(bt.*(bt+0.25)));
            atau(j)    = fac2(j)*atau0(j);
            psias(j)   = 1+modtyp.*(W(j)^2/12*(asR(j)^2+2*iR(j)*asR(j)));                          %(BdV, 2009)
            psitur(j)  = 1+modtyp*karman^2/10/Cf3(j)*(5*abs(iR(j))*q(j)*fac(j))^2;                 %(Blanckaert, 2009)
            psitot0(j) = (psi(j)*psias(j)*psitur(j))^modtyp;
            fsfn0(j)   = (8*(af).*(exp(-3.3*af.^(2/3))));                                          %(W. Ottevanger, 2009)
            fsfnd(j)   = fac(j)*fsfn0(j);
            fnfnd(j)   = fac(j)*(-1.5*log(af)+0.78)^2; 
            beta(j)    = bt;
            betap(j)   = btp;
            betam(j)   = btm;
        end
        
        % Inertial adaptation
        del = (13*sqrt(Cf2)).^(-2).*((13*sqrt(Cf2)).^(-1)-1/12);
        del = del./((13*sqrt(Cf2)).^(-2)/12 - (13*sqrt(Cf2)).^(-1)/40+1/945);
        l1  = h./Cf3./del;
        lambda_sec = l1;
        %l1  = 0.8*h./sqrt(Cf3);
        fnfndR0 = fnfnd.*iR;
        if length(FasRb)>2
           fnfndR0(1) = FasRb(3);
        end
        [fnfndR] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,fnfndR0);          %fnfndR = iL0*fnfndR0;
        fnfnd0 = fnfnd;
        [fnfnd] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,fnfnd0);          %fnfndR = iL0*fnfndR0;
        [psitot] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,psitot0);          %psitot = iL0*psitot0';
        Cf3   = psitot.*Cf2;
        [fnfnd] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,fnfnd.*sign(iR));   %fnfnd  = iL0*(fnfnd.*sign(iR));
        fsfndR = fsfnd.*iR;
        if length(FasRb)>1
           fsfndR(1) = FasRb(2);
        end
        %fsfndR(1) = -1;
        [fsfndR] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,fsfndR);           %fsfndR = iL0*fsfndR;
        [atau] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,atau);               %atau   = iL0*atau;%.*sign(fsfnd);
        %Ainf  = atau./physpar.Gthet;
        if (smoothrad == 0)
           [iR] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,iR0);         %atau  = iL0*atau;%.*sign(fsfnd);
        end
        iRs   = iR;
        [AR] = tdsol(l1.*B2a,l1.*B2b+B1b,l1.*B2c,AR0);         %atau  = iL0*atau;%.*sign(fsfnd);

        dsAR = matprodsol(B2a,B2b,B2c,AR);
        dsiR = matprodsol(B2a,B2b,B2c,iR);
        dsasR = matprodsol(B2a,B2b,B2c,asR);
        dsiRs = matprodsol(B2a,B2b,B2c,iRs);

        %Calculate solution
        F1   = 0.5*(Sn*Fr^2*iR + AR - iR);
        F2   = - 0.5*h./Cf3.*dsiRs.*(1-W.^2.*iR.*iR/6*modtyp);
        F3   = 4*chi*h.^2./(W.^2)./Cf3.*fsfndR.*((W.^2.*(Sn*Fr^2*iR + AR + 3*iR).*iR/12)*modtyp+1);
        F4   = modtyp*W.^2/24.*h./Cf3.*iR.^2.*(Sn*Fr^2*dsiRs+dsAR);
        FasR =  F1 + F2 + F3 + F4;     %(BdV, 2009: eq. (38)
                
        l1  = 0.5*h./Cf3.*((max(sn.*asR+abs(iR),0).*abs(iR)).*W.^2/12*modtyp+1);
        %l1  = 0.5*h./Cf3.*(((asR+iR).*(iR)).*W.^2/12+1).^modtyp;
        
        %Boundary condition;
        FasR(1)  =  FasRb(1);
        FasR(end)=  0;
        B1b2     = B1b;
        B1b2(end)= 0;
        
        asR0 = asR;
        [asRnew] = tdsol(l1.*B2a,l1.*B2b+B1b2,l1.*B2c,FasR);          %fnfndR = iL0*fnfndR0;
        asR = rn*asR+(1-rn)*asRnew;

        if k>2;
        asRdiff = max((asR-asR0).^2);
        end
        %asR     = asR - mean(asR);
        %asRdiff = max([abs(asRave-asRaveold);max(10-k,0)]);%1;%max(abs(asR-asR0));
        if (streamcurv == 1)
            %iRs = (1-difval)*iRs + difval*((asR + iR).*(W^2/8.*(B2*(asR+Sn*Fr^2*iR+AR)')').^2 + W^2/8.*(B4*(asR+Sn*Fr^2*iR+AR)')');
            iRs = iR + ((asR + iR).*(W.^2/8.*((dsasR+Sn*Fr^2*dsiR+dsAR))).^2 + W.^2/8.*(B4*(asR+Sn*Fr^2*iR+AR)));
            dsiRs = matprodsol(B2a,B2b,B2c,iRs);
        end
    end
    
    %Calculate erosion distance...
    d = Eu/2.*W.*asR.*q./h;
    
    % Determine timestep
    dt2 = dt;
    
    disp([dt,dt2,min(diff(s)),max(diff(s))]);
    
    dt = dt-dt2;
    
    % Shift points    [x,y] = spline2shift(x,y,ang,dt2*sn.*d);%,sn.*abs(iR));
    
    
end

%% Downstream boundary condition
t   = s<=L;
q   = q(t);
h   = h(t);
asR = asR(t);
s   = s(t);
iR  = iR(t);
Cf3 = Cf3(t);
%y   = y(t);
%x   = x(t);


%% Output
output.asR = asR;
%output.Ainf  = Ainf;
output.AR  = AR;
output.atau0 = atau0;
output.atau  = atau;
output.b   = iS.*s;
output.beta= beta;
output.betap= betap;
output.betam= betam;
output.Cf3 = Cf3;
output.del = del;
output.dsasR = dsasR;
output.dsiR  = dsiR;
output.F1  = F1;
output.F2  = F2;
output.F3  = F3;
output.F4  = F4;
output.fac = fac;
output.fac2 = fac2;
output.fsfnd = fsfnd;
output.fsfndR = fsfndR;
output.fnfnd = fnfnd;
output.fnfndR = fnfndR;
output.fnfndR0 = fnfndR0;
output.h   = h;
output.iR  = iR;
output.lambda = 0.5*h./Cf3.*((max(-sign(iR).*asR+iR,1e-8).*abs(iR)).*W.^2/12+1).^modtyp;
output.lambda_sec = lambda_sec;
output.psias  = psias;
output.psi  = psi;
output.q   = q;
output.s   = s;
output.sn  = sn;
output.W     = W;
output.psitur  = psitur;
