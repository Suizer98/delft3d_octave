function [xx,yy,dd]=findNetCircumference(netStruc)

bndLink=netStruc.bndLink;
linkNodes=netStruc.linkNodes;
nodeX=netStruc.nodeX;
nodeY=netStruc.nodeY;
nodeDepth=netStruc.nodeZ;

bndLinkUsed=zeros(size(bndLink));

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
%                iAcBnd=ibnd;
                ibr=1;
                bndNodes(nn)=node2;
            end
        end
        if ibr
            break
        end
    end
    if node2==linkNodes(bndLink(1),2)
        break
    end
end

for ii=1:length(bndNodes)
    iNode=bndNodes(ii);
    xx(ii)=nodeX(iNode);
    yy(ii)=nodeY(iNode);
    dd(ii)=nodeDepth(iNode);
end
