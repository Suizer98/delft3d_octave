vs_use ..\..\d3d\2d_uni_tide\trim-tes.dat;
xz=vs_get('map-const','XZ');
x=xz(2,2:end-1);
v1=vs_get('map-series','V1');
for i=1:length(v1);
   v=v1{i};
   vtd(i,:)=v(2,2:end-1);
end
t=([1:length(v1)]-1)*30
figure(2)
subplot(133);
pcolor(x,t(25:51)',vtd(25:51,:));
shading interp;
caxis([-1 1]);
colorbar
figure(3);
plot(x,vtd(76,:),'b-',x,vtd(88,:),'b-.',x,vtd(101,:),'b:',x,vtd(113,:),'r-',x,vtd(126,:),'r-.',x,vtd(139,:),'r:','linewidth',2)
