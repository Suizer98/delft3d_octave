function [out1,out2]=albers(in1,in2,labda0,phi0,phi1,phi2,varargin)

inv=0;

if ~isempty(varargin)
    switch varargin{1}
        case{'inverse'}
            inv=1;
    end
end

if inv
    x=in1;
    y=in2;
else
    lon=in1;
    lat=in2;
end


labda0=labda0*pi/180;
phi0=phi0*pi/180;
phi1=phi1*pi/180;
phi2=phi2*pi/180;

n=0.5*(sin(phi1)+sin(phi2));
c=(cos(phi1))^2+2*n*sin(phi1);
rho0=sqrt(c-2*n*sin(phi0))/n;

if inv
    
    rho=sqrt(x.^2+(rho0-y).^2);
    theta=atan(x./(rho0-y));
    
    out1=labda0+theta/n;
    out2=asin((c-rho.^2*n^2)/(2*n));
    
    out1=out1*180/pi;
    out2=out2*180/pi;

else

    labda=lon*pi/180;
    phi=lat*pi/180;

    rho=sqrt(c-2*n*sin(phi))/n;
    theta=n*(labda-labda0);
    
    out1=rho.*sin(theta);
    out2=rho0-rho.*cos(theta);

end
