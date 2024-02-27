function [areas,volumes]=kubint(x,y,z,varargin)

eps=1e-6;

datain='corners';
iplot=0;
outputfile=[];
times=[];
polygonfile=[];
polygonstruct=[];
outputtimeindex=0;
outputfolder='.';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'polygonstruct'}
                polygonstruct=varargin{ii+1};
            case{'polygonfile'}
                polygonfile=varargin{ii+1};
            case{'datain'}
                datain=varargin{ii+1};
            case{'plot'}
                iplot=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
            case{'outputfolder'}
                outputfolder=varargin{ii+1};
            case{'times'}
                times=varargin{ii+1};
            case{'outputtimeindex'}
                outputtimeindex=varargin{ii+1};
        end
    end
end

% Read polygons
if ~isempty(polygonfile)
    tekpol=tekal('read',polygonfile,'loaddata');
    for ipol=1:length(tekpol.Field)
        pol(ipol).x=tekpol.Field(ipol).Data(:,1);
        pol(ipol).y=tekpol.Field(ipol).Data(:,2);
        pol(ipol).name=tekpol.Field(ipol).Name;
    end
else
    if isempty(polygonstruct)
        error('Please provide polygon structure of polygon file name!');
    else
        pol=polygonstruct;
    end
end

if ndims(z)==3
    % Assume first index is time
    ntimes=size(z,1);
else
    ntimes=1;
end

volumes=zeros(ntimes,length(pol));
areas=zeros(1,length(pol));

if strcmpi(datain,'centres')
    % Using Matlab plot administration (i.e. outer depth values set to NaN)
    [xz0,yz0] = getXZYZ(xg,yg);
    x=zeros(size(xg));
    x(x==0)=NaN;
    y=x;
    x(1:end-1,1:end-1)=xz0(2:end,2:end);
    y(1:end-1,1:end-1)=yz0(2:end,2:end);
end

for ipol=1:length(pol)
    
    % Find cells that are within the bounding box of this polygon
    
    polx=pol(ipol).x;
    poly=pol(ipol).y;
    
    if size(polx,1)>1
        polx=polx';
        poly=poly';
    end
    
    if abs(polx(end)-polx(1))>eps && abs(poly(end)-poly(1))>eps
        % Close polygon
        polx=[polx polx(1)];
        poly=[poly poly(1)];
    end
    
    if iplot
        pp=plot(polx,poly,'k');hold on;
        set(pp,'LineWidth',2);
    end
    
    xmin=min(polx);
    ymin=min(poly);
    xmax=max(polx);
    ymax=max(poly);
    
    [iind,jind]=find(x>=xmin & x<=xmax & y>=ymin & y<=ymax);
    
    imin=min(iind);
    imax=max(iind);
    jmin=min(jind);
    jmax=max(jind);
    
    imin=max(imin-1,1);
    imax=min(imax+1,size(x,1));
    jmin=max(jmin-1,1);
    jmax=min(jmax+1,size(x,2));
    
    xin=x(imin:imax,jmin:jmax);
    yin=y(imin:imax,jmin:jmax);
    
    nn=(size(xin,1)-1)*(size(xin,2)-1);
    
    cellareas=cellarea(xin,yin);
    cellareas=reshape(cellareas,[1 nn]);
    cellareas(isnan(cellareas))=0;
    
    xgv=zeros(4,nn);
    ygv=zeros(4,nn);
    
    xgv(1,:)=reshape(xin(1:end-1,1:end-1),[1 nn]);
    xgv(2,:)=reshape(xin(2:end  ,1:end-1),[1 nn]);
    xgv(3,:)=reshape(xin(2:end  ,2:end  ),[1 nn]);
    xgv(4,:)=reshape(xin(1:end-1,2:end  ),[1 nn]);
    
    ygv(1,:)=reshape(yin(1:end-1,1:end-1),[1 nn]);
    ygv(2,:)=reshape(yin(2:end  ,1:end-1),[1 nn]);
    ygv(3,:)=reshape(yin(2:end  ,2:end  ),[1 nn]);
    ygv(4,:)=reshape(yin(1:end-1,2:end  ),[1 nn]);
        
    suminp=sum(inpolygon(xgv,ygv,polx,poly),1);

    for it=1:ntimes
        
        if ndims(z)==3
            zin=squeeze(z(it,imin:imax,jmin:jmax));
        else
            zin=z(imin:imax,jmin:jmax);
        end
        
        zgv=reshape(zin(1:end-1,1:end-1),[1 nn]);
        zgv(isnan(zgv))=0;
        
        % First do all cells that are completely within polygon
        allinp=suminp==4;
        volumes(it,ipol)=sum(allinp.*cellareas.*zgv);
        areas(ipol)=sum(allinp.*cellareas);
        
        if iplot
            xpv=[xgv;xgv(1,:)];
            ypv=[ygv;ygv(1,:)];
            for ii=1:5
                xpv(ii,~allinp)=NaN;
                ypv(ii,~allinp)=NaN;
            end
            plot(xpv,ypv,'b');
        end
        
        % Now the cells that are partially in the polygon
        someinp=(suminp>0 & suminp<4);
        
        %     iind=find(someinp==1);
        %     for ii=1:length(iind)
        %         ind=iind(ii);
        %         xcl=xgv(:,ind)';
        %         xcl=[xcl xcl(1)];
        %         ycl=ygv(:,ind)';
        %         ycl=[ycl ycl(1)];
        %
        %         poloverlap=overlappingpolygon(xcl,ycl,polx,poly);
        %         ar=0;
        %         for ip=1:length(poloverlap)
        %             if iplot
        %                 pp2=plot(poloverlap(ip).x,poloverlap(ip).y,'r');
        %                 set(pp2,'LineWidth',2);
        %             end
        %             % Area of polygon
        %             ar=ar+polyarea(poloverlap(ip).x,poloverlap(ip).y);
        %         end
        %         volumes(it,ipol)=volumes(it,ipol) + ar*zgv(ind);
        %         areas(it,ipol)=areas(it,ipol)+ar;
        %     end
    end
    next=1;
