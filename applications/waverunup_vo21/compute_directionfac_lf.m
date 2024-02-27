function fac=compute_directionfac_lf(hm0,tp,sl1,phi)
%
beta(1) = 0.40488;
beta(2) = 2.7073;
beta(3) = 0;
beta(4) = 0.5;
beta(5) = 0;
fac=(cos(phi*pi/180)).^(beta(1)+beta(2).*sl1);
