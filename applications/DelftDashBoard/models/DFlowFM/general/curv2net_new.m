function [netStruc,circ]=curv2net_new(xg,yg,z)

%% 
debugmode = 1;

%% Nodes
ni=size(xg,1);
nj=size(xg,2);
[xz,yz]=getXZYZ(xg,yg);
% x0=reshape(xg,[1 ni*nj]);
% y0=reshape(yg,[1 ni*nj]);
% z0=reshape(z,[1 ni*nj]);
% x=x0(~isnan(x0));
% y=y0(~isnan(x0));
% z=z0(~isnan(x0));
% 
% netStruc.node.x=x;
% netStruc.node.y=y;
% netStruc.node.z=z;
% netStruc.node.n=length(x);

nnodes=0;
for ii=1:ni
    for jj=1:nj
        if ~isnan(xg(ii,jj))
            nnodes=nnodes+1;
            netStruc.node.x(1,nnodes)=xg(ii,jj);
            netStruc.node.y(1,nnodes)=yg(ii,jj);
            netStruc.node.z(1,nnodes)=z(ii,jj);
            nodenr(ii,jj)=nnodes;
        else
            nodenr(ii,jj)=NaN;
        end
    end
end
netStruc.node.n=nnodes;

%% Edges
if debugmode == 1;  disp('edges'); tic; end 

nlinks=0;
for ii=1:ni
    for jj=1:nj
        if jj<size(xg,2)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1))
                nlinks=nlinks+1;
%                netStruc.edge.NetLink(1,nlinks)=nodenr(ii,jj);
%                netStruc.edge.NetLink(2,nlinks)=nodenr(ii,jj+1);
                netStruc.edge.NetLink(nlinks,1)=nodenr(ii,jj);
                netStruc.edge.NetLink(nlinks,2)=nodenr(ii,jj+1);
%                linkType(nlinks,1)=2;
            end
        end
        if ii<size(xg,1)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii+1,jj))
                nlinks=nlinks+1;
%                netStruc.edge.NetLink(1,nlinks)=nodenr(ii,jj);
%                netStruc.edge.NetLink(2,nlinks)=nodenr(ii+1,jj);
                netStruc.edge.NetLink(nlinks,1)=nodenr(ii,jj);
                netStruc.edge.NetLink(nlinks,2)=nodenr(ii+1,jj);
%                linkType(nlinks,1)=2;
            end
        end
    end
end

if debugmode == 1;  toc; end 

%% Faces
if debugmode == 1; disp('faces');  tic; end 

nelems=0;
for ii=1:size(xg,1)-1
    for jj=1:size(xg,2)-1
        if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1)) && ~isnan(xg(ii+1,jj+1)) && ~isnan(xg(ii+1,jj))
            nelems=nelems+1;
            netStruc.face.FlowElem_x(1,nelems)=xz(ii,jj);
            netStruc.face.FlowElem_y(1,nelems)=yz(ii,jj);
            netStruc.face.FlowElemCont_x(:,nelems)=[xg(ii,jj);xg(ii+1,jj);xg(ii+1,jj+1);xg(ii,jj+1);NaN;NaN];
            netStruc.face.FlowElemCont_y(:,nelems)=[yg(ii,jj);yg(ii+1,jj);yg(ii+1,jj+1);yg(ii,jj+1);NaN;NaN];
            netStruc.face.NetElemNode(nelems,:)=[nodenr(ii,jj) nodenr(ii+1,jj) nodenr(ii+1,jj+1) nodenr(ii,jj+1) NaN NaN];
        end
    end
end

if debugmode == 1;  toc; end 

%% Find boundary links
if debugmode == 1; disp('links');  tic; end 


[bnd,circ,sections]=find_boundary_sections_on_regular_grid(xg,yg, z, 0);
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
    ilnk=find(squeeze(netStruc.edge.NetLink(:,1))==bndnode1(ibnd) & squeeze(netStruc.edge.NetLink(:,2))==bndnode2(ibnd));
    netStruc.bndLink(ibnd,1)=ilnk;
end

% new pointers for chopping up into triangles to be used in plotMap
[netStruc.tri,netStruc.map3,netStruc.ntyp] = patch2tri(netStruc.node.x,netStruc.node.y,netStruc.face.NetElemNode,'quiet',1);


if debugmode == 1;  toc; end 


% netStruc.nodeX=nodeX;
% netStruc.nodeY=nodeY;
% netStruc.nodeZ=nodeDepth;
% netStruc.linkNodes=linkNodes;
% netStruc.linkType=linkType;
% netStruc.elemNodes=elemNodes;
% netStruc.bndLink=bndLink;
