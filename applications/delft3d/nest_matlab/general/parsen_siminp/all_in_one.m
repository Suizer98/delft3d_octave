function S = all_in_one(S)

hulp = [];

for irec = 1: length(S.File)
   if isempty(strfind(lower(S.File{irec}),'include'))
      hulp{end+1} = S.File{irec};
   else
       
      %
      % get the filename and read the contents, add to hulp
      %

      contents = sscanf(S.File{irec},'%s');
      istart   = strfind(lower(contents),'include');
      if istart > 1
          hulp{end+1} = contents(1:istart - 1);
      end
      contents = contents(istart:end);
      istart   = strfind(lower(contents),'''');
      filename = contents(istart(1)+1:end-1);
      % change - J. Groenenboom - May '17 - account for Linux notation
      % change - TK Fix only works if full path is given ('/p/anydir/etc/file.file')
      %             For relative path only slashes should be reversed 
      if any(strfind(filename,'/')) && strcmp(filename(1),'/')
          filename=[filename(2) ':' strrep(filename(3:end),'/','\')];
      else
          filename = strrep(filename,'/','\');
      end
      hulp2    = readsiminp(S.FileDir,filename);
      hulp(end+1:end + length(hulp2.File)) = hulp2.File;
   end
end

S.File = hulp;
