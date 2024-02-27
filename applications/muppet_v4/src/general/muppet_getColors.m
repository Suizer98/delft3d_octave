function rgb=muppet_getColors(colormaps,clrmap,n)
 
k=1;

for i=1:size(colormaps,2)
    if strcmpi(colormaps(i).name,clrmap)
        k=i;
    end
end
x=colormaps(k).val(:,1);
 
for i=2:size(x,1)
    x(i)=max(x(i),x(i-1)+1.0e-6);
end
 
r=colormaps(k).val(:,2);
g=colormaps(k).val(:,3);
b=colormaps(k).val(:,4);
 
x1=0:(1/(n-1)):1;
 
r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);
 
rgb(:,1)=r1/255;
rgb(:,2)=g1/255;
rgb(:,3)=b1/255;
 
rgb=max(0,rgb);
rgb=min(1,rgb);