end

if ~isempty(outputfile)
    fid=fopen([outputfolder filesep outputfile '.kub'],'wt');
    fprintf(fid,'%s\n','* column 1 : Area number');
    fprintf(fid,'%s\n','* column 2 : Area (m2)');
    fprintf(fid,'%s\n','* column 3 : Volume (m3)');
    fprintf(fid,'%s\n','* column 4 : Average (m)');
    fprintf(fid,'%s\n','* column 5 : Area name');
    if outputtimeindex==0
        itimes=1:ntimes;
    else
        itimes=outputtimeindex;
    end
    for ii=1:length(itimes)
        it=itimes(ii);
%        if isempty(times)
%            fprintf(fid,'%s\n',['kubint' num2str(it,'%0.4i')]);
            fprintf(fid,'%s\n',['kubint' num2str(ii,'%0.4i')]);
%         else
%             fprintf(fid,'%s\n',datestr(times(it),'yyyymmdd HHMMSS'));
%         end
        fprintf(fid,'%5i %5i\n',size(volumes,2),5);
        for ipol=1:size(volumes,2)
            str=['"' pol(ipol).name '"'];
            fprintf(fid,'%4i %14.6e %14.6e %14.6e %s\n',ipol,areas(ipol),volumes(it,ipol),volumes(it,ipol)/areas(ipol),str);
        end
    end
    fclose(fid);
end

if ~isempty(times)
    % Create tekal time series file
    fid=fopen([outputfolder filesep outputfile '_timeseries.tek'],'wt');
    fprintf(fid,'%s\n','* column 1 : Date');
    fprintf(fid,'%s\n','* column 2 : Time');
    for ipol=1:length(pol)
        fprintf(fid,'%s\n',['* column ' num2str(ipol+2) ' : Volume (m3) - ' pol(ipol).name]);
    end
    for ipol=1:length(pol)
        fprintf(fid,'%s\n',['* column ' num2str(ipol+length(pol)+2) ' : Average (m) - ' pol(ipol).name]);
    end
    fprintf(fid,'%s\n','kubint');
    fprintf(fid,'%5i %5i\n',size(volumes,1),2*length(pol)+2);
    for it=1:ntimes
        str1=datestr(times(it),'yyyymmdd HHMMSS');
        str2=num2str(volumes(it,:),'%14.6e');
        str3=num2str(volumes(it,:)./areas,'%14.6e');
        str=[str1 '  ' str2 '  ' str3];
        fprintf(fid,'%s\n',str);
    end    
    fclose(fid);
