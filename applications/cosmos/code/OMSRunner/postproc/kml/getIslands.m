function [innerisland,outerisland,vv]=getIslands(x,y,z,levs)

innerisland{1}=[];
outerisland{1}=[];
vv(1)=NaN;

figure(999);
set(gcf,'Visible','off');

z0=z;
z=max(z,levs(1));
z=min(z,levs(end));
z(isnan(z0))=NaN;
xmean=mean(x(isfinite(x)));
ymean=mean(y(isfinite(y)));
z(isnan(x))=NaN;
x(isnan(x))=xmean;
y(isnan(y))=ymean;

if isnan(max(max(z)))
    z=zeros(size(z));
end

if max(max(z))==min(min(z))
    % Data is constant, add some scatter
    rnd=rand(size(z));
    z=z+rnd*0.001;
end

[c,h]=contourf(x,y,z,levs);

ch=get(h,'Children');
nch=length(ch);

for i=1:length(ch)
    v(i)=get(ch(i),'CData');
    xx{i}=get(ch(i),'XData');
    yy{i}=get(ch(i),'YData');
    np(i)=length(xx{i});
    xmin(i)=min(xx{i});
    xmax(i)=max(xx{i});
    ymin(i)=min(yy{i});
    ymax(i)=max(yy{i});
end

close(999)

% tic
for i=1:nch
%     disp(['a: processing ' num2str(i) ' of ' num2str(nch)]);
    inp{i}=[];
    innerisland{i}=[];
    nin=0;
    for j=1:nch
        if i~=j
            xp1=xx{i};
            xp2=xx{j};
            yp1=yy{i};
            yp2=yy{j};
            inpol=0;
            if xmin(j)>=xmin(i) && xmax(j)<=xmax(i)
                if ymin(j)>=ymin(i) && ymax(j)<=ymax(i)
                    %                     for k=1:length(xp2)
                    if inpolygon(xp2(1),yp2(1),xp1,yp1)
                        %                    inpol=all(inpolygon(xp2,yp2,xp1,yp1));
                        inpol=1;
                    end
                    %                     end
                end
            end
            if inpol
                nin=nin+1;
                inp{i}(nin)=j;
            end
        end
    end
end
% toc

for i=1:nch
    inneris{i}=[];
end

for i=1:nch
%     disp(['b: processing ' num2str(i) ' of ' num2str(nch)]);
    nrin=[];
    if ~isempty(inp{i})
        inner=ones(1,length(inp{i}));
        % Inner island(s) in this polygon
        for j=1:length(inp{i})
            for k=1:length(inp{i})
                if j~=k
                iin1=inp{i}(j);
                iin2=inp{i}(k);
                if xmin(iin1)>=xmin(iin2) && xmax(iin1)<=xmax(iin2)
                    if ymin(iin1)>=ymin(iin2) && ymax(iin1)<=ymax(iin2)
                        % iin1 inside iin2
                        inner(j)=0;
                    end
                end
                end
            end
        end
        for j=1:length(inner)
            if inner(j)==1
                inneris{i}=[inneris{i} inp{i}(j)];
            end
        end
    end
end

k=0;
for i=1:nch
%     disp(['c: processing ' num2str(i) ' of ' num2str(nch)]);

    if ~isnan(v(i))
        k=k+1;
        vv(k)=v(i);
        outerisland{k}.x=xx{i};
        outerisland{k}.y=yy{i};
        for j=1:length(inneris{i})
            innerisland{k}(j).x=xx{inneris{i}(j)};
            innerisland{k}(j).y=yy{inneris{i}(j)};
        end
        
        % Inner islands for nan values
        for j=1:length(inp{i})
            iin1=inp{i}(j);
            if isnan(v(iin1))
                % Check if it's completely within existing inner island
                xn=xx{iin1};
                yn=yy{iin1};
                addinner=1;
                for n=1:length(innerisland{k})
                    if all(inpolygon(xn,yn,innerisland{k}(n).x,innerisland{k}(n).y));
                        addinner=0;
                    end
                end
                if addinner
                    nl=length(innerisland{k});
                    innerisland{k}(nl+1).x=xn;
                    innerisland{k}(nl+1).y=yn;
                    
                end
            end
        end
        
        
        
    end
end

