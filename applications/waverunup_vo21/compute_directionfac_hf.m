function fac=compute_directionfac_hf(hm0,tp,sl1,phi)
%
beta(1) = 4.1355e-10;
beta(2) = 4.3559e-10;
beta(3) = 0;
beta(4) = 0.5;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
fac=(cos(phi*pi/180)).^beta(1);
