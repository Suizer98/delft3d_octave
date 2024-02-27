function polout = interpolate_on_polygon(Gin,Din,pol,FlowElemDomain)
% interpolate flow data on polygon

if ( nargin<4)
    FlowElemDomain=-1;
end

pol.x = reshape(pol.x,1,[]);
pol.y = reshape(pol.y,1,[]);

% check sizes of Gin and Din
lenG = length(Gin);
lenD = length(Din);

% sizes should match
if ( lenG~=lenD )
    error('Grid and Map length do not match.');
end


for idmnp1=1:length(Gin)    % idmn + 1
    if ( iscell(Gin) )
        G = Gin{idmnp1};
        D = Din{idmnp1};
        FlowElemDomain = idmnp1-1; % assume partitioned data
        fprintf('Interpolating domain %i...', FlowElemDomain);
    else
        G = Gin;
        D = Din;
    end

    idxAtoL=G.edge.FlowLink(1,:)<=G.face.FlowElemSize & G.edge.FlowLink(2,:)<=G.face.FlowElemSize & ...
            G.edge.FlowLink(1,:)> 0                   & G.edge.FlowLink(2,:)>0 ;
    idxAtoL=find(idxAtoL);
    if ( isfield(G.face,'idmn')&& idmn>-1 )
%         idxAtoL=idxAtoL(min(G.face.FlowElemDomain(G.edge.FlowLink(1,idxAtoL)),    ...
%                             G.face.FlowElemDomain(G.edge.FlowLink(2,idxAtoL)))==idmn);
        idxAtoL=idxAtoL(G.face.idmn(G.face.Link(1,idxAtoL)) == FlowElemDomain |   ...
                        G.face.idmn(G.face.Link(2,idxAtoL)) == FlowElemDomain);
    end


%     len = length(idxAtoL);
% %   make sure index array is a row vector
%     idxAtoL = reshape(idxAtoL,1,len);
    
    A.x1 = G.face.FlowElem_x(G.edge.FlowLink(1,idxAtoL));
    A.y1 = G.face.FlowElem_y(G.edge.FlowLink(1,idxAtoL));
    A.x2 = G.face.FlowElem_x(G.edge.FlowLink(2,idxAtoL));
    A.y2 = G.face.FlowElem_y(G.edge.FlowLink(2,idxAtoL));

    B.x1 = pol.x(1:end-1);
    B.y1 = pol.y(1:end-1);
    B.x2 = pol.x(2:end);
    B.y2 = pol.y(2:end);

    C = dflowfm.intersect_lines(A,B);

    % compute arc length
    darc0 = sqrt((B.x2-B.x1).^2 + (B.y2-B.y1).^2);
    arc0 = cumsum(darc0);
    arc = arc0(C.idxB) - (1-C.beta).*darc0(C.idxB);
    
    
    %unique intersections only
    [dum,idx1,idx2] = unique(arc);
    
    % sort intersections on increasing arc length
    [dum,idx2] = sort(arc(idx1));
    idxarctoA = idx1(idx2);

    polout.arc = arc(idxarctoA);
    polout.x   = C.x(idxarctoA);
    polout.y   = C.y(idxarctoA);
    
    angtemp = atan2(diff(polout.y),diff(polout.x));
    if ( length(angtemp)>0 )
        angtemp = [angtemp,angtemp(end)];     %entend dimension of ang 
    end
    polout.ang = angtemp;

    % perform interpolation from D
    varnams= fieldnames(D.face);
    
    for i=1:length(varnams)
        var=varnams{i};
%       assume row indices correspond to layers
        NDIM=length(size(D.face.(var)));
        polout.face.(var) = [];
        for k=1:size(D.face.(var),2) % could be slow, possible future work: try to prevent loop
            dum = D.face.(var);
            polout.face.(var)(:,k) = interpolate(D.face.(var)(:,k));
        end
    end

    % interpolate bottom levels from G
    polout.face.FlowElem_z     = interpolate(D.face.z_cc );
    if ( isfield(G.face,'idmn') )
        polout.face.idmn = interpolate(G.face.idmn);
    end
    
    % 3D data: add X and Z coordinates (sigma layers only)
    numlay=size(D.face.u,2);
    if ( numlay>1 )
    %   compute water depth
        h=polout.face.zwl(:)-polout.face.FlowElem_z(:);
        h=reshape(h,length(h),1);
    %   layers *were* assumed to be uniformly distributed along the water
    %   column, not anymore, now using D.face.z_cc from readMap
%         polout.z=repmat((1:numlay)-0.5, length(h),1)/numlay .* repmat(h,1,numlay) + repmat(polout.face.FlowElem_z(:),1,numlay);
        polout.z = polout.face.z_cc;
        polout.arc=repmat(polout.arc(:),1,numlay);
        polout.ang=repmat(polout.ang(:),1,numlay);
        polout.x=repmat(polout.x(:),1,numlay);
        polout.y=repmat(polout.y(:),1,numlay);
    end
    
    %if 'u' and %'v' are available, compute velocity along and normal to polygon
    polout.ang = reshape(polout.ang,size(polout.face.u));
    if ( sum(ismember({'u','v'},varnams))==2 && isfield(polout,'ang') )
        polout.face.us = polout.face.u .* cos(polout.ang) +   ...
                             polout.face.v .* sin(polout.ang);
                            
        polout.face.un = -polout.face.u .* sin(polout.ang) +   ...
                              polout.face.v .* cos(polout.ang);
    end

    if ( iscell(Gin) )
        fprintf(' done.\n');
        pol_store{idmnp1} = polout;
    end

end

if ( iscell(Gin) )
    clear polout;
    polout = pol_store;
end

    function y = interpolate(x)
        
        y = (1-reshape(C.alpha(idxarctoA),size(idxarctoA))).*    ...
                reshape(    ...
                    x(G.edge.FlowLink(1,idxAtoL(C.idxA(idxarctoA)))),    ...
                    size(idxarctoA) ...
                ) +   ...
            reshape(C.alpha(idxarctoA),size(idxarctoA)) .*   ...
                reshape(    ...
                    x(G.edge.FlowLink(2,idxAtoL(C.idxA(idxarctoA)))),    ...
                    size(idxarctoA) ...
                );
    end

end