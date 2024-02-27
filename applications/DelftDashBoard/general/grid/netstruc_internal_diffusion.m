function z=netstruc_internal_diffusion(netstruc,xpol,ypol,varargin)

maxit=1000;
dzmax=0.01;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'maxiter'}
                maxit=varargin{ii+1};
            case{'dzmax'}
                dzmax=varargin{ii+1};            
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

% Indices of nodes that are NaN and inside polygon
ind=find(isnan(netstruc.node.mesh2d_node_z) & inp);
nind=length(ind);

z=netstruc.node.mesh2d_node_z;
np=length(z);
z(np+1)=NaN;

% Now find neigboring points
nnb=zeros(1,nind);
inb=zeros(10,nind);

c = ismember(netstruc.edge.mesh2d_edge_nodes, ind);
indices = sum(c,1)>0;
netstruc.edge.mesh2d_edge_nodes=netstruc.edge.mesh2d_edge_nodes(:,indices);

for ii=1:nind
      
    [iind,jind]=find(netstruc.edge.mesh2d_edge_nodes==ind(ii));
    for k=1:length(iind)
        if iind(k)==1
            inb(k,ii)=netstruc.edge.mesh2d_edge_nodes(2,jind(k));
        else
            inb(k,ii)=netstruc.edge.mesh2d_edge_nodes(1,jind(k));
        end
    end
   nnb(ii)=length(iind);

end

inb=inb(1:max(nnb),:);
inb(inb==0)=np+1;

if isempty(inb)
    % No neigboring points found
    z=z(1:end-1);
    return
end

% Now fill with depth values

nit=0;

while 1
    nit=nit+1;
    ok=1;
    z1=z;
    
    zz=z(ind);
    isnz=isnan(zz);
    
    nnnn=max(sum(~isnan(z(inb)),1),1);
    zm1=nansum(z(inb),1)./nnnn; % Points that were NaN
    zm2=0.5*z(ind)+0.5*nansum(z(inb),1)./nnnn;
    
    zz(isnz)=zm1(isnz);
    zz(~isnz)=zm2(~isnz);
    
    z1(ind)=zz;
        
    if max(abs(z1(ind)-z(ind)))>dzmax || ~isempty(find(isnan(z1(ind)), 1))
        ok=0;
    end
    %     end
    z=z1;
    if ok==1
        break
    end
    if nit>maxit
        break
    end
end

z=z(1:end-1);
