function h=muppet_plotTidalEllipse(handles,i,j,k)

h=[];

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

ffac=plt.scale/30;
for i=1:2:size(data.x,1)
    for j=1:2:size(data.x,2)
        [sema,ecc,inc,pha,w,twocir]=ap2ep(data.uamplitude(i,j),data.uphase(i,j),data.vamplitude(i,j),data.vphase(i,j),0);
        if sema>0
            sema=sema*ffac;
            if ecc>0
                clr='b';
            else
                clr='r';
            end
            plot_ellipse(sema,sema*ecc,inc,pha,[data.x(i,j) data.y(i,j)],clr);
        end
    end
end
