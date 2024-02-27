function netStruc=curv2net(xg,yg,z)

%% Get nodes
ni=size(xg,1);
nj=size(xg,2);
nnodes=0;
x0=reshape(xg,[1 ni*nj]);
y0=reshape(yg,[1 ni*nj]);
z0=reshape(z,[1 ni*nj]);
x=x0(~isnan(x0));
y=y0(~isnan(x0));
z=z0(~isnan(x0));

netStruc.node.x=x;
netStruc.node.y=y;
netStruc.node.z=z;
netStruc.node.n=length(x);

% for ii=1:size(xg,1)
%     for jj=1:size(xg,2)
%         if ~isnan(xg(ii,jj))
%             nnodes=nnodes+1;
%             nodeX(nnodes,1)=xg(ii,jj);
%             nodeY(nnodes,1)=yg(ii,jj);
%             nodeDepth(nnodes,1)=z(ii,jj);
%             nodenr(ii,jj)=nnodes;
%         else
%             nodenr(ii,jj)=NaN;
%         end
%     end
% end

%% netStruc links
nlinks=0;
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        if jj<size(xg,2)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1))
                nlinks=nlinks+1;
                linkNodes(nlinks,1)=nodenr(ii,jj);
                linkNodes(nlinks,2)=nodenr(ii,jj+1);
                linkType(nlinks,1)=2;
            end
        end
        if ii<size(xg,1)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii+1,jj))
                nlinks=nlinks+1;
                linkNodes(nlinks,1)=nodenr(ii,jj);
                linkNodes(nlinks,2)=nodenr(ii+1,jj);
                linkType(nlinks,1)=2;
            end
        end
    end
end

%% Elements
nelems=0;
for ii=1:size(xg,1)-1
    for jj=1:size(xg,2)-1
        if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1)) && ~isnan(xg(ii+1,jj+1)) && ~isnan(xg(ii+1,jj))
            nelems=nelems+1;
            elemNodes(nelems,1)=nodenr(ii,jj);
            elemNodes(nelems,2)=nodenr(ii,jj+1);
            elemNodes(nelems,3)=nodenr(ii+1,jj+1);
            elemNodes(nelems,4)=nodenr(ii+1,jj);
        end
    end
end

%% Find boundary links
bnd=find_boundary_sections_on_regular_grid(xg,yg, z, 0);
nbnd=length(bnd);
for ibnd=1:nbnd
    ii1=bnd(ibnd).m1;
    jj1=bnd(ibnd).n1;
    ii2=bnd(ibnd).m2;
    jj2=bnd(ibnd).n2;
    bndnode1(ibnd)=nodenr(ii1,jj1);
    bndnode2(ibnd)=nodenr(ii2,jj2);
end
    

% All boundaries found, now check with which boundaries they match
for ibnd=1:nbnd
    ilnk=find(squeeze(linkNodes(:,1))==bndnode1(ibnd) & squeeze(linkNodes(:,2))==bndnode2(ibnd));
    bndLink(ibnd,1)=ilnk;
end

netStruc.nodeX=nodeX;
netStruc.nodeY=nodeY;
netStruc.nodeZ=nodeDepth;
netStruc.linkNodes=linkNodes;
netStruc.linkType=linkType;
netStruc.elemNodes=elemNodes;
netStruc.bndLink=bndLink;
