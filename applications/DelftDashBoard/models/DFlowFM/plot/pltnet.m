function p=pltnet(netStruc)

% if size(netStruc.edge.NetLink,1)==2
%     % transpose
%     netStruc.edge.NetLink=netStruc.edge.NetLink';
% end



i1=netStruc.edge.mesh2d_edge_nodes(1,:);
i2=netStruc.edge.mesh2d_edge_nodes(2,:);
x=zeros(3,length(i1));
x(x==0)=NaN;
y=x;
x(1,:)=netStruc.node.mesh2d_node_x(i1);
y(1,:)=netStruc.node.mesh2d_node_y(i1);
x(2,:)=netStruc.node.mesh2d_node_x(i2);
y(2,:)=netStruc.node.mesh2d_node_y(i2);

x=reshape(x,[1 3*size(x,2)]);
y=reshape(y,[1 3*size(y,2)]);

p=plot(x,y);

% i1=netStruc.edge.NetLink(:,1);
% i2=netStruc.edge.NetLink(:,2);
% x=zeros(3,length(i1));
% x(x==0)=NaN;
% y=x;
% x(1,:)=netStruc.node.x(i1);
% y(1,:)=netStruc.node.y(i1);
% x(2,:)=netStruc.node.x(i2);
% y(2,:)=netStruc.node.y(i2);
% 
% x=reshape(x,[1 3*size(x,2)]);
% y=reshape(y,[1 3*size(y,2)]);
% 
% p=plot(x,y);
