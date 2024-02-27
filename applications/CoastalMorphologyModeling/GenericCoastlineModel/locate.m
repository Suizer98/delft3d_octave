function [sp,np]=locate(s,x,y,xp,yp)
ipp=0
ns=length(s)
for ip=1:length(xp)
    for i=1:ns-2
        cosa=(x(i+2)-x(i))/(s(i+2)-s(i));
        sina=(y(i+2)-y(i))/(s(i+2)-s(i));
        sproj=s(i)+(xp(ip)-x(i))*cosa+(yp(ip)-y(i))*sina;
        if sproj<s(1)
            ipp=ipp+1;
            sp(ipp)=sproj;
            np(ipp)=-(xp(ip)-x(1))*sina+(yp(ip)-y(1))*cosa;
            break
        elseif sproj>=s(i)&sproj<=s(i+2)
            ipp=ipp+1;
            sp(ipp)=sproj;
            np(ipp)=-(xp(ip)-x(i))*sina+(yp(ip)-y(i))*cosa;
            break
        elseif sproj>s(ns)
            ipp=ipp+1;
            sp(ipp)=sproj;
            np(ipp)=-(xp(ip)-x(ns))*sina+(yp(ip)-y(ns))*cosa;
            break
        end
    end
end