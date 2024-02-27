function rgb=GetColors(ColorMaps,ColorMap,n)
 
k=1;
 
for i=1:size(ColorMaps,2)
    if strcmpi(ColorMaps(i).Name,ColorMap)
        k=i;
    end
end
x=ColorMaps(k).Val(:,1);
 
for i=2:size(x,1)
    x(i)=max(x(i),x(i-1)+1.0e-6);
end
 
r=ColorMaps(k).Val(:,2);
g=ColorMaps(k).Val(:,3);
b=ColorMaps(k).Val(:,4);
 
x1=0:(1/(n-1)):1;
%x1=0:(1/(n)):1;
 
r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);
 
rgb(:,1)=r1/255;
rgb(:,2)=g1/255;
rgb(:,3)=b1/255;
 
rgb=max(0,rgb);
rgb=min(1,rgb);
