function grd = dflowfm_shiftNodesCutCellPolygon(grd)

if isfield(grd,'face') & isfield(grd,'node') && isfield(grd.face,'NetElemNode') && isfield(grd.face,'FlowElemCont_x') && isfield(grd.node,'x')
    %% find active nodes (which are included in grd.face.NetElemNode)
    IDactiveNodes = unique(grd.face.NetElemNode);
    IDactiveNodes(isnan(IDactiveNodes)) = [];
    % IDinactiveNodes = find(~ismember(1:length(grd.node.x),IDactiveNodes));
    
    % % set inactive nodes to NaN
    % grd.node.x(IDinactiveNodes) = NaN;
    % grd.node.y(IDinactiveNodes) = NaN;
    
    % temporarily store x and y coordinates of face contours
    contourXY = [grd.face.FlowElemCont_x(:) grd.face.FlowElemCont_y(:)];
    contourXY(isnan(contourXY(:,1)),:) = [];
    
    % Find nearest node to contour x,y coordinates and replace node coordinate by neareast contour x,y
    nodeXY = [grd.node.x' grd.node.y'];
    [ID,dist] = knnsearch(nodeXY,contourXY); % ID contains for each node the nearest point in contour XY
    grd.node.x(IDactiveNodes) = contourXY(ID(IDactiveNodes),1);
    grd.node.y(IDactiveNodes) = contourXY(ID(IDactiveNodes),2);
    disp('Nodes X and Y coordinates have been shifted to the cutcellpolygon.lst')
end