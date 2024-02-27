function [w,iref]=mkmap(x1,y1,x2,y2);
 
sz1=size(x1);
sz2=size(x2,2);
 
in=zeros(sz2);
iref=zeros(4,sz2,2);
w=zeros(4,sz2);
 
xp(:,:,1)=x1(1:end-1,1:end-1);
xp(:,:,2)=x1(2:end,  1:end-1);
xp(:,:,3)=x1(2:end,  2:end  );
xp(:,:,4)=x1(1:end-1,2:end  );
yp(:,:,1)=y1(1:end-1,1:end-1);
yp(:,:,2)=y1(2:end,  1:end-1);
yp(:,:,3)=y1(2:end,  2:end  );
yp(:,:,4)=y1(1:end-1,2:end  );
 
xmin=min(xp,[],3);
ymin=min(yp,[],3);
xmax=max(xp,[],3);
ymax=max(yp,[],3);
 
xmin(xmin==0)=NaN;
ymin(ymin==0)=NaN;
 
for k=1:sz2;
    [m{k},n{k}]=find(xmin<=x2(k) & xmax>=x2(k) & ymin<=y2(k) & ymax>=y2(k));
    if ~isempty(m{k})
        for j=1:size(m{k},1);
            in(k)=inpolygon(x2(k),y2(k),xp(m{k}(j),n{k}(j),:),yp(m{k}(j),n{k}(j),:));
            if in(k)==1
                iref(1,k,1)=m{k}(j);
                iref(1,k,2)=n{k}(j);
                w(1,k)=0.25;
                iref(2,k,1)=i+1;
                iref(2,k,1)=m{k}(j)+1;
                iref(2,k,2)=n{k}(j);
                w(2,k)=0.25;
                iref(3,k,1)=m{k}(j)+1;
                iref(3,k,2)=n{k}(j)+1;
                w(3,k)=0.25;
                iref(4,k,1)=m{k}(j);
                iref(4,k,2)=n{k}(j)+1;
                w(4,k)=0.25;
            end
        end
    end
end
