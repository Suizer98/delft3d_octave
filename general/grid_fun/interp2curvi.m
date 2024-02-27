function varargout=interp2curvi(varargin)

if length(varargin)==4
    xgin=varargin{1};
    ygin=varargin{2};
    xgout=varargin{3};
    ygout=varargin{4};
    iopt=1; % Just determine weights and indices, output is weights structure
elseif length(varargin)==5
    xgin=varargin{1};
    ygin=varargin{2};
    zgin=varargin{3};
    xgout=varargin{4};
    ygout=varargin{5};
    iopt=2; % Determine weights and indices, and then do the interpolation
elseif length(varargin)==6
    xgin=varargin{1};
    ygin=varargin{2};
    zgin=varargin{3};
    xgout=varargin{4};
    ygout=varargin{5};
    s=varargin{6};
    iopt=3; % Only do interpolation, weights are given
end

sz1=size(xgout,1);
sz2=size(xgout,2);
np=sz1*sz2;

if iopt==1 || iopt==2
    
    xgout=reshape(xgout,[1 sz1*sz2]);
    ygout=reshape(ygout,[1 sz1*sz2]);
    zgout=zeros(size(xgout));
    zgout(zgout==0)=NaN;
    
    s.w=zeros(np,4);
    s.m=zeros(np,1);
    s.n=zeros(np,1);

    x1=xgin(1:end-1,1:end-1);
    y1=ygin(1:end-1,1:end-1);
    x2=xgin(2:end  ,1:end-1);
    y2=ygin(2:end  ,1:end-1);
    x3=xgin(2:end  ,2:end  );
    y3=ygin(2:end  ,2:end  );
    x4=xgin(1:end-1,2:end  );
    y4=ygin(1:end-1,2:end  );
    xmin=min(min(min(x1,x2),x3),x4);
    xmax=max(max(max(x1,x2),x3),x4);
    ymin=min(min(min(y1,y2),y3),y4);
    ymax=max(max(max(y1,y2),y3),y4);
    xmin(isnan(x1))=NaN;
    xmin(isnan(x2))=NaN;
    xmin(isnan(x3))=NaN;
    xmin(isnan(x4))=NaN;
    ymin(isnan(y1))=NaN;
    ymin(isnan(y2))=NaN;
    ymin(isnan(y3))=NaN;
    ymin(isnan(y4))=NaN;
    
    for j=1:np
        posx=xgout(j);
        posy=ygout(j);
        [mm,nn]=find(xmin<=posx & xmax>=posx & ymin<=posy & ymax>=posy);
        if ~isempty(mm)
            for i=1:length(mm)
                xa=[xgin(mm(i),nn(i)) xgin(mm(i)+1,nn(i)) xgin(mm(i)+1,nn(i)+1) xgin(mm(i),nn(i)+1) ];
                ya=[ygin(mm(i),nn(i)) ygin(mm(i)+1,nn(i)) ygin(mm(i)+1,nn(i)+1) ygin(mm(i),nn(i)+1) ];
                w0=bilin5(xa,ya,posx,posy);
                if min(w0)>=0
                    s.w(j,:)=w0;
                    s.m(j)=mm(i);
                    s.n(j)=nn(i);
                    break
                end
            end
        end
    end
    
end

if iopt==2 || iopt==3    
    % Do interpolation    
    for ip=1:np
        if s.m(ip)>0
            zgout(ip)=s.w(ip,1)*zgin(s.m(ip),s.n(ip))+s.w(ip,2)*zgin(s.m(ip)+1,s.n(ip))+s.w(ip,3)*zgin(s.m(ip)+1,s.n(ip)+1)+s.w(ip,4)*zgin(s.m(ip),s.n(ip)+1);
        else
            zgout(ip)=NaN;
        end
    end    
    zgout=reshape(zgout,[sz1 sz2]);    
    varargout{1}=zgout;
    varargout{2}=s;    
else
    % Just return weights structure
    varargout{1}=s;    
end

%%
function w=bilin5(xa,ya,x0,y0)
w=[0 0 0 0];
x1  = xa(1);
y1  = ya(1);
x2  = xa(2);
y2  = ya(2);
x3  = xa(3);
y3  = ya(3);
x4  = xa(4);
y4  = ya(4);
x   = x0;
y   = y0;
%c The bilinear interpolation problem is first transformed
%c to the quadrangle with nodes
%c (0,0),(1,0),(x3t,y3t),(0,1)
%c and required location (xt,yt)
a21 = x2-x1;
a22 = y2-y1;
a31 = x3-x1;
a32 = y3-y1;
a41 = x4-x1;
a42 = y4-y1;
det = a21*a42-a22*a41;
if abs(det)<1e-12
    return
end
x3t = (a42*a31-a41*a32)/det;
y3t = (-a22*a31+a21*a32)/det;
xt  = (a42*(x-x1)-a41*(y-y1))/det;
yt  = (-a22*(x-x1)+a21*(y-y1))/det;
if x3t<0.0 || y3t<0.0
    return
end
if abs(x3t-1.0)<1.0e-13
    xi = xt;
    if abs(y3t-1.0)<1.0e-13
        eta = yt;
    else
        if abs(1.0+(y3t-1.0)*xt)<1.0e-12
            return
        else
            eta = yt/(1.0+(y3t-1.0)*xt);
        end
    end
else
    if abs(y3t-1.0)<1.0e-12
        eta = yt;
        if abs(1.0+(x3t-1.0)*yt)<1.e-12
            return
        else
            xi = xt/(1.0+(x3t-1.0)*yt);
        end
    else
        a     = y3t-1.0;
        b     = 1.0+(x3t-1.0)*yt-(y3t-1.0)*xt;
        c     = -xt;
        discr = b*b-4.0*a*c;
        if (discr<1.0e-12)
            return
        end
        xi    = (-b+sqrt(discr))/(2.0*a);
        eta   = ((y3t-1.0)*(xi-xt)+(x3t-1.0)*yt)/(x3t-1.0);
    end
end
w(1) = (1.-xi)*(1.-eta);
w(2) = xi*(1.-eta);
w(3) = xi*eta;
w(4) = eta*(1.-xi);
