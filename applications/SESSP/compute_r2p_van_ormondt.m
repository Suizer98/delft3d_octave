function [r2p,setup,sig,sinc]=compute_r2p_van_ormondt(hm0,tp,sl1,sl2,ztide,phi,drspr)
% Computes R2% run-up
% [r2p,setup,sig,sinc]=compute_r2p_van_ormondt(hm0,tp,sl1,sl2,ztide,phi,drspr)
% To be added: real beach profile (x,z)
%
% hm0   = deep water wave height Hm0 (m)
% tp    = deep water peak wave period Tp (s)
% sl1   = Dean slope (-)
% sl2   = beach slope (-)
% ztide = tide level (m)
% phi   = angle of incidence (deg)
% drspr = direction spreading (deg)
%
% e.g. [r2p,setup,sig,sinc]=compute_r2p_van_ormondt(4.0,12.0,0.03,0.05,0.0,20.0,10.0)
%
setup=compute_setup_filter(hm0,tp,sl1,sl2,ztide,phi,drspr);
sig=compute_hm0_lf_filter(hm0,tp,sl1,sl2,ztide,phi,drspr);
sinc=compute_hm0_hf_filter(hm0,tp,sl1,sl2,ztide,phi,drspr);
facsetup=compute_dirspeadfac_setup(hm0,tp,sl1,drspr);
faclf=compute_dirspeadfac_lf(hm0,tp,sl1,drspr);
fachf=compute_dirspeadfac_hf(hm0,tp,sl1,drspr);
setup=setup.*facsetup;
sig=sig.*faclf;
sinc=sinc.*fachf;
[c cg nnn k] = wavevelocity(tp, 500);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
ksi1=surfslope./(sqrt(hm0./l1));
ksi2=sl2./(sqrt(hm0./l1));
r2p=setup+0.7917*sqrt((0.88945*sig).^2+(0.63539*sinc).^2).*ksi2.^0.16431.*ksi1.^-0.07031;


