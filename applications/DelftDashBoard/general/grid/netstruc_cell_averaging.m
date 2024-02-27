function znew=netstruc_cell_averaging(netstruc,x,y,z,xpol,ypol,varargin)

distfac=0.75;
minpoints=3;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'distfac'}
                distfac=varargin{ii+1};
            case{'minpoints'}
                minpoints=varargin{ii+1};            
        end
    end
end


% Compute cell size for each node
tdist=zeros(1,length(netstruc.node.mesh2d_node_x));
nedge=tdist;

l=sqrt((netstruc.node.mesh2d_node_x(netstruc.edge.mesh2d_edge_nodes(1,:))-netstruc.node.mesh2d_node_x(netstruc.edge.mesh2d_edge_nodes(2,:))).^2 + ...
    (netstruc.node.mesh2d_node_y(netstruc.edge.mesh2d_edge_nodes(1,:)) - netstruc.node.mesh2d_node_y(netstruc.edge.mesh2d_edge_nodes(2,:))).^2);

for ie=1:size(netstruc.edge.mesh2d_edge_nodes,2)
    i1=netstruc.edge.mesh2d_edge_nodes(1,ie);
    i2=netstruc.edge.mesh2d_edge_nodes(2,ie);
    tdist(i1)=tdist(i1)+l(ie);
    tdist(i2)=tdist(i2)+l(ie);
    nedge(i1)=nedge(i1)+1;
    nedge(i2)=nedge(i2)+1;
end
nedge=max(nedge,1);
cellsize=tdist./nedge;

% Sort sample coordinates in x direction
[x,ind]=sort(x);
y=y(ind);
z=z(ind);

% Find grid points without elevation data
if ~isempty(xpol)
    inp=inpolygon(netstruc.node.mesh2d_node_x,netstruc.node.mesh2d_node_y,xpol,ypol);
else
    inp=zeros(1,length(netstruc.node.mesh2d_node_x))+1;
end
%% Set elevation in polygon to 1.0
%netstruc.node.mesh2d_node_z(~inp)=1;
netstruc.node.mesh2d_node_z(netstruc.node.mesh2d_node_z==-999)=NaN;

isn=find(isnan(netstruc.node.mesh2d_node_z) & inp);

xg=netstruc.node.mesh2d_node_x(isn);
yg=netstruc.node.mesh2d_node_y(isn);
cellsize=cellsize(isn);

znew=netstruc.node.mesh2d_node_z;

for ip=1:length(xg)

    xp=xg(ip);
    yp=yg(ip);
    dst=cellsize(ip);
    dst=dst*distfac;

    % Find 
    i1=find(x>=xp-dst,1,'first');
    i2=find(x<=xp+dst,1,'last');
    x1=x(i1:i2);
    y1=y(i1:i2);
    z1=z(i1:i2);
    
    i1=find(y1>=yp-dst & y1<=yp+dst);
    
    x1=x1(i1);
    y1=y1(i1);
    z1=z1(i1);
    
    dstt=sqrt((x1-xp).^2+(y1-yp).^2);
    inear=find(dstt<=dst);
    
    if length(inear)>=minpoints
        znew(isn(ip))=nanmean(z1(inear));
    end
    
end