end

%%
function pol=overlappingpolygon(x1,y1,x2,y2)

pol=[];

eps=abs(sqrt((x1(2)-x1(1))^2+(y1(2)-y1(1))^2))/1000000;
%eps=1e-3;

% Find intersecting points
[xi00,yi00,iout00,jout00]=intersections(x1,y1,x2,y2);

if length(xi00)<2
    if inpolygon(x1,y1,x2,y2)
        xp=x1;
        yp=y1;
    end
    if inpolygon(x2,y2,x1,y1)
        xp=x2;
        yp=y2;
    end
    return
end

iout00(iout00>length(x1)-eps)=1.0;
jout00(jout00>length(x2)-eps)=1.0;

% Check for double points
n=1;

xi0(1)=xi00(1);
yi0(1)=yi00(1);
iout0(1)=iout00(1);
jout0(1)=jout00(1);

for ii=2:length(xi00)
    if abs(xi00(ii)-xi00(ii-1))>eps || abs(yi00(ii)-yi00(ii-1))>eps
        n=n+1;
        xi0(n)=xi00(ii);
        yi0(n)=yi00(ii);
        iout0(n)=iout00(ii);
        jout0(n)=jout00(ii);        
    end
end

if length(xi0)<2
    return
end

if length(xi0)==2
    if abs(xi0(2)-xi0(1))<eps && abs(yi0(2)-yi0(1))<eps
        return
    end
end

% % Make polygons open again
% if abs(x1(end)-x1(1))<eps && abs(y1(end)-y1(1))<eps
%     x1=x1(1:end-1);
%     y1=y1(1:end-1);
% end
% 
% if abs(x2(end)-x2(1))<eps && abs(y2(end)-y2(1))<eps
%     x2=x2(1:end-1);
%     y2=y2(1:end-1);
% end

% First create two new polygons that include the intersecting points
[xp1,yp1,iint1]=includeintersectingpoints(x1,y1,xi0,yi0,iout0,eps);
[xp2,yp2,iint2]=includeintersectingpoints(x2,y2,xi0,yi0,jout0,eps);


% plot(xi0,yi0,'o')

iint1used=zeros(size(iint1));
iint2used=zeros(size(iint2));

% Start with first polygon
ifirst=find(iint1==1 & iint1used==0,1,'first');

pol(1).x=xp1(ifirst);
pol(1).y=yp1(ifirst);

ipol=1;

while sum(iint1used)<sum(iint1)
    
    % Not all points have been used
    
    % Get next section from polygon 1

    [xpa,ypa,iint1used]=getnextsection(xp1,yp1,iint1,iint1used,xp2,yp2,ifirst);
    
    pol(ipol).x=[pol(ipol).x xpa(2:end)];
    pol(ipol).y=[pol(ipol).y ypa(2:end)];
    
    ifirst=find(abs(xp2-xpa(end))<eps & abs(yp2-ypa(end))<eps);
    ifirst=ifirst(1);

    pppp=plot(xpa,ypa,'r');
    set(pppp,'LineWidth',2);
    % Get next section from polygon 2
    
    [xpb,ypb,iint2used]=getnextsection(xp2,yp2,iint2,iint2used,xp1,yp1,ifirst);

    pol(ipol).x=[pol(ipol).x xpb(2:end)];
    pol(ipol).y=[pol(ipol).y ypb(2:end)];
    
    ifirst=find(abs(xp1-xpb(end))<eps & abs(yp1-ypb(end))<eps);
    ifirst=ifirst(1);
    
    if iint1used(ifirst)
        
        % Point was already used, start next polygon
        ipol=ipol+1;
        
        ifirst=find(iint1==1 & iint1used==0,1,'first');
        
        if isempty(ifirst)
            % all intersection points have been used
            break
        end
        
        ifirst=ifirst(1);

        pol(ipol).x=xp1(ifirst);
        pol(ipol).y=yp1(ifirst);

    end
            
