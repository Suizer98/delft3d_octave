function [xg,yg,zg]=xyz2regulargrid(varargin)
% Returns vectors xg, yg, and matrix zg of regular grid, if vector x and y
% appear to be constitute data on a regular grid. Input can be either x,y,z
% vectors or a file name

if ischar(varargin{1})
    % File name
    s=load(varargin{1});
    x=squeeze(s(:,1));
    y=squeeze(s(:,2));
    z=squeeze(s(:,3));
else
    % x,y,z vectors
    x=varargin{1};
    y=varargin{2};
    z=varargin{3};
end


np=length(x);

%% First try to establish if this is on a regular grid

xmin=min(x);
ymin=min(y);

% icheckedx=zeros(1,np);
% icheckedy=zeros(1,np);
% 
% nx=0;
% ny=0;
% for ip=1:np
%     % Find values that have the same x coordinate
%     if ~icheckedx(ip) % new x value found
%         nx=nx+1;
%         xval(nx)=x(ip);
%         isame= x==x(ip);
%         icheckedx(isame)=1;
%     end
%     % Find values that have the same y coordinate
%     if ~icheckedy(ip) % new y value found
%         ny=ny+1;
%         yval(ny)=y(ip);
%         isame= y==y(ip);
%         icheckedy(isame)=1;
%     end    
% end

% This eliminates duplicates and orders low to high
xvalsort=unique(x);
yvalsort=unique(y);

% Check for regular spacing between points
% First find minimum spacing mindx between values, all spacings between the
% points should be a multiple of this value
% x
% xvalsort=sort(xval);
dx=xvalsort(2:end)-xvalsort(1:end-1);
mindx=min(dx);
xmultiple=dx/mindx; % this number must be very close to an integer
r=max(abs(xmultiple-round(xmultiple)));
if r>1/100
    warning_str = ['Min(dx)=',num2str(min(dx)),', Max(dx)=',num2str(max(dx))];
    ddb_giveWarning('text',{'xyz data does not appear to be on a regular grid!',warning_str});
    error('xyz data does not appear to be on a regular grid!');
end
% y
%yvalsort=sort(yval);
dy=yvalsort(2:end)-yvalsort(1:end-1);
mindy=min(dy);
ymultiple=dy/mindy; % this number must be very close to an integer
r=max(abs(ymultiple-round(ymultiple)));
if r>1/100
    warning_str = ['Min(dy)=',num2str(min(dy)),', Max(dy)=',num2str(max(dy))];
    ddb_giveWarning('text',{'xyz data does not appear to be on a regular grid!',warning_str});
    error('xyz data does not appear to be on a regular grid!');
end

%% Data appears to be stored on a regular grid
% xg=xvalsort(1):mindx:xvalsort(end);
% yg=yvalsort(1):mindy:yvalsort(end);

% Using the mean value preserves the length of the array better, especially when
% the array has lot of elements. Otherwise length(xg)*length(yg) <> np.
mdx=mean(dx); 
mdy=mean(dy);
xg=xvalsort(1):mdx:xvalsort(end);
yg=yvalsort(1):mdy:yvalsort(end);
zg=zeros(length(yg),length(xg));
zg(zg==0)=NaN;
% Now for each point on the grid, find its i and j index
for ip=1:np
    jj=round((x(ip)-xmin)/mdx)+1;
    ii=round((y(ip)-ymin)/mdy)+1;
    zg(ii,jj)=z(ip);
end
