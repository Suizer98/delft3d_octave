function txt = nesthd_reatxt(filename)

% reatxt: reads a simple text file

fid = fopen(filename,'r');

iline = 0;
while ~feof(fid)
     iline = iline + 1;
     txt{iline} = fgetl(fid);
end

fclose(fid);

