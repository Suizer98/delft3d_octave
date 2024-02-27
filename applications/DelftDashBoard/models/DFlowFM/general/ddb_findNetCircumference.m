function circumference=ddb_findNetCircumference(netStruc)

bndLink=netStruc.face.BndLink;
linkNodes=netStruc.edge.NetLink';
nodeX=netStruc.node.x;
nodeY=netStruc.node.y;
nodeDepth=netStruc.node.z;

bndLinkUsed=zeros(size(bndLink));
bndLinkUsed(1)=1;

% Finds boundary points

% Start with first boundary link
node2=linkNodes(bndLink(1),2);

bndNodes(1)=linkNodes(bndLink(1),1);
bndNodes(2)=node2;
nn=2;

nit=0;
while 1
    nit=nit+1;
    if nit>2*length(bndLink)
        break
    end
    % Find links connected to node2
    [ilinks,dummy]=find(linkNodes==node2);
    % And now find the next link that is also a boundary link and that contains
    % node2
    ibr=0;
    %

    for k=1:length(ilinks)
        
        ilnk=ilinks(k);

        
        % Find boundary links that match this link
        ibnd=find(bndLink==ilnk);
        if ~isempty(ibnd)
            % This is a boundary link!
            % Check if this is not the present link
            % Check if this link has nt already been indentified
            if ~bndLinkUsed(ibnd)
                bndLinkUsed(ibnd)=1;
                nn=nn+1;
                % Next boundary section found
                if node2==linkNodes(ilnk,1)
                    node2=linkNodes(ilnk,2);
                else
                    node2=linkNodes(ilnk,1);
                end
                ibr=1;
                bndNodes(nn)=node2;
            end
        end
        if ibr
            break
        end
    end
    if ibr==0
        % Did not find next node!!!!
        break
    end
    if node2==linkNodes(bndLink(1),2)
        break
    end
end

for ii=1:length(bndNodes)
    iNode=bndNodes(ii);
    circumference.x(ii)=nodeX(iNode);
    circumference.y(ii)=nodeY(iNode);
    circumference.z(ii)=nodeDepth(iNode);
    circumference.n(ii)=iNode;
end
