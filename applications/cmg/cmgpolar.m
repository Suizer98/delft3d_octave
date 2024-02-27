function cmgpolar(u,v)

if all(u>=0) & all(v>=0)
	u=u;
else
	[u,v]=cmguv2spd(u,v);
end;
v=v*pi/180;
umax=max(u);
umin=min(u);
udiff=umax-umin;
if udiff<1000
	umax2=100*ceil(umax/100);
end;
if udiff<100
	umax2=10*ceil(umax/10);
end;
if udiff<10
	umax2=ceil(umax);
end;
polar([v;0], [u;umax2], '+');
view(90,-90);

return;