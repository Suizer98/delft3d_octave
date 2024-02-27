function [xg,yg,zg]=ddb_computeTsunamiWave2(xs,ys,depths,dips,wdts,sliprakes,slips,varargin)

xg=[];
yg=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'xg'}
                xg=varargin{ii+1};
            case{'yg'}
                yg=varargin{ii+1};
        end
    end
end

% Generates 20 initial tsunami wave transects along fault line and
% interpolates onto rectangular grid.

try

nrTransects=20;    
    
degrad=pi/180;

% Define transects and interpolate earthquake parameters with spline
% function.

pd=pathdistance(xs,ys);
dx=pd(end)/nrTransects;

xp=pd(1):dx:pd(end);
xc = spline(pd,xs,xp);
yc = spline(pd,ys,xp); 
depth=spline(pd,depths,xp);
dip=spline(pd,dips,xp);
wdt=spline(pd,wdts,xp);
sliprake=spline(pd,sliprakes,xp);
slip=spline(pd,slips,xp);

strike(1)=atan2(yc(2)-yc(1),xc(2)-xc(1));

for i=2:length(xc)
    strike(i)=atan2(yc(i)-yc(i-1),xc(i)-xc(i-1));
end
strike=strike/degrad;
strike=90-strike;

n0=round(1000*wdt(1)/dx); % Number of transects before start of fault line
n1=length(xc); % Number of transects within fault line
n2=round(1000*wdt(end)/dx); % Number of transects after end of fault line

% Find grid size for okatrans. Grid size must be identical for each
% transect.
gridsize=0;
for i=1:length(wdt)
    gridsize=max(gridsize,wdt(i)*3);
end

for i=1:n0+n1+n2
    
    % Run through transect
    
%    disp([num2str(i) ' of ' num2str(n0+n1+n2)]);
    
    % Distance from start of fault line (in km)
    distStart=0.001*(i-n0-1)*dx;
        
    % Distance from end of fault line (in km)
    distEnd=-0.001*(i-n0-n1)*dx;

    % If distStart or distEnd are negative, the transect is beyond start or end of fault line

    ddx=0;
    ddy=0;

    if i<=0.5*(n0+n1+n2)
        % Get data south of epicentre
        ii=max(1,i-n0);        
        [x,z]=okaTrans2(depth(ii),dip(ii),wdt(ii),sliprake(ii),slip(ii),distStart,'start',gridsize);
        if distStart<0
            % Point before start of fault line
            phirot=(90-strike(1))*degrad;
            ddx=distStart*cos(phirot)*1000; % m
            ddy=distStart*sin(phirot)*1000; % m
        end
    else
        % Get data north of epicentre
        ii=min(n1,i-n0);
        [x,z]=okaTrans2(depth(ii),dip(ii),wdt(ii),sliprake(ii),slip(ii),distEnd,'end',gridsize);
        if distEnd<0
            % Point after end of fault line
            phirot=(90-strike(end))*degrad;
            ddx=-distEnd*cos(phirot)*1000; % m
            ddy=-distEnd*sin(phirot)*1000; % m
        end
    end        

    % Convert to m
    x=x*1000;
    
    % Horizontal shift w.r.t. fault line
    xshift = 1000*depth(ii)/tan(dip(ii)*degrad);    
    x=x+xshift;
        
    % Rotate
    y=x*sin(-(strike(ii))*degrad);
    x=x*cos(-(strike(ii))*degrad);

    % Translate
    x=x+xc(ii)+ddx;
    y=y+yc(ii)+ddy;

    % And put in matrix
    xx(i,:)=x;
    yy(i,:)=y;
    zz(i,:)=z;

end

if isempty(xg)

   % Generate rectangular grid

   xg(1)=min(min(xx));
   xg(2)=max(max(xx));
   yg(1)=min(min(yy));
   yg(2)=max(max(yy));
   dborder=0.1*(xg(2)-xg(1));
   xg(1)=xg(1)-dborder;
   xg(2)=xg(2)+dborder;
   yg(1)=yg(1)-dborder;
   yg(2)=yg(2)+dborder;

   dxg=2000;
   dyg=2000;

   [xg,yg]=meshgrid(xg(1):dxg:xg(2),yg(1):dyg:yg(2));
else
   [xg,yg]=meshgrid(xg,yg);
end

% And interpolate data
zg=griddata(xx,yy,zz,xg,yg);


catch
    shite=3
end