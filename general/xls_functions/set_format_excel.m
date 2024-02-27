function set_format_excel(fileName,sheet,range,format)

filename =  relativeToabsolutePath(fileName);

%
% Get sheetnr ifname is specified
%

isheet = get_sheet_nr(fileName,sheet);

%
% Opens excel workbook
%

excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%
% Select and activate the required sheet
%

excelSheets    = excelWorkbook.Sheets;
% excelSheets_no = excelSheets.get('Item', isheet);
% excelSheets_no.Activate;

%
% Set Range (cells for which to apply the format)
%

eActivesheetRange = excelObj.Activesheet.get('Range', range);

%
% Set Format
%

eActivesheetRange.NumberFormat = format;

%
% Save and close the workbook
%

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);
