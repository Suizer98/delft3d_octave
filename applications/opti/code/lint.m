function [zi,intStat]=lint(x,y,z,xi,yi,intStat)

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

%Find centers of cells
xc=(x(1:end-1,1:end-1)+x(2:end,2:end))./2;
yc=(y(1:end-1,1:end-1)+y(2:end,2:end))./2;
% xc=x;
% yc=y;
% zc=z;

m=[];
n=[];
for ii=1:length(xi(:))
    
    %calculate distance of input point to all other points
    dists=sqrt((xc-xi(ii)).^2+(yc-yi(ii)).^2);
    
    [sorted, sortID]=sort(dists(:));
    candidates=sortID(1);
    [tm,tn]=ind2sub(size(dists),candidates);
    %Correct index
    tm=tm+1;
    tn=tn+1;
    
    %Check if the point is in the grid, check if it is in the polygon made
    %by [tm,tn tm+1,tn tm+1,tn+1 tm,tn+1]
    inpoly=[];
    try %Because we can be at the edges
        surCellsX=[x(tm,tn) x(tm+1,tn) x(tm+1,tn+1) x(tm,tn+1)];
        surCellsY=[y(tm,tn) y(tm+1,tn) y(tm+1,tn+1) y(tm,tn+1)];
        surCellsZ=[z(tm,tn) z(tm+1,tn) z(tm+1,tn+1) z(tm,tn+1)];
        inpoly=inpolygon(xi(ii),yi(ii),surCellsX,surCellsY);
    end
    if isempty(inpoly)|inpoly==0
        try%Because we can be at the edges
            surCellsX=[x(tm,tn) x(tm-1,tn) x(tm-1,tn-1) x(tm,tn-1)];
            surCellsY=[y(tm,tn) y(tm-1,tn) y(tm-1,tn-1) y(tm,tn-1)];
            surCellsZ=[z(tm,tn) z(tm-1,tn) z(tm-1,tn-1) z(tm,tn-1)];
            inpoly=inpolygon(xi(ii),yi(ii),surCellsX,surCellsY);
        end
    end
    
    if isempty(inpoly)|inpoly==0
        disp(['*** Point ' num2str(ii) ' : ' num2str(xi(ii)) ',' num2str(yi(ii)) ' outside grid...']);
        zi(ii)=nan;    
    else
        sDists=sqrt((surCellsX-xi(ii)).^2+(surCellsY-yi(ii)).^2);
        [fac,id]=sort(sDists);
        %Use first four
        zz=surCellsZ(id);
        zi(ii)=sum(fac(1:4)./sum(fac(1:4)).*flipud(zz));
        
    end
    
    
end


