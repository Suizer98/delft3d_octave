function [handles] = ddb_ModelMakerToolbox_XBeach_quickMode_drawtransects(handles)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Get X and Y
X = handles.toolbox.modelmaker.xb_trans.X;
Y = handles.toolbox.modelmaker.xb_trans.Y;
ntransects = length(X)-1;

% Get locations of the model
for ii = 1:ntransects;
    dx = abs((X(ii+1)-X(ii)));     dy = abs((Y(ii+1)-Y(ii)));
    coast(ii) = (atand( dy / dx));
    
    % Based on
    dx_2(ii) = X(ii+1) - X(ii); dy_2(ii) = Y(ii+1) - Y(ii);

    % Based on degrees
    xorg(ii) = (X(ii+1) + X(ii))/2;
    yorg(ii) = (Y(ii+1) + Y(ii))/2;
    distances(ii) = ((X(ii+1) - X(ii)).^2 + (Y(ii+1) - Y(ii)).^2).^0.5;
    dx = X(ii+1) - X(ii); dy = Y(ii+1) - Y(ii);
   
    if dx >= 0 && dy <= 0 
    xback(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy < 0
    xback(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx > 0 && dy > 0
    xback(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy > 0
    xback(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
end

% Keep coast, X, Y and distance
for ii = 1:length(distances);
    if ii == 1;
    distances_cum(ii) = distances(ii);
    else
    distances_cum(ii) = distances_cum(ii-1) + distances(ii);
    end
end

if handles.toolbox.modelmaker.transects ~= 0
    distances_total = sum(distances);
    ntransects = handles.toolbox.modelmaker.transects;
    ndivide = handles.toolbox.modelmaker.transects + 1;
    for jj = 1:ntransects
        distances_wanted = max(distances_cum)/ndivide * jj;
        xoff2(jj) = interp1(distances_cum,xoff,distances_wanted);
        yoff2(jj) = interp1(distances_cum,yoff,distances_wanted);
        xback2(jj) = interp1(distances_cum,xback,distances_wanted);
        yback2(jj) = interp1(distances_cum,yback,distances_wanted);
        coast2(jj) = interp1(distances_cum,coast,distances_wanted);
        distances2(jj) = distances_wanted;
    end
    for jj = 1:ntransects+1;
    id = (~isnan(xoff2) & ~isnan(xback2) & ~isnan(yoff2) & ~isnan(yback2));
    xoff = xoff2(id); xback = xback2(id);
    yoff = yoff2(id); yback = yback2(id);
    coast = coast2(id); distances = distances2(id); ntransects = length(xoff);
    end
    
    for jj = 1:length(distances);
        if jj == 1;
        distances0(jj) = distances(jj);
        else
        distances0(jj) = distances(jj)-distances(jj-1);
        end
    end
    average_dx  = round(nanmean(distances0(2:end)));
    distances   = ones(1,length(distances)) * nanmean(distances0);
else
    ntransects = length(xoff);
    average_dx = round(nanmean(distances));
end

% Set values
handles.toolbox.modelmaker.xb_trans.ntransects = ntransects;
handles.toolbox.modelmaker.xb_trans.xoff = xoff;
handles.toolbox.modelmaker.xb_trans.yoff = yoff;
handles.toolbox.modelmaker.xb_trans.xback = xback;
handles.toolbox.modelmaker.xb_trans.yback = yback;
handles.toolbox.modelmaker.xb_trans.distances = distances;
handles.toolbox.modelmaker.xb_trans.coast = coast;
handles.toolbox.modelmaker.average_dx = average_dx;
setHandles(handles);

end

