function [x2,y2]=Mercator1SP(x1,y1,a,finv,lato,lono,fe,fn,ko,iopt)

% latitude of natural origin not used in these formulations !!!

f  = 1/finv;
e2 = 2*f-f^2;
e  = e2^.5;

x2 = nan(size(x1));
y2 = nan(size(y1));


if iopt==1

    %           geo2xy
    
    lon   = x1;
    lat   = y1;
    
    x2 = fe + a*ko*(lon - lono);
    y2 = fn + a*ko*log(tan(pi/4 + lat/2)*((1.0 - e*sin(lat)) / (1.0 + e*sin(lat))).^(0.5*e));    
    
else

    %           xy2geo

    e2=e^2;
    e4=e^4;
    e6=e^6;
    e8=e^8;
    
    n1=numel(x1);
    
    for ii=1:n1

        east  = x1(ii);
        north = y1(ii);

        B=exp(1.0);
        t=B^((fn-north)/(a*ko));
        chi = pi/2.0 - 2*(atan(t));

        y2(ii) = chi + (e2/2.0 + 5.0*e4/24.0 + e6/12.0 + 13.0*e8/360.0)*sin(2.0*chi) + ...
            (7.0*e4/48.0 + 29.0*e6/240.0 + 811.0*e8/11520.0)*sin(4.0*chi) + ...
            (7.0*e6/120.0 + 81.0*e8/1120.0)*sin(6.0*chi) + (4279.0*e8/161280.0)*sin(8*chi);
        
        x2(ii) = ((east - fe)/(a*ko)) + lono;
        
    end
end