end

%%
function [xp,yp,iintused]=getnextsection(xp1,yp1,iint,iintused,xp2,yp2,ifirst)

% Find next point on this polygon

% eps=1e-3;

inext=ifirst+1;
if inext>length(xp1)
    inext=1;
end
dx=xp1(inext)-xp1(ifirst);
dy=yp1(inext)-yp1(ifirst);
xtst=xp1(ifirst)+1e-3*dx;
ytst=yp1(ifirst)+1e-3*dy;

if inpolygon(xtst,ytst,xp2,yp2)
    % Going the right direction
    idir=1;
else
    idir=-1;
end

iintused(ifirst)=1;

n=ifirst;

xp(1)=xp1(ifirst);
yp(1)=yp1(ifirst);
ip=1;

% Walk around polygon to find next intersection point

while 1

    ip=ip+1; % counter
      
    n=n+idir;
    if n>length(xp1)
        n=1;
    end
    if n<1
        n=length(xp1);
    end
    
    xp(ip)=xp1(n);
    yp(ip)=yp1(n);

    if iint(n)==1
        iintused(n)=1;
        break
    end
    
%     if iint(n)==1
%         iintused(n)=1;
%     end
%     
%     if iint(n)==1 && iint2(n)==0
%         break
%     end
%     
    
end

%%
function [xp,yp,iint]=includeintersectingpoints(xp,yp,xi,yi,iout,eps)

% Polygon 1
[iout,ind] = sort(iout,2,'ascend');
xi=xi(ind);
yi=yi(ind);
n=0;

iint=zeros(1,length(xp));

for ii=1:length(xi)
     if abs(iout(ii)-round(iout(ii)))>eps
        % Not the same point
        n=n+1;
        isec=floor(iout(ii))+n-1;
        xp=[xp(1:isec) xi(ii) xp(isec+1:end)];
        yp=[yp(1:isec) yi(ii) yp(isec+1:end)];
        iint=[iint(1:isec) 1 zeros(1,length(iint)-isec)];
     else
         % Same point, don't add to polygon but do set intersection
        iint(round(iout(ii))+n)=1;
     end    
end

%%
function [x0,y0,iout,jout] = intersections(x1,y1,x2,y2,robust)
%INTERSECTIONS Intersections of curves.
%   Computes the (x,y) locations where two curves intersect.  The curves
%   can be broken with NaNs or have vertical segments.
%
% Example:
%   [X0,Y0] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% where X1 and Y1 are equal-length vectors of at least two points and
% represent curve 1.  Similarly, X2 and Y2 represent curve 2.
% X0 and Y0 are column vectors containing the points at which the two
% curves intersect.
%
% ROBUST (optional) set to 1 or true means to use a slight variation of the
% algorithm that might return duplicates of some intersection points, and
% then remove those duplicates.  The default is true, but since the
% algorithm is slightly slower you can set it to false if you know that
% your curves don't intersect at any segment boundaries.  Also, the robust
% version properly handles parallel and overlapping segments.
%
% The algorithm can return two additional vectors that indicate which
% segment pairs contain intersections and where they are:
%
%   [X0,Y0,I,J] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% For each element of the vector I, I(k) = (segment number of (X1,Y1)) +
% (how far along this segment the intersection is).  For example, if I(k) =
% 45.25 then the intersection lies a quarter of the way between the line
% segment connecting (X1(45),Y1(45)) and (X1(46),Y1(46)).  Similarly for
% the vector J and the segments in (X2,Y2).
%
% You can also get intersections of a curve with itself.  Simply pass in
% only one curve, i.e.,
%
%   [X0,Y0] = intersections(X1,Y1,ROBUST);
%
% where, as before, ROBUST is optional.

