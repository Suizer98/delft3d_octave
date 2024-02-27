function z=netstruc_smoothing(netstruc,xpol,ypol,varargin)

maxit=5;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'maxiter'}
                maxit=varargin{ii+1};
        end
    end
end

% First find points with NaN depth inside polygon
% Find grid points without elevation data
if ~isempty(xpol)
    inp=inpolygon(netstruc.node.mesh2d_node_x,netstruc.node.mesh2d_node_y,xpol,ypol);
else
    inp=zeros(1,length(netstruc.node.mesh2d_node_x))+1;
end
netstruc.node.mesh2d_node_z(netstruc.node.mesh2d_node_z==-999)=NaN;

% Indices of nodes that are not NaN and inside polygon
ind=find(~isnan(netstruc.node.mesh2d_node_z) & inp);
nind=length(ind);

z=netstruc.node.mesh2d_node_z;
np=length(z);
z(np+1)=NaN;

% tic
% Now find neigboring points that are not NaN
nnb=zeros(1,nind);
inb=zeros(10,nind);

c = ismember(netstruc.edge.mesh2d_edge_nodes, ind);
indices = sum(c,1)>0;
netstruc.edge.mesh2d_edge_nodes=netstruc.edge.mesh2d_edge_nodes(:,indices);

for ii=1:nind
      
    [iind,jind]=find(netstruc.edge.mesh2d_edge_nodes==ind(ii));
    k1=0;
    for k=1:length(iind)
        if iind(k)==1
            if ~isnan(z(netstruc.edge.mesh2d_edge_nodes(2,jind(k))))
                k1=k1+1;
                inb(k1,ii)=netstruc.edge.mesh2d_edge_nodes(2,jind(k));
            end
        else
            if ~isnan(z(netstruc.edge.mesh2d_edge_nodes(1,jind(k))))
                k1=k1+1;
                inb(k1,ii)=netstruc.edge.mesh2d_edge_nodes(1,jind(k));
            end
        end
    end
    nnb(ii)=k1;
end
% toc
inb=inb(1:max(nnb),:);
inb(inb==0)=np+1;

% Now apply smoothing
% tic

for nit=1:maxit
    
    z1=z;

    
    zm=0.5*z(ind)+0.5*nansum(z(inb),1)./max(nnb,1);
       
    z1(ind)=zm;
    
    z=z1;
end
% toc

z=z(1:end-1);
