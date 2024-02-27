function [bnd0,circ,sections]=find_boundary_sections_on_regular_grid(xg,yg,varargin)

if nargin==2
    % No depth specified
    zg=zeros(size(xg))+1;
    thresh=0;
else
    zg=varargin{1};
    thresh=varargin{2};
end

br=0;
% Find first boundary
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        if ~isnan(xg(ii,jj))
            ii1=ii;
            jj1=jj;
            br=1;
            break
        end
    end
    if br
        break
    end
end

% Now find boundaries going counter clockwise
dr='right';
nbnd=0;
ii=ii1;
jj=jj1;
while 1
    switch dr
        case 'right'
            drc{1}='down';
            drc{2}='right';
            drc{3}='up';
        case 'up'
            drc{1}='right';
            drc{2}='up';
            drc{3}='left';
        case 'left'
            drc{1}='up';
            drc{2}='left';
            drc{3}='down';
        case 'down'
            drc{1}='left';
            drc{2}='down';
            drc{3}='right';
    end
    br=0;
    for idr=1:3
        switch drc{idr}
            case{'right'}
                if ii<size(xg,1)
                    if ~isnan(xg(ii+1,jj))
                        nbnd=nbnd+1;
                        ii2=ii+1;
                        jj2=jj;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'up'}
                if jj<size(xg,2)
                    if ~isnan(xg(ii,jj+1))
                        nbnd=nbnd+1;
                        ii2=ii;
                        jj2=jj+1;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'left'}
                if ii>1
                    if ~isnan(xg(ii-1,jj))
                        nbnd=nbnd+1;
                        ii2=ii-1;
                        jj2=jj;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'down'}
                if jj>1
                    if ~isnan(xg(ii,jj-1))
                        nbnd=nbnd+1;
                        ii2=ii;
                        jj2=jj-1;
                        dr=drc{idr};
                        br=1;
                    end
                end
        end
        if br
            break
        end
    end
    switch dr
        case{'up','right'}
            bnd0(nbnd).m1=ii;
            bnd0(nbnd).n1=jj;
            bnd0(nbnd).m2=ii2;
            bnd0(nbnd).n2=jj2;
        case{'down','left'}
            bnd0(nbnd).m1=ii2;
            bnd0(nbnd).n1=jj2;
            bnd0(nbnd).m2=ii;
            bnd0(nbnd).n2=jj;
    end
    
    bnd(nbnd).m1=ii;
    bnd(nbnd).n1=jj;
    bnd(nbnd).m2=ii2;
    bnd(nbnd).n2=jj2;

    ii=ii2;
    jj=jj2;
    if ii2==ii1 && jj2==jj1
        % Went around, so break
        break
    end
end

%% Now determine grid circumference
for ib=1:length(bnd)
    xb(ib)=xg(bnd(ib).m1,bnd(ib).n1);
    yb(ib)=yg(bnd(ib).m1,bnd(ib).n1);
    zb(ib)=zg(bnd(ib).m1,bnd(ib).n1);
    m(ib)=bnd(ib).m1;
    n(ib)=bnd(ib).n1;
end
xb(end+1)=xg(bnd(end).m2,bnd(end).n2);
yb(end+1)=yg(bnd(end).m2,bnd(end).n2);
zb(end+1)=zg(bnd(end).m2,bnd(end).n2);
m(end+1)=bnd(end).m2;
n(end+1)=bnd(end).n2;

%% Now find boundary sections along which the depth exceeds threshold value
% Find first point after dry point
% ifirstwet=[];
ifirstwet=find(zb<thresh,1,'first');
if isempty(ifirstwet)
    ifirstwet=1;
end
if ifirstwet==length(xb)
    ifirstwet=1;
end

% Now start looking for first wet point
xb=[xb(ifirstwet:end) xb(1:ifirstwet-1)];
yb=[yb(ifirstwet:end) yb(1:ifirstwet-1)];
zb=[zb(ifirstwet:end) zb(1:ifirstwet-1)];
m=[m(ifirstwet:end) m(1:ifirstwet-1)];
n=[n(ifirstwet:end) n(1:ifirstwet-1)];

% Now find sections with consecutive points that exceed thresh
nsec=0;
sections=[];
findnewsection=1;
for ib=1:length(xb)
    if findnewsection
        if zb(ib)<thresh
            % New section found
            findnewsection=0;
            nsec=nsec+1;
            np=1;
            sections(nsec).x(np)=xb(ib);
            sections(nsec).y(np)=yb(ib);
            sections(nsec).z(np)=zb(ib);
            sections(nsec).m(np)=m(ib);
            sections(nsec).n(np)=n(ib);
        else
            % No new section found yet, so continue ...
        end
    else
        if zb(ib)>thresh
            % End of section found
            findnewsection=1;
        else
            np=np+1;
            sections(nsec).x(np)=xb(ib);
            sections(nsec).y(np)=yb(ib);
            sections(nsec).z(np)=zb(ib);
            sections(nsec).m(np)=m(ib);
            sections(nsec).n(np)=n(ib);
        end        
    end    
end

% Subdivide sections in case of sharp changes in orientation
% First find the sharp changes

nsec2=0;

for isec=1:nsec
    
    n=1;
    istart=[];
    iend=[];
    istart(n)=1;
    iend(n)=length(sections(isec).x);

    for ip=1:length(sections(isec).x)-1
        x1=sections(isec).x(ip);
        y1=sections(isec).y(ip);
        x2=sections(isec).x(ip+1);
        y2=sections(isec).y(ip+1);
        angle=atan2(y2-y1,x2-x1);
        if ip>1
            dang=mod(angle-lastangle,2*pi);
            if dang>pi/4 && dang<1.5*pi
                % Sharp angle found
                iend(n)=ip;
                n=n+1;
                istart(n)=ip;
                iend(n)=length(sections(isec).x);
            end
        end
        lastangle=angle;
    end

    for iisec=1:n
        nsec2=nsec2+1;
        sections2(nsec2).x=sections(isec).x(istart(iisec):iend(iisec));
        sections2(nsec2).y=sections(isec).y(istart(iisec):iend(iisec));
    end
    
end
sections=sections2;

circ.x=xb;
circ.y=yb;
circ.z=zb;
circ.m=m;
circ.n=n;

