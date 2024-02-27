function fac=compute_directionfac_setup(hm0,tp,sl1,phi)
%
beta(1) = 1.4291;
beta(2) = 0.0035124;
beta(3) = 0.31891;
beta(4) = 0.5;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
steepness = hm0./l1;
fac=1-beta(2)*steepness.^beta(3).*abs(phi).^beta(1);
