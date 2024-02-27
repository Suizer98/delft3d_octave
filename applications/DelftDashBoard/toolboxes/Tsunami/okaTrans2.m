function [x,z]=okaTrans(depth,dip,wdt,sliprake,slip,xx,startend,gridsize)
% Get central transect from Okada 85

xl=round(gridsize/2);
dx=2;
%dx=xl/100;
%xl=round(4*wdt/2);
%xl=round(gridsize);
[E,N] = meshgrid(-xl:dx:xl,-xl:dx:xl);
lngth=wdt;
% Focal depth
%focdpt = 0.5*wdt*sin(dip*pi/180) + depth;
%[uE,uN,uZ] = okada85(E,N,focdpt,0,dip,lngth,wdt,sliprake,slip,0);
[uE,uN,uZ] = okada85(E,N,depth,0,dip,lngth,wdt,sliprake,slip,0);

if strcmpi(startend,'start')
    % ix0 is index of southernmost transect
    ix0=size(E,1)/2-wdt/2/dx;
    % ix is xx/dx north of ix0
    ix=ix0+xx/dx;
    ix=round(ix);
    % ix can be no higher than central transect
    ix=min(ix,ceil(size(E,1)/2));
    % and ix is at least 1
    ix=max(ix,1);    
else
    % ix0 is index of northernmost transect
    ix0=size(E,1)/2+wdt/2/dx;
    % ix is xx/dx north of ix0
    ix=ix0-xx/dx;
    ix=round(ix);
    % ix can be no lower than central transect
    ix=max(ix,ceil(size(E,1)/2));
    % and ix cannot be more than grid size
    ix=min(ix,size(E,1));    
end

try
x=E(ix,:);
z=uZ(ix,:);
catch
    shite=2
end

% figure(5)
% pcolor(E,N,uZ);view(2);axis equal;colorbar

