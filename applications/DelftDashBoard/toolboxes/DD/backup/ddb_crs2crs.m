function ncrs=ddb_crs2crs(grd1,crs1,grd2,crs2)

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

fid=fopen(crs1);
counter=0;
while ~feof(fid)
    regel=fgetl(fid);
    counter=counter+1;
    crsNames{counter}=deblank2(regel(1:20));
    mnc=str2num(regel(21:end));
    Mstart0(counter)=mnc(1);
    Nstart0(counter)=mnc(2);
    Mend0(counter)=mnc(3);
    Nend0(counter)=mnc(4);
end
fclose(fid);

nc=0;
for i=1:length(Mstart0)

    Mstart=Mstart0(i);
    Nstart=Nstart0(i);
    Mend=Mend0(i);
    Nend=Nend0(i);
    if Mend<Mstart || Nend<Nstart
        mtmp=Mstart;
        ntmp=Nstart;
        Mstart=Mend;
        Nstart=Nend;
        Mend=mtmp;
        Nend=ntmp;
    end
    if Nend>Nstart
        xcrs1=x1(Mstart,Nstart-1);
        ycrs1=y1(Mstart,Nstart-1);
        xcrs2=x1(Mend,Nend);
        ycrs2=y1(Mend,Nend);
    else
        xcrs1=x1(Mstart-1,Nstart);
        ycrs1=y1(Mstart-1,Nstart);
        xcrs2=x1(Mend,Nend);
        ycrs2=y1(Mend,Nend);
    end
    dist=sqrt( (x2-xcrs1).^2 + (y2-ycrs1).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xcrs2-xcrs1)^2 + (ycrs2-ycrs1)^2);
        tm1=tm0;
        tn1=tn0;
    else
        tm1=0;
        tn1=0;
    end
   
    dist=sqrt( (x2-xcrs2).^2 + (y2-ycrs2).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xcrs2-xcrs1)^2 + (ycrs2-ycrs1)^2);
        tm2=tm0;
        tn2=tn0;
    else
        tm2=0;
        tn2=0;
    end
    
    if tm1==tm2 && tm1>0 && tm2>0
        nc=nc+1;
        crsM1(nc)=tm1;
        crsM2(nc)=tm2;
        crsN1(nc)=tn1+1;
        crsN2(nc)=tn2;
    elseif tn1==tn2 && tm1>0 && tm2>0
        nc=nc+1;
        crsM1(nc)=tm1+1;
        crsM2(nc)=tm2;
        crsN1(nc)=tn1;
        crsN2(nc)=tn2;
    else
        nc=nc+1;
        Warning=['Cross section ' crsNames{i} ' not found!'];
        crsM1(max(nc,1))=0;
    end

end

ncrs=0;
fid = fopen(crs2,'wt');
for i=1:nc
    if crsM1(i)>0
        ncrs=ncrs+1;
        fprintf(fid,'%s  %6i %6i %6i %6i\n',[crsNames{i} repmat(' ',1,20-length(crsNames{i}))],crsM1(i),crsN1(i),crsM2(i),crsN2(i));
    end
end
fclose(fid);

if ncrs==0
    delete(crs2)
end
