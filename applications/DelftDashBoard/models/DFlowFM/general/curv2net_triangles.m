function netStruc=curv2net_triangles(p, t,z)

% %% Get nodes 1
% nnodes=0;
% for ii=1:size(p,1)
%     nnodes=nnodes+1;
%     nodeX(nnodes,1)=p(ii,1);
%     nodeY(nnodes,1)=p(ii,2);
%     nodeDepth(nnodes,1)=z(ii);
%     nodenr(ii)=nnodes;
% end
%% Get nodes 2
nodeX = p(:,1);
nodeY = p(:,2);
nodeDepth = z;
nodenr = 1:length(z);

% %% netStruc links 1
% nlinks=0;
% for ii=1:size(t,1)
%     nlinks=nlinks+1;
%     linkNodes(nlinks,1)=t(ii,1);
%     linkNodes(nlinks,2)=t(ii,2);
%     linkType(nlinks,1)=2;
% end
% for ii=1:size(t,1)
%     nlinks=nlinks+1;
%     linkNodes(nlinks,1)=t(ii,2);
%     linkNodes(nlinks,2)=t(ii,3);
%     linkType(nlinks,1)=2;
% end
% 
% for ii=1:size(t,1)
%     nlinks=nlinks+1;
%     linkNodes(nlinks,1)=t(ii,3);
%     linkNodes(nlinks,2)=t(ii,1);
%     linkType(nlinks,1)=2;
% end

%% netStruc links2
number = length(t(:,1));
for ii = 1:3
    if ii == 1; i1 = 1;             i2 = number; end
    if ii == 2; i1 = 1+number;      i2 = number*2; end
    if ii == 3; i1 = 1+number*2;     i2 = number*3; end
    if ii == 1; linkNodes([i1:i2],1)=t(:,1);  linkNodes([i1:i2],2)=t(:,2); linkType([i1:i2],1)=2;       end
    if ii == 2; linkNodes([i1:i2],1)=t(:,2);  linkNodes([i1:i2],2)=t(:,3); linkType([i1:i2],1)=2;       end
    if ii == 3; linkNodes([i1:i2],1)=t(:,3);  linkNodes([i1:i2],2)=t(:,1); linkType([i1:i2],1)=2;       end
end

%% Finish
nelems=0;
netStruc.nodeX=nodeX;
netStruc.nodeY=nodeY;
netStruc.nodeZ=nodeDepth;
netStruc.linkNodes=linkNodes;
netStruc.linkType=linkType;
