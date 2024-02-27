function v=compute_hm0_hf(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=9.5635099e-01;
beta(2)=2.0143005e+00;
beta(3)=5.3602429e-01;
beta(4)=2.0000000e+00;
beta(5)=0.0000000e+00;
beta(6)=6.1856544e-01;
beta(7)=1.0000000e+00;
beta(8)=0.0000000e+00;
%
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
ksib=sl2./(sqrt(hm0./l1));
v=beta(1)*hm0.*ksib.^beta(2).*tanh((ksis+beta(5)).^beta(6)./(beta(3)*ksib.^beta(4)));
%fac1=compute_dirspreadfac_hf(hm0,tp,sl1,drspr);
%fac2=compute_dirfac_hf(hm0,tp,sl1,phi);
%fac2=1.0;
%v=v.*fac1.*fac2;
