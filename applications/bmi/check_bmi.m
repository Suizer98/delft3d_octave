%% check BMI with exe
input = load('d:\Checkouts\swan\branches\feature\esmf\esmf40.91\tests\DMrecSWAN02\SWANOUT1_exe', '-ascii');
exe.hsig = input(:,1);
exe.twoD.hsig = reshape(exe.hsig,[26 26]);
exe.twoD.hsig(exe.twoD.hsig==-999)=NaN;

figure
surfc(double(s.twoD.XP), double(s.twoD.YP), double(exe.twoD.hsig))
title('Hs exe')
colorbar

%% EOF