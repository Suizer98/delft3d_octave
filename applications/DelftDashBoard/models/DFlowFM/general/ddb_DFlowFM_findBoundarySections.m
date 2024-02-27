function boundaries=ddb_DFlowFM_findBoundarySections(circumference,maxdist,minlev,cstype)

xx=circumference.x;
yy=circumference.y;
dd=circumference.z;

% First loop around circumference and find first wet point after dry point
for ii=1:length(xx)-1
    if dd(ii)>minlev && dd(ii+1)<=minlev
        % Point found
        ifirst=ii+1;
        xx=[xx(ifirst:end) xx(1:ifirst-1)];
        yy=[yy(ifirst:end) yy(1:ifirst-1)];
        dd=[dd(ifirst:end) dd(1:ifirst-1)];
        break
    end
end

% Now loop around and find sections in which depth exceed minlev
npol=1;
ip=0;
dpol(npol).index(1)=1;
for ii=2:length(xx)
    if dd(ii-1)>minlev && dd(ii)<=minlev
        % New section found
        npol=npol+1;
        ip=1;
        dpol(npol).index(ip)=ii;
        dpol(npol).x(ip)=xx(ii);
        dpol(npol).y(ip)=yy(ii);
    elseif dd(ii-1)<=minlev && dd(ii)<=minlev
        % New point along section found
        ip=ip+1;
        dpol(npol).index(ip)=ii;
        dpol(npol).x(ip)=xx(ii);
        dpol(npol).y(ip)=yy(ii);
    else
        % Do nothing
    end    
end

% Remove sections with just one point
dpol0=dpol;
npol0=npol;
dpol=[];
npol=0;
for ipol=1:npol0
    if length(dpol0(ipol).index)>1
        npol=npol+1;
        dpol(npol).index=dpol0(ipol).index;
        dpol(npol).x=dpol0(ipol).x;
        dpol(npol).y=dpol0(ipol).y;
    end    
end

% Now loop around circumference and find where sharp angles are made
dpol0=dpol;
npol0=npol;
dpol=[];
npol=0;
for ipol=1:npol0
    pathang=pathangle(dpol0(ipol).x,dpol0(ipol).y,cstype);
    npol=npol+1;
    ip=1;
    dpol(npol).x(ip)=dpol0(ipol).x(1);
    dpol(npol).y(ip)=dpol0(ipol).y(1);
    for ii=2:length(dpol0(ipol).x)
        ip=ip+1;
        dpol(npol).x(ip)=dpol0(ipol).x(ii);
        dpol(npol).y(ip)=dpol0(ipol).y(ii);
        dif = abs(angleDiff(pathang(ii),pathang(ii-1)));
        if dif>0.25*pi
            % New section found            
            ip=1;
            npol=npol+1;
            dpol(npol).x(ip)=dpol0(ipol).x(ii);
            dpol(npol).y(ip)=dpol0(ipol).y(ii);
        end
    end
end

% Now loop around polylines and cut up in sections smaller than maxdist
for ipol=1:npol
    dist=0;
    pathdist=pathdistance(dpol(ipol).x,dpol(ipol).y,cstype);
    nsec=1;
    boundaries(ipol).x(1)=dpol(ipol).x(1);
    boundaries(ipol).y(1)=dpol(ipol).y(1);
    nsec=nsec+1;
    for ii=2:length(dpol(ipol).x)
        dist=dist+pathdist(ii)-pathdist(ii-1);
        if dist>maxdist
            % New section found
            nsec=nsec+1;
            dist=0;
        end        
        boundaries(ipol).x(nsec)=dpol(ipol).x(ii);
        boundaries(ipol).y(nsec)=dpol(ipol).y(ii);
    end
end

function dif=angleDiff(phi1,phi2)
dif=mod(phi2-phi1,2*pi);
dif(dif>pi)=dif(dif>pi)-2*pi;

