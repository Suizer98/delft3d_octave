function set_colwidth_excel (fileName,sheet,icol,width)
%set_colwidth_excel

fileName =  relativeToabsolutePath(fileName);

%
% Get sheetnr if name is specified
%

isheet = get_sheet_nr(fileName,sheet);

%
% Opens excel workbook
%

excelObj      = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%
% Select and activate the required sheet
%

excelSheets    = excelWorkbook.Sheets;
excelSheets_no = excelSheets.get('Item', isheet);
excelSheets_no.Activate;

%
% Set Column width
%

excelSheets_no.Columns.Item(icol).columnWidth = width;

%
% Save and close exel workbook
%

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);
