function buq=sfincs_make_buq_grid_v01(x00,y00,nmax,mmax,dx,dy,rot,pol)

np        = nmax*mmax;
buq_n     = zeros(1,np);
buq_m     = zeros(1,np);
buq_level = zeros(1,np);

ib=0;
for m=1:mmax
    for n=1:nmax
        ib=ib+1;
        buq_n(ib)=n;
        buq_m(ib)=m;
        buq_level(ib)=0;
    end
end

npol=length(pol);    % number of polygons
if isempty(pol(1).x)
    npol=0;
end
for ipol=1:npol
    [buq_n,buq_m,buq_level]=buq_refine(buq_n,buq_m,buq_level,pol(ipol),x00,y00,dx,dy,rot);
end

% cosrot=cos(rot*180/pi);
% sinrot=sin(rot*180/pi);
% 
% nb=length(buq_n);
% 

% xg=zeros(5,nb);
% yg=zeros(5,nb);
% for ib=1:nb
%     iref=buq_level(ib);
%     dx1=dx*0.5^iref;
%     dy1=dy*0.5^iref;
%     xg(1,ib)=x00 + cosrot*((buq_m(ib)-1)*dx1) - sinrot*((buq_n(ib)-1)*dy1);
%     yg(1,ib)=y00 + sinrot*((buq_m(ib)-1)*dx1) + cosrot*((buq_n(ib)-1)*dy1);
%     xg(2,ib)=x00 + cosrot*((buq_m(ib)  )*dx1) - sinrot*((buq_n(ib)-1)*dy1);
%     yg(2,ib)=y00 + sinrot*((buq_m(ib)  )*dx1) + cosrot*((buq_n(ib)-1)*dy1);
%     xg(3,ib)=x00 + cosrot*((buq_m(ib)  )*dx1) - sinrot*((buq_n(ib)  )*dy1);
%     yg(3,ib)=y00 + sinrot*((buq_m(ib)  )*dx1) + cosrot*((buq_n(ib)  )*dy1);
%     xg(4,ib)=x00 + cosrot*((buq_m(ib)-1)*dx1) - sinrot*((buq_n(ib)  )*dy1);
%     yg(4,ib)=y00 + sinrot*((buq_m(ib)-1)*dx1) + cosrot*((buq_n(ib)  )*dy1);
%     xg(5,ib)=xg(1,ib);
%     yg(5,ib)=yg(1,ib);    
% end

