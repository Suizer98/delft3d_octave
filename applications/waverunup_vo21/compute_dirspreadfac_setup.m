function fac=compute_dirspreadfac_setup(hm0,tp,sl1,dirspread)
%
beta(1) = 0.031448;
beta(2) = 0.69432;
beta(3) = 0.66677;
beta(4) = 0.5;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-beta(1).*dirspread.^beta(2) .* (1.0 - tanh(beta(3).*ksis)));
