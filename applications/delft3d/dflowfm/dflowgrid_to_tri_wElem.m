function [tri,triConst,index]=dflowgrid_to_tri_wElem(NetElemNode,const);
%function [tri,triConst,index]=dflowgrid_to_tri(NetElemNode);
% Split cells into triangles, so they can be used in Matlab routines. Also
% distributes constituent in flow elements into the new triangular flow 
% elements defined by the triangles tri
% eg:
% const = ncread(modelFile,'sa1',[10 1 1],[1 inf 1]);
% NetElemNode = ncread(modelFile,'NetElemNode');
% [tri,triConst,index] = dflowgrid_to_tri(NetElemNode,const);
% trisurf(tri,NetNode_x,NetNode_y,0*NetNode_z,triConst);
% author: verlaan
% edited: schueder

n=size(NetElemNode,1);
NetElemNode(NetElemNode<0)=NaN; %replace dummy values
% const(const<0) = NaN;
count=sum(~isnan(NetElemNode),2); %number of netnodes per cell/flowElement

m4=sum(count==4); %numeber of cells with 4 nodes
m5=sum(count==5);
m6=sum(count==6);

index=1:1:n;
index4=find(count==4);
index5=find(count==5);
index6=find(count==6);

tri=zeros(n+m4+2*m5+3*m6,3); %reserve memory for additional triangles;
tri(1:n,1:3)=NetElemNode(1:n,1:3);
triConst=zeros(n+m4+2*m5+3*m6,1); %reserve memory for additional triangles;
triConst(1:n,1)=const(1:n,1);
% 4 nodes
offset=n;
tri(offset+(1:m4),1:3)=NetElemNode(index4,[1 3 4]);
triConst(offset+(1:m4),1)=const(index4,[1]);
index(offset+(1:m4))=index4;
offset=offset+m4;
%5 nodes
if(m5>0),
   tri(offset+(1:m5),1:3)=NetElemNode(index5,[1 3 4]);
   triConst(offset+(1:m5),1)=const(index5,[1]);
   index(offset+(1:m5))=index5;
   offset=offset+m5;
   tri(offset+(1:m5),1:3)=NetElemNode(index5,[1 4 5]);
   triConst(offset+(1:m5),1)=const(index5,[1]);
   index(offset+(1:m5))=index5;
   offset=offset+m5;
end;
%6 nodes
if(m6>0),
   tri(offset+(1:m6),1:3)=NetElemNode(index6,[1 3 4]);
   triConst(offset+(1:m6),1)=const(index6,[1]);

   index(offset+(1:m6))=index6;
   offset=offset+m6;
   tri(offset+(1:m6),1:3)=NetElemNode(index6,[1 4 5]);
   triConst(offset+(1:m6),1)=const(index6,[1]);

   index(offset+(1:m6))=index6;
   offset=offset+m6;
   tri(offset+(1:m6),1:3)=NetElemNode(index6,[1 5 6]);
   triConst(offset+(1:m6),1)=const(index6,[1]);

   index(offset+(1:m6))=index6;
end;

