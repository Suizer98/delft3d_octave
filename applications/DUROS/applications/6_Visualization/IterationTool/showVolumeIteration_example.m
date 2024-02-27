% McToolsConnect
d = readTransectData('Jarkus Data','Schiermonnikoog','01000','2005');

xInitial = d.xi;
zInitial = d.zi;
Hs = 9;
Tp = 14;
WL = 5.5;
D50 = 220e-6;

showVolumeIteration(xInitial, zInitial, D50, WL, Hs, Tp);

