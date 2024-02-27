function [r2p,setup,sig,sinc,surfslope]=compute_r2p(hm0,tp,sl1,sl2,ztide,phi,drspr,sl1opt)
%
% Compute surf zone slope
%
if length(ztide)==1
    ztide=zeros(size(hm0))+ztide;
end
if length(sl2)==1
    sl2=zeros(size(hm0))+sl2;
end
switch sl1opt
    case{'ad'}
        gambr=1;
        fh=1/gambr;
        surfslope=(fh*hm0)./(fh*hm0./sl1).^1.5;
        for itide=1:length(ztide)
            if ztide(itide)==0
            else
                xxx=-1000:5:5000;
                yyy0=-sl1(itide)*xxx.^(2/3);
                yyy0(xxx<0)=-xxx(xxx<0)*sl2(itide);
                yyy=yyy0-ztide(itide);
                ii1=find(yyy<0,1,'first');
                ii2=find(yyy<-hm0(itide)/gambr,1,'first');
                surfslope(itide,1)=(yyy(ii1)-yyy(ii2))/(xxx(ii2)-xxx(ii1));
            end
        end
    case{'slope'}
        surfslope=sl1;
    case{'xz'}
        gambr=1;
        xxxx=sl1.x(1):1:sl1.x(end);
        zzzz=interp1(sl1.x,sl1.z,xxxx);
        sl1.x=xxxx;
        sl1.z=zzzz;
        for itide=1:length(ztide)
                xxx=sl1.x;
                yyy0=sl1.z;
                yyy=yyy0-ztide(itide);
                ii1=find(yyy<0,1,'first');
                ii2=find(yyy<-hm0(itide)/gambr,1,'first');
                surfslope(itide,1)=(yyy(ii1)-yyy(ii2))/(xxx(ii2)-xxx(ii1));
        end
end

[c cg nnn k] = wavevelocity(tp, 1000);
l1=2*pi./k;
ksi1=surfslope./(sqrt(hm0./l1));
ksi2=sl2./(sqrt(hm0./l1));
%
setup=compute_setup_filter(hm0,tp,surfslope,sl2,ztide,phi,drspr);
sig=compute_hm0_lf_filter(hm0,tp,surfslope,sl2,ztide,phi,drspr);
sinc=compute_hm0_hf_filter(hm0,tp,surfslope,sl2,ztide,phi,drspr);
r2p=setup+0.82396*sqrt((0.82694*sig).^2+(0.73965*sinc).^2).*ksi2.^0.15201.*ksi1.^-0.086635;
