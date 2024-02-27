function delete_empty_ecelsheets(fileName)
% delete_empty_excelsheets

fileName =  relativeToabsolutePath(fileName);

%
% Opens excel workbook
%

excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%
% Get sheet information
%

worksheets = excelObj.sheets;
numSheets = worksheets.Count;

%
% Delete sheets with name "Sheet?"
%

sheetIdx = 1;
sheetIdx2 = 1;
while sheetIdx2 <= numSheets
   sheetName = worksheets.Item(sheetIdx).Name(1:end-1);
   if ~isempty(strmatch(sheetName,'Sheet'))
      worksheets.Item(sheetIdx).Delete;
   else
      % Move to the next sheet
      sheetIdx = sheetIdx + 1;
   end
   sheetIdx2 = sheetIdx2 + 1; % prevent endless loop...
end

%
% Save and quit workbook
%

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);

