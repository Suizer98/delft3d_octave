function varargout = EHY_plot_satellite_map(varargin)
%% EHY_plot_satellite_map
%
% This functions plots a esri world image in your current figure
% You may also be interested in EHY_plot_ldb.m
%
% Example1: EHY_plot_satellite_map
% Example2: hSurf = EHY_plot_satellite_map
%
% EXAMPLE - plot a map showing some capitals in Europe:
%    lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
%    lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];
%    plot(lon,lat,'.r','MarkerSize',20)
%    EHY_plot_satellite_map
%
% created by Julien Groenenboom, April 2019

%% default settings
OPT.FaceAlpha = 0.5; % transparancy index 
OPT.rescale   = 1;   % change axes to get correct projection
OPT.axes      = gca; 
OPT.source    = 'esri_worldimagery'; % choose from: 'google','bluemarble','bingmaps','esri_worldimagery','openstreetmap'
OPT.localEPSG = []; % specify local EPSG (e.g. 28992)
OPT.localUnit = 'm'; % 'm' or 'km'
OPT.plot_map  = 1; % By switching to 0, EHY_plot_satellite_map can be used just to rescale the current axes
OPT           = setproperty(OPT,varargin);
%% get current axis
curAxis = axis(OPT.axes);
if any(abs(curAxis)>180) && isempty(OPT.localEPSG)
    error('You''re probably not using spherical coordinates. Check the OPT.localEPSG option in this function')
end

if strcmpi(OPT.localUnit,'km')
    curAxis = curAxis*10^3;
end

%% rescale
if OPT.rescale % based on (EHY_)plot_google_map
    
    if ~isempty(OPT.localEPSG) % local to WGS coordinates
        [curAxis(1:2), curAxis(3:4)] = convertCoordinates(curAxis(1:2), curAxis(3:4),'CS1.code',OPT.localEPSG,'CS2.code',4326);
    end
    
    % adjust current axis limit to avoid strectched maps
    [xExtent,yExtent] = latLonToMeters(curAxis(3:4), curAxis(1:2) );
    xExtent = diff(xExtent); % just the size of the span
    yExtent = diff(yExtent); 
    % get axes aspect ratio
    drawnow
    org_units = get(OPT.axes,'Units');
    set(OPT.axes,'Units','Pixels')
    ax_position = get(OPT.axes,'position');        
    set(OPT.axes,'Units',org_units)
    aspect_ratio = ax_position(4) / ax_position(3);
    
    if xExtent*aspect_ratio > yExtent        
        centerX = mean(curAxis(1:2));
        centerY = mean(curAxis(3:4));
        spanX = (curAxis(2)-curAxis(1))/2;
        spanY = (curAxis(4)-curAxis(3))/2;
       
        % enlarge the Y extent
        spanY = spanY*xExtent*aspect_ratio/yExtent; % new span
        if spanY > 85
            spanX = spanX * 85 / spanY;
            spanY = spanY * 85 / spanY;
        end
        curAxis(1) = centerX-spanX;
        curAxis(2) = centerX+spanX;
        curAxis(3) = centerY-spanY;
        curAxis(4) = centerY+spanY;
    elseif yExtent > xExtent*aspect_ratio
        
        centerX = mean(curAxis(1:2));
        centerY = mean(curAxis(3:4));
        spanX = (curAxis(2)-curAxis(1))/2;
        spanY = (curAxis(4)-curAxis(3))/2;
        % enlarge the X extent
        spanX = spanX*yExtent/(xExtent*aspect_ratio); % new span
        if spanX > 180
            spanY = spanY * 180 / spanX;
            spanX = spanX * 180 / spanX;
        end
        
        curAxis(1) = centerX-spanX;
        curAxis(2) = centerX+spanX;
        curAxis(3) = centerY-spanY;
        curAxis(4) = centerY+spanY;
    end            
    % Enforce Latitude constraints of EPSG:900913
    if curAxis(3) < -85
        curAxis(3:4) = curAxis(3:4) + (-85 - curAxis(3));
    end
    if curAxis(4) > 85
        curAxis(3:4) = curAxis(3:4) + (85 - curAxis(4));
    end
    
    if ~isempty(OPT.localEPSG) % WGS to local coordinates
        [curAxis(1:2), curAxis(3:4)] = convertCoordinates(curAxis(1:2), curAxis(3:4),'CS1.code',4326,'CS2.code',OPT.localEPSG);
    end
    
    % update axis as quickly as possible, before downloading new image
    if strcmpi(OPT.localUnit,'km')
        axis(OPT.axes, curAxis/10^3);
    else
        axis(OPT.axes, curAxis);
    end
    drawnow
end

%% plot Esri map
if OPT.plot_map
    
    if ~isempty(OPT.localEPSG) % local to WGS coordinates
        [curAxis(1:2), curAxis(3:4)] = convertCoordinates(curAxis(1:2), curAxis(3:4),'CS1.code',OPT.localEPSG,'CS2.code',4326);
    end
    
    no_tries = 0;
    success = 0;
    while no_tries < 5 && ~success
        try
            [IMG,lon,lat] = wms('image',wms('tms',OPT.source),'',curAxis(1:2),curAxis(3:4));
            success = 1;
        catch
            no_tries = no_tries + 1;
            disp(['Attempt ' num2str(no_tries) ' out of 5 to load satellite image failed. Let''s try again in ' num2str(no_tries*3) ' seconds.'])
            pause(no_tries*3)
        end
    end
    
    if ~success
        disp('<strong>Failed to load satellite image</strong>');
        return
    end
    
    if ~isempty(OPT.localEPSG) % WGS to local coordinates
        lon = linspace(lon(1),lon(2),length(lat));
        [lon,lat] = convertCoordinates(lon, lat,'CS1.code',4326,'CS2.code',OPT.localEPSG);
        if strcmpi(OPT.localUnit,'km')
            lon=lon/1000;lat=lat/1000;
        end
    end
    
    hSurf = surface(lon,lat,zeros(length(lat),length(lon)),'cdata',IMG,'facecolor','texturemap', ...
        'edgecolor','none','cLimInclude','off','ZData',repmat(-10^9,length(lat),length(lon)));
    set(hSurf,'FaceAlpha', OPT.FaceAlpha, 'AlphaDataMapping', 'none');
    
    if nargout == 1
        varargout{1} = hSurf;
    end
end
end

function [x,y] = latLonToMeters(lat, lon )
% Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
originShift = 2 * pi * 6378137 / 2.0; % 20037508.342789244
x = lon * originShift / 180;
y = log(tan((90 + lat) * pi / 360 )) / (pi / 180);
y = y * originShift / 180;
end