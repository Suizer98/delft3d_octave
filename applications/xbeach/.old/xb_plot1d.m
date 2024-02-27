function xb_plot1d
%XB_PLOT1D plot 1D XBeach profiles
%
%See also: xbeach

xbdims=getdimensions
[x,H ]=readvar1d('H.dat' ,xbdims);
[x,zs]=readvar1d('zs.dat',xbdims);
[x,zb]=readvar1d('zb.dat',xbdims);
[x,ue]=readvar1d('ue.dat',xbdims);
[x,ve]=readvar1d('ve.dat',xbdims);
figure(1)
for i=1:xbdims.nt
subplot(511)
plot(x,zb(:,i),x,zs(:,i));axis([0 1000 -10 3])
subplot(512)
plot(x,zs(:,i));axis([0 1000 -.5 .5])
subplot(513)
plot(x,H(:,i));axis([0 1000 0 3])
subplot(514)
plot(x,ue(:,i));axis([0 1000 -2 2])
subplot(515)
plot(x,ve(:,i));axis([0 1000 -1 1])
drawnow
end