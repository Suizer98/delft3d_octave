function ndry=ddb_dry2dry(grd1,dry1,grd2,dry2)

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

[Mstart, Nstart, Mend, Nend]=textread(dry1,'%n %n %n %n','delimiter',' ');

ip=zeros(size(xc2));

%fid = fopen('dry.ldb','wt');

for i=1:length(Mstart)

    if Mend(i)<Mstart(i) || Nend(i)<Nstart(i)
        mtmp=Mstart(i);
        ntmp=Nstart(i);
        Mstart(i)=Mend(i);
        Nstart(i)=Nend(i);
        Mend(i)=mtmp;
        Nend(i)=ntmp;
    end

    n=0;
    for j=Mstart(i)-1:Mend(i)
        n=n+1;
        ldbx{i}(n)=x1(j,Nstart(i)-1);
        ldby{i}(n)=y1(j,Nstart(i)-1);
    end        
    for j=Nstart(i):Nend(i)
        n=n+1;
        ldbx{i}(n)=x1(Mend(i),j);
        ldby{i}(n)=y1(Mend(i),j);
    end
    for j=Mend(i)-1:-1:Mstart(i)-1
        n=n+1;
        ldbx{i}(n)=x1(j,Nend(i));
        ldby{i}(n)=y1(j,Nend(i));
    end        
    for j=Nend(i)-1:-1:Nstart(i)-1
        n=n+1;
        ldbx{i}(n)=x1(Mstart(i)-1,j);
        ldby{i}(n)=y1(Mstart(i)-1,j);
    end

    ip=ip+inpolygon(xc2,yc2,ldbx{i},ldby{i});

%     fprintf(fid,'%2s %0.3i\n','BL',i);
%     fprintf(fid,'%7.0f %7.0f\n',n,2);
%     for j=1:n
%         fprintf(fid,'%10.1f %10.1f\n',ldbx{i}(j),ldby{i}(j));
%     end
    
end

%fclose(fid);

[mdry,ndry]=find(ip>0);

fid = fopen(dry2,'wt');
for i=1:length(mdry)
    fprintf(fid,'%7i %7i %7i %7i\n',mdry(i),ndry(i),mdry(i),ndry(i));
end
fclose(fid);
ndry=length(mdry);

if ndry==0
    delete(dry2)
end


