function jpeg=jpg(jpgname,nanval,step);
 
jpgcol0=imread(jpgname);
jpgcol1=jpgcol0(1:step:end,1:step:end,:);
col0=double(jpgcol1)/255;
for k=size(col0,1):-1:1
    m=size(col0,1)-k+1;
    x(k,:)=1:size(col0,2);
    y(k,:)=zeros(size(x(k,:)))+m;
    col(k,:,:)=col0(k,:,:);
end
z=zeros(size(x));
 
a=sum(col,3);
col(a>nanval*3)=NaN;
 
jpeg.c = permute(col,[2 1 3]);
jpeg.x   = transpose(x);
jpeg.y   = transpose(y);
jpeg.z   = transpose(z);
