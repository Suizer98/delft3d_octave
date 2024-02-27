function [isheet] = get_sheet_nr(filename,sheetname)
%get_sheet_nr

filename =  relativeToabsolutePath(filename);

if isnumeric(sheetname)
   isheet = sheetname;
else
   [status,sheets] = xlsfinfo(filename);
   isheet = strmatch(sheetname,sheets);
end
