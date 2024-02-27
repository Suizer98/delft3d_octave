function sandandmudtransportdemo
%%
clc;

time = 0:60:12.5*3600;
h    = 5+sin(time()./(12.5*2*pi));
ux   = 0.1+0.1*sin(time()./(12.5*2*pi));
uy   = zeros(size(ux));
H13  = 0.0001+zeros(size(ux));
Tp   = 0.0001+zeros(size(ux));

[cmud, csand, z, qxmud1depthint, qymud1depthint, qxsand1depthint,...
   qysand1depthint] = sandandmudtransport(time,h,ux,uy,H13,Tp);

%%


time = 0:60:60%12.5*3600;
h    = 3+sin(time()./(12.5*2*pi));
ux   = 0.5+0.1*sin(time()./(12.5*2*pi));
uy   = zeros(size(ux));
H13  = 2+zeros(size(ux));
Tp   = 15+zeros(size(ux));

[cmud, csand, z, qxmud1depthint, qymud1depthint, qxsand1depthint,...
   qysand1depthint] = sandandmudtransport(time,h,ux,uy,H13,Tp);


%% PLOT

>> check reference height, friction etc.. and all other inputs  help sandandmudtransport
>> check units of output SSC ? should be kg/m3 = 1e6 mg/1e3L = 1000 mg/L
>> Look for general magnitudes in VanRij et al. 2007 - part II 


figure

for kk=1:length(time)
plot(csand(kk,:),z(kk,:))
drawnow
end