function [m,n]=EHY_xy2mn(x,y,grdFile)
% [m,n]=EHY_xy2mn(x,y,grdFile)
%
% Find the m,n-location(s) of your x,y-location(s) in a structured
% Delft3D/SIMONA grid.
%
% Example1: [m,n]=EHY_xy2mn(70000,445000,'D:\Nederland.grd')
% Example2: [m,n]=EHY_xy2mn([70000 80000],[445000 455000],'D:\Nederland.grd')
%
% created by Julien Groenenboom, May 2017

tempGrdFile=[tempdir 'tmp.grd'];
copyfile(grdFile,tempGrdFile);
grd=wlgrid('read',tempGrdFile);
delete(tempGrdFile);

grd.Xcen=corner2centernan(grd.X);
grd.Ycen=corner2centernan(grd.Y);

% check if grid is rectangular
xx=round(diff(grd.Xcen)*10^10)/10^10;
xx=unique(xx(~isnan(xx)));
yy=round(diff(grd.Ycen')*10^10)/10^10;
yy=unique(yy(~isnan(yy)));

if length(x)~=length(y)
    error('x and y should have the same length');
elseif length(xx)==1 && length(yy)==1
    xvector=mode(grd.Xcen');
    yvector=mode(grd.Ycen);
    for ixy=1:length(x)
        [~,mm]=min(abs(xvector-x(ixy)));
        [~,nn]=min(abs(yvector-y(ixy)));
        m(ixy,1)=mm+1;
        n(ixy,1)=nn+1;
    end
else
    for ixy=1:length(x)
        dist=sqrt( (grd.Xcen-x(ixy)).^2 + (grd.Ycen-y(ixy)).^2 );
        [mm,nn]=find(dist==min(min(dist)));
        m(ixy,1)=mm(1)+1;
        n(ixy,1)=nn(1)+1;
    end
end

end
