function write_tekal(infil,outfil,val_n,addcomments)

% write_tekal : reads tekal file, writes new one with additional column and column information
% see also : TEKAL

fid1 = fopen(infil);

iline = 0;
while 1
   iline = iline + 1;
   tline{iline} = fgetl(fid1);
   if ~ischar(tline{iline});
      break;
   end;
end;
fclose (fid1);


fid2 = fopen(outfil,'w+');

iline = 1;
irow  = 0;
comment = true;
while iline < length(tline)
    if comment
       if tline{iline}(1:1) == '*'
           fprintf(fid2,'%s \n',tline{iline});
       else
          for icom = 1: length(addcomments)
             fprintf (fid2,'%s \n',addcomments{icom});
          end
          fprintf (fid2,'%s \n',tline{iline});
          iline = iline+1;
          noroco    = str2num(tline{iline});
          noroco(2) = noroco(2) + 1;
          format    = repmat('%6i',1,length(noroco));
          fprintf (fid2,[format '\n'],noroco);
          comment = false;
       end
    else
       irow = irow + 1;
       fprintf(fid2,'%s ',tline{iline});
       for icol = 1: size(val_n,1)
          fprintf(fid2,'%12.6f',val_n(icol,irow));
       end
       fprintf(fid2,'\n');
    end
    iline = iline + 1;
end

fclose (fid2);

