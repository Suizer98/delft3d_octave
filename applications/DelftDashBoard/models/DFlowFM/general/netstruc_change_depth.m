function z1=netstruc_change_depth(netstruc,opt,unifval,xpol,ypol)

if ~isempty(xpol)
    inp=inpolygon(netstruc.node.mesh2d_node_x,netstruc.node.mesh2d_node_y,xpol,ypol);
else
    inp=zeros(1,length(netstruc.node.mesh2d_node_x))+1;
end

ind=find(inp==1);

z1=netstruc.node.mesh2d_node_z;

z0=netstruc.node.mesh2d_node_z(ind);

switch lower(opt)
    case{'unif-missing'}
        z0(isnan(z0))=unifval;
    case{'unif-all'}
        z0=unifval;
    case{'max'}
        z0(~isnan(z0))=max(z0(~isnan(z0)),unifval);
    case{'min'}
        z0(~isnan(z0))=min(z0(~isnan(z0)),unifval);
    case{'plus'}
        z0=z0+unifval;
    case{'times'}
        z0=z0*unifval;
    case{'nan'}
        z0=zeros(size(z0));
        z0(z0==0)=NaN;
end

z1(ind)=z0;