function v=compute_setup_filter(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=6.3106953e-01;
beta(2)=1.0000000e+00;
beta(3)=3.8781958e-01;
beta(4)=6.7674356e-02;
beta(5)=1.0141240e+00;
beta(6)=3.4994996e-01;
beta(7)=1.2470412e-12;
beta(8)=2.4236054e-01;
beta(9)=-4.2535980e-02;
%
[c cg nnn k] = wavevelocity(tp, 500);
l1=2*pi./k;
gambr=0.73;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
if length(ztide)==1
    ztide=zeros(size(hm0))+ztide;
end
%
for itide=1:length(ztide);
    if ztide(itide)==0
    else
        xxx=-1000:1000;
        yyy0=-sl1(itide)*xxx.^(2/3);
        yyy0(xxx<0)=-xxx(xxx<0)*sl2(itide);
        yyy=yyy0-ztide(itide);
        ii1=find(yyy<0,1,'first');
        ii2=find(yyy<-hm0(itide)/gambr,1,'first');
        surfslope(itide)=(yyy(ii1)-yyy(ii2))/(xxx(ii2)-xxx(ii1));
    end
end
ksis=surfslope./(sqrt(hm0./l1));
ksib=sl2./(sqrt(hm0./l1));
steepness=hm0./l1;
%
ksism=beta(5);
ksibm=beta(6);
cs=beta(7);
cb=beta(8);
psisd=ksis.^beta(3);
psibd=ksib.^beta(4);
psism=ksism.^(beta(3)+cs);
psibm=ksibm.^(beta(4)+cb);
psisr=psism./ksis.^cs;
psibr=psibm./ksib.^cb;
psis=psisd;
psis(ksis>ksism)=psisr(ksis>ksism);
psib=psibd;
psib(ksib>ksibm)=psibr(ksib>ksibm);
v=beta(1)*hm0.^beta(2).*psis.*psib.*steepness.^beta(9);
v=v.*sqrt(cos(phi*pi/180));

function v=compute_hm0_lf_filter(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=1.3353204e+00;
beta(2)=4.0810559e-01;
beta(3)=-8.9121433e-01;
beta(4)=4.4086462e-01;
beta(5)=2.3338437e+00;
beta(6)=4.0144150e-02;
beta(7)=-2.8011592e-01;
beta(8)=2.8794554e-01;
%
[c cg nnn k] = wavevelocity(tp, 500);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
steepness=hm0./l1;
surfwidth=(fh.*hm0./surfslope);
relsurfwidth=surfwidth./l1;
if length(ztide)==1
    ztide=zeros(size(hm0))+ztide;
end
%
for itide=1:length(ztide);
    if ztide(itide)==0
    else
        xxx=-1000:1000;
        yyy0=-sl1(itide)*xxx.^(2/3);
        yyy0(xxx<0)=-xxx(xxx<0)*sl2(itide);
        yyy=yyy0-ztide(itide);
        ii1=find(yyy<0,1,'first');
        ii2=find(yyy<-hm0(itide)/gambr,1,'first');
        surfslope(itide)=(yyy(ii1)-yyy(ii2))/(xxx(ii2)-xxx(ii1));
    end
end
tlow=compute_tm01_ig_filter(hm0,tp,sl1,sl2,0,0,0);
higin=hm0.*surfslope.^beta(7).*exp(-(relsurfwidth).^beta(8));
l0=sqrt(9.81*1).*tlow;
ksib=sl2./(sqrt(higin./l0));
ksib=ksib-beta(6);
ksib=max(ksib,0);
ksibm=beta(5)*surfslope.^beta(4); % should increase with surfslope ie beta(5)>0
cb=beta(3)*sqrt(surfslope); % assume linear decrease ie beta(3)<0
psibd=ksib.^beta(2);
psibr=cb.*(ksib-ksibm)+ksibm.^beta(2);
psib=psibd;
psib(ksib>ksibm)=psibr(ksib>ksibm);
v=beta(1)*higin.*psib;
if length(drspr)==1
    drspr=zeros(size(hm0))+drspr;
end

function v=compute_hm0_hf_filter(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=8.7761739e-01;
beta(2)=1.8651668e+00;
beta(3)=3.4064302e-01;
beta(4)=2.0000000e+00;
beta(5)=0.0000000e+00;
beta(6)=7.1344385e-01;
beta(7)=1.0000000e+00;
beta(8)=0.0000000e+00;
%
[c cg nnn k] = wavevelocity(tp, 500);
l1=2*pi./k;
gambr=0.73;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
if length(ztide)==1
    ztide=zeros(size(hm0))+ztide;
end
%
for itide=1:length(ztide);
    if ztide(itide)==0
    else
        xxx=-1000:1000;
        yyy0=-sl1(itide)*xxx.^(2/3);
        yyy0(xxx<0)=-xxx(xxx<0)*sl2(itide);
        yyy=yyy0-ztide(itide);
        ii1=find(yyy<0,1,'first');
        ii2=find(yyy<-hm0(itide)/gambr,1,'first');
        surfslope(itide)=(yyy(ii1)-yyy(ii2))/(xxx(ii2)-xxx(ii1));
    end
end
ksis=surfslope./(sqrt(hm0./l1));
ksib=sl2./(sqrt(hm0./l1));
v=beta(1)*hm0.*ksib.^beta(2).*tanh((ksis+beta(5)).^beta(6)./(beta(3)*ksib.^beta(4)));

function fac=compute_dirspeadfac_setup(hm0,tp,sl1,dirspread)
%
beta(1) = 0.067356;
beta(2) = 0.5;
beta(3) = -0.25744;
beta(4) = 1;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-max(beta(1).*dirspread.^beta(2) + beta(3).*ksis.^beta(4),0));

function fac=compute_dirspeadfac_lf(hm0,tp,sl1,dirspread)
%
beta(1) = 0.090286;
beta(2) = 0.5;
beta(3) = -0.28253;
beta(4) = 1;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-max(beta(1).*dirspread.^beta(2) + beta(3).*ksis.^beta(4),0));

function fac=compute_dirspeadfac_hf(hm0,tp,sl1,dirspread)
%
beta(1) = 0.035285;
beta(2) = 0.5;
beta(3) = -0.36867;
beta(4) = 1;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-max(beta(1).*dirspread.^beta(2) + beta(3).*ksis.^beta(4),0));

function v=compute_tm01_ig_filter(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=4.3231843e+00;
beta(2)=1.2159635e+00;
beta(3)=-4.7189959e-01;
beta(4)=2.1100015e+02;
beta(5)=0.0000000e+00;
%
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
gambr=0.70;
fh=1/gambr;
surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
steepness=hm0./l1;
v=beta(1)+beta(2).*surfslope.^beta(3).*steepness.^beta(4);
v=v.*tp;
