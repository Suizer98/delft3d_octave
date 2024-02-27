function h2=muppet_plotScatterBin(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

clmap=muppet_getColors(handles.colormaps,plt.colormap,64);

h2 = muppet_scatterbin(x,y,'scale',500,'edgesx',50,'edgesy',50,'colormap',clmap);

xmin=plt.xmin;
xmax=plt.xmax;
ymin=plt.ymin;
ymax=plt.ymax;
szx=plt.position(3);
szy=plt.position(4);
scx=(xmax-xmin)/szx;
scy=(ymax-ymin)/szy;

x(isnan(y))=NaN;
y(isnan(x))=NaN;
x=x(~isnan(x));
y=y(~isnan(y));
% 
% % Add statistics
% 
% % RMSE
% rmse=sqrt(mean((y-x).^2));
% txt=['RMSE = ' num2str(rmse,'%8.3f')];
% xt=xmin+0.1*scx;
% yt=ymax-0.3*scy;
% text(xt,yt,txt);
% 
% % Bias
% bias=mean(y-x);
% txt=['Bias = ' num2str(bias,'%8.3f')];
% xt=xmin+0.1*scx;
% yt=ymax-0.70*scy;
% text(xt,yt,txt);
% 
% % R^2
% cc=corrcoef(x,y);
% cc=cc(1,2)^2;
% txt=['R^2 = ' num2str(cc,'%8.3f')];
% xt=xmin+0.1*scx;
% yt=ymax-1.1*scy;
% text(xt,yt,txt);
