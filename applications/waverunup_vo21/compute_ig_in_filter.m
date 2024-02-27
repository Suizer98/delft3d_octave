function v=compute_ig_in(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=2.2740842e+00;
beta(2)=1.0000000e+00;
beta(3)=5.0000000e-01;
beta(4)=2.7211454e+03;
beta(5)=2.0000000e+00;
beta(6)=1.7794945e+01;
beta(7)=1.8728433e-01;
%
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
steepness=hm0./l1;
v=beta(1)*hm0.*surfslope.^beta(3).*exp(-(surfslope/beta(6)).^beta(2)).*exp(-(steepness/beta(4)).^beta(5));
v=hm0.*( beta(1)*surfslope.^beta(3).*exp(-beta(6)*surfslope.^beta(2)) + beta(7)*exp(-beta(4)*steepness.^beta(5)) );
