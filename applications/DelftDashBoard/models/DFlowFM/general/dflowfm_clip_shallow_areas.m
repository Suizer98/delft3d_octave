function netstruc1=dflowfm_clip_shallow_areas(netstruc,mindep, type, varargin)

xpol=[];
ypol=[];

if ~isempty(varargin)
    xpol=varargin{1};
    ypol=varargin{2};
end

x=netstruc.node.mesh2d_node_x;
y=netstruc.node.mesh2d_node_y;
z=netstruc.node.mesh2d_node_z;

nz1=length(z)+1;
z(nz1)=999;

netlink=netstruc.edge.mesh2d_edge_nodes;
netelemnode=netstruc.face.mesh2d_face_nodes;
ncol=size(netelemnode,1);

netelemnode(isnan(netelemnode))=nz1;
netelemnode(netelemnode==0)=nz1;

% Compute mean depth in cell centres
zz=z(netelemnode);

zzmin=min(zz,[],1);

if strcmp(type, 'max')
    imin=find(zzmin<mindep);
elseif strcmp(type, 'min')
    imin=find(zzmin>mindep);
end

if ~isempty(xpol)
    inpol=inpolygon(x,y,xpol,ypol);
else
    inpol=zeros(size(x))+1;
end

netelemnode(netelemnode==nz1)=NaN;

% Now
inp=false(size(x));
for ii=1:length(imin)
    for jj=1:ncol
        if netelemnode(jj,imin(ii))<nz1 
            ind=netelemnode(jj,imin(ii));
            if inpol(ind)
                inp(ind)=true;
            end
        end
    end
end
inp=~inp;

node1.mesh2d_node_x=netstruc.node.mesh2d_node_x(~inp);
node1.mesh2d_node_y=netstruc.node.mesh2d_node_y(~inp);
node1.mesh2d_node_z=netstruc.node.mesh2d_node_z(~inp);
node1.n=sum(inp);

n=0;
for ii=1:length(x)
    if ~inp(ii)
        n=n+1;
        ind(ii)=n;
    else
        ind(ii)=0;
    end
end

n=0;
for ii=1:size(netlink,2)
    if ~inp(netlink(1,ii)) && ~inp(netlink(2,ii))
        % both points active
        n=n+1;
        netlink1(1,n)=ind(netlink(1,ii));
        netlink1(2,n)=ind(netlink(2,ii));
    end
end

ncol=size(netelemnode,1);
n=0;
for ii=1:size(netelemnode,2)
    netelemtmp=squeeze(netelemnode(:,ii));
    % Remove NaNs
    netelemtmp=netelemtmp(~isnan(netelemtmp));
    inptmp=inp(netelemtmp);
    % Check if all surrounding points are active
    if all(~inptmp)
        %    if ~inp(netelemnode(ii,1)) && ~inp(netelemnode(ii,2)) && ~inp(netelemnode(ii,3)) && ~inp(netelemnode(ii,4)) && ~inp(netelemnode(ii,5)) && ~inp(netelemnode(ii,6))
        % All surrounding points active
        n=n+1;
        for j=1:ncol
            if ~isnan(netelemnode(j,ii))
                netelemnode1(j,n)=ind(netelemnode(j,ii));
            else
                netelemnode1(j,n)=NaN;
            end
        end
    end
end

netstruc1=netstruc;
netstruc1.node=node1;
netstruc1.edge.mesh2d_edge_nodes=netlink1;
netstruc1.face.mesh2d_face_nodes=netelemnode1;
