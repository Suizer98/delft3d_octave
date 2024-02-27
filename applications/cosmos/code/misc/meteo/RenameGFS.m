a=dir('gfs05*');

for i=1:length(a)
    fname=a(i).name;
    tstr=fname(7:end-4);
    disp(tstr);
    copyfile(fname,['gfs1p0_' tstr '.mat']);
end