% buq_mu1=zeros(1,nb);
% buq_mu2=zeros(1,nb);
% buq_md1=zeros(1,nb);
% buq_md2=zeros(1,nb);
% buq_nu1=zeros(1,nb);
% buq_nu2=zeros(1,nb);
% buq_nd1=zeros(1,nb);
% buq_nd2=zeros(1,nb);
% 
% % Find neighbors
% for ib=1:nb
% 
%     % Same level
% 
%     % Right
%     j=find(buq_level==buq_level(ib) & buq_m==buq_m(ib)+1 & buq_n==buq_n(ib));
%     if ~isempty(j)
%         buq_mu1(ib)=j;
%         buq_mu2(ib)=0;
%         buq_md1(j)=ib;
%         buq_md2(j)=0;
%     end
%     
%     % Above
%     j=find(buq_level==buq_level(ib) & buq_m==buq_m(ib) & buq_n==buq_n(ib)+1);
%     if ~isempty(j)
%         buq_nu1(ib)=j;
%         buq_nu2(ib)=0;
%         buq_nd1(j)=ib;
%         buq_nd2(j)=0;
%     end
%     
%     % Coarser (only possible if level>0)
%     if buq_level(ib)>0
%         
%         % Right
%         % Only possible for even numbers of m
%         if iseven(buq_m(ib))
%             if iseven(buq_n(ib))            
%                 j=find(buq_level==buq_level(ib)-1 & (buq_m==buq_m(ib)/2+1 & buq_n==buq_n(ib)/2));
%                 if ~isempty(j)
%                     buq_mu1(ib)=j;
%                     buq_mu2(ib)=0;                    
%                     buq_md2(j)=ib;
%                 end    
%             else
%                 j=find(buq_level==buq_level(ib)-1 & (buq_m==buq_m(ib)/2+1 & buq_n==(buq_n(ib)+1)/2));
%                 if ~isempty(j)
%                     buq_mu1(ib)=j;
%                     buq_mu2(ib)=0;                    
%                     buq_md1(j)=ib;
%                 end    
%             end            
%         end
%         
%         % Above
%         % Only possible for even numbers of n
%         if iseven(buq_n(ib))
%             if iseven(buq_m(ib))            
%                 j=find(buq_level==buq_level(ib)-1 & (buq_n==buq_n(ib)/2+1 & buq_m==buq_m(ib)/2));
%                 if ~isempty(j)
%                     buq_nu1(ib)=j;
%                     buq_nu2(ib)=0;                    
%                     buq_nd2(j)=ib;
%                 end    
%             else
%                 j=find(buq_level==buq_level(ib)-1 & (buq_n==buq_n(ib)/2+1 & buq_m==(buq_m(ib)+1)/2));
%                 if ~isempty(j)
%                     buq_nu1(ib)=j;
%                     buq_nu2(ib)=0;                    
%                     buq_nd1(j)=ib;
%                 end    
%             end            
%         end
%     end    
%         
%     % Finer
% 
%     % Right
%     j=find(buq_level==buq_level(ib)+1 & (buq_m==buq_m(ib)*2+1 & buq_n==buq_n(ib)*2-1));
%     if ~isempty(j)
%         buq_mu1(ib)=j;
%         buq_md1(j)=ib;
%         buq_md2(j)=0;
%     end    
%     j=find(buq_level==buq_level(ib)+1 & (buq_m==buq_m(ib)*2+1 & buq_n==buq_n(ib)*2  ));
%     if ~isempty(j)
%         buq_mu2(ib)=j;
%         buq_md1(j)=ib;
%         buq_md2(j)=0;
%     end
%         
%     % Above
%     j=find(buq_level==buq_level(ib)+1 & (buq_n==buq_n(ib)*2+1 & buq_m==buq_m(ib)*2-1));
%     if ~isempty(j)
%         buq_nu1(ib)=j;
%         buq_nd1(j)=ib;
%         buq_nd2(j)=0;
%     end    
%     j=find(buq_level==buq_level(ib)+1 & (buq_n==buq_n(ib)*2+1 & buq_m==buq_m(ib)*2  ));
%     if ~isempty(j)
%         buq_nu2(ib)=j;
%         buq_nd1(j)=ib;
%         buq_nd2(j)=0;
%     end
%     
% end

buq.x0=x00;
buq.y0=y00;
buq.dx=dx;
buq.dy=dy;
buq.rotation=rot;

buq.level=buq_level;
buq.m=buq_m;
buq.n=buq_n;
% buq.mu1=buq_mu1;
% buq.nu1=buq_nu1;
% buq.md1=buq_md1;
% buq.nd1=buq_nd1;
% buq.mu2=buq_mu2;
% buq.nu2=buq_nu2;
% buq.md2=buq_md2;
% buq.nd2=buq_nd2;


function [buq1_n,buq1_m,buq1_level]=buq_refine(buq0_n,buq0_m,buq0_level,pol,x00,y00,dx0,dy0,rot)

nb=length(buq0_n);

buq1_n=zeros(1,4*nb);
buq1_m=zeros(1,4*nb);
buq1_level=zeros(1,4*nb);

cosrot=cos(rot*180/pi);
sinrot=sin(rot*180/pi);

ib1=0;

for ib0=1:nb
    iref=buq0_level(ib0);
    dx=dx0*0.5^iref;
    dy=dy0*0.5^iref;
    xcen=x00 + cosrot*((buq0_m(ib0)-1)*dx+0.5*dx) - sinrot*((buq0_n(ib0)-1)*dy+0.5*dy);
    ycen=y00 + sinrot*((buq0_m(ib0)-1)*dx+0.5*dx) + cosrot*((buq0_n(ib0)-1)*dy+0.5*dy);
    inp=inpolygon(xcen,ycen,pol.x,pol.y);
    if inp
        % Point inside polygone: refine
        ib1=ib1+1;
        buq1_level(ib1)=buq0_level(ib0)+1;
        buq1_m(ib1)=buq0_m(ib0)*2-1;
        buq1_n(ib1)=buq0_n(ib0)*2-1;
        ib1=ib1+1;
        buq1_level(ib1)=buq0_level(ib0)+1;
        buq1_m(ib1)=buq0_m(ib0)*2-1;
        buq1_n(ib1)=buq0_n(ib0)*2;
        ib1=ib1+1;
        buq1_level(ib1)=buq0_level(ib0)+1;
        buq1_m(ib1)=buq0_m(ib0)*2;
        buq1_n(ib1)=buq0_n(ib0)*2-1;
        ib1=ib1+1;
        buq1_level(ib1)=buq0_level(ib0)+1;
        buq1_m(ib1)=buq0_m(ib0)*2;
        buq1_n(ib1)=buq0_n(ib0)*2;
    else    
        ib1=ib1+1;
        buq1_level(ib1)=buq0_level(ib0);
        buq1_m(ib1)=buq0_m(ib0);
        buq1_n(ib1)=buq0_n(ib0);
    end
