%directory_tmd.m

filenames=dir;
for i=3:61
    date=filenames(i).date; D=datenum(date);
    date=datestr(D,1);
    disp([filenames(i).name '   ' date])
end
