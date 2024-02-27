function nbnd=ddb_bnd2bnd(grd1,bnd1,grd2,bnd2)

[x0,y0,enc1]=ddb_wlgrid('read',grd1);
x1=zeros(size(x0,1)+1,size(x0,2)+1);
y1=zeros(size(x1));
x1(1:end-1,1:end-1)=x0;
y1(1:end-1,1:end-1)=y0;
x1(x1==0)=NaN;
y1(y1==0)=NaN;

[x0,y0,enc2]=ddb_wlgrid('read',grd2);
x2=zeros(size(x0,1)+1,size(x0,2)+1);
y2=zeros(size(x2));
x2(1:end-1,1:end-1)=x0;
y2(1:end-1,1:end-1)=y0;
x2(x2==0)=NaN;
y2(y2==0)=NaN;

fid=fopen(bnd1);
counter=0;
while ~feof(fid)
    regel=fgetl(fid);
    counter=counter+1;
    bndNames{counter}=deblank2(regel(1:24));
    mnc=str2num(regel(25:48));
    Mstart0(counter)=mnc(1);
    Nstart0(counter)=mnc(2);
    Mend0(counter)=mnc(3);
    Nend0(counter)=mnc(4);
    otherNames{counter}=deblank2(regel(49:end));
end
fclose(fid);

nc=0;
for i=1:length(Mstart0)
    
    bndM1(i)=0;
    
    Mstart=Mstart0(i);
    Nstart=Nstart0(i);
    Mend=Mend0(i);
    Nend=Nend0(i);

    if Nend==Nstart
        if isfinite(x1(Nstart)) & x1(Nstart)~=0
            n1=Nstart;
            n2=Nend;
        else
            n1=Nstart-1;
            n2=Nend-1;
        end
        if Mend>Mstart
            m1=Mstart-1;
            m2=Mend;
        else
            m1=Mstart;
            m2=Mend-1;
        end
    else
        if isfinite(x1(Mstart)) & x1(Mstart)~=0
            m1=Mstart;
            m2=Mend;
        else
            m1=Mstart-1;
            m2=Mend-1;
        end
        if Nend>Nstart
            n1=Nstart-1;
            n2=Nend;
        else
            n1=Nstart;
            n2=Nend-1;
        end
    end

    xbnd1=x1(m1,n1);
    xbnd2=x1(m2,n2);
    ybnd1=y1(m1,n1);
    ybnd2=y1(m2,n2);
    
    dist=sqrt( (x2-xbnd1).^2 + (y2-ybnd1).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xbnd2-xbnd1)^2 + (ybnd2-ybnd1)^2);
        tm1=tm0;
        tn1=tn0;
    else
        tm1=0;
        tn1=0;
    end
    
    dist=sqrt( (x2-xbnd2).^2 + (y2-ybnd2).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xbnd2-xbnd1)^2 + (ybnd2-ybnd1)^2);
        tm2=tm0;
        tn2=tn0;
    else
        tm2=0;
        tn2=0;
    end

    if tm1==tm2 & tm1>0
        nc=nc+1;
        if isfinite(x2(tm1+1)) & x2(tm1+1)~=0
            bndM1(nc)=tm1;
            bndM2(nc)=tm2;
        else
            bndM1(nc)=tm1+1;
            bndM2(nc)=tm2+1;
        end
        if tn2>tn1
            bndN1(nc)=tn1+1;
            bndN2(nc)=tn2;
        else
            bndN1(nc)=tn1;
            bndN2(nc)=tn2+1;
        end            
    elseif tn1==tn2 & tn1>0
        nc=nc+1;
        if isfinite(x2(tn1+1)) & x2(tn1+1)~=0
            bndN1(nc)=tn1;
            bndN2(nc)=tn2;
        else
            bndN1(nc)=tn1+1;
            bndN2(nc)=tn2+1;
        end            
        if tm2>tm1
            bndM1(nc)=tm1+1;
            bndM2(nc)=tm2;
        else
            bndM1(nc)=tm1;
            bndM2(nc)=tm2+1;
        end            
    else
        Warning=['Boundary section ' deblank(bndNames{i}) ' not found!']
        bndM1(max(nc,1))=0;
    end
end

nbnd=0;
fid = fopen(bnd2,'wt');
for i=1:nc
    if bndM1(i)>0
        nbnd=nbnd+1;
        fprintf(fid,'%s  %5i %5i %5i %5i %s\n',[bndNames{i} repmat(' ',1,20-length(bndNames{i}))],bndM1(i),bndN1(i),bndM2(i),bndN2(i),otherNames{i});
    end
end
fclose(fid);
if nbnd==0
    delete(bnd2)
end