end

buq1_n=buq1_n(1:ib1);
buq1_m=buq1_m(1:ib1);
buq1_level=buq1_level(1:ib1);



% 
% 
% np0=nmax*mmax; % number of points in original coarse grid
% npol=length(pol);    % number of polygons
% indices=1:np0;
% 
% % % Determine number of refinement steps (nrefpol) for each polygon
% % for ipol1=1:npol
% %     nrefpol(ipol1)=1;
% %     for ipol2=1:npol
% %         if ipol1~=ipol2
% %             inpol=find(inpolygon(pol(ipol1).x,pol(ipol1).y,pol(ipol2).x,pol(ipol2).y), 1);
% %             if ~isempty(inpol)
% %                 % polygon 1 is inside polygon 2
% %                 nrefpol(ipol1)=nrefpol(ipol1)+1;
% %             end
% %         end
% %     end
% % end
% 
% if isempty(pol)
%     nref=0;
% else
% nref=max(nrefpol); % maximum number of refinement steps
% end
% 
% cosrot=cos(rot*180/pi);
% sinrot=sin(rot*180/pi);
% 
% poly=[];
% % Reorder polygons
% for iref=1:nref 
%     j=find(nrefpol==iref);
% %    ipolref{iref}=j;  %
%     for k=1:length(j)
%         
%       xp  =   cosrot*(pol(j(k)).x - x00) + sinrot*(pol(j(k)).y - y00);
%       yp  = - sinrot*(pol(j(k)).x - x00) + cosrot*(pol(j(k)).y - y00);
%         
%         poly(iref).pol(k).x=xp;
%         poly(iref).pol(k).y=yp;
%     end
% end
% 
% % ind=zeros(np0,nref+2);
% 
% % Compute coordinates of original coarse grid
% % xc=zeros(np0,1);
% % yc=xc;
% % for ip=1:np0
% %     ind(ip,1)=ip;
% %     ind(ip,2)=0;
% %     m=floor((indices(ip)-1)/nmax)+1;
% %     n=indices(ip)-(m-1)*nmax;
% %     xc(ip)=x00+(m-0.5)*dx*cosphi-(n-0.5)*dy*sinphi;
% %     yc(ip)=y00+(m-0.5)*dx*sinphi+(n-0.5)*dy*cosphi;
% % end
% 
% np=0; % Total number of cells
% cells=[];
% for ip=1:np0
%     quadrant=[];
%     m0=floor((indices(ip)-1)/nmax)+1;
%     n0=indices(ip)-(m0-1)*nmax;
%     [cells,np]=sfincs_quadtree_refine(n0,m0,0,quadrant,dx,dy,poly,cells,np);    
% end
% 
% 
% % That was easy. Now we find the neighbors of each cell
% % (nmu1,nmu2,nmd1,nmd2,num1,num2,ndm1,ndm2).
% cells=sfincs_quadtree_neighbors(cells,nref,nmax,mmax);
% [cells,up,vp]=sfincs_quadtree_velocity_points(cells);
% 
% % 
% % 
% % 
% % 
% % % Loop through refinement steps
% % for iref=1:nref
% %     
% %     % Loop through polygons in this refinement step
% %     for j=1:length(ipolref{iref})
% %         
% %         ipol=ipolref{iref}(j);
% %         inpol=find(inpolygon(xc,yc,pol(ipol).x,pol(ipol).y));
% %         
% %         % First fill new array indnew
% %         indnew=zeros(length(inpol),4,nref+2);
% %         iold=zeros(1,length(inpol));
% %         for k=1:length(inpol)
% %             ip=inpol(k);
% %             iold(k)=ip;
% %             for iq=1:4
% %                 indnew(k,iq,:)=ind(ip,:);
% %                 indnew(k,iq,2)=iref; % New refinement level
% %                 indnew(k,iq,iref+2)=iq;
% %             end
% %         end
% %         
% %         % Now stick new cells into old ind array (should do this better to ensure data locality!!!!)
% %         for k=1:length(inpol)
% %             i1=iold(k);
% %             ind=[ind(1:i1-1,:);squeeze(indnew(k,:,:));ind(i1+1:end,:)];
% %             iold(k+1:end)=iold(k+1:end)+3;
% %         end
% %         
% %         [xg,yg,xc,yc]=sfincs_quadtree_getcoordinates(ind,x00,y00,dx,dy,nmax,mmax); % Must include rotation !!!
% %         
% %     end
% %     
% % end
% % 
% % cells.indices=ind(:,1);
% % cells.iref=ind(:,2);
% % cells.quadrants=ind(:,3:end);
% % 
% % links=[];
% % 
% % % And now for the flow links
% % 
% % np=size(ind,1);
% % 
% % % Determine m and n indices at this level and one level coarser
% % for ip=1:np
% %     ind0=ind(ip,:);
% %     [n0(ip,1),m0(ip,1)]=sfincs_quadtree_indices(ind0,nmax,mmax);
% %     % Coarser
% %     ind0=ind(ip,:);
% %     ind0(2)=ind0(2)-1;
% %     [ncrs(ip,1),mcrs(ip,1)]=sfincs_quadtree_indices(ind0,nmax,mmax);
% % end
% % 
% % ilink=0;
% % 
% % 
% % for ip=1:np
% %     
% %     cells.nmu(ip,1)=0;
% %     cells.num(ip,1)=0;
% %     cells.link_u(ip,1)=0;
% %     cells.link_u(ip,2)=0;
% %     cells.link_v(ip,1)=0;
% %     cells.link_v(ip,2)=0;
% %     
% %     % U points
% %     
% %     % Find neighbouring cell with same resolution
% %     inb=find(n0==n0(ip) & m0==m0(ip)+1 & ind(:,2)==ind(ip,2));
% %     if ~isempty(inb)
% %         % Neighbouring grid cell with same resolution found!
% %         ilink=ilink+1;
% %         links.cell_index(ilink,:)=[ip inb];
% %         links.uv(ilink,1)=0;
% %         cells.nmu(ip)=inb;
% %         cells.link_u(ip,1)=ilink;        
% %         cells.link_u(ip,2)=0;        
% %     else        % Find neighbouring cell with coarser resolution
% %         iref=ind(ip,2);
% %         inb=find(n0==ncrs(ip) & m0==mcrs(ip)+1 & ind(:,2)==iref-1);
% %         if ~isempty(inb)
% %             % Neighbouring grid cell with coarser resolution found!
% %             ilink=ilink+1;
% %             links.cell_index(ilink,:)=[ip inb];
% %             links.uv(ilink,1)=0;
% %             cells.nmu(ip)=inb;
% %             cells.link_u(ip,1)=ilink;        
% %             cells.link_u(ip,2)=0;        
% %         else
% %             % Find neighbouring cells (!) with higher resolution
% %             if iref<nref
% %                 inb=find(ncrs==n0(ip) & mcrs==m0(ip)+1 & ind(:,2)==iref+1 & (ind(:,iref+3)==1 | ind(:,iref+3)==3));
% %                 if ~isempty(inb)
% %                     % Neighbouring grid cells with higer resolution found!
% %                     ilink=ilink+1;
% %                     links.cell_index(ilink,:)=[ip inb(1)];
% %                     links.uv(ilink,1)=0;
% %                     cells.nmu(ip)=inb(1);
% %                     cells.link_u(ip,1)=ilink;        
% %                     ilink=ilink+1;
% %                     links.cell_index(ilink,:)=[ip inb(2)];
% %                     links.uv(ilink,1)=0;
% %                     cells.nmu(ip)=inb(2);
% %                     cells.link_u(ip,2)=ilink;        
% %                 end
% %             end
% %         end
% %     end
% %     
% %     % V points
% %     
% %     % Find neighbouring cell with same resolution
% %     inb=find(n0==n0(ip)+1 & m0==m0(ip) & ind(:,2)==ind(ip,2));
% %     if ~isempty(inb)
% %         % Neighbouring grid cell with same resolution found!
% %         ilink=ilink+1;
% %         links.cell_index(ilink,:)=[ip inb];
% %         links.uv(ilink,1)=1;
% %         cells.num(ip)=inb;
% %         cells.link_v(ip,1)=ilink;        
% %         cells.link_v(ip,2)=0;        
% %     else
% %         % Find neighbouring cell with coarser resolution
% %         iref=ind(ip,2);
% %         inb=find(n0==ncrs(ip)+1 & m0==mcrs(ip) & ind(:,2)==iref-1);
% %         if ~isempty(inb)
% %             % Neighbouring grid cell with coarser resolution found!
% %             ilink=ilink+1;
% %             links.cell_index(ilink,:)=[ip inb];
% %             links.uv(ilink,1)=1;
% %             cells.num(ip)=inb;
% %             cells.link_v(ip,1)=ilink;        
% %             cells.link_v(ip,2)=0;        
% %         else
% %             % Find neighbouring cells (!) with higher resolution
% %             if iref<nref
% %                 inb=find(ncrs==n0(ip)+1 & mcrs==m0(ip) & ind(:,2)==iref+1 & (ind(:,iref+3)==1 | ind(:,iref+3)==2));
% %                 if ~isempty(inb)
% %                     % Neighbouring grid cells with higer resolution found!
% %                     ilink=ilink+1;
% %                     links.cell_index(ilink,:)=[ip inb(1)];
% %                     links.uv(ilink,1)=1;
% %                     cells.num(ip)=inb(1);
% %                     cells.link_v(ip,1)=ilink;        
% %                     ilink=ilink+1;
% %                     links.cell_index(ilink,:)=[ip inb(2)];
% %                     links.uv(ilink,1)=1;
% %                     cells.num(ip)=inb(2);
% %                     cells.link_v(ip,2)=ilink;        
% %                 end
% %             end
% %         end
% %     end
% %     
% % end % loop
% % 
% % % Now loop through links and find upwind and downwind links
% % nlinks=ilink;
% % 
% %     links.nmu=zeros(nlinks,1);
% %     links.nmd=zeros(nlinks,1);
% %     links.num=zeros(nlinks,1);
% %     links.ndm=zeros(nlinks,1);
% % 
% % for ilink=1:nlinks
% %     
% %     if ilink==3
% %         shite=1
% %     end
% %     
% %     cell_index=links.cell_index(ilink,:);
% %     uv=links.uv(ilink,1);
% %     ic1=cell_index(1);
% %     ic2=cell_index(2);
% %     if uv==0
% %         % U points
% %         % NMU
% %         if cells.link_u(ic2,2)==0
% %             % 1 normal link to the right
% %             links.nmu(ilink)=cells.link_u(ic2,1);
% %         end
% %         % NMD
% %         nmd=find(links.cell_index(:,2)==ic1 & links.uv==uv); % link index of link to the left
% %         if ~isempty(nmd) && length(nmd)==1
% %             links.nmd(ilink)=nmd;
% %         end
% %     else
% %         % V points
% %         % NUM
% %         if cells.link_v(ic2,2)==0
% %             % 1 normal link to the right
% %             links.num(ilink)=cells.link_v(ic2,1);
% %         end
% %         % NDM
% %         ndm=find(links.cell_index(:,2)==ic1 & links.uv==uv); % link index of link to the left
% %         if ~isempty(ndm) && length(ndm)==1
% %             links.ndm(ilink)=ndm;
% %         end
% %         
% %     end
% %     
% % end
% % 
% % 
% % % Now find links linked to cell
% % for ip=1:np
% %     [ii,jj]=find(links.cell_index==ip);
% %     nfl=length(ii); % Number of flow links linked to this cell
% %     for ilink=1:nfl
% %         cells.link_index(ip,ilink)=ii(ilink);
% %         if jj(ilink)==1
% %             % Outflowing
% %             cells.link_direction(ip,ilink)=-1;
% %         else
% %             % Inflowing
% %             cells.link_direction(ip,ilink)=1;
% %         end
% %     end
% % end
% % 
