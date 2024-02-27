%HDFVSAVE_LOAD_TEST2      test of hdfvsave and hdfvload
clear S0 S1

fname = 'hdfvsave_tst2.hdf';

%% -------------------

 S0(1).rand    = rand(2,3,4);
 S0(1).a       = rand(4);
 S0(1).b       = rand(8);
 S0(1).c       = ['abcdefghijklmnopqrstuvw',
                  'ABCDEFGHIJKLMNOPQRSTUVW'];
 S0(1).D.a     = 1;
 S0(1).D.b     = 2;
 S0(1).D.c     = 3;
 S0(1).D.ascii = [char(0:255)];
 S0(1).E.e     = rand(5);
 S0(1).F.f     = 1.1;
 S0(1).G.g     = 'ab';
 S0(1).G.h     = [1 2 3];
 S0(1).G.i     = 'ef';
 S0(1).G(2).g  = 'cd';
 S0(1).G(2).h  = [1 2 3];
 S0(1).G(2).i  = 'gh';
%S0(1).G.l     = {1};

 S0(1).H.H.g = 'aaa';

%% -------------------

 S0(2).rand    = rand(2,3,4);
 S0(2).a       = rand(4);
 S0(2).b       = rand(8);
 S0(2).c       = ['abcdefghijklmnopqrstuvw',
                  'ABCDEFGHIJKLMNOPQRSTUVW'];
 S0(2).D.a     = 4;
 S0(2).D.b     = 5;
 S0(2).D.c     = 6;
 S0(2).D.ascii = [char(0:255)];
 S0(2).E.e     = rand(5);
 S0(2).F.f     = 1.1;
 S0(2).G.g     = 'ij';
 S0(2).G.h     = [4 5 6];
 S0(2).G.i     = 'mn';  
 S0(2).G(2).g  = 'kl';
 S0(2).G(2).h  = [4 5 6];
 S0(2).G(2).i  = 'op';
%S0(2).G.l     = {1};

 S0(2).H.H.g = 'aaa';

%% -------------------

status = hdfvsave(fname,S0);

disp('saved');

[S1,S1attr,status] = hdfvload(fname);

disp('opened');

for isize=1:length(S0)
   streq = repmat(0,[length(S0(isize).D.ascii(:)) 1]);
   for i=1:length(S0(isize).D.ascii(:))
      streq(i) = strcmp(S0(isize).D.ascii(i),S1(isize).D.ascii(i));
   end
end

wrongascii = find(streq==0);

% streq = num2str(streq');
% [S0.D.ascii(:) S1.D.ascii(:) streq];

% structcmp(S0,S1,eps)

% S0.a(end)=S0.a(end)-3*eps; % to test matdiff
% S0.F.f = S0.F.f-3*eps; % to test matdiff

structsavefields('S0',S0);%save('S0','-struct','S0');
pause(1)
structsavefields('S1',S1);%save('S1','-struct','S1');

matdiff('S0','S1')



