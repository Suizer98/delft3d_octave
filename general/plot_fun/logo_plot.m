function varargout = logo_plot(imname,ax)
%LOGO_PLOT plots image into self-scaling bounding box
%
% logoplot(imname,ax) plots an image inside bounding box ax.
%
% ax is the 4-element axis bounding box [x0 x1 y0 y1],
% just like axis command, where one element can can be 
% NaN for self-scaling. Note: LOGO_PLOT sets axis equal  
% so aspect ratio of image is correct.
%
% Example:
%  pcolor(peaks);clim([-3 3]);
%  hold on;
%  logo_plot(oetlogo,[45 55 43 nan]);
%
%See also: imread

% ax = [77e3 nan 366.5 650];
%ax = [77 78 366.5 nan].*1e3;
%imname = 'deltares.png';

LG.data = imread(imname);

aspect = size(LG.data,2)/size(LG.data,1);

ind = find(isnan(ax));
n   = length(ind);
if n > 1
    error('at least 3 corners of bounding box required')
elseif n==1
    if  ind < 3
       h = (ax(4)-ax(3));
       w = h*aspect;
       if     ind==1;ax(1) = ax(2) - w;
       elseif ind==2;ax(2) = ax(1) + w;
       end
    else
       w = (ax(2)-ax(1));
       h = w/aspect;
       if     ind==3;ax(3) = ax(4) - h;
       elseif ind==4;ax(4) = ax(3) + h;
       end
    end
end

LG.x    = linspace(ax(1),ax(2),size(LG.data,1));
LG.y    = linspace(ax(4),ax(3),size(LG.data,2));
axis equal
h = image(LG.data,'XData',LG.x,'YData',LG.y);set(gca,'YDir','normal');
set(gca,'Visible','on'); % undo
set(h,'clipping','off')

if nargout==1
    varargout = {h};
end