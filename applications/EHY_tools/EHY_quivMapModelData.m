function varargout = EHY_quivMapModelData(gridInfo,vel_x,vel_y,varargin)
%% varargout = EHY_quivMapModelData(gridInfo,vel_x,vel_y,varargin)
% Create quiver vectors
%
% This function only plots the quiver vector part,
% so you can easily add your own colorbar, xlims, etc.
%
% gridInfo     :   struct (with fields Xcen and Ycen) obtained with:
%                  gridInfo=EHY_getGridInfo(filename,{'XYcen'});
%                  if not available on map-file, you can also use:
%                  struct (with fields face_nodes_x and face_nodes_x) obtained with:
%                  gridInfo=EHY_getGridInfo(filename,{'face_nodes_xy'});
%
% vel_x        :   x-velocity in cell centers (= Data.vel_x obtained with EHY_getMapModelData)
% vel_y        :   y-velocity in cell centers (= Data.vel_y obtained with EHY_getMapModelData)
%
% Example1:   EHY_quivMapModelData(gridInfo,vel_x,vel_y,'thinning',2)
%             with gridInfo = EHY_getGridInfo(outputfile,{'XYcen'});
%                  Data     = EHY_getMapModelData(outputfile, ... );
%                  vel_x    = Data.vel_x(5,:,7);
%                  vel_y    = Data.vel_y(5,:,7);  % e.g. time_index = 5, layer = 7
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2019
%
%% Settings
OPT.color         = 'k';       % color of the vectors
OPT.scaling       = 1;         % scale factor: the velocity vectors are multiplied by this factor
OPT.thinningStyle = 'uniform'; % 'uniform' or 'distance' (in model coordinates)
OPT.thinning      = 1;         % thinning factor, if thinningStyle is 'uniform', than this should be integer
OPT.vectorStyle   = 'quiver';  % straight 'quiver' vectors or curved 'curvec' vectors
OPT.domain        = [];        % plot domain [Xmin,Xmax,Ymin,Ymax] for curvec grid interpolation
OPT.filter        = [];        % (file path [*.pol] of) polygon [m x 2] encircling area to exclude
OPT.flipfilter    = 0;         % 0 = exclude curved vectors IN polygon, 1 =  exclude curved vectors OUTSIDE polygon

% if pairs were given as input OPT
if ~isempty(varargin)
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin);
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% check input
if strcmp(OPT.thinningStyle,'uniform') && strcmp(OPT.vectorStyle,'quiver')
    OPT.thinning = round(OPT.thinning);
end

if ~isnumeric(OPT.scaling);  OPT.scaling  = str2num(OPT.scaling);  end
if ~isnumeric(OPT.thinning); OPT.thinning = str2num(OPT.thinning); end

vel_x = squeeze(vel_x);
vel_y = squeeze(vel_y);
if size(vel_x,2) == 1; vel_x = vel_x'; end
if size(vel_y,2) == 1; vel_y = vel_y'; end

if ~all([exist('gridInfo','var') exist('vel_x','var') exist('vel_y','var')])
    error('input arguments gridInfo, vel_x and vel_y are required')
end

% make sure we have cell center coordinates
if ~all(ismember({'Xcen','Ycen'},fieldnames(gridInfo)))
    if isfield(gridInfo,'face_nodes_x')
        disp('Taking nanmean of face_nodes_x/y to get the (approximated) cell center coordinates')
        gridInfo.Xcen = nanmean(gridInfo.face_nodes_x,1);
        gridInfo.Ycen = nanmean(gridInfo.face_nodes_y,1);
    elseif isfield(gridInfo,'Xcor')
        disp('Using corner2center to get cell center coordinates')
        gridInfo.Xcen = corner2center(gridInfo.Xcor);
        gridInfo.Ycen = corner2center(gridInfo.Ycor);
    end
end

if size(gridInfo.Xcen,2) == 1
    gridInfo.Xcen = gridInfo.Xcen';
end
if size(gridInfo.Ycen,2) == 1
    gridInfo.Ycen = gridInfo.Ycen';
end

