function nsrc=ddb_src2src(grd1,src1,grd2,src2)

[x0,y0,enc1]=ddb_wlgrid('read',grd1);
x1=zeros(size(x0,1)+1,size(x0,2)+1);
y1=zeros(size(x1));
xc1=zeros(size(x1));
yc1=zeros(size(x1));
x1(1:end-1,1:end-1)=x0;
y1(1:end-1,1:end-1)=y0;
x1(x1==0)=NaN;
y1(y1==0)=NaN;

x0=0.25*(x1(1:end-2,1:end-2)+x1(2:end-1,1:end-2)+x1(2:end-1,2:end-1)+x1(1:end-2,2:end-1));
y0=0.25*(y1(1:end-2,1:end-2)+y1(2:end-1,1:end-2)+y1(2:end-1,2:end-1)+y1(1:end-2,2:end-1));
xc1(2:end-1,2:end-1)=x0;
yc1(2:end-1,2:end-1)=y0;

[x0,y0,enc2]=ddb_wlgrid('read',grd2);
x2=zeros(size(x0,1)+1,size(x0,2)+1);
y2=zeros(size(x2));
xc2=zeros(size(x2));
yc2=zeros(size(x2));
x2(1:end-1,1:end-1)=x0;
y2(1:end-1,1:end-1)=y0;
x2(x2==0)=NaN;
y2(y2==0)=NaN;

x0=0.25*(x2(1:end-2,1:end-2)+x2(2:end-1,1:end-2)+x2(2:end-1,2:end-1)+x2(1:end-2,2:end-1));
y0=0.25*(y2(1:end-2,1:end-2)+y2(2:end-1,1:end-2)+y2(2:end-1,2:end-1)+y2(1:end-2,2:end-1));
xc2(2:end-1,2:end-1)=x0;
yc2(2:end-1,2:end-1)=y0;

fid=fopen(src1);
counter=0;
while ~feof(fid)
    regel=fgetl(fid);
    counter=counter+1;
    srcNames{counter}=deblank2(regel(1:20));
    typNames{counter}=deblank2(regel(21:22));
    mnk=str2num(regel(23:47));
    srcM(counter)=mnk(1);
    srcN(counter)=mnk(2);
    srcK(counter)=mnk(3);
end
fclose(fid);

for i=1:length(srcM)
    obsx(i)=xc1(srcM(i),srcN(i));
    obsy(i)=yc1(srcM(i),srcN(i));
end

nsrc=0;

fid=fopen(src2,'w');
for i=1:length(srcM)
    dist=sqrt( (xc2-obsx(i)).^2 + (yc2-obsy(i)).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm,tn]=ind2sub(size(dist),candidates);
    if tm>1 & tm>1
        xpol(1)=x2(tm-1,tn-1);ypol(1)=y2(tm-1,tn-1);
        xpol(2)=x2(tm,tn-1);  ypol(2)=y2(tm,tn-1);
        xpol(3)=x2(tm,tn);    ypol(3)=y2(tm,tn);
        xpol(4)=x2(tm-1,tn);  ypol(4)=y2(tm-1,tn);
        xpol(5)=xpol(1);      ypol(5)=ypol(1);
        ip=inpolygon(obsx(i),obsy(i),xpol,ypol);
        if ip>0
            nsrc=nsrc+1;
            fprintf(fid,'%s  %6i   %6i   %6i\n',[srcNames{i} repmat(' ',1,20-length(srcNames{i})) ' ' typNames{i}],tm,tn,srcK(i));
        else
            warning=['Source point ' srcNames{i} ' not found!'];
        end
    else
        warning=['Source point ' srcNames{i} ' not found!'];
    end
end
fclose(fid);

if nsrc==0
    delete(src2)
end
