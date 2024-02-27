function fac=compute_dirspreadfac_lf(hm0,tp,sl1,dirspread)
%
beta(1) = 0.047593;
beta(2) = 0.67228;
beta(3) = 0.50777;
beta(4) = 0.5;
beta(5) = 0;
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
ksis=surfslope./(sqrt(hm0./l1));
fac=exp(-beta(1).*dirspread.^beta(2) .* (1.0 - tanh(beta(3).*ksis)));
