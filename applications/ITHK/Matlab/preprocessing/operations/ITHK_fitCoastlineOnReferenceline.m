function [Y1new,idY1,Xcoast_new,Ycoast_new,Xcoast_old,Ycoast_old]= fitCoastlineOnReferenceline(XYref,XYcoast)
%function Y1 = fitCoastlineOnReferenceline(XYref,XYcoast)
%
% INPUT:
%    XYref     Array [Nx2] with reference line coordinates
%    XYcoast   Array [Nx2] with coastline coordinates
%
% OUTPUT:
%    Y1     Cross-shore distance to coastline (along the normal of the reference line)
%
% Example:
% Y1 = fitCoastlineOnReferenceline([Xref,Yref],[Xcoast,Ycoast]);

Xr = XYref(:,1);
Yr = XYref(:,2);
Xc = XYcoast(:,1);
Yc = XYcoast(:,2);

% dx,dy values
dx=Xr(2:end)-Xr(1:end-1); %for line in-between each reference point
dy=Yr(2:end)-Yr(1:end-1);
dxR=[dx(1);(dx(2:end)+dx(1:end-1));dx(end)]/2; %averaged for each reference point
dyR=[dy(1);(dy(2:end)+dy(1:end-1));dy(end)]/2;

Y1=[];
count = 0;
for ii=1:length(Xr)
    %% Find in-between which two Xc points the normal of the reference
    %% point intersects
    scalefactor=1;
    P1 = [Xr(ii)-scalefactor*dxR(ii);Yr(ii)-scalefactor*dyR(ii)];
    P2 = [Xr(ii)+scalefactor*dxR(ii);Yr(ii)+scalefactor*dyR(ii)];
    
    Xc_proj=[];Yc_proj=[];uc=[];
    for jj=1:length(Xc)
        P3 = [Xc(jj);Yc(jj)];
        [P,L,u]=pointTOline(P1,P2,P3);
        Xc_proj(jj) = P(1);
        Yc_proj(jj) = P(2);
        uc(jj)      = u;
        if  Xc_proj(jj)>=P1(1) && Xc_proj(jj)<=P2(1) && Yc_proj(jj)>=P1(2) && Yc_proj(jj)<=P2(2)
            CinR(ii,jj) = 1;
        else
            CinR(ii,jj) = 0;
        end
    end

    %% find two points on coastline closest to reference line point
    % Check with margin of 0.5 on both sides (usually point will be at 0.5)
    id1=find(uc<=1);
    id2=find(uc>=0);
    
%     if isempty(id1) || isempty(id2)
%         [usorted, id] = sort(abs(uc-0.5));
%         id=id(1:2);
%     else
%        id(1)=id1(find(min(abs(uc(id1)-0.5))));
%        id(2)=id2(find(min(abs(uc(id2)-0.5))));
%        %id(1)=id1(find(abs(uc(id1)-0.5)==min(abs(uc(id1)-0.5))));
%        %id(2)=id2(find(abs(uc(id2)-0.5)==min(abs(uc(id2)-0.5))));
%     end
    
    
    if ~isempty(id1) && ~isempty(id2) %Xc point is in between Xr points
        % id1 & id2 may not be equal
        if id2(1)==id1(1)
            try
                id2=id2(2);
            catch
                id2=[];
            end
        end
        
        count = count+1;
       id(1)=id1(find(min(abs(uc(id1)-0.5))));
       id(2)=id2(find(min(abs(uc(id2)-0.5))));
       %id(1)=id1(find(abs(uc(id1)-0.5)==min(abs(uc(id1)-0.5))));
       %id(2)=id2(find(abs(uc(id2)-0.5)==min(abs(uc(id2)-0.5))));
    
    
    %% Determine the crossing point of the normal of the reference line (at
    %% grid point ii, defined by -dxR and dyR) and the line between the two 
    %% selected points of the coastline ldb (defined by dxC and dyC).
    dxC = Xc(id(2))-Xc(id(1));
    dyC = Yc(id(2))-Yc(id(1));

    %% line normal to reference point
    a = -dxR(ii)/dyR(ii);
    b = -a*Xr(ii)+Yr(ii);
    %% line normal to reference point
    c = dyC/dxC;
    d = -c*Xc(id(1))+Yc(id(1));

    %% determine projected reference point on coastline
    if dyR(ii)==0
        %special case dy(referenceline)=0 -> x=Xr
        x=Xr(ii);
        y=c*x+d;
    elseif dxC==0
        %special case dx(coastline)=0 -> x=Xc
        x=Xc(id(1));
        y=a*x+b;
    elseif dxR(ii)==0
        %special case dx(referenceline)=0 -> y=Yr
        y=Yr(ii);
        x=(y-d)/c;
    elseif dyC==0
        %special case dy(coastline)=0 -> y=Yc
        y=Yc(id(1));
        x=(y-b)/a;
    elseif a~=c && a~=d % && a~=-c
        x = (d-b)/(a-c);
        y = (b*c/a-d)/(c/a-1);
    else
        fprintf('Warning : Lines run parallel or 90 degrees oblique! (approximating Y1 distance)')
        x=mean([Xc(id(1));Xc(id(1))]);
        y=mean([Yc(id(1));Yc(id(1))]);
    end
    Xcoast_new(count)= x;Ycoast_new(count)= y;
    Xcoast_old(count)= Xr(ii);Ycoast_old(count)= Yr(ii);
    Y1(count)=sqrt((Xr(ii)-x).^2+(Yr(ii)-y).^2);
    idY1(count)=ii;
    end

    %% plot data
%     figure;
%     plot([P1(1);P2(1)],[P1(2);P2(2)],'r*-');hold on;
%     plot(P3(1),P3(2),'ks');
%     axis equal;plot(Xc(id),Yc(id),'c+');
%     plot(Xc_proj(id),Yc_proj(id),'g*');
%     xline1=[Xr(ii),x];yline1=a*xline1+b; plot(xline1,yline1,'k:')
%     xline2=[Xc(id(1)),Xc(id(2))];yline2=c*xline2+d; plot(xline2,yline2,'k--');
%     legend(['orientation of reference line at gridpnt ',num2str(ii)],...
%            'nearest location on coastline','coastline points',...
%            'projection on reference line','normal of reference line');
end
% Find ids of points on ref line corresponding to coastline points and interpolate between these points (for smoothing)
for jj=1:length(Xc)
    if      jj==1
            closest_id(jj)=idY1(1);
    elseif  jj==length(Xc)
            closest_id(jj)=idY1(end);
    elseif  ~isempty(CinR(:,jj))
            closest_id(jj)=find(CinR(:,jj)~=0,1,'first');
    else    dist = sqrt((Xr-Xc(jj)).^2+(Yr-Yc(jj)).^2);
            closest_id(jj)=find(dist==min(dist));
    end
    idinY1(jj)=find(idY1==closest_id(jj));
end
%
Y1new = interp1(Xr(unique(closest_id)),Y1(unique(idinY1))',Xr(idY1));
% Plot figure
%figure();plot(Xr(closest_id),Y1(idinY1)','r*');hold on;plot(Xr(idY1),Y1new,'k-');