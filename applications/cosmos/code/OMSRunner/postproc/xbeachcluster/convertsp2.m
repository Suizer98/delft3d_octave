clear variables;close all;

s=readSP2('hot_1_20100827.000000');

grd=wlgrid('read','sdo.grd');
depth=wldep('read','sdo.dep',grd);

Spec.Description='San Diego, southwesterly swell Hs=1m, Tp=10s, dir=225deg (Frequency spectrum JONSWAP, directional spreading 10 degrees)';
Spec.X=grd.X';
Spec.Y=grd.Y';
Spec.Depth=depth(1:end-1,1:end-1);

Spec.Freqs=s.Freqs;
Spec.dirs=s.dirs;

e=reshape(s.time.points,[201 201]);

clear s;

Spec.energy=single(zeros(201,201,25,36));

rho=1024;
g=9.81;
f=pi/180;

for i=1:201
    for j=1:201
%        e(i,j).energy=0.5*rho*g*e(i,j).Factor*e(i,j).energy;
        Spec.energy(i,j,:,:)=single(0.5*rho*g*e(i,j).Factor*e(i,j).energy);
    end
end

save('sdo_spec.mat','Spec');
