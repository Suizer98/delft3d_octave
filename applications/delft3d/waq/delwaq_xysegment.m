function gridStruct = delwaq_xysegment(lgaFile)
%DELWAQ_XYSEGMENT Read Delwaq LGA files and gives back the center of the segment.
%
%   GRIDSTRUCT = DELWAQ_XYSEGMENT(LGAFILE)
% 
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if ischar(lgaFile)
    gridStruct = delwaq('open',lgaFile);
elseif isstruct(lgaFile)
    gridStruct = lgaFile;
    clear lgaFile;
end

[Xcen Ycen] = corner2center(gridStruct.X,gridStruct.Y);
s_coll = [];
xcen = [];
ycen = [];
xcr_coll = [];
ycr_coll = [];

%  For all segments
for iseg = 1:gridStruct.NoSegPerLayer
     [im in] = find(gridStruct.Index==iseg);

    if isempty(im)
       disp(['The segment ' num2str(iseg) ' does not have a corresponding x and y'])
       xcn = nan;
       ycn = nan;
       xcr = nan(1,4);
       ycr = nan(1,4);
    else

        if length(im)>1
           x_cen = [];
           y_cen = [];
           x_cor = []; %#ok<*NASGU>
           y_cor = [];

           for ib = 1:length(im)
                x_cen = [x_cen Xcen(im(ib)-1,in(ib)-1)];
                y_cen = [y_cen Ycen(im(ib)-1,in(ib)-1)];
           end

        else
          x_cen = Xcen(im-1,in-1);
          y_cen = Ycen(im-1,in-1);
        end

        mmin = min(im) ;
        nmin = min(in) ;
        mmax = max(im) ;
        nmax = max(in) ;
        x_cor = gridStruct.X(mmin-1:mmax,nmin-1:nmax);
        y_cor = gridStruct.Y(mmin-1:mmax,nmin-1:nmax);


        xcn = (nanmin(x_cen) + nanmax(x_cen))/2;
        ycn = (nanmin(y_cen) + nanmax(y_cen))/2;
        xcr = [x_cor(1,1) x_cor(end,1) x_cor(1,end) x_cor(end,end)];
        ycr = [y_cor(1,1) y_cor(end,1) y_cor(1,end) y_cor(end,end)];

        if any(isnan(xcr)) || any(isnan(ycr)) 
         xcr = dummycorner2(x_cor);
         ycr = dummycorner2(y_cor);
        end
    end

    s_coll = [s_coll(:); 1];
    xcen = [xcen(:); xcn(1)];
    ycen = [ycen(:); ycn(1)];
    xcr_coll = [xcr_coll; xcr]; %#ok<*AGROW>
    ycr_coll = [ycr_coll; ycr];
end
 
gridStruct.cen.x = xcen(:);
gridStruct.cen.y = ycen(:);
gridStruct.cen.Index = [];
gridStruct.cor.x = [];
gridStruct.cor.y = [];
gridStruct.cor.Index = [];

for iseg= 1:length(s_coll)
    gridStruct.cor.x(iseg,:)= [xcr_coll(iseg,1),xcr_coll(iseg,2),xcr_coll(iseg,3),xcr_coll(iseg,4)];
    gridStruct.cor.y(iseg,:)= [ycr_coll(iseg,1),ycr_coll(iseg,2),ycr_coll(iseg,3),ycr_coll(iseg,4)];
    gridStruct.cor.Index(iseg,1) = iseg;
    gridStruct.cen.Index(iseg,1) = iseg;
end

% -------------------------------------------------------------------------
% Finding dummy corner
% -------------------------------------------------------------------------
function dx = dummycorner2(x)

[nr nc] = size(x);

row = [1 1 nr nr];
col = [1 nc 1 nc];
dx = nan(2,2);

for i = 1:length(row)
   xdummy = nan(size(x));
   xdummy(row(i),:) = x(row(i),:);
   xdummy(:,col(i)) = x(:,col(i));
   dx(row(i),col(i)) = findNearestPoint(xdummy,row(i),col(i));
end

dx = [dx(1,1) dx(end,1) dx(1,end) dx(end,end)];


% -------------------------------------------------------------------------
% Finding the nearest delta
% -------------------------------------------------------------------------
function neardx  = findNearestPoint(dx,irow,icol)

[rval cval] =  find(~isnan(dx));
if ~isnan(rval)
    dis = sqrt((rval-irow).^2 + (cval-icol).^2);
    i = find(dis==min(dis),1,'first');
    neardx = dx(rval(i),cval(i));
else
   neardx = nan;
end