if any(size(vel_x)~=size(vel_y))
    error('size(vel_x) should be equal to size(vel_y)')
elseif isfield(gridInfo,'face_nodes_x') && size(gridInfo.face_nodes_x,2)~=numel(vel_x)
    error('size(gridInfo.face_nodes_x,2) should be the same as  prod(size(zData))')
elseif isfield(gridInfo,'Xcen') && any(size(gridInfo.Xcen)~=size(vel_x))
    error('size(gridInfo.Xcor) and size(vel_x) should be the same')
end

%% thinning
if strcmp(OPT.vectorStyle,'quiver')
    switch OPT.thinningStyle
        case 'uniform'
            if ndims(vel_x) == 2 && min(size(vel_x)) == 1
                vel_x = vel_x(1:OPT.thinning:end);
                vel_y = vel_y(1:OPT.thinning:end);
                gridInfo.Xcen = gridInfo.Xcen(1:OPT.thinning:end);
                gridInfo.Ycen = gridInfo.Ycen(1:OPT.thinning:end);
            elseif ndims(vel_x) == 2 && min(size(vel_x)) > 1
                vel_x = vel_x(1:OPT.thinning:end,1:OPT.thinning:end);
                vel_y = vel_y(1:OPT.thinning:end,1:OPT.thinning:end);
                gridInfo.Xcen = gridInfo.Xcen(1:OPT.thinning:end,1:OPT.thinning:end);
                gridInfo.Ycen = gridInfo.Ycen(1:OPT.thinning:end,1:OPT.thinning:end);
            end
            
        case 'distance'
            % Make use of QuickPlot-functionality reducepoints_r2007a_7p4.mexw64 
            keep_index = calldll('reducepoints_r2007a_7p4',OPT.thinning,gridInfo.Xcen,gridInfo.Ycen);
                        
            % next step works for both structured and unstructured grids
            vel_x = vel_x(keep_index);
            vel_y = vel_y(keep_index);
            gridInfo.Xcen = gridInfo.Xcen(keep_index);
            gridInfo.Ycen = gridInfo.Ycen(keep_index);
    end
end

%% vectors
switch OPT.vectorStyle
    case 'quiver'
        hVector = quiver(gridInfo.Xcen,gridInfo.Ycen,OPT.scaling*vel_x,OPT.scaling*vel_y,0);
        
        % color
        set(hVector,'color',OPT.color);
        
    case 'curvec'
        if isempty(OPT.domain)
            Xmin = min(gridInfo.Xcen); Xmax = max(gridInfo.Xcen);
            Ymin = min(gridInfo.Ycen); Ymax = max(gridInfo.Ycen);
        else
            Xmin = OPT.domain(1); Xmax = OPT.domain(2);
            Ymin = OPT.domain(3); Ymax = OPT.domain(4);
        end
        vecLength = (Ymax-Ymin)*OPT.scaling;
        [X, Y]    = meshgrid(Xmin:OPT.thinning:Xmax,Ymin:OPT.thinning:Ymax);
        pos       = reshape(cat(2,X',Y'),[],2); pos = [pos,ones(length(pos),1)];
        Fx        = scatteredInterpolant(gridInfo.Xcen',gridInfo.Ycen',vel_x','linear');
        Fy        = scatteredInterpolant(gridInfo.Xcen',gridInfo.Ycen',vel_y','linear');
        ux        = Fx(X, Y); uy = Fy(X, Y);
        if ~isempty(OPT.filter)
            if ~isnumeric(OPT.filter)
                landPol = io_polygon('read',OPT.filter);
            else
                landPol = OPT.filter;
            end
            landArea  = inpolygon(X,Y,landPol(:,1),landPol(:,2));
            if OPT.flipfilter 
                landArea = ~landArea;
            end
            ux(landArea) = NaN; uy(landArea) = NaN;
        end
        [polx,poly] = curvec(X,Y,ux,uy,'length',vecLength,'position',pos);
        hVector = patch(polx,poly,OPT.color);
        set(hVector,'EdgeAlpha',0);
end

if nargout==1
    varargout{1} = hVector;
end

end