function [zi,intStat]=lint2(x,y,z,xi,yi,intStat)

% LINT - Bilinear interpolation
% 
% Usage:
% 
% [zi,intStat]=lint(x,y,z,xi,yi,intStat(optional))
% 
% x,y must be matrices, but can be curvelinear grids

if ~exist('intStat','var')
    intStat=[];
end

if numel(size(x))~=2|numel(size(y))~=2|numel(size(z))~=2%|~(size(x)==size(y)==size(z))
    error('Inputs no matrices or not equal in size')
    return
end

findSC=.25; %Find range around transect in dx dy of transect

zi=zeros(size(xi));

%Make array of cell enclosures
xx=reshape(cat(3,x(1:end-1,1:end-1),x(1:end-1,2:end),x(2:end,2:end),x(2:end,1:end-1)),(size(x,1)-1)*(size(x,2)-1),4);
yy=reshape(cat(3,y(1:end-1,1:end-1),y(1:end-1,2:end),y(2:end,2:end),y(2:end,1:end-1)),(size(y,1)-1)*(size(y,2)-1),4);
zz=reshape(cat(3,z(1:end-1,1:end-1),z(1:end-1,2:end),z(2:end,2:end),z(2:end,1:end-1)),(size(z,1)-1)*(size(z,2)-1),4);

%Find cells in the vicinity of the transect
cellID=find(xx(:,1)>min(xi)-findSC*abs(min(xi)-max(xi))&...
    xx(:,1)<max(xi)+findSC*abs(min(xi)-max(xi))&...
    yy(:,1)>min(yi)-findSC*abs(min(yi)-max(yi))&...
    yy(:,1)<max(yi)+findSC*abs(min(yi)-max(yi)));
    


wH=waitbar(0,'Interpolating...');
for ii=1:length(cellID)

    waitbar(ii/length(cellID),wH);
    %Check if any of the points are in the current cell
    id=find(inpolygon(xi,yi,xx(cellID(ii),:),yy(cellID(ii),:)));
    
    if ~isempty(id)
        
        for jj=1:length(id)
            
            %calculate distance of input point to other cell points
            dists=sqrt((xx(cellID(ii),:)-xi(id(jj))).^2+(yy(cellID(ii),:)-yi(id(jj))).^2);
            
            fac=sort(dists);
            %Use first four
            zi(id(jj))=sum(fac(1:4)./sum(fac(1:4)).*fliplr(zz(cellID(ii),:)));
        end
    end
end
close(wH);