% Version: 1.12, 27 January 2010
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Theory of operation:
%
% Given two line segments, L1 and L2,
%
%   L1 endpoints:  (x1(1),y1(1)) and (x1(2),y1(2))
%   L2 endpoints:  (x2(1),y2(1)) and (x2(2),y2(2))
%
% we can write four equations with four unknowns and then solve them.  The
% four unknowns are t1, t2, x0 and y0, where (x0,y0) is the intersection of
% L1 and L2, t1 is the distance from the starting point of L1 to the
% intersection relative to the length of L1 and t2 is the distance from the
% starting point of L2 to the intersection relative to the length of L2.
%
% So, the four equations are
%
%    (x1(2) - x1(1))*t1 = x0 - x1(1)
%    (x2(2) - x2(1))*t2 = x0 - x2(1)
%    (y1(2) - y1(1))*t1 = y0 - y1(1)
%    (y2(2) - y2(1))*t2 = y0 - y2(1)
%
% Rearranging and writing in matrix form,
%
%  [x1(2)-x1(1)       0       -1   0;      [t1;      [-x1(1);
%        0       x2(2)-x2(1)  -1   0;   *   t2;   =   -x2(1);
%   y1(2)-y1(1)       0        0  -1;       x0;       -y1(1);
%        0       y2(2)-y2(1)   0  -1]       y0]       -y2(1)]
%
% Let's call that A*T = B.  We can solve for T with T = A\B.
%
% Once we have our solution we just have to look at t1 and t2 to determine
% whether L1 and L2 intersect.  If 0 <= t1 < 1 and 0 <= t2 < 1 then the two
% line segments cross and we can include (x0,y0) in the output.
%
% In principle, we have to perform this computation on every pair of line
% segments in the input data.  This can be quite a large number of pairs so
% we will reduce it by doing a simple preliminary check to eliminate line
% segment pairs that could not possibly cross.  The check is to look at the
% smallest enclosing rectangles (with sides parallel to the axes) for each
% line segment pair and see if they overlap.  If they do then we have to
% compute t1 and t2 (via the A\B computation) to see if the line segments
% cross, but if they don't then the line segments cannot cross.  In a
% typical application, this technique will eliminate most of the potential
% line segment pairs.


% Input checks.
error(nargchk(2,5,nargin))

% Adjustments when fewer than five arguments are supplied.
switch nargin
	case 2
		robust = true;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 3
		robust = x2;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 4
		robust = true;
		self_intersect = false;
	case 5
		self_intersect = false;
end

% x1 and y1 must be vectors with same number of points (at least 2).
if sum(size(x1) > 1) ~= 1 || sum(size(y1) > 1) ~= 1 || ...
		length(x1) ~= length(y1)
	error('X1 and Y1 must be equal-length vectors of at least 2 points.')
end
% x2 and y2 must be vectors with same number of points (at least 2).
if sum(size(x2) > 1) ~= 1 || sum(size(y2) > 1) ~= 1 || ...
		length(x2) ~= length(y2)
	error('X2 and Y2 must be equal-length vectors of at least 2 points.')
end


% Force all inputs to be column vectors.
x1 = x1(:);
y1 = y1(:);
x2 = x2(:);
y2 = y2(:);

% Compute number of line segments in each curve and some differences we'll
% need later.
n1 = length(x1) - 1;
n2 = length(x2) - 1;
xy1 = [x1 y1];
xy2 = [x2 y2];
dxy1 = diff(xy1);
dxy2 = diff(xy2);

