%HDFVSAVE_LOAD_TEST       test of hdfvsave and hdfvload
clear S0 S1

fname = 'hdfvsave_tst2.hdf';

S0.rand = rand(2,3,4);
S0.a = rand(4);
S0.b = rand(8);
S0.c = ['abcdefghijklmnopqrstuvw',
       'ABCDEFGHIJKLMNOPQRSTUVW'];
S0.D.a     = 1;
S0.D.b     = 2;
S0.D.c     = 3;
S0.D.ascii = [char(0:255)];
S0.E.e = rand(5);
S0.F.f = 1.1;
%S0.G.l = {1};

S0.G.G.g = 'aaa';

status = hdfvsave(fname,S0);

disp('saved');

[S1,S1attr,status] = hdfvload(fname);

disp('opened');

streq = repmat(0,[length(S0.D.ascii(:)) 1]);
for i=1:length(S0.D.ascii(:))
   streq(i) = strcmp(S0.D.ascii(i),S1.D.ascii(i));
end

wrongascii = find(streq==0);

% streq = num2str(streq');
% [S0.D.ascii(:) S1.D.ascii(:) streq];

% structcmp(S0,S1,eps)

% S0.a(end)=S0.a(end)-3*eps; % to test matdiff
% S0.F.f = S0.F.f-3*eps; % to test matdiff

save('S0','-struct','S0');
pause(1)
save('S1','-struct','S1');

matdiff('S0','S1'); % matdiff is part of wlsettings (Deltares proprietary)
