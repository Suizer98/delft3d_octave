%HDFVSAVE_SDS_TST         test of hdfvsave and hdfvload
clear S0 S1

fname = 'hdfvsave_tst2.hdf';

S0.s.a = rand(1,2,3);
S0.s.b = rand(2,3,4);
S0.s.c = rand(3,4,5);

status = hdfvsave(fname,S0);

disp('saved');

[S1,S1attr,status] = hdfvload(fname);

disp('opened');

savestructfields('S0',S0);
pause(1)
savestructfields('S1',S1);

matdiff('S0','S1')