% Determine the combinations of i and j where the rectangle enclosing the
% i'th line segment of curve 1 overlaps with the rectangle enclosing the
% j'th line segment of curve 2.
[i,j] = find(repmat(min(x1(1:end-1),x1(2:end)),1,n2) <= ...
	repmat(max(x2(1:end-1),x2(2:end)).',n1,1) & ...
	repmat(max(x1(1:end-1),x1(2:end)),1,n2) >= ...
	repmat(min(x2(1:end-1),x2(2:end)).',n1,1) & ...
	repmat(min(y1(1:end-1),y1(2:end)),1,n2) <= ...
	repmat(max(y2(1:end-1),y2(2:end)).',n1,1) & ...
	repmat(max(y1(1:end-1),y1(2:end)),1,n2) >= ...
	repmat(min(y2(1:end-1),y2(2:end)).',n1,1));

% Force i and j to be column vectors, even when their length is zero, i.e.,
% we want them to be 0-by-1 instead of 0-by-0.
i = reshape(i,[],1);
j = reshape(j,[],1);

% Find segments pairs which have at least one vertex = NaN and remove them.
% This line is a fast way of finding such segment pairs.  We take
% advantage of the fact that NaNs propagate through calculations, in
% particular subtraction (in the calculation of dxy1 and dxy2, which we
% need anyway) and addition.
% At the same time we can remove redundant combinations of i and j in the
% case of finding intersections of a line with itself.
if self_intersect
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2)) | j <= i + 1;
else
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2));
end
i(remove) = [];
j(remove) = [];

% Initialize matrices.  We'll put the T's and B's in matrices and use them
% one column at a time.  AA is a 3-D extension of A where we'll use one
% plane at a time.
n = length(i);
T = zeros(4,n);
AA = zeros(4,4,n);
AA([1 2],3,:) = -1;
AA([3 4],4,:) = -1;
AA([1 3],1,:) = dxy1(i,:).';
AA([2 4],2,:) = dxy2(j,:).';
B = -[x1(i) x2(j) y1(i) y2(j)].';

% Loop through possibilities.  Trap singularity warning and then use
% lastwarn to see if that plane of AA is near singular.  Process any such
% segment pairs to determine if they are colinear (overlap) or merely
% parallel.  That test consists of checking to see if one of the endpoints
% of the curve 2 segment lies on the curve 1 segment.  This is done by
% checking the cross product
%
%   (x1(2),y1(2)) - (x1(1),y1(1)) x (x2(2),y2(2)) - (x1(1),y1(1)).
%
% If this is close to zero then the segments overlap.

% If the robust option is false then we assume no two segment pairs are
% parallel and just go ahead and do the computation.  If A is ever singular
% a warning will appear.  This is faster and obviously you should use it
% only when you know you will never have overlapping or parallel segment
% pairs.

if robust
	overlap = false(n,1);
	warning_state = warning('off','MATLAB:singularMatrix');
	% Use try-catch to guarantee original warning state is restored.
	try
		lastwarn('')
		for k = 1:n
			T(:,k) = AA(:,:,k)\B(:,k);
			[unused,last_warn] = lastwarn;
			lastwarn('')
			if strcmp(last_warn,'MATLAB:singularMatrix')
				% Force in_range(k) to be false.
				T(1,k) = NaN;
				% Determine if these segments overlap or are just parallel.
				overlap(k) = rcond([dxy1(i(k),:);xy2(j(k),:) - xy1(i(k),:)]) < eps;
			end
		end
		warning(warning_state)
	catch err
		warning(warning_state)
		rethrow(err)
	end
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) <= 1 & T(2,:) <= 1).';
	% For overlapping segment pairs the algorithm will return an
	% intersection point that is at the center of the overlapping region.
	if any(overlap)
		ia = i(overlap);
		ja = j(overlap);
		% set x0 and y0 to middle of overlapping region.
		T(3,overlap) = (max(min(x1(ia),x1(ia+1)),min(x2(ja),x2(ja+1))) + ...
			min(max(x1(ia),x1(ia+1)),max(x2(ja),x2(ja+1)))).'/2;
		T(4,overlap) = (max(min(y1(ia),y1(ia+1)),min(y2(ja),y2(ja+1))) + ...
			min(max(y1(ia),y1(ia+1)),max(y2(ja),y2(ja+1)))).'/2;
		selected = in_range | overlap;
	else
		selected = in_range;
	end
	xy0 = T(3:4,selected).';
	
	% Remove duplicate intersection points.
	[xy0,index] = unique(xy0,'rows');
	x0 = xy0(:,1);
	y0 = xy0(:,2);
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		sel_index = find(selected);
		sel = sel_index(index);
		iout = i(sel) + T(1,sel).';
		jout = j(sel) + T(2,sel).';
	end
else % non-robust option
	for k = 1:n
		[L,U] = lu(AA(:,:,k));
		T(:,k) = U\(L\B(:,k));
	end
	
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) < 1 & T(2,:) < 1).';
	x0 = T(3,in_range).';
	y0 = T(4,in_range).';
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		iout = i(in_range) + T(1,in_range).';
		jout = j(in_range) + T(2,in_range).';
	end
end

