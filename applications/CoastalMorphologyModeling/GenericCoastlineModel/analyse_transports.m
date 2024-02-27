function [dist_cross,ScumRel]=analyse_transports()
load SC.mat
ncond=length(p);
nx=length(x);
for ix=1:nx
    Scav(ix)=0;
    for ic=1:ncond
        Scav(ix)=Scav(ix)+p(ic)*Sc(ix,ic,6);
    end
    Scav(ix)=Scav(ix)/sum(p);
end
figure;
plot(x,Scav);
Scum(1)=0;
for ix=2:nx
    Scum(ix)=Scum(ix-1)+.5*(Scav(ix)+Scav(ix-1))*(x(ix)-x(ix-1));
end
ScumRel=Scum/Scum(end);
ScumRel=[ScumRel,1];
dist_cross=[x,+inf];
figure;
plot(dist_cross,ScumRel,'linewidth',2)
title('relative cumulative distribution of transport')
xlabel('cross-shore distance (m)')
ylabel ('cum. transport (%)')