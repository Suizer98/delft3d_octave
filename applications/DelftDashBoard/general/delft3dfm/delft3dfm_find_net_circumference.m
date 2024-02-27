function circumference=delft3dfm_find_net_circumference(netstruc)

face=netstruc.face.mesh2d_face_nodes;
face(face<0)=0;
face(isnan(face))=0;

% Make sure face is at 6 rows long
face=[face;zeros(6-size(face,1),size(face,2))];

f1a=face(1,:);
f1b=face(2,:);
f1b(f1b==0)=f1a(f1b==0);
f1=[f1a;f1b];
imin=min(f1,[],1);
iok=find(imin>0);
f1=f1(1:2,iok);

f2a=face(2,:);
f2b=face(3,:);
f2b(f2b==0)=f1a(f2b==0);
f2=[f2a;f2b];
imin=min(f2,[],1);
iok=find(imin>0);
f2=f2(1:2,iok);

% f3=[];
% if size(face,1)>3
    f3a=face(3,:);
    f3b=face(4,:);
    f3b(f3b==0)=f1a(f3b==0);
    f3=[f3a;f3b];
    imin=min(f3,[],1);
    iok=find(imin>0);
    f3=f3(1:2,iok);
% end

% f4=[];
% if size(face,1)>4
    f4a=face(4,:);
    f4b=face(5,:);
    f4b(f4b==0)=f1a(f4b==0);
    f4=[f4a;f4b];
    imin=min(f4,[],1);
    iok=find(imin>0);
    f4=f4(1:2,iok);
% end

% f5=[];
% f6=[];
% if size(face,1)>5
    f5a=face(5,:);
    f5b=face(6,:);
    f5b(f5b==0)=f1a(f5b==0);
    f5=[f5a;f5b];
    imin=min(f5,[],1);
    iok=find(imin>0);
    f5=f5(1:2,iok);
    
    f6a=face(6,:);
    f6b=face(1,:);
    f6b(f6b==0)=f1a(f6b==0);
    f6=[f6a;f6b];
    imin=min(f6,[],1);
    iok=find(imin>0);
    f6=f6(1:2,iok);
% end

f=[f1 f2 f3 f4 f5 f6];
f=sort(f,1);
[u,m,n] = unique(f','rows');

% determine counts for each unique edge
counts = accumarray(n(:), 1);
% extract edges that only occurred once
O = u(counts==1,:);
O=O';

ntot=size(O,2)+1; % total number of boundary nodes
% nb=zeros(1,ntot);

nb(1)=O(1,1);
nb(2)=O(2,1);

ilast=2;
jlast=1;

for ix=3:ntot
    [ii,jj]=find(O==nb(ix-1));
    if ii(1)==ilast && jj(1)==jlast
        % already have this one, it's the other one
        isame=ii(2);
        jsame=jj(2);
    else
        isame=ii(1);
        jsame=jj(1);
    end
    if isame==1
        ilast=2;
    else
        ilast=1;
    end
    jlast=jsame;
    newindex=O(ilast,jlast);
    nb(ix)=O(ilast,jlast);
    if newindex==nb(1)
        % back where we started
        break
    end
end        

xx=netstruc.node.mesh2d_node_x(nb);
yy=netstruc.node.mesh2d_node_y(nb);

if poly_isclockwise(xx,yy)
    % Make it counter clockwise
    nb=fliplr(nb);
    xx=fliplr(xx);
    yy=fliplr(yy);
end

for ii=1:length(nb)
    inode=nb(ii);
    circumference.x(ii)=netstruc.node.mesh2d_node_x(inode);
    circumference.y(ii)=netstruc.node.mesh2d_node_y(inode);
    circumference.z(ii)=netstruc.node.mesh2d_node_z(inode);
    circumference.n(ii)=inode;
end
