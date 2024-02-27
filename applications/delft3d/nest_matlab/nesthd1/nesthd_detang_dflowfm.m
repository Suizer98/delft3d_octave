function angles = nesthd_detang_dflowfm(grid_fine,bnd)


% detrmine orientation of the boundary such that inflow is positive.
% angle is defined as angle of positive flow + 90 degrees, in cartesian (0
% degrees is east, counterclockwise is positve).

% store X and Y coordinates in vectors
X_bndAll = [bnd.DATA.X];
Y_bndAll = [bnd.DATA.Y];

% determine unique boundary names
bndNames = bnd.Name;
pliNames = unique(bnd.FileName);

for bb = 1:length(pliNames)
    bndIDs = find(~cellfun('isempty',regexp(bnd.Name,pliNames{bb})));
    [~,ID,ID2] = unique(bndNames(bndIDs));
    
    X_bnd = X_bndAll(bndIDs(ID));
    Y_bnd = Y_bndAll(bndIDs(ID));
    
    
    % calculate direction if one follows the support
    % points
    dX = [diff(X_bnd(1:2)) mean([diff(X_bnd(1:end-1));diff(X_bnd(2:end))],1) diff(X_bnd(end-1:end))];
    dY = [diff(Y_bnd(1:2)) mean([diff(Y_bnd(1:end-1));diff(Y_bnd(2:end))],1) diff(Y_bnd(end-1:end))];
    
    angleBnd = mod(90-atan2(dX,dY)*180/pi,360);
    
    % determine for each support point the closest 5 nodes to determine on which side of the .pli the network is located
    for pp = 1:length(X_bnd)
        dist = sqrt((grid_fine.X-X_bnd(pp)).^2 + (grid_fine.Y-Y_bnd(pp)).^2 );
        [disSort,IDsort]=sort(dist);
        XnodesMean = mean(grid_fine.X(IDsort(1:5)));
        YnodesMean = mean(grid_fine.Y(IDsort(1:5)));
        
        posAngle(pp) = mod(90-atan2(XnodesMean-X_bnd(pp),YnodesMean-Y_bnd(pp))*180/pi,360);
    end
    
    % if difference between positive angle and earlier determined angleBnd is larger than 180 for most support points, 180 degrees need to be added to angleBnd
    if length(find(mod(angleBnd-posAngle,360)>180)) > length(X_bnd)/2
        angleBnd = mod(angleBnd+180,360);
    end
    
    angles(bndIDs) = angleBnd(ID2);
    clear posAngle
end