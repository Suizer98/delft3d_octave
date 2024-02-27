function v=compute_tm01_ig(hm0,tp,sl1,sl2,ztide,phi,drspr)
%
beta(1)=4.4021341e-07;
beta(2)=1.8635421e+00;
beta(3)=-4.2705433e-01;
beta(4)=7.2541023e-02;
beta(5)=2.0058478e+01;
%
[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
surfslope=sl1;
steepness=hm0./l1;
v=beta(1)+beta(2).*surfslope.^beta(3).*steepness.^beta(4)+beta(5)*surfslope;
v=v.*tp;
