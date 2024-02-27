function h=muppet_plotImage(handles,i,j,k)

h=[];

% Uses surf i.s.o. image function

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if isempty(data.alpha)
    data.alpha=zeros(size(data.c,1),size(data.c,2))+255;
end

if ~isempty(data.x)
    % Georeferenced image
    opt.verticallevel=0;
      data.z=zeros(size(data.c,1),size(data.c,2))+opt.verticallevel;
      p=surf(data.x,data.y,data.z,double(data.c)/255);shading flat;
%     p=image(data.x,data.y,data.c);
%     p=surf(data.x,data.y,data.c);shading flat;
else
    data.z=zeros(size(data.c,1),size(data.c,2));
    data.c(:,:,1)=flipud(data.c(:,:,1));
    data.c(:,:,2)=flipud(data.c(:,:,2));
    data.c(:,:,3)=flipud(data.c(:,:,3));
    data.alpha=flipud(data.alpha);
    if opt.whitevalue<1
        brightness=sum(data.c,3)/3;
        data.z(brightness>255*opt.whitevalue)=NaN;
    end    
%     data.z(data.alpha==0)=NaN;        
%    p=surf(data.z,double(data.c)/255);shading flat;
    p=image(data.c);
end

if opt.opacity<1
    data.alpha=data.alpha*opt.opacity;
end
set(p,'AlphaData',double(data.alpha)/255);
