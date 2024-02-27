function set_color_excel(fileName,sheet,range_cell,color,varargin)
%set_color_excell set color of excel cells
%
%  set_color_excell(fileName,sheet,range,color,varargin)
% where range is a string like 'A1' color is hexadecimal like 'FF0000'
%
% See also: xls_functions, xls, xlsread, xlswrite

%% Create complete filename inclusive of the path
fileName =  relativeToabsolutePath(fileName);

%% Fill cell array range with ranges (either single character or cell array of ranges)
if ischar(range_cell)
    range{1} = range_cell;
else
    range    = range_cell;
end

%% Get sheetnr if name is specified
isheet = get_sheet_nr(fileName,sheet);

%%  Sets background color of a apart of an excell sheet
%  Default is Excel hexadecimal colors
%  alternative rgb colors
if nargin == 5 && strcmpi(varargin{1},'rgb')
   hex1    = dec2hex(floor(color/16));
   hex2    = dec2hex(mod(color,16)*16);
   hex_col = [hex1(3),hex2(3),hex1(2),hex2(2),hex1(1),hex2(1)];
else
   hex_col  = color;
end

%% Opens excell workbook
excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%% Select and activate the requested sheet
excelSheets    = excelWorkbook.Sheets;
excelSheets_no = excelSheets.get('Item', isheet);
excelSheets_no.Activate;

%
%% Cycle over all ranges
for i_range = 1: length(range)

    %% set range
    eActivesheetRange = excelObj.Activesheet.get('Range', range{i_range});

    %% Set color
    eActivesheetRange.interior.Color=hex2dec(hex_col);
end

%% Save workbook, quit and delete

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);

