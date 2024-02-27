function v=compute_setup(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=4.0455506e+00;
beta(2)=2.3740615e-02;
beta(3)=2.0340287e+00;
beta(4)=4.6497588e-01;
beta(5)=7.0244541e-01;
beta(6)=5.0000000e-01;
beta(7)=-3.1727583e-01;
%
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
ksib=sl2./(sqrt(hm0./l1));
steepness=hm0./l1;
v=beta(1).*hm0.*(beta(2)+exp(-beta(3).*ksis.^beta(7).*ksib.^beta(4)).*ksib.^beta(5));
fac1=compute_dirspreadfac_setup(hm0,tp,sl1,drspr);
fac2=compute_directionfac_setup(hm0,tp,sl1,phi);
v=v.*fac1.*fac2;
