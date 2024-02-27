function fac=compute_dirspreadfac_hf(hm0,tp,sl1,dirspread)
%
beta(1) = 0.044544;
beta(2) = 1;
beta(3) = 21.1281;
beta(4) = 0.5;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-beta(1).*dirspread.^beta(2) .* (1.0 - tanh(beta(3).*ksis)));
