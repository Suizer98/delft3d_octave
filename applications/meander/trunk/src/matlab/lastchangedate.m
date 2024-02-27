function lastchangedate(dirstr)
dirlist = dir(dirstr);
maxval  = -1;
filecount = 0;
for k = 1:length(dirlist)
   if (~dirlist(k).isdir)
      if dirlist(k).datenum > maxval
          maxval = dirlist(k).datenum;
          maxk   = k;
      end
      filecount = filecount+1;
   end
end
if filecount>0
disp(['Last changed: ',dirlist(maxk).date]);
end