function boundaries=findBoundarySections(netStruc,maxdist,minlev,cstype)

bndLink=netStruc.bndLink;
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
    xx(ii)=nodeX(iNode);
    yy(ii)=nodeY(iNode);
    dd(ii)=nodeDepth(iNode);
end

% And now determine boundary sections
npol=0;
iac=0;
% First find separate polylines that are below minlev and also don't make
% sharp angles
for ii=1:length(xx)
    if ~iac && dd(ii)<=minlev
        if ii<length(xx)
            if dd(ii+1)<=minlev
                % New section started (depth in ii and ii+1 greater than minlev)
                npol=npol+1;
                iac=1;
                iPol1(npol)=ii;
            end
        end
    end
    if iac==1
        if ii==length(xx)
            % End of all points found
            iac=0;
            iPol2(npol)=ii;
        elseif dd(ii+1)>minlev
            % End of section found
            iac=0;
            iPol2(npol)=ii;
        end
    end
end

% Now find sections shorter than maxdist

pathdist=pathdistance(xx,yy,cstype);
pathang=pathangle(xx,yy,cstype);

for ipol=1:npol
    ifirst=iPol1(ipol);
    ilast=iPol2(ipol);
    i1=ifirst;
    np=1;
    polln(ipol).ip(np)=ifirst;
    for j=ifirst:ilast
        if j==ilast
            % Last point found
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        elseif abs(pathang(j)-pathang(max(1,j-1)))>pi/20
            % Next angle exceeds 10 degrees
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        elseif pathdist(j)-pathdist(i1)>maxdist
            % Max distance reached at next point 
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        end
    end
end

% Put everything in structure boundaries
for ipol=1:length(polln)
    for ip=1:length(polln(ipol).ip)
        boundaries(ipol).x(ip)=xx(polln(ipol).ip(ip));
        boundaries(ipol).y(ip)=yy(polln(ipol).ip(ip));
    end
end

